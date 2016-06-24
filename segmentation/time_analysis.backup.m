function [analysis] = time_analysis(opt)
% [analysis] = time_analyze(opt)
% reads analysis files and compiles them
% S. Dmitrieff, March 2013


if nargin==0
    opt=spin_default_options();
elseif isempty(opt)
    opt=spin_default_options();
end
if isfield(opt,'max_polarity')
	npmax=opt.max_polarity;
else
	defopt=spin_default_options();
	npmax=defopt.max_polarity;
end
load 'times.mat';
filename='spindles.txt';
regfilename='regions.txt';



tmax=round(listind(2,end)+1-listind(2,1));
%tmax=round(listind(2,end))
n_times=max(listind(1,:));
regions=load_objects(regfilename);
n_regs=numel(regions);

% Time dependant int, len, angle of spindles
spindles_int_time=cell(n_regs,npmax);
spindles_len_time=cell(n_regs,npmax);
spindles_ang_time=cell(n_regs,npmax);
%spindles_pts_time=cell(n_regs,npmax,n_times);
nobs=zeros(n_regs,npmax);

% Counting rates of state dep.
time_on=zeros(n_regs,1);
n_stays=zeros(npmax,1);
t_stays=zeros(npmax,1);
t2_stays=zeros(npmax,1);
spin_state=-ones(n_regs,1);
exch_rate=zeros(npmax,npmax);
exch_count=zeros(npmax,npmax);
% Counting total spin rep.
spin_count=zeros(npmax,n_times);
spin_moyct=zeros(npmax,1);



%% Building the arrays
for i=listind(1,:)
    if i>0
        fold_name=num2str(i);
        cd(fold_name);
        t=listind(2,i);
        for n=1:npmax
            fname=[num2str(n-1) '_polar_'];
            fname_int=[fname 'intens.txt'];
            %fname_pts=[fname 'points.txt'];
            fname_ang_len=[fname 'angle_length.txt'];
            if exist(fname_ang_len,'file') && exist(fname_int,'file')
                an_sp_ang_len=load_objects(fname_ang_len);
                an_sp_int=load_objects(fname_int);
                %an_sp_pts=load_objects(fname_pts);
                nspin=numel(an_sp_ang_len);
                %if i>1
                %    spin_ct=spin_count(:,i-1);
                %end
                for j=1:nspin
                    al=an_sp_ang_len{j};
                    in=an_sp_int{j};
                    jid=al.id;
                    
                    spin_count(n,i)=spin_count(n,i)+1;
                    old_n=spin_state(jid);
                    spin_state(jid)=n;
                    
                    if old_n==-1
                        time_on(jid)=1;
                    elseif old_n==n
                        time_on(jid)=time_on(jid)+1;
                        %exch_rate(n,n)=exch_rate(n)+1/spin_ct(old_n);
                        %exch_count(n,n)=exch_count(n,n)+1;
                    else
                        t_stays(old_n)=t_stays(old_n)+time_on(jid);
                        t2_stays(old_n)=t2_stays(old_n)+time_on(jid)^2;
                        n_stays(old_n)=n_stays(old_n)+1;
                        exch_rate(old_n,n)=exch_rate(old_n,n)+1/time_on(jid);
                        exch_count(old_n,n)=exch_count(old_n,n)+1;
                        time_on(jid)=1;
                        
                    end
                    %pl=an_sp_pts{j};
                    
                    
                    spindles_ang_time{jid,n}=horzcat(spindles_ang_time{jid,n},[al.points(:,1);t]);
                    spindles_len_time{jid,n}=horzcat(spindles_len_time{jid,n},[al.points(:,2);t]);
                    spindles_int_time{in.id,n}=horzcat(spindles_int_time{in.id,n},[in.points(1);t]);
                    
                    %spindles_pts_time{pl.id,n,i}=pl.points;
                    
                    
                    nobs(jid,n)=nobs(jid,n)+1;
                end
            end
        end
        cd '..';
    end
end
for n=1:npmax
    if n_stays(n)==0
        n_stays(n)=1;
    end
