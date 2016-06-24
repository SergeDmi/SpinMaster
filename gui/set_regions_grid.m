function regions = set_regions_grid(image, opt)

% spots = set_regions_grid( image )
%
% define a grid of rectangular regions
%
% F. Nedelec, Jan. 2008


%%

if nargin < 1  || isempty(image)
    error('You must provide an image');
end

show_image(image);

fprintf( 'Click the four corners clockwise, starting from the upper-left\n');
clk = mouse_points(4);


answer=inputdlg({'Number of dots horizontally', 'Number of dots vertically'},...
    'Input',2,{'9','9'});
hsize = str2double(answer{1});
vsize = str2double(answer{2});

%commandwindow;
%hsize = input('Number of dots horizontally ?');
%vsize = input('Number of dots vertically   ?');

% calculate the grid based on these corners:
xc = ( 0:hsize-1 )  / (hsize-1);
yc = ( 0:vsize-1 )' / (vsize-1);
array = zeros( vsize, hsize, 2 );

for d = 1:2
    array(:,:,d) = yc*xc * clk(3,d) +  (1-yc)*xc * clk(2,d) ...
        + yc*(1-xc) * clk(4,d) + (1-yc)*(1-xc) * clk(1,d);
end

spots = reshape( array, hsize*vsize, 2 );


%% Calculate the distance between the points
dia = min(sqrt( diff(spots(:,1)).^2 + diff(spots(:,2)).^2 ));

if nargin < 2
    opt.radius = round( dia / 2 );
else
    if 2*opt.radius > dia
        warning('The regions overlap');
    end
end

%% display positions for verification
plot( spots(:,2), spots(:,1), 'gx', 'MarkerSize', 12 );

regions = zeros( size(spots,1), 5 );
for n = 1:size(spots)
    rec = rectangle(spots(n,:), opt.radius);
    image_drawrect( rec, 'g-', sprintf(' %i', n));
    regions(n,1)   = n;
    regions(n,2:5) = rec;
end

%%

k = questdlg('Do you want to save the regions?', 'Confirm', 'Yes', 'No', 'Yes');
if  strcmp(k, 'Yes')
    save_regions(regions);
end

%%
function rect = rectangle(center,r)
    rect=[ center(1)-r, center(2)-r, center(1)+r, center(2)+r ];
end



end


