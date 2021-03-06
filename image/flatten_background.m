function [imr, err] = flatten_background(im, tile, range)

%function flatten_background(im)
%function flatten_background(im, tile)
%function flatten_background(im, tile, range)
%
% Corrects uneven exposure/acquisition of confocal images
%
% tile (2 elements) specifies a vertical and horizontal tiling
% range (2 elements) specifies the range of pixel values used for the correction
%
% F. Nedelec, April 2008, March 2013

if isfield(im, 'data')
    im = im.data;
end

if nargin < 2  || isempty(tile)
    tile = [1, 1];
end

if nargin < 3
    [b, s] = image_background(im);
    range = [ 0, b+s ];
    %fprintf(' Background range is [%.1f %.1f]\n', range(1), range(2));
end


imz = size(im) ./ tile;
imr = zeros(size(im));

err = 0;
nbx = 0;

for i = 0:tile(1)-1
for j = 0:tile(2)-1
    
    irange = round( (1:imz(1))+i*imz(1));
    jrange = round( (1:imz(2))+j*imz(2));
    iii = double(im(irange, jrange));
    [min(irange) max(irange)];
    [min(jrange) max(jrange)];
    
    %calculate the best quadratic fit:
    %quad = fit_quadratic_iso(iii, ( iii < level ));
    [b, s] = image_background(iii);
    range = [ 0, b+s ];
    msk = ( range(1) < iii ) & ( iii < range(2) );
    
    quad = fit_quadratic(iii, msk);
    %fprintf(' Quadratic fit: %.3f x^2 %+.3f y^2 %+.3f x*y %+.3f x %+.3f y %+.3f\n', quad);
    
    qval = quadratic(imz, quad);
    
    err = err + sum(sum( (qval-double(iii)).^2 .* msk ));
    nbx = nbx + sum(sum(msk));
%show_overlay_mask(qval, msk, 'magnification', 1);

    imr(irange, jrange) = iii - qval;

end
end

err = sqrt( err / nbx );

%show( ( im < range(2) ) .* double(im) );

end