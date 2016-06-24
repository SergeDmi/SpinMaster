function objects = edit_objects(im, objects, filename, rectangle_mode)

% Creates a GUI to draw objects using the mouse on the provided image.
%
% Syntax:
%
%  objects = edit_objects(image, objects, filename, rectangle_mode)
%  objects = edit_objects(image, objects, filename)
%  objects = edit_objects(image, [], filename)
%
% Objects are defined by clicking on the image:
%  A simple click defines an object composed of one point.
%  A click-and-drag motion defines an object composed of two points.
%  Further points can be added with shift-clicks.
%
% You can select/deselect objects by clicking on them and:
% - delete selected object with backspace
% - move selected objects with the arrow-keys
% Selected objects are highligted in red.
% If an object is selected, shift-clicks will add point to this object.
%
% In addition one can:
% - zoom in and out with the mouse-wheel
% - translate the image by holding the space-bar and moving the mouse
%
% If a return value is expected, the function will block until the dialog
% is closed by the user.
%
% If ( objects == [] ), the objects are first loaded from `filename`.
% If ( rectangle_mode == 1 ), 2-points objects are drawn as rectangles.
% If ( filename == [] ) nothing will be saved to file, but the edited 
% objects can still be retrieved in the returned value.
%
% See also
%     save_objects, load_objects and show_objects
%
% F. Nedelec, Jan. 2009 - Nov. 2012


if nargin < 1
    error('First argument should be an image');
end

if nargin < 2
    error('Second argument should be empty or objects');
end

if nargin < 3
    error('Third argument should be empty or a file_name');
end

if nargin < 4
    rectangle_mode = 0;
end


if isempty(objects) && ~isempty(dir(filename))
    objects = load_objects(filename);
elseif ~iscell(objects)
    error('2d argument (objects) should be a cell array');
end

if isempty(filename) && nargout == 0
    fprintf(2, 'The objects will not be saved because a filename was not provided\n');
    fprintf(2, 'The objects are returned unmodified\n');
end

if ischar(rectangle_mode) && strcmp(rectangle_mode, 'rect')
    rectangle_mode = 1;
end

objects_saved = objects;

%% prepare the image

[hImage, pixels] = show_image(im);

hAxes  = gca;
hFig   = gcf;
hPanel = [];

% draw objects on top of image
for o = 1:length(objects)
    draw_object(objects{o});
end

%% 

focusP = [ mean(xlim) mean(ylim) ];
zoomF  = 1;
downP  = [ 0 0 ];

spaceKey = 0;
shiftKey = 0;


mouse_rect = [];
mouse_line = [];

selected_object = [];
new_object = [];


set(hFig,  'pointer', 'crosshair');

set(hFig,  'KeyPressFcn',   {@callback_key_down});
set(hFig,  'KeyReleaseFcn', {@callback_key_up});
set(hFig,  'DeleteFcn',     {@callback_quit});

set(hFig,  'WindowButtonDownFcn',   {@callback_mouse_down});
set(hFig,  'WindowButtonUpFcn',     {@callback_mouse_up});
set(hFig,  'WindowButtonMotionFcn', {@callback_mouse_motion});
set(hFig,  'WindowScrollWheelFcn',  {@callback_mouse_wheel});

set(hImage,'Interruptible', 'off');
set(hFig,  'Interruptible', 'off');


%% prepare the dialog

fPos = get(hFig, 'Position');
dPos = [ fPos(1)+fPos(3)+100, fPos(2)+fPos(4), 280, 90 ];

hDia = dialog('Name', 'Edit Objects', 'Position', dPos, 'WindowStyle', 'normal', 'Color', [0 0 1]);
set(hDia,  'DeleteFcn',     {@callback_close});

uicontrol(hDia, 'Style', 'PushButton',...
    'Position', [ 10 5 70 40],...
    'String', 'Help', 'FontSize', 17, 'Callback', {@callback_help});

uicontrol(hDia, 'Style', 'PushButton',...
    'Position', [ 10 45 70 40],...
    'String', 'Quit', 'FontSize', 17, 'Callback', {@callback_quit});


uicontrol(hDia, 'Style', 'PushButton',...
    'Position', [ 90 5 70 40],...
    'String', 'Erase', 'FontSize', 17, 'Callback', {@callback_erase});

uicontrol(hDia, 'Style', 'PushButton',...
    'Position', [ 90 45 70 40],...
    'String', 'Save', 'FontSize', 17, 'Callback', {@callback_save});


