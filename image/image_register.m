function [ C, dx, dy ] = image_register(obj, im, bin, debug)

% function res = image_correlation(image, obj)
%
% try to register 'obj' inside 'image'
% F.Nedelec, March 2008


%compatibility with tiffread
if ( isfield(im, 'data') ) 
    if ( length(im) > 1 ) 
        disp('show_image displaying picture 1 only');
    end
    im = im(1).data;
end


if nargin > 2  &&  ~isempty(bin)
    obj = image_resample(obj, bin);
    im  = image_resample(im, bin);
else
    bin = 1;
end

if 1
    
    sz = size(im);
    
    %that seems to work best if obj is a binary image
    fft_im  = fft2(double(im));
    fft_obj = fft2(rot90(double(obj),2), sz(1), sz(2));
    C = ifft2( fft_obj .* fft_im );
    
    [xm, ix] = max(abs(C(:)));
    [dx, dy] = ind2sub(size(C), ix(1));
    dx = dx - size(obj,1) + 1;
    dy = dy - size(obj,2) + 1;

    
    
elseif 1
    
    %that works for im,obj both in gray scale
    C = normxcorr2(obj, im);
    %find the best translation:

    [xm, ix] = max(abs(C(:)));
    [dx, dy] = ind2sub(size(C), ix(1));
    dx = dx - size(obj,1) + 1;
    dy = dy - size(obj,2) + 1;

else
    
    %super slow method:
    C = zeros(size(im));
    obj_sum = sum(sum( obj .^ 2 ));

    h = waitbar(0, 'convoluting...');
    sz = size(obj);

    for dx = 1:1:size(im,1)
        waitbar(dx/size(im,1), h);
        for dy = 1:1:size(im,2)

            sub = image_crop(im, [dx dy dx+sz(1)-1 dy+sz(2)-1], 0);
            scl = obj_sum / sum(sum( sub .* obj ));
            %scl = 1;
            C(dx, dy) = sum(sum( ( sub*scl-obj ).^2 ));

        end
    end

    close(h);
    %find the best translation:

    [xm, ix] = min(abs(C(:)));
    [dx, dy] = ind2sub(size(C), ix(1));

end

if nargin > 3
    fprintf('best fit at %i %i\n', bin*dx, bin*dy);
    %display the best overlay:
    bw = zeros(size(im));
    bw(dx:dx+size(obj,1)-1, dy:dy+size(obj,2)-1) = obj;
    show_overlay(im, im, bw);
end

end