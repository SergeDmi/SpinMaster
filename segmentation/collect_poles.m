function [seq_poles,seq_times] = collect_poles(fname,n,opt)
% Collects pole trajectories
% Reads (n-1)-polar spindle  in files fnames
% Orders data as pole trajectory with time
% Poles are described by angle (rad) and length
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
regions=load_objects(regfilename);
n_times=max(listind(1,:));
n_regs=numel(regions);

% Time dependant int, len, angle of spindles
spindles_len_time=cell(n_regs,1);
spindles_ang_time=cell(n_regs,1);
spindles_array=zeros(n-1,2,n_regs,n_times);
times_array=zeros(n-1,2,n_regs,n_times);

occupat=zeros(n_regs,n_times);

seq_poles={};
seq_times={};
%% Building the arrays
for i=listind(1,:)
    if i>0
        fold_name=num2str(i);
        cd(fold_name);
        t=listind(2,i);       
        if exist(fname,'file')
            an_sp=load_objects(fname);
            nspin=numel(an_sp);
            for j=1:nspin
                al=an_sp{j};
                jid=al.id;                
                
                spindles_ang_time{jid}=horzcat(spindles_ang_time{jid},[al.points(:,1);t]);
                spindles_len_time{jid}=horzcat(spindles_len_time{jid},[al.points(:,2);t]);
                spindles_array(:,:,i,jid)=al.points(:,:);
                times_array(:,:,i,jid)=[t*ones(n-1,1),t*ones(n-1,1)];
                occupat(jid,i)=1;
            end
        end
        
        cd '..';
    end
end


np=0;
for jid=1:n_regs
    occ=occupat(jid,:);
    succ={};
    [succ]=breakdown(occ,succ,1,1);
    for i=1:numel(succ);
        times=succ{i};
        [ang_len_poles,time_poles]=order_poles_times(spindles_array(:,:,times,jid),times_array(:,:,times,jid));
        for k=1:n-1
            np=np+1;
            seq_poles{np}.points=ang_len_poles(:,:,k);
            seq_poles{np}.info=num2str(jid);
            seq_poles{np}.id=np;
            seq_times{np}.points=time_poles(:,:,k);
            seq_times{np}.info=num2str(jid);
            seq_times{np}.id=np;
        end
    end
    
end




end
   

function [poles,times]=order_poles_times(anglen_spindles,time_spindles)
% Order spindle poles to follow single pole with time
s=size(anglen_spindles);
if length(s)>2
    nt=s(3);
else
    nt=1;
end
n =s(1);
poles=zeros(nt,2,n);
times=zeros(nt,2,n);
[~,ord]=reorder_array(convert_anglen_pos(anglen_spindles));
for t=1:nt
    for k=1:n
        poles(t,:,k)=anglen_spindles(ord(k,t),:,t);
        times(t,:,k)=time_spindles(ord(k,t),:,t);
    end
end
end

function poles=order_poles(anglen_spindles)
% Order spindle poles to follow single pole with time
s=size(anglen_spindles);
if length(s)>2
    nt=s(3);
else
    nt=1;
end
n =s(1);
poles=zeros(nt,2,n);
[~,ord]=reorder_array(convert_anglen_pos(anglen_spindles));
for t=1:nt
    for k=1:n
        poles(t,:,k)=anglen_spindles(ord(k,t),:,t);
    end
end
end
    


