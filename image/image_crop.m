function [ subim, rec ] = image_crop( im, brect, padding_value )

% sub = image_crop( image, brect )
% sub = image_crop( image, brect, padding_value )
%
% return 'image' cropped by rectange 'brect'
% brect = [ x_inf, y_inf, x_sup, y_sup ] can be any size,
% coordinates may be negative or beyond the image size.
%
% The first and second forms differ in the way they handle clipping:
%    1: the returned image is always of size (x_sup - x_inf + 1, y_sup - y_inf + 1)
%       pixels outside the image are set to value 'padding_value'
%    0: clipping occurs, the image size may be smaller than brect
%
% F. Nedelec


if any( rem(brect,1) > 0 )
   brect = round( brect );
end

%compatibility with tiffread:
if isfield(im, 'data')  
    im = im.data; 
end


%---------------------------------------------------------------------
subim = [];

sx = size(im,1);
sy = size(im,2);

if sx==0 || sy == 0 
    warning('image_crop() called for empty image');
    return
end

lx = brect(1);
ly = brect(2);
ux = brect(3);
uy = brect(4);

clx = min(sx, max(1, lx));
cly = min(sy, max(1, ly));
cux = min(sx, max(1, ux));
cuy = min(sy, max(1, uy));

if nargin < 3
   
    %----- clipping
    if  ux >= 1  &&  uy >= 1  &&  lx <= sx  &&  ly <= sy ...
            &&  cux >= clx  &&  cuy >= cly
        subim = im(clx:cux, cly:cuy, :);
    end

else
    
    %----- padding
    
    dimen = size(im);
    dimen(1) =  ux - lx + 1;
    dimen(2) =  uy - ly + 1;
    
    if numel(padding_value) == 1
        subim = double(padding_value) * ones(dimen);
    else
        subim = ones(dimen);
        for d = 1:size(padding_value)
            subim(:,:,d) = padding_value(d) .* ones(dimen(1), dimen(2));
        end
    end
    
    if  ux >= 1  &&  uy >= 1  &&  lx <= sx  &&  ly <= sy ...
            &&  cux >= clx  &&  cuy >= cly
        subim(clx-lx+1:cux-lx+1, cly-ly+1:cuy-ly+1, :) = im(clx:cux, cly:cuy, :);
    end
   
end

rec = [ clx, cly, cux, cuy ];

end