end
t_stays=t_stays./n_stays;
t2_stays=sqrt(t2_stays./n_stays-t_stays.^2);
spin_moyct(:)=sum(spin_count,2);
spin_moyct(:)=spin_moyct/sum(spin_moyct);

exch_rate=exch_rate./max(exch_count,1);

rms_bipo=0;
mean_bipo=0;
count_bipo=0;

%% Reorganizing the angle/lengths arrays
for i=1:n_regs
    i
    %% For 1 polar spindles : n=2
    n=2;
    if ~isempty(spindles_ang_time{i,n})
        angles=spindles_ang_time{i,n}(1:n-1,:);
        for t=2:nobs(i,n)
            dA=angles(1,t)-angles(1,t-1);
            while abs(dA)>pi
                if dA<0
                    angles(1,t)=angles(1,t)+2*pi;
                else
                    angles(1,t)=angles(1,t)-2*pi;
                end
                dA=angles(1,t)-angles(1,t-1);
            end
        end
        spindles_ang_time{i,2}(1,:)=angles;
    end
    %% For 2 or more polar spindles n>2
    for n=3:npmax
        
        if ~isempty(spindles_ang_time{i,n})
            
            %disp('next spin')
            angles=spindles_ang_time{i,n}(1:n-1,:);
            lengths=spindles_len_time{i,n}(1:n-1,:);
            points_old=[lengths(:,1) lengths(:,1)].*[cos(angles(:,1)) sin(angles(:,1))];
            %points_old=spindles_pts_time{i,n,t};
            for t=2:nobs(i,n)
                points=[lengths(:,t) lengths(:,t)].*[cos(angles(:,t)) sin(angles(:,t))];
                %pts=spindles_pts_time{i,n,t}
                %Track poles 
                %disp('next t : ')
                [points_old,odr]=reorder_points(points,points_old);
                %points_old
                
                angles(:,t)=angles(odr,t);
                lengths(:,t)=lengths(odr,t);
                % Track angles so RMS does not converge
                for k=1:n-1
                    dA=angles(k,t)-angles(k,t-1);
                    while abs(dA)>pi
                        if dA<0
                            angles(k,t)=angles(k,t)+2*pi;
                        else
                            angles(k,t)=angles(k,t)-2*pi;
                        end
                        dA=angles(k,t)-angles(k,t-1);
                    end
                end
            end
            %angles
            %lengths
            
            spindles_ang_time{i,n}(1:n-1,:)=angles;
            spindles_len_time{i,n}(1:n-1,:)=lengths;
        end
        %For bipolar spindles, we compute the angle between the two poles
        if n==2
            nt=size(angles,2);
            bipolar_delta_ang{i}=zeros(2,l);
            bipolar_delta_ang{i}(2,:)=spindles_ang_time{i,2}(2,:);
            bipolar_delta_ang{i}(1,:)=mod(abs(angles(1,:)-angles(2,:)),2*pi);
            mean_bipo=mean_bipo+sum(bipolar_delta_ang{i}(1,:));
            rms_bipo=mean_bipo+sum(bipolar_delta_ang{i}(1,:).^2);
            count_bipo=count_bipo+nt;
        end
    end
end
mean_bipo=mean_bipo/count_bipo;
rms_bipo=rms_bipo/count_bipo;
rms_bipo=sqrt(rms_bipo-mean_bipo^2);


%% Computing MSDs
MSD_int=cell(npmax,1);
MSD_len=cell(npmax,1);
MSD_ang=cell(npmax,1);
MSD_int_err=cell(npmax,1);
MSD_len_err=cell(npmax,1);
MSD_ang_err=cell(npmax,1);
MSD_int_cnt=cell(npmax,1);
MSD_len_cnt=cell(npmax,1);
MSD_ang_cnt=cell(npmax,1);
%MSD_ang=zeros(npmax,tmax);
%MSD_len=zeros(npmax,tmax);
%MSD_int=zeros(npmax,tmax);

