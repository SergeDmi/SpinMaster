function make_time_folders(opt)
% make_time_folders(opt) creat one folder per tubulin images
% assumes the tub images to be separated by a time time_interval 
% and the starting time to be time_start
% A DNA file is needed for latter analysis.
% S. Dmitrieff, March 2013

%% Input control
filename='spindles.txt';
regfilename='regions.txt';
if nargin < 2
    opt=spin_default_options();
end
if isfield(opt,'seg_number')
    nc=opt.seg_number;
else
    defopt=spin_default_options;
    nc=defopt.seg_number;
end

if isfield(opt,'time_start')
    t0=opt.time_start;
else
    defopt=spin_default_options;
    t0=defopt.time_start;
end

if isfield(opt,'time_interval')
    dt=opt.time_interval;
else
    defopt=spin_default_options;
    dt=defopt.time_interval;
end


%% Creating the folders

% Reading image list
listim=image_list();
imdna=[];
t=t0-dt;
nim=numel(listim);
listind=zeros(2,nim-1);
ind=1;
if nim>2
    increment=listim(2).index-listim(1).index;
end

for i=1:nim
    if strcmp(listim(i).kind,'tub')
        listind(1,ind)=i;
        listind(2,ind)=get_time(listim(i),increment);
        ind=ind+1;
    elseif strcmp(listim(i).kind,'dna')
        imdna=listim(i);
    end
end

if isempty(imdna)
    error('You must provide a dna image')
end


% Making folders and copying information there
for i=listind(1,:)
    if i>0
        fold_name=num2str(i);
        if exist(fold_name,'dir')
            try 
                rmdir(fold_name,'s');
            end
        end
        mkdir(fold_name);
        copyfile(regfilename,fold_name);
        copyfile(filename,fold_name);
        listim(i).time=t;
        % Making an image list from the image and DNA image
        cd(fold_name);
        make_inherited_list([listim(i) imdna]);
        cd '..';
    end
end

save('times.mat','listind');

end
