function [analysis] = tracked_poles_analysis(tracked_poles,tracked_times,opt)
% [analysis] = tracked_poles_analysis(tracked_poles,opt) 
% reads results of poles tracking and analyzes them
% S. Dmitrieff, Aug 2013
if nargin==0
    [opt,npmax]=check_options_npmax();
    tracked_poles=cell(npmax);
    for n=2:npmax
        if n>1
            fname=[num2str(n-1) '_polar_poles.txt'];
            tname=[num2str(n-1) '_polar_times.txt'];
            tracked_poles{n}=load_objects(fname);
            tracked_times{n}=load_objects(tname);
        end
    end
elseif nargin==2 || nargin==3
    [opt,npmax]=check_options_npmax();
else
    error('Invalid nulber of arguments');
end
if isempty(tracked_poles) || isempty(tracked_times)
    error('Empty tracked poles or times');
end

%load 'times.mat';
%filename='spindles.txt';
%regfilename='regions.txt';
%tmax=round(listind(2,end)+1-listind(2,1));
%n_times=max(listind(1,:));
%regions=load_objects(regfilename);
%n_regs=numel(regions);
%tot_obs=n_times-n_regs;

%% Computing MSDs (msd, variance, 
MSD_len=cell(npmax,1);
MSD_ang=cell(npmax,1);
MSD_len_err=cell(npmax,1);
MSD_ang_err=cell(npmax,1);
MSD_len_cnt=cell(npmax,1);
MSD_ang_cnt=cell(npmax,1);
%% Misc observables
polarity_count=cell(npmax,1);
nobs=zeros(npmax,1); %Number of spindles.min observed with polarity n-1
moyobs=zeros(npmax,1); %Avg time spent in spindle polarity n-1
varobs=zeros(npmax,1); %Variance of moyobs
ctobs=zeros(npmax,1); 
ntraj=zeros(npmax,1);

angles=[];
totangs=[];
totlens=[];
rellength=[];

dpar=[];
dper=[];
Ndpar=[];
Ndper=[];

moylen=zeros(npmax,1);
moyang=zeros(npmax,1);
varlen=zeros(npmax,1);
varang=zeros(npmax,1);
cntlen=zeros(npmax,1);
cntang=zeros(npmax,1);

ang_fourier={};
ace_fourier={};
%[tmax,tot_obs]=longer_track(tracked_poles);
[T0,TE,tmax,tot_obs]=track_info(tracked_times);
%tmax=TE-T0;
total_count=zeros(1,TE-T0+1);
for n=2:npmax
    tt=tracked_times{n};
    polarity_count{n}=zeros(2,TE-T0+1);
    polarity_count{n}(1,:)=T0:TE;
    poles=tracked_poles{n};
    np=numel(poles);
    ntraj(n)=np;
    
    if np>0
        MSD_ang{n}=zeros(1,tmax-1);
        MSD_len{n}=zeros(1,tmax-1);
        MSD_ang_err{n}=zeros(1,tmax-1);
        MSD_len_err{n}=zeros(1,tmax-1);
        MSD_ang_cnt{n}=zeros(1,tmax-1);
        MSD_len_cnt{n}=zeros(1,tmax-1);
        
        
        for j=1:np
            pts=poles{j}.points;
            tts=tt{j}.points;
            m=size(pts,1);
            nobs(n)=nobs(n)+m;
            varobs(n)=varobs(n)+m^2;
            ctobs(n)=ctobs(n)+1;
            %[msd,merr,times,counts]=msd_untimed(pts(:,1),'angular');

            [msd,merr,times,counts]=msd_timed(pts(:,1),tts(:,1),'angular');
            %[msd,merr,times,counts]=msd_untimed(pts(:,1),'angular');
            MSD_ang{n}(times)=MSD_ang{n}(times)+msd;
            MSD_ang_err{n}(times)=MSD_ang_err{n}(times)+merr;
            MSD_ang_cnt{n}(times)=MSD_ang_cnt{n}(times)+counts;
            % Lengths MSD
            [msd,merr,times,counts]=msd_timed(pts(:,2),tts(:,1));
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
            % Counting
            tline=tts(:,1);
            polarity_count{n}(2,tline-T0+1)=polarity_count{n}(2,tline-T0+1)+1.0/n;
            total_count(1,tline-T0+1)=total_count(1,tline-T0+1)+1.0/n;
        end
        
        %% --- Only bipos
        if n==3
            [tstart,tend]=time_range(tt);
            % MSDs
            MSD_bipang=zeros(1,tmax-1);
            MSD_biplen=zeros(1,tmax-1);
            MSD_bipang_err=zeros(1,tmax-1);
            MSD_biplen_err=zeros(1,tmax-1);
            MSD_bipang_cnt=zeros(1,tmax-1);
            MSD_biplen_cnt=zeros(1,tmax-1);
            MSD_relen=zeros(1,tmax-1);
            MSD_relen_err=zeros(1,tmax-1);
            MSD_relen_cnt=zeros(1,tmax-1);
            % Time_dpt variables
            mean_length=zeros(2,tend-tstart+1);
            count_ml=zeros(1,tend-tstart+1);
            sq_ml=zeros(2,tend-tstart+1);
            ang_diff=zeros(2,tend-tstart);
            count_ad=zeros(1,tend-tstart);
            sq_ad=zeros(2,tend-tstart);
            mean_acent=zeros(2,tend-tstart+1);
            sq_acent=zeros(2,tend-tstart+1);
            mean_intp=zeros(2,tend-tstart+1);
            sq_intp=zeros(2,tend-tstart+1);
            count_acent=zeros(1,tend-tstart+1);
            
            %Init. times
            mean_length(1,:)=tstart:tend;
            sq_ml(1,:)=tstart:tend;
            ang_diff(1,:)=tstart:tend-1;
            sq_ad(1,:)=tstart:tend-1;
            mean_acent(1,:)=tstart:tend;
            sq_acent(1,:)=tstart:tend;
            mean_intp(1,:)=tstart:tend;
            sq_intp(1,:)=tstart:tend;
            %Conseq. angles
            ssq1_ang=[];
            cnt_ssang=0;
            
            nc=floor(np/2);
            if nc~=np/2
                error('Incorrect bipolar spindles saved : not even pole number');
            end
            for j=1:nc
                p1=poles{2*j-1};
                p2=poles{2*j};
                tts=tt{2*j}.points;
                pts1=p1.points;
                pts2=p2.points;
                tline=tts(:,1);
                if strcmp(p1.info,p2.info)
                    % Angular difference
                    das=pts1(:,1)-pts2(:,1);
                    %ovlens=pts1(:,2)+pts2(:,2);
                    ld=length(das);
                    for i=1:ld
                        if das(i)>0
                            das(i)=das(i)-pi;
                        elseif 0>das(i)
                            das(i)=das(i)+pi;
                        end
                    end
                    angles=[angles;das];
                    %% Spindle acentricity, excentricity, angle and length
                    R1=[pts1(:,2) pts1(:,2)].*[cos(pts1(:,1)) sin(pts1(:,1))];%pole 1
                    R2=[pts2(:,2) pts2(:,2)].*[cos(pts2(:,1)) sin(pts2(:,1))];%pole 2
                    % Pole-pole center C
                    C=(R1+R2)/2;
                    % Distance from 0 to C
                    nc=cnorm(C);
                    U=R2-R1;
                    nu=cnorm(U);
                    U=U./(nu*[1 1]);
                    cnorm(U);
                    V=[U(:,2) -U(:,1)];
                    CpU=C.*U;
                    CpV=C.*V;
                    DX=abs(CpU(:,1)+CpU(:,2));
                    DY=sqrt(nc.^2-DX.^2);
                    dpar=[dpar;DX];
                    dper=[dper;DY];
                    
                    % Computing acentricity and orientation
                    R=[[0 0];R2-R1];
                    ovangs=align_angles(aster_angles(R));
                    ovlens=abs(abs(pts1(:,2)))+abs(pts2(:,2));
                    rel=(pts1(:,2)-pts2(:,2));
                    rellength=[rellength;rel];
                    
                    %Avg spindle lengths
                    mean_length(2,tline-tstart+1)=mean_length(2,tline-tstart+1)+ovlens';
                    sq_ml(2,tline-tstart+1)=sq_ml(2,tline-tstart+1)+ovlens'.^2;
                    count_ml(1,tline-tstart+1)=count_ml(1,tline-tstart+1)+1;
                    %Avg spindle acentricity
                    mean_acent(2,tline-tstart+1)=mean_acent(2,tline-tstart+1)+rel'.^2;
                    sq_acent(2,tline-tstart+1)=sq_acent(2,tline-tstart+1)+rel'.^4;
                    count_acent(1,tline-tstart+1)=count_acent(1,tline-tstart+1)+1;
                    %Av interpolar spindle
                    
                    mean_intp(2,tline-tstart+1)=mean_intp(2,tline-tstart+1)+das'.^2;
                    sq_intp(2,tline-tstart+1)=sq_intp(2,tline-tstart+1)+das'.^4;
                    %If more than one time in the trajectory
                    na=length(ovangs);
                    if na>1       
                        [msd,merr,times,counts]=msd_timed(ovangs,tline);
                        MSD_bipang(times)=MSD_bipang(times)+msd;
                        MSD_bipang_err(times)=MSD_bipang_err(times)+merr;
                        MSD_bipang_cnt(times)=MSD_bipang_cnt(times)+counts;
                        % length difference
                        %dls=pts1(:,2)-pts2(:,2);
                        %distances=[distances;dls];
                        %[msd,merr,times,counts]=msd_untimed(dls);
                        %[msd,merr,times,counts]=msd_untimed(rel);
                        [msd,merr,times,counts]=msd_timed(ovlens,tline);
                        MSD_biplen(times)=MSD_biplen(times)+msd;
                        MSD_biplen_err(times)=MSD_biplen_err(times)+merr;
                        MSD_biplen_cnt(times)=MSD_biplen_cnt(times)+counts;
                        
                        [msd,merr,times,counts]=msd_timed(rel,tline);
                        MSD_relen(times)=MSD_relen(times)+msd;
                        MSD_relen_err(times)=MSD_relen_err(times)+merr;
                        MSD_relen_cnt(times)=MSD_relen_cnt(times)+counts;
                        
                        cnt_ssang=cnt_ssang+na-1;
                        ssq1_ang=[ssq1_ang abs(ovangs(1:na-1)-ovangs(2:na))];
                        
                        %ang_fourier=[ang_fourier;fourier_modes_timed(ovangs,tline)];
                        %ace_fourier=[ace_fourier;fourier_modes_timed(ovlens,tline)];
                        %if na>6 && 0.02>rand
                        %    plot(1:na,rel)
                        %end
                        
                        %Computing the mean angle turned in one min.
                        dA=diff(ovangs);
                        dT=diff(tline);
                        for i=1:na-1
                            if dT(i)==1
                                ang_diff(2,tline(i)-tstart+1)=ang_diff(2,tline(i)-tstart+1)+dA(i)^2;
                                sq_ad(2,tline(i)-tstart+1)=sq_ad(2,tline(i)-tstart+1)+dA(i)^4;
                                count_ad(1,tline(i)-tstart+1)=count_ad(1,tline(i)-tstart+1)+1;
                            end
                        end
                    end
                end
            end
        end
        %% -----------------
    end
    
    if nobs(n)>0
        MSD_len{n}=MSD_len{n}./max(MSD_len_cnt{n},1);
        MSD_ang{n}=MSD_ang{n}./max(MSD_ang_cnt{n},1);
        MSD_len_err{n}=sqrt(MSD_len_err{n}./max(MSD_len_cnt{n},1)-MSD_len{n}.^2);
        MSD_ang_err{n}=sqrt(MSD_ang_err{n}./max(MSD_ang_cnt{n},1)-MSD_ang{n}.^2);
        
    end
end
for n=2:npmax
    polarity_count{n}(2,:)=polarity_count{n}(2,:)./total_count(1,:);
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
varlen=(varlen./cntlen - moylen.^2);
moyang=moyang./cntang;
varang=(varang./cntang - moyang.^2);

analysis.msd_ang.value=MSD_ang;
analysis.msd_ang.stddev=MSD_ang_err;
analysis.msd_ang.count=MSD_ang_cnt;
analysis.msd_ang.name='MSD of angles';
analysis.msd_len.value=MSD_len;
analysis.msd_len.stddev=MSD_len_err;
analysis.msd_len.count=MSD_len_cnt;
analysis.msd_len.name='MSD of pole length';

analysis.time_ct.value=polarity_count;
analysis.time_ct.count=polarity_count;
analysis.time_ct.name='Proportion of n-polar spindles, of time';

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

%analysis.moyang.value=moyang;
%analysis.moyang.count=cntang;
%analysis.moyang.name='Mean pole angle (n=3:bipolar)';

analysis.moylen.value=moylen;
analysis.moylen.count=cntlen;
analysis.moylen.stddev=sqrt(varlen);
analysis.moylen.name='Mean pole length (n=3:bipolar)';


analysis.ntraj.value=ntraj;
analysis.ntraj.name='Number of trajectories';
if ~isempty(angles)
    
    mean_length(2,:)=mean_length(2,:)./max(1,count_ml);
    sq_ml(2,:)=sqrt(sq_ml(2,:)./max(1,count_ml)-mean_length(2,:).^2);
    ang_diff(2,:)=sqrt(ang_diff(2,:)./max(1,count_ad));
    sq_ad(2,:)=sqrt(sqrt(sq_ad(2,:)./max(1,count_ad)-ang_diff(2,:).^4));
    mean_acent(2,:)=sqrt(mean_acent(2,:)./count_acent);
    sq_acent(2,:)=sqrt(sqrt(sq_acent(2,:)./count_acent-mean_acent(2,:).^4));
    
    
    
    
    mean_intp(2,:)=sqrt(mean_intp(2,:)./count_acent);
    sq_intp(2,:)=sqrt(sqrt((sq_intp(2,:)./count_acent)-mean_intp(2,:).^4));
    
    cont_bipang=length(angles);
    mean_bipang=sum(angles)/cont_bipang;
    sdev_bipang=sqrt(sum(angles.^2)/cont_bipang-mean_bipang.^2);
    %cont_biplen=length(distances);
    %mean_biplen=sum(distances)/cont_biplen;
    %sdev_biplen=sqrt(sum(distances.^2)/cont_biplen-mean_biplen.^2);
    cont_biplen=length(rellength);
    mean_biplen=sum(rellength)/cont_biplen;
    sdev_biplen=sqrt(sum(rellength.^2)/cont_biplen-mean_biplen.^2);
    %xa=[((1:21)-11)*pi/10];
    %xa=[(0.05:0.1:0.95)*pi];
    xa=36;
    %[bin_ang,hist_ang]=rose(angles,xa);
    [bin_ang,hist_ang]=rose(abs(angles),xa);
    err_ang=sqrt(hist_ang.*(1-hist_ang/cont_bipang));
    %distances=abs(distances)/moylen(3);
    rellength=abs(rellength);
    %xl=[0.025:0.05:0.975];
    xl=3:6:57;
    %[hist_dis,bin_dis]=hist(distances,xl);
    [hist_dis,bin_dis]=hist(rellength,xl);
    err_dis=sqrt(hist_dis.*(1-hist_dis/cont_biplen));
    hist_dis=hist_dis/cont_biplen;
    err_dis=err_dis/cont_biplen;
    %xd=[-16:2:16];
    %xd=15;
    %xd=1:2:19;
    xd=[1:2:25];
    [hist_dpar,bin_dpar]=hist(dpar,xd);
    err_dpar=sqrt(hist_dpar.*(1-hist_dpar/cont_biplen));
    hist_dpar=hist_dpar/cont_biplen;
    err_dpar=err_dpar/cont_biplen;
    
    xd=[0.5:1:14.5];
    [hist_dper,bin_dper]=hist(dper,xd);
    err_dper=sqrt(hist_dper.*(1-hist_dper/cont_biplen));
    hist_dper=hist_dper/cont_biplen;
    err_dper=err_dper/cont_biplen;
    
    xd=10;
    [hist_Ndpar,bin_Ndpar]=hist(Ndpar,xd);
    err_Ndpar=sqrt(hist_Ndpar.*(1-hist_Ndpar/cont_biplen));
    [hist_Ndper,bin_Ndper]=hist(Ndper,xd);
    err_Ndper=sqrt(hist_Ndper.*(1-hist_Ndper/cont_biplen));
    
    [hist_ssang,bin_ssang]=hist(ssq1_ang,10);
    err_ssang=sqrt(hist_ssang.*(1-hist_ssang/cnt_ssang));
    
    
    
    % Finishing MSD
    MSD_bipang=MSD_bipang./(max(MSD_bipang_cnt,1));
    MSD_biplen=MSD_biplen./(max(MSD_biplen_cnt,1));
    MSD_bipang_err=sqrt(MSD_bipang_err./(max(MSD_bipang_cnt,1))-MSD_bipang.^2);
    MSD_biplen_err=sqrt(MSD_biplen_err./(max(MSD_biplen_cnt,1))-MSD_biplen.^2);
    MSD_relen=MSD_relen./(max(MSD_relen_cnt,1));
    MSD_relen_err=sqrt(MSD_relen_err./(max(MSD_relen_cnt,1))-MSD_relen.^2);
    
    
    
    analysis.bipo_MSDang.value=MSD_bipang;
    analysis.bipo_MSDang.stddev=MSD_bipang_err;
    analysis.bipo_MSDang.count=MSD_bipang_cnt;
    %analysis.bipo_MSDang.name='MSD of relative pole angle in bipolar spindles';
    analysis.bipo_MSDang.name='MSD of spindle orientation';
    %analysis.bipo_MSDlen.value=MSD_biplen;
    %analysis.bipo_MSDlen.stddev=MSD_biplen_err;
    %analysis.bipo_MSDlen.count=MSD_biplen_cnt;
    %analysis.bipo_MSDlen.name='MSD of bipolar spindle total length';
    
    analysis.bipo_MSDrelen.value=MSD_relen;
    analysis.bipo_MSDrelen.stddev=MSD_relen_err;
    analysis.bipo_MSDrelen.count=MSD_relen_cnt;
    analysis.bipo_MSDrelen.name='MSD of bipolar spindle acentricity';
    
    analysis.bipo_angdistri.value=[bin_ang;hist_ang];
    analysis.bipo_angdistri.stddev=[bin_ang;err_ang];
    analysis.bipo_angdistri.count=cont_bipang;
    analysis.bipo_angdistri.name='Histogram of relative pole angle in bipolar spindles';
    analysis.bipo_lendistri.value=[bin_dis;hist_dis];
    analysis.bipo_lendistri.stddev=[bin_dis;err_dis];
    analysis.bipo_lendistri.count=cont_biplen;
    analysis.bipo_lendistri.name='Histogram of acentricity in bipolar spindles';

    
    analysis.bipo_dpar.value=[bin_dpar;hist_dpar];
    analysis.bipo_dpar.stddev=[bin_dpar;err_dpar];
    analysis.bipo_dpar.count=cont_biplen;
    analysis.bipo_dpar.name='Histogram of parrallel excentricty in bipolar spindles';
    
    
    analysis.bipo_dper.value=[bin_dper;hist_dper];
    analysis.bipo_dper.stddev=[bin_dper;err_dper];
    analysis.bipo_dper.count=cont_biplen;
    analysis.bipo_dper.name='Histogram of normal excentricty in bipolar spindles';
    
    
    %analysis.bipo_nextangdistri.value=[bin_ssang;hist_ssang];
    %analysis.bipo_nextangdistri.stddev=[bin_ssang;err_ssang];
    %analysis.bipo_nextangdistri.count=cnt_ssang;
    %analysis.bipo_nextangdistri.name='Histogram next A bipolar spindles';
    
    analysis.bipo_lengthoft.value=mean_length;
    analysis.bipo_lengthoft.stddev=sq_ml;
    analysis.bipo_lengthoft.count=count_ml;
    analysis.bipo_lengthoft.name='Spindle length  with time';
    
    analysis.bipo_dAoft.value=ang_diff;
    analysis.bipo_dAoft.stddev=sq_ad;
    analysis.bipo_dAoft.count=count_ad;
    analysis.bipo_dAoft.name='Std. Dev. ang. progr  with time';
    
    analysis.bipo_acentoft.value=mean_acent;
    analysis.bipo_acentoft.stddev=sq_acent;
    analysis.bipo_acentoft.count=count_acent;
    analysis.bipo_acentoft.name='Std dev. of acentricity  with time';
    %analysis.bipo_angoft.value=mean_angpro;
    %analysis.bipo_angoft.stddev=sqrt(var_angpro);
    %analysis.bipo_angoft.count=count_aligned;
    %analysis.bipo_angoft.name='Spindle angle progression with time';
    analysis.bipo_intpoft.value=mean_intp;
    analysis.bipo_intpoft.stddev=sq_intp;
    analysis.bipo_intpoft.count=count_acent;
    analysis.bipo_intpoft.name='Std dev. of interpolar angle with time';
end


end

function [t0,te,det,n]=track_info(tp)
m=1;
n=0;
t0=666666666;
te=0;
det=0;
for i=1:numel(tp)
    t=tp{i};
    for j=1:numel(t)
        pts=t{j}.points;
        k=size(pts,1);
        n=n+k;
        ti=pts(1,1);
        tf=pts(k,1);
        det=max(det,1+tf-ti);
        t0=min(t0,ti);
        te=max(te,tf);
    end
end
end


function [m,n]=longer_track(tp)
m=1;
n=0;
for i=1:numel(tp)
    t=tp{i};
    for j=1:numel(t)
        k=size(t{j}.points,1);
        m=max(m,k);
        n=n+k;
    end
end
end

function [ta,tb]=time_range(tp)
ta=666666;
tb=1;
for i=1:numel(tp)
    t=tp{i}.points;
    ta=min(ta,min(t(:,1)));
    tb=max(tb,max(t(:,1)));
end
end

function anglist=align_angles(anglist)
for i=2:length(anglist)
    while anglist(i-1)-anglist(i)>pi
        anglist(i)=anglist(i)+2*pi;
    end
    while -pi>anglist(i-1)-anglist(i)
        anglist(i)=anglist(i)-2*pi;
    end
end

end

function NV=cnorm(VEC)
NV=sqrt(VEC(:,1).^2+VEC(:,2).^2);
end