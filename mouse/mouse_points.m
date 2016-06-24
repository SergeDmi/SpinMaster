function points = mouse_points( max, im )


% function points = mouse_points( number, image )
%
% collect and return "number" clicks on the image
% number is 1 by default
%
% F. Nedelec

if nargin < 1
    max = 1;
end
if nargin > 1 
    show_image(im);
end

hFig = gcf;

%find axes object
h = findobj(get(hFig, 'Children'), 'Type', 'axes');
if ~isempty(h)
    hAxes = h(1);
end

points=[];

%prepare for mouse click:
pointer = get(hFig, 'pointer');
set(hFig, 'pointer', 'fullcrosshair');
set(hFig, 'units', 'pixels');

n = 1;
while n <= max
    
    if waitforbuttonpress
        if gcf == hFig
            %keyboard pressed
            k = get(hFig, 'CurrentCharacter');
            if k == 'r'
                %reset all points
                n = 1;
                points=[];
                %delete text:
                delete( findobj(get(hFig, 'Children'), 'Type', 'text') );
            else
                break
            end
        end
    else
        if gcf == hFig
            %right mouse button:
            if strcmp( get(hFig, 'SelectionType') ,'alt' )
                break
            end
            % mouse button down detected
            P = get(hAxes,'CurrentPoint');
            P = P(1,[2,1]);        % swap x and y
            %plot( P(2), P(1), 'go' );
            text( P(2), P(1), sprintf('%i',n), 'Color', 'g', 'FontSize', 14);
            points(n, [1,2]) = P;
            n = n + 1;
        end
    end
   
end

set(hFig, 'pointer', pointer);

end

