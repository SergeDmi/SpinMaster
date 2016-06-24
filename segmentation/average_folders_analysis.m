function [analysis] = average_folders_analysis(opt)
% loads results from different folders to average the in analysis
% S. Dmitrieff, Aug 2013

if nargin==0
    [opt,npmax]=check_options_npmax();
else
    [opt,npmax]=check_options_npmax(opt);
end

%folders={
%'../Analysis_Celine_2012.10.18_pos2_32-42min',
%'../im_article'
%};

folders=folder_names();

nf=numel(folders);
tracked_poles=cell(npmax);
tracked_bipoles=cell(npmax);
tracked_times=cell(npmax);
tracked_bitimes=cell(npmax);
home=pwd;

answer=inputdlg({'Number of images horizontally', 'Number of images vertically'},...
    'Input',2,{'3','3'});
vsize = str2double(answer{1});
hsize = str2double(answer{2});
tiling=[vsize hsize];


for f=1:nf
    fold=folders{f};
    fold=strrep(fold,'../','');
    cd(fold);
    quick_fix_times;
    analyze_folders(tiling,opt);
    for n=2:npmax
        fname=[num2str(n-1) '_polar_poles.txt'];
        tname=[num2str(n-1) '_polar_times.txt'];
        tracked_poles{n}=concatenate_objects(tracked_poles{n},load_objects(fname));
        tracked_times{n}=concatenate_objects(tracked_times{n},load_objects(tname));
    end
    bname='bipolar_poles.txt';
    tname='bipolar_times.txt';
    tracked_bipoles{3}=concatenate_objects(tracked_bipoles{3},load_objects(bname));
    tracked_bitimes{3}=concatenate_objects(tracked_bitimes{3},load_objects(tname));
    cd(home);
end

analysis{1}=tracked_poles_analysis(tracked_poles,tracked_times,opt);
analysis{1}.file_name='analysis_all.txt';
analysis{2}=tracked_poles_analysis(tracked_bipoles,tracked_bitimes,opt);
analysis{2}.file_name='analysis_goodbipo.txt';

save_struct_analysis(analysis);
plot_struct_analysis(analysis);

end