for n=1:npmax
    if sum(spin_count(n,:))>0
        MSD_ang{n}=zeros(1,tmax-1);
        MSD_int{n}=zeros(1,tmax-1);
        MSD_len{n}=zeros(1,tmax-1);
        MSD_ang_err{n}=zeros(1,tmax-1);
        MSD_int_err{n}=zeros(1,tmax-1);
        MSD_len_err{n}=zeros(1,tmax-1);
    end
end

count_ang=zeros(npmax,tmax-1);
count_len=zeros(npmax,tmax-1);
count_int=zeros(npmax,tmax-1);
for i=1:n_regs
    for n=2:npmax
        angs=spindles_ang_time{i,n};
        lens=spindles_len_time{i,n};
        ints=spindles_int_time{i,n};
    
        if length(ints)>1
            %Angles MSD
            for j=1:n-1
                [msd,merr,times,counts]=msd_timed_data(angs(j,:),angs(n,:),'angular');
                MSD_ang{n}(times)=MSD_ang{n}(times)+msd;
                MSD_ang_err{n}(times)=MSD_ang_err{n}(times)+merr;
                count_ang(n,times)=count_ang(n,times)+counts;
                %Lengths MSD
                [msd,merr,times,counts]=msd_timed_data(lens(j,:),lens(n,:));
                MSD_len{n}(times)=MSD_len{n}(times)+msd;
                MSD_len_err{n}(times)=MSD_len_err{n}(times)+merr;
                count_len(n,times)=count_len(n,times)+counts;
            end
            %Intensity MSD
            [msd,merr,times,counts]=msd_timed_data(ints(1,:),ints(2,:));
            MSD_int{n}(times)=MSD_int{n}(times)+msd;
            MSD_int_err{n}(times)=MSD_int_err{n}(times)+merr;
            count_int(n,times)=count_int(n,times)+counts;
        end
    end
end
for n=2:npmax    
    if sum(spin_count(n,:))>0
        MSD_int{n}=MSD_int{n}./max(count_int(n,:),1);
        MSD_len{n}=MSD_len{n}./max(count_len(n,:),1);
        MSD_ang{n}=MSD_ang{n}./max(count_ang(n,:),1);
        MSD_int_err{n}=MSD_int_err{n}./max(count_int(n,:),1);
        MSD_len_err{n}=MSD_len_err{n}./max(count_len(n,:),1);
        MSD_ang_err{n}=MSD_ang_err{n}./max(count_ang(n,:),1);
        MSD_int_cnt{n}=count_int(n,:);
        MSD_len_cnt{n}=count_len(n,:);
        MSD_ang_cnt{n}=count_ang(n,:);
    end
end

%analysis.msd_int.value=MSD_int;
%analysis.msd_int.stddev=MSD_int_err;
%analysis.msd_int.name='Mean square displacement of intensity';
analysis.msd_ang.value=MSD_ang;
analysis.msd_ang.stddev=MSD_ang_err;
analysis.msd_ang.count=MSD_ang_cnt;
analysis.msd_ang.name='Mean square displacement of angles';
analysis.msd_len.value=MSD_len;
analysis.msd_len.stddev=MSD_len_err;
analysis.msd_len.count=MSD_len_cnt;
analysis.msd_len.name='Mean square displacement of pole length';

analysis.bipo_angles.value=mean_bipo;
analysis.bipo_angles.stddev=rms_bipo;
analysis.bipo_angles.count=count_bipo;
analysis.bipo_angles.name='Angle difference in bipolar spindles';

analysis.moyct.value=spin_moyct';
analysis.moyct.count=spin_count';
analysis.moyct.name='Average spindle repartition (n=3 : bipolar)';

analysis.timespent.value=t_stays';
analysis.timespent.stddev=t2_stays';
analysis.timespent.count=n_stays';
analysis.timespent.name='Average time spent in polarity (n=3:bipolar)';

analysis.transitionrates.value=exch_rate;
analysis.transitionrates.count=exch_count;
analysis.transitionrates.name='Matrix of transition rates';

save_struct_analysis(analysis,1);


end
