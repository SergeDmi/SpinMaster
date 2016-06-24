function show_objects(im, objects, color, mode)

% Display objects on image
%
% Syntax:
%     show_objects(im, objects, color, rectangle_mode)
%     show_objects(im, objects, color, rectangle_mode)
%     show_objects(im, file_name)
%
% If ( im == [] ) objects will be drawn on the current axes.
% If 'objects' is a file name, the objects will be loaded from this file.
%
% See also
%    save_objects, load_objects and edit_objects
%
% F. Nedelec, Feb. 2009 - Nov 2012
%
%

if nargin < 1
    error('First argument must be an image or empty');
end

if nargin < 2
    error('Second argument must be objects or filename');
end

if nargin < 3
    color = 'g';
else
    if ~ischar(color)
        error('wrong 3rd argument (color)');
    end
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


%% load from file if necessary

if ischar(objects)
    objects = load_objects(objects);
end

%% display

if ~ isempty(im)
    show(im);
end

% draw objects on top of image
for o = 1:length(objects)
    draw_object(objects{o});
end
drawnow;

%% Sub-functions


    function hp = draw_object(obj)

        pN = size(obj.points, 1);
        if pN >= 1
            pX = obj.points(:,1);
            pY = obj.points(:,2);
            
            spec.Color = color;
            spec.LineWidth = 2;
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


end
