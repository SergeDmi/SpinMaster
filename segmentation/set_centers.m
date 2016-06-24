function [spindles] = set_centers(image,opt)

% poles = spin_save_clicks(image)
%
% use regions on the image to get the poles in each region clicked
% %npmax : maximum number of poles to be considered
% %any higher polarity can be stored under npmax too.
%
% S. Dmitrieff Nov 2012


%% Init.

filename='regions.txt';
if nargin < 1  || isempty(image)
    error('You must provide an image');
else
    if nargin<2
        defopt=spin_default_options;
        npmax=defopt.max_polarity;
    else
        if isfield(opt,'max_polarity');
            npmax=opt.max_polarity;
        else
            defopt=spin_default_options;
            npmax=defopt.max_polarity;
        end
    end
    
    % compatibility with tiffread grayscale image
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
   
end

%% First import the regions

regions=load_objects(filename);
n_reg=numel(regions);
%Create a structure type to store region state, center, number of poles
spindles{n_reg}.points=[1 1];

%% Then plot each region and ask for coordinates
for n=1:n_reg
    coords=regions{n}.pts;
    center=[(coords(1)+coords(3))/2,(coords(4)+coords(2))/2];
    spindles{n}.points=center;
    spindles{n}.id=n;
    spindles{n}.info=num2str(regions{n}.id);
end
save_objects(spindles,'spindles.txt');
end


