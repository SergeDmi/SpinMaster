function images = spin_load_images(kind, which, opt)

% im = spin_load_images(kind)
% im = spin_load_images(kind, what)
%
% Read from 'image.txt', and load images cooresponding to 'kind'
% if 'what' is numeric, load only image at index 'what'
% the returned structure has a field .data containing the pixel values
% 
%
% F. Nedelec, April 2008 - 25 Oct 2012



if nargin < 1
    kind = [];
end
if nargin < 2
    which = [];
end
if nargin < 3
    opt = [];
end

images = [];


if isempty(dir('image_list.m'))
    error('You must run "make_image_list.m" to generate the image list');
end

rehash;
list = image_list;


%% find selected images

if isempty(kind)
    
    sel = 1:length(list);

else
    
    sel = [];
    
    for u = 1 : length(list)
        if list(u).kind == kind
            sel = cat(1, sel, u);
        end
    end
    
end


if isempty(sel)
    %warning('could not find "%s" images', kind);
    return
end


%% reduce selection if specified:

if  ~isempty(which)  &&  isnumeric(which)  &&  length(sel) > 1
    try
        sel = sel(which);
    catch
        error('Image index out of range');
    end
end

%% Load images

nbImages = length(sel);

feedback = ( nbImages > 10 );
if ( feedback )
    fprintf('Loading %i images...       ', length(sel));
end

for u = 1:length(sel)
    
    if ( feedback )
        fprintf('\b\b\b\b\b\b%6i', u);
    end
    
    ims = list(sel(u));
    
    if ~isfield(opt, 'load_pixels') || opt.load_pixels
        
        ims = spin_load_pixels(ims, opt);
         
    end

    images = cat(1, images, ims);
    
end

if ( feedback )        
    fprintf('\n');
end

end


