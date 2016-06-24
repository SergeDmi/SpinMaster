function image = spin_load_pixels(image, opt)

% Load the pixel data for the given image
%
% Syntax:
%         spin_load_pixels(image, opt)
%
% image should be a struct with the following fields:
% * image.file_name
% * image.index
% * image.channel
%
% This will correct uneven illumination is ( opt.flatten_image > 0 ),
% and might also provide a calibration field image.pixelSize
%
% F. Nedelec - 25 Oct 2012


if nargin < 2
    opt = [];
end

im = tiffread(image.file_name, image.index);


%copy the pixel size which is stored in the LSM meta-data
if isfield(im, 'lsm') && isfield(im.lsm, 'VoxelSizeX') && isfield(im.lsm, 'VoxelSizeY')
    if ( im.lsm.VoxelSizeX == im.lsm.VoxelSizeY )
        image.pixelSize = im.lsm.VoxelSizeX * 1e6; %convert to micro-meters
    end
end

% image resolution stored in the TIFF-data
if isfield(im, 'x_resolution') || isfield(im, 'y_resolution')
    %fprintf(2, 'Discarding image resolution informations\n');
end


% get specified channel in color images:
if iscell(im.data)
    image.data = im.data{image.channel};
else
    image.data = im.data;
end

% background correction for LSM Live 5 tiled acquisition
if isfield(opt, 'flatten_image')  &&  opt.flatten_image > 0
    
    fprintf('Correcting exposure for 3x3 image "%s"\n', name);
    image.data = flatten_background(image.data, [3, 3]);
    image.back = 0;

end

end