function [analysis] = tracked_poles_analysis(tracked_poles,opt)
% [analysis] = tracked_poles_analysis(tracked_poles,opt) 
% reads results of poles tracking and analyzes them
% S. Dmitrieff, Aug 2013
if nargin==0
    [opt,npmax]=check_options_npmax();
    tracked_poles=cell(npmax);
    for n=2:npmax
        if n>1
            fname=[num2str(n-1) '_polar_poles.txt'];
            tracked_poles{n}=load_objects(fname);
        end
    end
elseif nargin==1
    [opt,npmax]=check_options_npmax();
else
    [opt,npmax]=check_options_npmax(opt);
end
if isempty(tracked_poles)
    error('Invalid tracked poles');
end

load 'times.mat';
filename='spindles.txt';
regfilename='regions.txt';
tmax=round(listind(2,end)+1-listind(2,1));
n_times=max(listind(1,:));
regions=load_objects(regfilename);
n_regs=numel(regions);
tot_obs=n_times-n_regs;

%% Computing MSDs (msd, variance, 
MSD_len=cell(npmax,1);
MSD_ang=cell(npmax,1);
MSD_len_err=cell(npmax,1);
MSD_ang_err=cell(npmax,1);
MSD_len_cnt=cell(npmax,1);
MSD_ang_cnt=cell(npmax,1);
%% Misc observables
nobs=zeros(npmax,1); %Number of spindles.min observed with polarity n-1
moyobs=zeros(npmax,1); %Avg time spent in spindle polarity n-1
varobs=zeros(npmax,1); %Variance of moyobs
ctobs=zeros(npmax,1); 
angles=[];
distances=[];

moylen=zeros(npmax,1);
moyang=zeros(npmax,1);
varlen=zeros(npmax,1);
varang=zeros(npmax,1);
cntlen=zeros(npmax,1);
cntang=zeros(npmax,1);

for n=2:npmax
    poles=tracked_poles{n};
    np=numel(poles);
    if np>0
        MSD_ang{n}=zeros(1,tmax-1);
        MSD_len{n}=zeros(1,tmax-1);
        MSD_ang_err{n}=zeros(1,tmax-1);
        MSD_len_err{n}=zeros(1,tmax-1);
        MSD_ang_cnt{n}=zeros(1,tmax-1);
        MSD_len_cnt{n}=zeros(1,tmax-1);
        
        
        for j=1:np
            pts=poles{j}.points;
            m=size(pts,1);
            nobs(n)=nobs(n)+m;
            varobs(n)=varobs(n)+m^2;
            ctobs(n)=ctobs(n)+1;
            [msd,merr,times,counts]=msd_untimed(pts(:,1),'angular');
            MSD_ang{n}(times)=MSD_ang{n}(times)+msd;
            MSD_ang_err{n}(times)=MSD_ang_err{n}(times)+merr;
            MSD_ang_cnt{n}(times)=MSD_ang_cnt{n}(times)+counts;
            % Lengths MSD
            [msd,merr,times,counts]=msd_untimed(pts(:,2));
            MSD_len{n}(times)=MSD_len{n}(times)+msd;
            MSD_len_err{n}(times)=MSD_len_err{n}(times)+merr;
            MSD_len_cnt{n}(times)=MSD_len_cnt{n}(times)+counts;
            % Mean ang ; len value
            moyang(n)=moyang(n)+sum(pts(:,1));
            varang(n)=varang(n)+sum(pts(:,1).^2);
            cntang(n)=cntang(n)+m;
            moylen(n)=moylen(n)+sum(pts(:,2));
            varlen(n)=varlen(n)+sum(pts(:,2).^2);
            cntlen(n)=cntlen(n)+m;
        end
        
        %% --- Only bipos
        if n==3
            MSD_bipang=zeros(1,tmax-1);
            MSD_biplen=zeros(1,tmax-1);
            MSD_bipang_err=zeros(1,tmax-1);
            MSD_biplen_err=zeros(1,tmax-1);
            MSD_bipang_cnt=zeros(1,tmax-1);
            MSD_biplen_cnt=zeros(1,tmax-1);

            nc=floor(np/2);
            if nc~=np/2
                error('Incorrect bipolar spindles saved : not even pole number');
            end
            for j=1:nc
                p1=poles{2*j-1};
                p2=poles{2*j};
                pts1=p1.points;
                pts2=p2.points;
                if strcmp(p1.info,p2.info)
                    % Angular difference
                    das=pts1(:,1)-pts2(:,1);
                    ld=length(das);
                    for i=1:ld
                        if das(i)>0
                            das(i)=das(i)-pi;
                        elseif 0>das(i)
                            das(i)=das(i)+pi;
                        end
                    end
                    angles=[angles;das];
                    [msd,merr,times,counts]=msd_untimed(das,'angular');
                    MSD_bipang(times)=MSD_bipang(times)+msd;
                    MSD_bipang_err(times)=MSD_bipang_err(times)+merr;
                    MSD_bipang_cnt(times)=MSD_bipang_cnt(times)+counts;
                    % length difference
                    dls=pts1(:,2)-pts2(:,2);
                    distances=[distances;dls];
                    [msd,merr,times,counts]=msd_untimed(dls);
                    MSD_biplen(times)=MSD_biplen(times)+msd;
                    MSD_biplen_err(times)=MSD_biplen_err(times)+merr;
                    MSD_biplen_cnt(times)=MSD_biplen_cnt(times)+counts;
                end
            end
        end
        %% -----------------
    end
    
    if nobs(n)>0
        MSD_len{n}=MSD_len{n}./max(MSD_len_cnt{n},1);
        MSD_ang{n}=MSD_ang{n}./max(MSD_ang_cnt{n},1);
        MSD_len_err{n}=sqrt(MSD_len_err{n}./max(MSD_len_cnt{n},1));
        MSD_ang_err{n}=sqrt(MSD_ang_err{n}./max(MSD_ang_cnt{n},1));
    end
end
%% Computing averages
% Res time & prop
moyobs(:)=nobs./max(ctobs(:),1);
varobs(:)=varobs./max(ctobs(:),1)-moyobs(:).^2;
sum_obs=sum(nobs);
% Proportion of each kind of spindles 
nspin_obs=nobs/sum_obs;
% Success of nucleation
nuc_obs=sum_obs/tot_obs;
% len & ang
moylen=moylen./cntlen;
varlen=sqrt(varlen./cntlen - varlen.^2);
moyang=moyang./cntang;
varang=sqrt(varang./cntang - varang.^2);


analysis.msd_ang.value=MSD_ang;
analysis.msd_ang.stddev=MSD_ang_err;
analysis.msd_ang.count=MSD_ang_cnt;
analysis.msd_ang.name='Mean square displacement of angles';
analysis.msd_len.value=MSD_len;
analysis.msd_len.stddev=MSD_len_err;
analysis.msd_len.count=MSD_len_cnt;
analysis.msd_len.name='Mean square displacement of pole length';

analysis.moyct.value=nspin_obs;
analysis.moyct.count=nobs;
analysis.moyct.name='Average spindle repartition (n=3 : bipolar)';

analysis.timespent.value=moyobs;
analysis.timespent.stddev=sqrt(varobs);
analysis.timespent.count=ctobs;
analysis.timespent.name='Average time spent in polarity (n=3:bipolar)';

analysis.nucleation.value=nuc_obs;
analysis.nucleation.count=sum_obs;
analysis.nucleation.name='Average nucleation per spot';

analysis.moyang.value=moyang;
analysis.moyang.count=cntang;
analysis.moyang.name='Mean pole angle (n=3:bipolar)';

analysis.moylen.value=moylen;
analysis.moylen.count=cntlen;
analysis.moylen.name='Mean pole length (n=3:bipolar)';

if ~isempty(angles)
    cont_bipang=length(angles);
    mean_bipang=sum(angles)/cont_bipang;
    sdev_bipang=sqrt(sum(angles.^2)/cont_bipang-mean_bipang.^2);
    cont_biplen=length(distances);
    mean_biplen=sum(distances)/cont_biplen;
    sdev_biplen=sqrt(sum(distances.^2)/cont_biplen-mean_biplen.^2);
    x=[((1:11)-6)*pi/5];
    [bin_ang,hist_ang]=rose(angles,x);
    [hist_dis,bin_dis]=hist(distances);
    % Finishing MSD
    MSD_bipang=MSD_bipang./(max(MSD_bipang_cnt,1));
    MSD_biplen=MSD_biplen./(max(MSD_biplen_cnt,1));
    MSD_bipang_err=sqrt(MSD_bipang_err./(max(MSD_bipang_cnt,1))-MSD_bipang.^2);
    MSD_biplen_err=sqrt(MSD_biplen_err./(max(MSD_biplen_cnt,1))-MSD_biplen.^2);
    
    analysis.bipo_MSDang.value=MSD_bipang;
    analysis.bipo_MSDang.stddev=MSD_bipang_err;
    analysis.bipo_MSDang.count=MSD_bipang_cnt;
    analysis.bipo_MSDang.name='MSD of relative pole angle in bipolar spindles';
    analysis.bipo_MSDlen.value=MSD_biplen;
    analysis.bipo_MSDlen.stddev=MSD_biplen_err;
    analysis.bipo_MSDlen.count=MSD_biplen_cnt;
    analysis.bipo_MSDlen.name='MSD of relative pole length in bipolar spindles';
    
    analysis.bipo_angdistri.value=[bin_ang;hist_ang];
    analysis.bipo_angdistri.count=cont_bipang;
    analysis.bipo_angdistri.name='Histogram of relative pole angle in bipolar spindles';
    analysis.bipo_lendistri.value=[bin_dis;hist_dis];
    analysis.bipo_lendistri.count=cont_biplen;
    analysis.bipo_lendistri.name='Histogram of relative pole distances in bipolar spindles';
end


end
