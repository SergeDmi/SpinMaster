function output = edit_regions(im, filename)

% Usage:
%       edit_regions(image)
%       edit_regions(image, filename)
%
% creates a GUI to edit objects on the provided image,
% This calls edit_objects(im, [], filename);
%
%
% F. Nedelec, Jan. 2009 - 2012

if nargin < 1
    error('First argument should be an image');
end

if nargin < 2
    filename = 'regions.txt';
end

%%

output = edit_objects(im, [], filename, 1);


end
