function hImage = show_overlay_mask(image, mask, varargin)

% function hImage = show_overlay_mask(image, mask, varargin)
%
% show a gray-scale image with the mask overlayed in yellow
%
% F. Nedelec, March 2008 - 2012


pixels = image_get_pixels(image);

if any( size(pixels) ~= size(mask) )
    error('Size missmatch');
end

cLim = image_auto_colors(image);

    function res = scale_pixels(pixels, range)
        scale  = 1.0 / double( range(2) - range(1) );
        res = ( double(pixels) - range(1) ) .* scale;
        sel = logical( res < 0 );
        res(sel) = 0;
        sel = logical( res > 1 );
        res(sel) = 1;
    end

R = scale_pixels(pixels, cLim);
G = R;
B = R;

try
    ed = logical(edge(double(mask), 'sobel'));
    R(ed) = 1;
    G(ed) = 1;
    B(ed) = 0;
catch
    mk = logical(mask);
    R(mk) = 1;
    G(mk) = 1;
    B(mk) = 0;
end

im = zeros([size(image), 3]);
im(:,:,1) = R;
im(:,:,2) = G;
im(:,:,3) = B;

clear R G B;

hImage = show_image(im, 'ColorRange', [0 1], varargin{:});

end