uicontrol(hDia, 'Style', 'PushButton',...
    'Position', [ 170 5 100 40],...
    'String', 'Select All', 'FontSize', 17, 'Callback', {@callback_select_all});

uicontrol(hDia, 'Style', 'PushButton',...
    'Position', [ 170 45 100 40],...
    'String', 'Save+Quit', 'FontSize', 17, 'Callback', {@callback_save_quit});

figure(hFig);

if nargout > 0
    waitfor(hDia);
end



%% Functions

    function rec = make_rectangle(pts)
        if numel(pts) == 4
            pX = sort(pts(:, 1));
            pY = sort(pts(:, 2));
            rec = [pX(1) pY(1); pX(2) pY(2)];
        else
            rec = pts;
        end
    end


    function m = current_point()
        P = get(hAxes, 'CurrentPoint');
        m = P(1,1:2);
    end


%% Callbacks

    function delete_handles()
        if ishandle(mouse_line)
            delete(mouse_line);
            mouse_line = [];
        end
        if ishandle(mouse_rect)
            delete(mouse_rect);
            mouse_rect = [];
        end
    end


    function callback_mouse_down(hObject, eventData)
        %fprintf('down in window\n');
        downP = current_point;
        if ~spaceKey
            pts = [downP(2) downP(1)];
            if shiftKey
                % add a point to object:
                if isempty(selected_object)
                    ix = length(objects);
                else
                    ix = object_index(selected_object);
                end
                if numel(ix) == 1
                    objects{ix}.points = cat(1, objects{ix}.points, pts);
                    redraw_object(objects{ix});
                else
                    warning('Cannot add point to complicated object');
                end
            else
                obj.id     = create_id;
                obj.points = pts;
                new_object = obj;
            end
            
            if rectangle_mode
                mouse_rect = rectangle('Position', [downP 1 1]);
                set(mouse_rect, 'LineWidth', 2, 'EraseMode', 'xor', 'LineStyle', ':', 'HitTest', 'off');
            else
                mouse_line = line('XData', [downP(1) downP(1)], 'YData', [downP(2) downP(2)]);
                set(mouse_line, 'LineWidth', 2, 'EraseMode', 'xor', 'LineStyle', ':', 'HitTest', 'off');
            end
        end
    end


    function callback_mouse_up(hObject, eventData)
        pos = current_point;
        T = pos - downP;

        if ~ isempty(selected_object)
            
            % the click was on an object:
            
            if norm(T) > 4   
                move_point(selected_object, T([2,1]));
            end

        elseif ~isempty(new_object)
 
            if norm(T) > 4
                pts = cat(1, new_object.points, [pos(2), pos(1)]);
                if rectangle_mode
                    pts = make_rectangle(pts);
                end
                new_object.points = pts;
            end
            
            objects = cat(1, objects, new_object);
            draw_object(new_object);
            new_object = [];

        end
        
        new_object = [];
        delete_handles;
    end


    function callback_mouse_motion(hObject, eventData)
        P = downP;
        Q = current_point;
        if ishandle(mouse_rect)
            rec = [ min(P,Q), abs(P-Q) ];
            if rec(3) > 0  &&  rec(4) > 0
                set(mouse_rect, 'Position', rec);
            end
        elseif ishandle(mouse_line)
            set(mouse_line, 'XData', [P(1) Q(1)], 'YData', [P(2) Q(2)]);
        elseif spaceKey
            focusP = focusP + P - Q;
            %fprintf('focus <- %f %f\n', focusP(1), focusP(2));
            adjust_view(focusP, zoomF);
        end
    end


    function callback_mouse_wheel(hObject, eventData)
        if ishandle(hPanel)
            api = iptgetapi(hPanel);
            r = api.getVisibleImageRect();
            y = r(2) + r(4) * eventData.VerticalScrollCount / 50;
            yl = get(hImage, 'YData') - [ 0 r(4) ];
            if y < yl(1) ; y = yl(1); end
            if y > yl(2) ; y = yl(2); end
            api.setVisibleLocation(r(1), y);
        else
            m = current_point;
            z = zoomF;
            if eventData.VerticalScrollCount > 0
                if ( zoomF < 100 )
                    zoomF = zoomF * 1.1;
                end
            elseif eventData.VerticalScrollCount < 0
                if ( zoomF > 1 )
                    zoomF = zoomF / 1.1;
                end
            end
            focusP = ((zoomF-z)*m + z*focusP)/zoomF;
            adjust_view(focusP, zoomF);               
        end
    end



    function callback_hit(hObject, eventData)
        new_object = [];
        if ~spaceKey
            %hit = str2num(get(hObject, 'Tag'));
            hits = str2num(get(hObject, 'Tag'));
            hit=hits(1);
            if numel(hits)==21
                pt=hits(2);
            end
            fprintf('hit %d\n', hit);
            if get_state(hit)
                set_state(hit, 0);
                selected_object = []; %setdiff(selected_object, hit);
            else
                set_state(selected_object, 0);
                set_state(hit, 1);
                selected_object = hit; %cat(1, selected_object, hit);
            end
            delete_handles;
            mouse_line = line('XData', [downP(1) downP(1)], 'YData', [downP(2) downP(2)]);
            set(mouse_line, 'LineWidth', 2, 'EraseMode', 'xor', 'LineStyle', ':', 'HitTest', 'off');
        end
    end


    function callback_key_down(hObject, eventData)
        %keyboard action
        if eventData.Character == 'z'
            reset_view;
            set_state(selected_object, 0);
        elseif eventData.Character == ' '
            downP = current_point;
            spaceKey = 1;
        elseif strcmp(eventData.Key, 'shift')
            shiftKey = 1;
        elseif strcmp(eventData.Key, 'backspace')
            delete_object(selected_object);
        elseif strcmp(eventData.Key, 'leftarrow')
            move_points(selected_object, [0 -1]);
        elseif strcmp(eventData.Key, 'rightarrow')
            move_points(selected_object, [0 +1]);
        elseif strcmp(eventData.Key, 'downarrow')
            move_points(selected_object, [+1 0]);
        elseif strcmp(eventData.Key, 'uparrow')
            move_points(selected_object, [-1 0]);
        end
    end


    function callback_key_up(hObject, eventData)
        if eventData.Character == ' '
            spaceKey = 0;
        elseif strcmp(eventData.Key, 'shift')
            shiftKey = 0;
        end
    end


    function callback_quit(hObject, eventData)
        save_with_confirmation;
        if ishandle(hFig)
            delete(hFig);
        end
        if ishandle(hDia)
            delete(hDia);
        end
    end


    function callback_close(hObject, eventData)
        save_with_confirmation;
        if ishandle(hFig)
            set(hFig,  'pointer', 'arrow');
            set(hFig,  'KeyPressFcn',  '');
            set(hFig,  'DeleteFcn',    '');
            set(hImage,'ButtonDownFcn', '');
            set(hFig,  'WindowButtonUpFcn', '');
            set(hFig,  'WindowButtonMotionFcn', '');
        end 
        if ishandle(hDia)
            delete(hDia);
        end
    end


    function callback_erase(hObject, eventData)
        delete_object(selected_object);
    end


    function callback_select_all(hObject, eventData)
        ida = all_object_ids;
        ids = selected_object;
        if length(ida) == length(ids)
            set_state(ida, 0);
        else
            set_state(ida, 1);
        end
    end


    function callback_help(hObject, eventData)
        % matlab might crash if the help-dialog is closed.
        % So we do not provide it at the moment
        doc edit_objects;
    end


