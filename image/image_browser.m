function image_browser(mode)

% Creates a dialog to navigate through a set of images
%
% Syntax:
%          image_browser()
%
% The images displayed are those returned by image_list,
% and pixels are loaded with load_pixels
%
% See also
%    make_image_list, load_pixels, edit_objects
%
% F. Nedelec, Feb. 2009 - Nov. 2012

%%


if nargin < 1
    mode = 0;
else
    if ischar(mode) 
        if strcmpi(mode, 'line')
            mode = 0;
        elseif strncmpi(mode, 'rect', 4)
            mode = 1;
        elseif strcmpi(mode, 'star')
            mode = 2;
        else
            error('Fourth argument should be "line", "rect" or "star"');
        end
    end
end
mode

%%

dPos = [ 100 100 400 140 ];

hDia = dialog('Name', 'Image Browser', 'Position', dPos, 'WindowStyle', 'normal');

hIndx = uicontrol(hDia, 'Style', 'text', 'Position', [ 10 90 40 30 ],...
    'String', 'N', 'FontSize', 16);

hText = uicontrol(hDia, 'Style', 'text','Position', [ 50 90 340 40 ],...
    'String', 'filename', 'FontSize', 14);


uicontrol(hDia, 'Style', 'PushButton', 'Position', [ 10 8 180 40 ], ...
    'String', 'Next', 'FontSize', 17, 'Callback', {@callback_next});

uicontrol(hDia, 'Style', 'PushButton', 'Position', [ 10 50 180 40 ],...
    'String', 'Prev', 'FontSize', 17, 'Callback', {@callback_prev});


uicontrol(hDia, 'Style', 'PushButton', 'Position', [ 200 8 180 40 ],...
    'String', 'Show', 'FontSize', 17, 'Callback', {@callback_show});

uicontrol(hDia, 'Style', 'PushButton', 'Position', [ 200 50 180 40 ], ...
    'String', 'Click!', 'FontSize', 17, 'Callback', {@callback_click});


%% Variables


imIndex = 1;
image   = [];
hImage  = [];

update_image;

%% Function to load image

    function load_image
        list = image_list;
        im = list(imIndex);
        image = load_pixels(im);
    end


%% Callbacks

    function callback_next(src, evnt)
        imIndex = imIndex + 1;
        update_image;
    end

    function callback_prev(src, evnt)
        if imIndex > 1
            imIndex = imIndex - 1;
            update_image;
        end
    end

    function callback_show(src, evnt)
        if isempty(hImage) || ~ishandle(hImage)
            load_image;
            hImage = show_image(image);
            update_image;
        end
    end


    function callback_click(src, evnt)
        if ~isempty(image)
            res = edit_objects(image, {}, click_file_name, mode);
            update_image;
        end
    end


%% Functions

    function filename = click_file_name
        [pathstr, name, ext] = fileparts(image.file_name);
        if isfield(image, 'index')  &&  image.index > 1
            filename = sprintf('%s_idx%i.pts', name , image.index);
        else
            filename = sprintf('%s.pts', name);
        end
    end


    function delete_objects
        hAxes = get(hImage, 'Parent');
        child = get(hAxes, 'Children');
        child = setdiff(child, hImage);
        delete(child);
    end


    function update_display
        if ishandle(hImage)
            delete_objects;
            show_image(image, 'Handle', hImage);
            file = click_file_name;
            if ~isempty(dir(file))
                show_objects([], file, 'y', mode);
            end
        end
    end


    function update_image
        set(hIndx, 'String', num2str(imIndex));
        try
            load_image;
            set(hText, 'String', image.file_name);
            update_display;
        catch ME
            image = [];
            %fprintf(2, 'Function %s\n', ME.stack(1).name);
            %fprintf(2, 'File %s\n', ME.stack(1).file);
            set(hText, 'String', ME.message);
        end
    end


end
