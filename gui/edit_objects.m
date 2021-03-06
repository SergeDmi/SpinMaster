function objects = edit_objects(im, objects, filename, mode)
% Creates a GUI to draw objects using the mouse on the provided image.
%
% Syntax:
%
%  objects = edit_objects(image, objects, filename, mode)
%  objects = edit_objects(image, objects, filename)
%  objects = edit_objects(image, [], filename)
%
% Objects are defined by clicking on the image:
%  A simple click defines an object composed of one point.
%  A click-and-drag motion defines an object composed of two points.
%  Further points can be added to objects with shift-clicks.
%
% You can select/deselect objects by clicking on them and:
% - delete selected object with backspace
% - move selected objects with the arrow-keys
% Selected objects are highligted in red.
% If an object is selected, shift-clicks will add point to this object.
%
% You can switch to the next object (or point) by pressing "Return"
% You can toggle between point and object selection by pressing the "*" key
%
% In addition one can:
% - zoom in and out with the mouse-wheel
% - translate the image by holding the space-bar and moving the mouse
%
% If a return value is expected, the function will block until the dialog
% is closed by the user.
%
% If ( objects == [] ), the objects are first loaded from `filename`.
% If ( mode == 1 ), 2-points objects are drawn as rectangles.
% If ( mode == 2 ), n-points objects are drawn as asters.
% If ( filename == [] ) nothing will be saved to file, but the edited 
% objects can still be retrieved in the returned value.
%
% See also
%     save_objects, load_objects and show_objects
%
% F. Nedelec, Jan. 2009 - Nov. 2012 - Jan 2013
% S. Dmitrief -  2013 - 2014

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


if isempty(objects) && ~isempty(filename) && ~isempty(dir(filename))
    objects = load_objects(filename);
elseif ~iscell(objects)
    error('Second argument (objects) should not be empty since no file was specified');
end

if isempty(filename) && nargout == 0
    fprintf(2, 'The objects will not be saved because a filename was not provided\n');
    fprintf(2, 'The objects are returned unmodified\n');
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

focusP = [ mean(ylim) mean(xlim) ];
zoomF  = 1;
downP  = [ 0 0 ];

spaceKey = 0;
shiftKey = 0;

selected_object = [];  %This is the ID of the selected object
selected_point  = [];
new_point = [];
last_object = [];

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
    'String', 'Erase', 'FontSize', 17, 'Callback', {@callback_delete});

uicontrol(hDia, 'Style', 'PushButton',...
    'Position', [ 90 45 70 40],...
    'String', 'Save', 'FontSize', 17, 'Callback', {@callback_save});


uicontrol(hDia, 'Style', 'PushButton',...
    'Position', [ 170 45 100 40],...
    'String', 'Save+Quit', 'FontSize', 17, 'Callback', {@callback_save_quit});

figure(hFig);

% adjust mouse style:
pointer_saved = get(gcf, 'pointer');
%set(hFig, 'pointer', 'fullcrosshair');

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


    function m = current_point
        P = get(hAxes, 'CurrentPoint');
        m = [ P(1,2), P(1,1) ];
    end