%% Functions for the GUI


    function save_with_confirmation
        if ~isequal(objects_saved, objects)
            if isempty(filename)
                fprintf(2, 'Data unsaved because file_name was not specified\n');
            else
                k = questdlg('Do you want to save the points?', 'Confirm', 'Yes', 'No', 'Yes');
                if  strcmpi(k, 'Yes')
                    save_objects(objects, filename, im.file_name);
                end
            end
        end
        %do not ask the same question, unless the data has changed:
        objects_saved = objects;
    end


    function callback_save(src, evt)
        if isempty(filename)
            fprintf(2, 'Data unsaved because file_name was not specified\n');
        else
            save_objects(objects, filename, im.file_name);
        end
        objects_saved = objects;
    end


    function callback_save_quit(src, evt)
        callback_save(src, evt);
        if ishandle(hFig)
            delete(hFig);
        end
        if ishandle(hDia)
            delete(hDia);
        end
    end


%% Functions to manipulate the objects

    function tag = object_tag(ref)
        tag = num2str(ref);
    end

    function res = all_object_ids
        res = [];
        for n = 1 : length(objects)
            res = cat(1, res, objects{n}.id);
        end
        res = unique(res);
    end


    function id = create_id
        if isempty(objects)
            id = 1;
        else
            id = max(all_object_ids)+1;
        end
    end


    function move_point(id, T)
        for ix = 1 : length(objects)
            if id == objects{ix}.id 
                TT = T;
                while size(TT,1) < size(objects{ix}.points,1)
                    TT = cat(1, TT, T);
                end
                objects{ix}.points = objects{ix}.points + TT;
                redraw_object(objects{ix});
            end
        end
    end


    function move_points(ids, T)
        for i = 1:length(ids)
            move_point(ids(i), T);
        end
        set_state(ids, 1)
    end


    function draw_object(obj)
        tag = object_tag(obj.id);
        pN = size(obj.points, 1);
        pX = obj.points(:,1);
        pY = obj.points(:,2);
       
        %fprintf('draw %i %.2f %.2f\n', obj.id, px, py);

        if rectangle_mode && pN == 2
            rec = make_rectangle(obj.points);
            h(1) = plot(hAxes, [rec(1,2), rec(1,2), rec(2,2), rec(2,2), rec(1,2)], [rec(1,1), rec(2,1), rec(2,1), rec(1,1), rec(1,1)], 'g-');
            h(2) = text(rec(1,2), rec(1,1), [' ', tag], 'Color', 'g', 'FontWeight', 'bold', 'FontSize', 18, 'VerticalAlignment', 'Bottom', 'Parent', hAxes);
        else
            h(1) = plot(hAxes, pY, pX, 'Marker', 'o', 'MarkerSize', 16, 'Color', 'g', 'LineWidth', 2);
            h(2) = text(pY(pN), pX(pN), ['   ', tag], 'Color', 'g', 'FontWeight', 'bold', 'FontSize', 18, 'Parent', hAxes);
            if pN > 1
                h(3) = plot(hAxes, pY(1), pX(1), 'Marker', 'x', 'MarkerSize', 16, 'Color', 'g');
            end
        end
        set(h, 'SelectionHighlight', 'off', 'ButtonDownFcn', {@callback_hit});
        set(h, 'Tag', tag);
     end


    function redraw_object(obj)
        delete(findobj(hAxes, 'Tag', num2str(obj.id)));
        draw_object(obj);
    end


