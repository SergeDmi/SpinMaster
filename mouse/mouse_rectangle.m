function rect = mouse_rectangle()

% function rect = mouse_rectangle
% function rect = mouse_rectangle( rect_size )
% 
% return a rectangular selection performed by the user with the mouse
% In the second form, the width and height of the rectangle is imposed
%
% nedelec@embl-heidelberg.de,   Feb. 2008, October 2008

if nargin > 0
    error('Does not accept arguments');
end

%% Check that we have a figure:

hFig = get(0,'CurrentFigure');

if isempty(hFig)
    error('Could not associate with an existing image/figure');
end

hAxes = get(hFig,'CurrentAxes');

if isempty(hAxes)
    error('Could not find axes');
end

axes(hAxes);

%% Get rectangular selection

    function m = current_point()
        P = get(hAxes, 'CurrentPoint');
        m = P(1,1:2);
    end


k = waitforbuttonpress;

if k == 0
    point1 = current_point;     % button down detected
    rbbox;                      % return figure units (not usable)
    point2 = current_point;     % button up detected
    
    lower  = min(point1, point2);
    upper  = max(point1, point2);
    rect = [ lower(2), lower(1), upper(2), upper(1) ];
else
    rect = [];
end


end