%% Callbacks


    function callback_hit(hObject, eventData)
        new_point = [];
        if ~spaceKey
            % only one object can be selected at any time
            if strcmpi(get(hObject, 'Selected'), 'on')
                set_selection([], []);
            else
                id = str2num(get(hObject, 'Tag'));
                if ~strcmp(get(hObject, 'Marker'), 'none')
                    pts = objects{object_index(id)}.points;
                    set_selection(id, closest_point(pts, current_point));
                else
                    set_selection(id, []);
                end
            end
        end
    end


    function callback_mouse_down(hObject, eventData)
        %fprintf('down in window\n');
        downP = current_point;
        if ~spaceKey
            new_point = downP;
        end
    end


    function callback_mouse_up(hObject, eventData)
        
        pos = current_point;
        T = pos - downP;

        if isempty(new_point)
            
            % drag object or selected point:
            if ~isempty(selected_object) &&  norm(T) > 4
                move_point(selected_object, selected_point, T);
                set_selection([], []);
            end
 
        else
                           
            if norm(T) > 4
                pts = cat(1, new_point, pos);
            else
                pts = new_point;
            end

            if shiftKey
                % add points to an existing object

                if isempty(selected_object)
                    ix = object_index(last_object);
                    if isempty(ix)
                        ix = size(objects,1);
                    end
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
                create_object(pts);
            end
       
            new_point = [];
        end
    end


    function callback_mouse_motion(hObject, eventData)
        P = downP;
        Q = current_point;
        if spaceKey
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


    function callback_key_down(hObject, eventData)        
        %keyboard action
        T = [];
        if eventData.Character == 'z'
            reset_view;
            set_selection([], []);
        elseif eventData.Character == 'q'
            callback_quit();
        elseif eventData.Character == ' '
            downP = current_point;
            spaceKey = 1;
        elseif strcmp(eventData.Key, 'escape')
            callback_save_quit([],[]);
        elseif strcmp(eventData.Key, 'shift')
            shiftKey = 1;
        elseif strcmp(eventData.Key, 'backspace')
            callback_delete;
        elseif strcmp(eventData.Key, 'leftarrow')
            T = [0 -1];
        elseif strcmp(eventData.Key, 'rightarrow')
            T = [0 +1];
        elseif strcmp(eventData.Key, 'downarrow')
            T = [+1 0];
        elseif strcmp(eventData.Key, 'uparrow')
            T = [-1 0];
        elseif strcmp(eventData.Key,'return')
            select_next_item();     
        elseif eventData.Character == '*'
            toggle_selection_mode();
        end
        if ~isempty(T) &&  ~isempty(selected_object)
            if shiftKey
                T = T * 10;
            end
            if isempty(selected_point)
                move_object(selected_object, T);
            else
                move_point(selected_object, selected_point, T);
            end
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
        set(hFig, 'pointer', pointer_saved);
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


    function callback_delete(hObject, eventData)
        if ~isempty(selected_object)
            if isempty(selected_point)
                delete_objects(selected_object);
                selected_object = [];
            else
                ix = delete_point(selected_object, selected_point);
                if isempty(ix)
                    selected_object = [];
                else
                    nP = size(objects{ix}.points, 1);
                    if selected_point > nP
                        selected_point = nP;
                    end
                    redraw_object(objects{ix});
                end
            end
        end
    end





    function callback_help(hObject, eventData)
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

    function res = all_object_ids()
        res = [];
        for n = 1 : length(objects)
            res = cat(1, res, objects{n}.id);
        end
        res = unique(res);
    end


    function id = create_id()
        if isempty(objects)
            id = 1;
        else
            ids = all_object_ids;
            s = setdiff(1:max(ids)+1, ids);
            id = s(1);
        end
    end


    function create_object(pts)
        obj.id     = create_id;
        obj.points = pts;
        objects = cat(1, objects, obj);
        draw_object(obj);
        last_object = obj.id;
    end


    function move_point(id, pti, T)
        ix = object_index(id);
        if isempty(pti)
            np = size(objects{ix}.points, 1);
            objects{ix}.points = objects{ix}.points + ones(np,1)*T;
        else
            objects{ix}.points(pti,:) = objects{ix}.points(pti,:) + T;
        end
        redraw_object(objects{ix});
    end


    function move_object(ids, T)
        for i = 1:size(ids, 1)
            move_point(ids(i,:), [], T);
        end
    end


    function inx = closest_point(pts, pos)
        inx = 1;
        dis = norm(pts(1,:)-pos);
        for k = 2:size(pts,1)
            if norm(pts(k,:)-pos) < dis
                inx = k;
                dis = norm(pts(k,:)-pos);
            end
        end
    end


    function hp = draw_object(obj)

        pN = size(obj.points, 1);
        if pN >= 1
            pX = obj.points(:,1);
            pY = obj.points(:,2);
            
            spec.Color = 'g';
            spec.LineWidth = 2;
            spec.Parent = hAxes;
            spec.SelectionHighlight = 'off';
            spec.ButtonDownFcn = @callback_hit;
            spec.Tag = num2str(obj.id);

            font.FontSize = 18;
            font.FontWeight = 'bold';
            font.VerticalAlignment = 'bottom';

            % draw the backbone of the object:
            if mode == 1 && pN == 2
                spX = sort(pX);
                spY = sort(pY);
                h(1) = text(spY(1), spX(2), [' ', spec.Tag], spec, font);
                h(2) = plot([spY(1), spY(1), spY(2), spY(2), spY(1)], [spX(1), spX(2), spX(2), spX(1), spX(1)], '--', spec);
            else
                h(1) = text(pY(pN), pX(pN), ['   ', spec.Tag], spec, font);
                if mode == 2
                    for i=2:pN
                        h(i) = plot([pY(1), pY(i)], [pX(1) pX(i)], spec);
                    end
                else
                    h(2) = plot(pY, pX, spec);
                end
            end
            
            % use a fat symbol for each point:
            spec.Marker = 's';
            spec.MarkerSize = 16;
            
            for p = 1:pN
                hp(p) = plot(pY(p), pX(p), spec);
                spec.Marker = 'o';
            end
        end
    end


    function erase_object(id)
        h = findobj(hAxes, 'Tag', num2str(id));
        delete(h);
    end


    function redraw_object(obj)
        erase_object(obj.id);
        hp = draw_object(obj);
        if selected_object == obj.id
            if isempty(selected_point)
                h = findobj(hAxes, 'Tag', num2str(obj.id));
                set(h, 'Selected', 'on', 'Color', [1 0 0]);
            else
                set(hp(selected_point), 'Selected', 'on', 'Color', [1 0 0]);   
            end
        end
    end


