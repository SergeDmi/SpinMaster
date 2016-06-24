function show_regions(im, regions)

% show_regions(im, regions)
%
% display the regions on the given image, or on the current image
% with the seconf form
%
% F. Nedelec, Jan. 2008 - 2012


if nargin < 1
    error('First argument should be an image or empty');
end

if nargin < 2
    error('Second argument should be regions or file-name');
end

%%

if ischar(regions)
    regions = load_regions(regions);
end


if ~isempty(im)
    show_image(im);
else
    d = round(max(max(regions))) + 20;
    show_image(zeros(d));
end

%%

hold on;

if size(regions,2) == 4

    % format [ x_inf, y_inf, x_sup, y_sup ]
    for n = 1:size(regions,1)
        image_drawrect(regions(n,:), 'g-', num2str(n));
    end
    
else
    
    % format [ id-number, x_inf, y_inf, x_sup, y_sup, color ]
    rgb = 'rgbymwc';
    for n = 1:size(regions,1)
        col = 'g';
        %Column 6 specifies a color
        if size(regions,2) > 5
            inx = min(regions(n,6), length(rgb));
            if inx > 0
                col = rgb(inx);
            end
        end
        %column 1 specifies the region-number
        image_drawrect(regions(n,2:5), [col '.-'], num2str(regions(n,1)));
    end
    
end

end
