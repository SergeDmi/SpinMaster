function threshold = manual_threshold( im, val, varargin )

% function manual_threshold( image, threshold, display-arguments )
%
% Display image with a slider, allowing the user to select a threshold
%
% F. Nedelec, Feb. 2008

%% display

[hImage, pixels] = show_image(im);

if nargin < 2 
    threshold = [];
else
    threshold = val;
end

if isempty(threshold)
    % start with the background level:
    threshold = image_background(pixels);
end

%% calculate extreme values

inf = min(min(pixels));
sup = max(max(pixels));

if threshold < inf || threshold > sup 
    threshold = ( inf + sup ) / 2;
end

% display thresholded image:
show_image( pixels>threshold, 'Handle', hImage);

%% build GUI

hFig  = gcf;
hAxes = gca;

shift = 40;
fPos  = get(hFig, 'Position');

set(hFig, 'Name', 'Manual threshold', 'Position', fPos + [0 0 0 shift]);
set(hAxes, 'Units', 'pixels', 'Position', [1 shift fPos(3:4)]);


dp = 1 / double(sup - inf );

hSlider = uicontrol(hFig, 'Style', 'slider',...
    'Position',[ 10 2 fPos(3)-150 25 ], 'FontSize', 14, ...
    'Min', inf, 'Max', sup, 'Value', threshold,...
    'SliderStep', [ dp dp ],...
    'Callback',{@callback_slider});

handle.listener(hSlider, 'ActionEvent', @callback_slider);

hButton = uicontrol(hFig, 'Style', 'pushbutton',...
    'Position',[ fPos(3)-130 1 120 shift ],...
    'String', 'Set & Close', 'FontSize', 14,...
    'Callback',{@callback_button});

refresh(hFig);
uiwait(hFig);



%% callbacks

    function update_image
        %fprintf('threshold=%i\n', threshold);
        set(hFig, 'Name', sprintf('Threshold = %i', threshold));
        show_image(pixels > threshold, 'Handle', hImage);
        %show_overlay_mask(pixels, pixels>threshold, hImage);  %this is too slow
        %fprintf( 'threshold %i\n', threshold);
        refresh(hFig);
    end


    function callback_slider(hObject, eventData)
        threshold = round( get(hObject, 'Value') );
        update_image;
    end


    function callback_button(hObject, eventData)
        close(hFig);
    end


end

