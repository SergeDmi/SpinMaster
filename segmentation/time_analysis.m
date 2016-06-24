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



regions=load_objects(regfilename);
n_regs=numel(regions);

% Counting rates of state dep.
tracked_poles=cell(npmax,1);
tracked_times=cell(npmax,1);
for n=2:npmax
    if n>1
        fname=[num2str(n-1) '_polar_'];
        fname_ang_len=[fname 'angle_length.txt'];
        [tracked_poles{n} tracked_times{n}]=collect_poles(fname_ang_len,n,opt);
    end
    fname=[num2str(n-1) '_polar_poles.txt'];
    save_objects(tracked_poles{n},fname);
    tname=[num2str(n-1) '_polar_times.txt'];
    save_objects(tracked_times{n},tname);
end

bname_anglen='bipolar_angle_length.txt';
tracked_bipoles=cell(npmax,1);
tracked_bitimes=cell(npmax,1);
[tracked_bipoles{3},tracked_bitimes{3}]=collect_poles(bname_anglen,3,opt);
save_objects(tracked_bipoles{3},'bipolar_poles.txt');
save_objects(tracked_bitimes{3},'bipolar_times.txt');


analysis{1}=tracked_poles_analysis(tracked_poles,tracked_times,opt);
analysis{1}.file_name='analysis_all.txt';
analysis{2}=tracked_poles_analysis(tracked_bipoles,tracked_bitimes,opt);
analysis{2}.file_name='analysis_goodbipo.txt';

end