%% Function to select objects


    function set_selection(object_id, point_index)
       %fprintf(1, 'selected_object %i -> %i\n', selected_object, object_id);
       if ~isempty(selected_object)
           %h = findobj(hAxes, 'Tag', num2str(selected_object))
           h = findobj(hAxes, 'Selected', 'on');
           set(h, 'Selected', 'off', 'Color', [0 1 0]);
       end
       selected_object = object_id;
       selected_point = point_index;
       if ~isempty(selected_object)
           idx = object_index(selected_object);
           redraw_object(objects{idx});
       end
    end


    function select_next_object(point_index)
        ids = all_object_ids();
        if ~isempty(ids)
            if isempty(selected_object)
                idx = 1;
            else
                idx = find(ids > selected_object, 1, 'first');
                if isempty(idx)
                    idx = 1;
                end
            end
            set_selection(ids(idx), point_index);
        end
    end


    function select_next_item()
        if ~isempty(selected_object)
            if isempty(selected_point)
                select_next_object([]);
            else                
                ix = object_index(selected_object);
                if selected_point >= size(objects{ix}.points,1)
                    select_next_object(1);
                else
                    set_selection(selected_object, selected_point+1);
                end
            end
        else
            select_next_object([]);
        end
    end



    function toggle_selection_mode()
        if isempty(selected_object)
            if ~isempty(objects)
                set_selection(objects{1}.id, []);
            end
        elseif isempty(selected_point)
            set_selection(selected_object, 1);
        else
            set_selection(selected_object, []);
        end
    end


    function res = object_index(ids)
        res = [];
        for ix = 1 : length(objects)
            if any( objects{ix}.id == ids )
                res = cat(1, res, ix);
            end
        end
    end


    function delete_objects(ids)
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


    function ix = delete_point(id, pti)
        ix = object_index(id);
        nP = size(objects{ix}.points, 1);
        if pti <= nP
            if size(objects{ix}.points, 1) > 1
                objects{ix}.points(pti,:) = [];
            else
                delete_objects(id)
                ix = [];
            end
        end
    end


    function adjust_view(focus, z)
        w = 0.5 * ( size(pixels, 2) - 1 ) / z;
        h = 0.5 * ( size(pixels, 1) - 1 ) / z;
        roi = [focus(2)-w, focus(2)+w, focus(1)-h, focus(1)+h];
        axis(hAxes, roi);
        refresh(hFig);
    end


    function reset_view()
        roi = [1, size(pixels,2), 1, size(pixels,1)];
        axis(hAxes, roi);
        focusP = [ mean(roi(3:4)), mean(roi(1:2)) ];
        zoomF  = 1;
        refresh(hFig);
    end


end
