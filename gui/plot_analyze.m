function analysis = plot_analyze(analysis,opt)

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
if isfield(opt,'seg_number')
    nc=opt.seg_number;
else
    defopt=spin_default_options;
    nc=defopt.seg_number;
end

%Tubulin analysis
nsp=analysis.numbers;
for i=1:npmax+1
    if nsp(i)>0
        %% plotting
        Int=figure;hold all;
        Wid=figure;hold all;
        D=analysis.seg_dist_mean(i,:);
        dD=analysis.seg_dist_err(i,:);
        % Normed. Intens
        figure(Int);
        xlabel('Distance from DNA (in pixels)');
        ylabel('Tubulin density');
        plot(D,analysis.seg_dens_mean(i,:),'b.-');
        legend([num2str(i-1) '-polar spindles']);
        % Width
        figure(Wid);
        xlabel('Distance from DNA (in pixels)');
        ylabel('Spindle width');
        plot(D,analysis.seg_width_mean(i,:),'b.-');
        legend([num2str(i-1) '-polar spindles']);
        % Error bars
        for j=1:nc
            figure(Int);
            plot([D(j) D(j)],[analysis.seg_dens_mean(i,j)+analysis.seg_dens_err(i,j),analysis.seg_dens_mean(i,j)-analysis.seg_dens_err(i,j)],'b--');
            plot([D(j)-dD(j) D(j)+dD(j)],[analysis.seg_dens_mean(i,j),analysis.seg_dens_mean(i,j)],'b--');
            figure(Wid)
            plot([D(j) D(j)],[analysis.seg_width_mean(i,j)+analysis.seg_width_err(i,j),analysis.seg_width_mean(i,j)-analysis.seg_width_err(i,j)],'b--');
            plot([D(j)-dD(j) D(j)+dD(j)],[analysis.seg_width_mean(i,j),analysis.seg_width_mean(i,j)],'b--');
        end
        figure(Int);
        axis([0 max(D+dD) 0 max(analysis.seg_dens_mean(i,:)+analysis.seg_dens_err(i,:))]);
        figure(Wid);
        axis([0 max(D+dD) 0 max(analysis.seg_width_mean(i,:)+analysis.seg_width_err(i,:))]);
    end
end


end
