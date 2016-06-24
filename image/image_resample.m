function res = image_resample( im, bin )

% function res = image_resample( image, bin )
% 
% Join pixels together to produce an image of lower resolution
% The pixel values are added and divided by bin^2
%
% F. nedelec, March 2008

%compatibility with tiffread:
if isfield(im,'data')
    im = im.data;
end

%reduce the x,y range by binning pixels:
[ux, uy] = size(im);
uxb = floor( ux / bin );
uyb = floor( uy / bin );

ldx = 1:bin:uxb*bin;
ldy = 1:bin:uyb*bin;

res = zeros(uxb, uyb);
for x=0:bin-1;
    for y=0:bin-1;
        res = res + double(im(ldx+x, ldy+y));
    end
end

res = res ./ ( bin*bin );

end

