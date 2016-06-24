function [consec_sp] = collect_poles(fname,n,opt)
% Collects pole trajectories
% Reads (n-1)-polar spindle  in files fnames
% Writes into consec_sp, and write to file
% S. Dmitrieff, Aug. 2013


if nargin==0
    error('No pole number given');
elseif nargin==1
    opt=spin_default_options();
end

if isempty(opt)
    opt=spin_default_options();
end
if isfield(opt,'max_polarity')
	npmax=opt.max_polarity;
else
	defopt=spin_default_options();
	npmax=defopt.max_polarity;
end

if n>npmax || 2>n
    error('Invalid pole number')
end

load 'times.mat';
regfilename='regions.txt';



tmax=round(listind(2,end)+1-listind(2,1));
%tmax=round(listind(2,end))
n_times=max(listind(1,:));
regions=load_objects(regfilename);
n_regs=numel(regions);

% Time dependant int, len, angle of spindles
spindles_len_time=cell(n_regs,1);
spindles_ang_time=cell(n_regs,1);

spindles_array=sparse(n-1,2,n_regs,t);

nobs=zeros(n_regs,1);

% Counting rates of state dep.
time_on=zeros(n_regs,1);
t2_stays=zeros(npmax,1);
spin_state=-ones(n_regs,1);
% Counting total spin rep.
spin_count=zeros(1,n_times);

occupat=zeros(n_regs,n_times);

consec_sp={};

%% Building the arrays
for i=listind(1,:)
    if i>0
        fold_name=num2str(i);
        cd(fold_name);
        t=listind(2,i);
        
        if exist(fname_ang_len,'file') && exist(fname_int,'file')
            an_sp=load_objects(fname);
            nspin=numel(an_sp);

            for j=1:nspin
                al=an_sp{j};
                jid=al.id;
                
                spin_count(n,i)=spin_count(n,i)+1;
                old_n=spin_state(jid);
                spin_state(jid)=n;
                
                
                spindles_ang_time{jid}=horzcat(spindles_ang_time{jid},[al.points(:,1);t]);
                spindles_len_time{jid}=horzcat(spindles_len_time{jid},[al.points(:,2);t]);
                
                spindles_array(:,:,jid,i)=al.points(:,:);
                
                occupat(jid,i)=1;
                
                %spindles_pts_time{pl.id,n,i}=pl.points;
                
                
                nobs(jid,n)=nobs(jid,n)+1;
            end
        end
        
        cd '..';
    end
end


n_sp=0;
for jid=1:nregs
    occ=occupat(jid,:);
    succ={};
    [succ]=breakdown(occ,succ,1,1);
    for i=1:numel(succ);
        times=succ{i};
        n_sp=n_sp+1;
        pol_arr=spindles_array(:,:,jid,times);
        conseq_sp{n_sp}=
        
        
    
end
end


    