%% Function to select objects

    function sel = get_state(ids)
        sel = zeros(size(ids));
        for n = 1:size(ids, 1)
            id = ids(n,:);
            h = findobj(hAxes, 'Tag', num2str(id));
            if any(strcmpi('on', get(h, 'Selected')))
                sel(n) = 1;
            end
        end
    end


    function set_state(ids, sel)
        if sel
            for n = 1:size(ids,1)
                id = ids(n,:);
                h = findobj(hAxes, 'Tag', num2str(id));
                set(h, 'Selected', 'on');
                set(h, 'Color', [1 0 0]);
            end
        else
            for n = 1:size(ids,1)
                id = ids(n,:);
                h = findobj(hAxes, 'Tag', num2str(id));
                set(h, 'Selected', 'off');
                set(h, 'Color', [0 1 0]);
            end
        end
        refresh(hFig);
    end


    function res = object_index(ids)
        res = [];
        for ix = 1 : length(objects)
            if any( objects{ix}.id == ids )
                res = cat(1, res, ix);
            end
        end
    end


    function delete_object(ids)
        pruned = {};
        for ix = 1:length(objects)
            id = objects{ix}.id;
            if any( id == ids )
                delete( findobj(hAxes, 'Tag', num2str(id)));
            else
                pruned = cat(1, pruned, objects{ix});
            end
        end
        objects = pruned;
    end


    function set_label(ids, label)
        for ix = 1:length(objects)
            if any( objects{ix}.id == ids )
                objects{ix}.label = label;
                h = findobj(hAxes, 'Tag', ['label', num2str(id)]);
                set(h, 'String', label);
            end
        end
    end


    function adjust_view(p, z)
        w = 0.5 * ( size(pixels, 2) - 1 ) / z;
        h = 0.5 * ( size(pixels, 1) - 1 ) / z;
        roi = [p(1)-w, p(1)+w, p(2)-h, p(2)+h];
        axis(hAxes, roi);
        refresh(hFig);
    end


    function reset_view()
        roi = [1, size(pixels,2), 1, size(pixels,1)];
        axis(hAxes, roi);
        focusP = [ mean(roi(1:2)), mean(roi(3:4)) ];
        zoomF  = 1;
        refresh(hFig);
    end



end
