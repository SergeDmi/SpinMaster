function [ subim, rect ] = mouse_crop( im, rect_size )

% function [ subim, rect ] = mouse_crop( im )
% function [ subim, rect ] = mouse_crop( im, rect_size )
% 
% Extract a rectangular region of an image selected by the mouse
% In the second form, the width and height of the rectangle is imposed
%
% nedelec@embl-heidelberg.de,   Feb. 2008


show_image( im );

savedpointer = get(gcf, 'pointer');
set(gcf, 'pointer', 'fullcrosshair');
set(gcf, 'units', 'pixels')

if  nargin < 2
    rect = mouse_rectangle;
else
    rect = mouse_rectangle(rect_size);
end

set( gcf, 'pointer', savedpointer );
subim = image_crop(im, rect);

end