function  analysis=analyze_spindles(image,tiling,opt)
% [analysis,profiles] = analyze_spindles(image, opt, tiling)
% Triggers analysis of spindle contours or backbones (according to opt)
% Tiling contains the tiling of the image (used for background removal)
% Important : published version of SpinMaster has no contours
% Just analyzing pole dynamics is done with opt.contour_analysis == 0
% S. Dmitrieff, March 2013
if nargin<1
    image=image_base();
    tiling=[];
    opt=spin_default_options();
elseif nargin<2 
    tiling=[];
    opt=spin_default_options();
elseif nargin < 3
    opt=spin_default_options();
end

if  isfield(image, 'data') 
    if ( length(image) > 1 ) 
        disp('show_image displaying picture 1 only');
    end
    image = image(1).data;
end
% compatibility with tiffread color image
if  iscell(image)    
    tmp = image;
    image = zeros([size(tmp{1}), 3]);
    try
        for c = 1:numel(tmp)
            image(:,:,c) = tmp{c};
        end
    catch
        disp('show_image failed to assemble RGB image');
    end
    clear tmp;
end



if isempty(tiling)
    answer=inputdlg({'Number of images horizontally', 'Number of images vertically'},...
        'Input',2,{'3','3'});
    vsize = str2double(answer{1});
    hsize = str2double(answer{2});
else
    vsize=tiling(1);
    hsize=tiling(2);
end 

if ~isfield(opt,'contour_analysis')
	defopt=spin_default_options();
	opt.contour_analysis=defopt.contour_analysis;
end

if opt.contour_analysis == 0
    analysis=analyze_folders([vsize,hsize],opt);   
    save_struct_analysis(analysis);
    plot_struct_analysis(analysis);
else
    analysis=analyze_contours(image,[vsize,hsize],opt);
end


end
