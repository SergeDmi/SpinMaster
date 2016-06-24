function analysis = save_analyze(analysis,opt)

% spindles = save_regions(spindles, filename)
%
% Save the spindles to file filename or 'spindles.txt'(default)
%
% S. Dmitrieff, Nov 2012

if nargin ==0
    error('You must provide analysis data');
else
    if ~isfield(analysis,'fraction_mon')
        error('You must provide valid analysis data');
    end
    filename='analysis.txt';
    if nargin==1
        warning('No options, saving in analysis.txt');
        opt.analysis_filename=filename;
    else
        if isfield(opt,'analysis_filename');
            filename=opt.analysis_filename;
        else
            warning('No options, saving in analysis.txt');
            opt.analysis_filename=filename;
        end
    end
end
if isfield(opt,'max_polarity')
	npmax=opt.max_polarity;
else
	defopt=spin_default_options();
	npmax=defopt.max_polarity;
end
file=dir(filename);
%% Creates backup if filename exists
try
    fdates=textscan(file.date,'%s %s');
    fdate=fdates{1};
    time=fdates{2};
    backup=sprintf('%s.%s-%s.back',filename,fdate{1},time{1});
    movefile(filename, backup);
    warning('the pre-existing "%s" was renamed "%s"\n', filename,backup);
catch
end

%% Saving
fid = fopen(filename, 'wt');
if isfield(opt,'base')
    list=image_list();
    [~, fname, ~] = fileparts(list(opt.base).file_name);
    fprintf(fid, '%% Data from %s \n ',fname);
end
fprintf(fid, '%% Analyzed on %s \n',date);
fprintf(fid, '%% Contains result from analysis of spindles arrays \n');
% Saving analysis.foo_bar
fprintf(fid, '%% Monopolar fraction  \n');
fprintf(fid, '%f \n',analysis.fraction_mon );
fprintf(fid, '%% Bipolar fraction \n');
fprintf(fid, '%f \n',analysis.fraction_bi   );
fprintf(fid, '%% Multipolar fraction \n');
fprintf(fid, '%f \n',analysis.fraction_multi);
%Tubulin analysis
nsp=analysis.numbers;
for i=1:npmax+1
    if nsp(i)>0
        fprintf(fid, '%% **** For %s-polar spindles ****  \n',num2str(i-1));
        fprintf(fid, '%% Dist of segments  and error \n');
        fprintf(fid, '%s    +/- %s \n', num2str(analysis.seg_dist_mean(i,:)),num2str(analysis.seg_dist_err(i,:)));
        fprintf(fid, '%% Intensity of segments per unit length and error \n');
        fprintf(fid, '%s    +/- %s \n', num2str(analysis.seg_intens_mean(i,:)),num2str(analysis.seg_intens_err(i,:)));
        fprintf(fid, '%% width of segments  and error \n');
        fprintf(fid, '%s    +/- %s \n', num2str(analysis.seg_width_mean(i,:)),num2str(analysis.seg_width_err(i,:)));
        fprintf(fid, '%% density of segments per unit surface and error \n');
        fprintf(fid, '%s    +/- %s \n', num2str(analysis.seg_dens_mean(i,:)),num2str(analysis.seg_dens_err(i,:)));
        fprintf(fid, '%% Total Intensity  \n');
        fprintf(fid, '%s    +/- %s \n', num2str(analysis.tot_intens_mean(i)),num2str(analysis.tot_intens_err(i)));
        fprintf(fid, '%% Total length of spindles  \n');
        fprintf(fid, '%s    +/- %s \n', num2str(analysis.tot_lengs_mean(i)),num2str(analysis.tot_lengs_err(i)));
        fprintf(fid, '%% Aspect of spindles (negative is thinnig)  \n');
        fprintf(fid, '%s    +/- %s \n', num2str(analysis.tot_aspect_mean(i)),num2str(analysis.tot_aspect_err(i)));
    end
end
fclose(fid);
fprintf('Analysis saved in %s\n', filename);
end
