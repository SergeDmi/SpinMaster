function hImage = show_overlay(R, G, B, varargin)

% function image_handle = image_overlay(red, green, blue, varargin)
%
% display color image with the three specified components
% Empty components may be specified
%
% F. Nedelec, March 2008

R = pixels(R);
G = pixels(G);
B = pixels(B);


if ~isempty(R)
    ims = size(R);
elseif ~isempty(G)
    ims = size(G);
elseif ~isempty(B)
    ims = size(B);
end


im = zeros([ims, 3]);

if ~isempty(R)
    if any( size(R) ~= ims )
        error('Size missmatch (R)');
    end
    im(:,:,1) = R;
end

if ~isempty(G)
    if any( size(G) ~= ims )
        error('Size missmatch (G)');
    end
    im(:,:,2) = G;
end

if ~isempty(B)
    if any( size(B) ~= ims )
        error('Size missmatch (B)');
    end
    im(:,:,3) = B;
end

hImage = show_image(im, varargin{:});

    
    function pix = pixels(im)
        if isfield(im, 'data')
            pix = im.data;
        else
            pix = im;
        end
    end

end