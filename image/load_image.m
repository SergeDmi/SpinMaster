function images = load_image(key, value, which, opt)

% im = load_images(key, value)
% im = load_images(key, value, which, opt)
%
% Read from 'image.txt', and load images cooresponding to 'kind'
% if 'what' is numeric, load only image at index 'what'
% the returned structure has a field .data containing the pixel values
% 
%
% F. Nedelec, April 2008 - 25 Oct 2012



if nargin < 2
    key = '';
    value = '';
end
if nargin < 3
    which = [];
end
if nargin < 4
    opt = [];
end

images = [];

try
    list = image_list;
catch ME
    error('You must run "make_image_list.m" to generate the image list');
    rethrow(ME)
end

%% find selected images

if isempty(key)
    
    sel = 1:length(list);

else
    
    sel = [];
    
    for u = 1 : length(list)
        if list(u).(key) == value
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
        fprintf('\b\b\b\b\b\b\b:%5i:', u);
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


