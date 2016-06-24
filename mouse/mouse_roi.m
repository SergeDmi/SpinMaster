function [ points, isrect ] = mouse_roi( im )

% function [ points, isrect ] = mouse_roi( im )
%
% let user define a polygon by clicks on a picture
% the polygon is closed by clicking the right button, or a keyboard
% F. Nedelec, nedelec@embl-heidelberg.de  last modified Dec. 2007


points = [];
isrect = 0;

if ( nargin > 0 )
    show_image(im);
end

savedpointer = get(gcf, 'pointer');
set(gcf, 'pointer', 'fullcrosshair');
set(gcf, 'units', 'pixels')

%%
n = 1;
while ( 1 )
    
    drawnow;
    k = waitforbuttonpress;
   
    %stop if key pressed or right mouse button:
    if k || strcmp( get( gcf, 'SelectionType' ) ,'alt' )
        if ( n > 1 ); points(n,1:2) = points(1,1:2); end
        break;
    end 
    
    p = get(gca,'CurrentPoint');       % button down detected
    p = p(1,[2,1]);                    % extract x and y
    
    if ( n == 1 )   %if first points is a drag --> we switch to rectangle
        finalrect = rbbox;               % drag a rectangle, return figure units
        if ( (finalrect(3) > 5) && (finalrect(4) > 5) ) % rectangle is not too small
            q = get(gca,'CurrentPoint');        % button up detected
            q = q(1,[2,1]);                    % extract x and y
            isrect = 1;
            points = corners( [ p q ] );
            for n=1:4
                plot( points(n:n+1,2), points(n:n+1,1) ); 
            end
            break;
        end
    end
        
   points(n,1:2) = p;
   if ( n > 1 )
       plot( points(n-1:n,2), points(n-1:n,1) ); 
   else
       plot( points(n,2), points(n,1), 'o' ); 
   end
   n = n + 1;
   
end

%% crop the points to the size of the rectangle:
xmax = floor( max( get( gca, 'XLim') ) );
ymax = floor( max( get( gca, 'YLim') ) );



if ( n > 1 )
    % at least one point has been clicked:
    plot( points([n-1 n],2), points([n-1 n],1) );
else
    % otherwise, the all picture is selected:
    points = corners( [1 1 ymax xmax ] );
end


for i=1:size(points,1)
    points(i,:) = max( points(i,:), [ 1 1 ] );
    points(i,:) = min( points(i,:), [ ymax xmax ] );
end

set( gcf, 'pointer', savedpointer );

end


%%
function pts = corners( rect )
pl  = [ min( rect(1), rect(3) ), min( rect(2), rect(4) ) ];
pr  = [ max( rect(1), rect(3) ), max( rect(2), rect(4) ) ];
pst = zeros(5,2);
pts(1,1:2) = pl;
pts(2,1:2) = [pr(1), pl(2)];
pts(3,1:2) = pr;
pts(4,1:2) = [pl(1), pr(2)];
pts(5,1:2) = pl;
end
