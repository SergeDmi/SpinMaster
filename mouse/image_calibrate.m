function umperpixel = image_calibrate( filename );

% calibrate from a picture of a calibration slide,
% by clicking on two points, and asking the user for the real distance
% F. Nedelec, last modified July 30 / 2002

if ( nargin == 0 )
    [filename, pathname] = uigetfile('*.tif;*.stk', 'select image file');
    filename = [pathname, filename];
end

if ischar( filename )
    im = tiffread( filename );
else
    im = filename;
    filename = 'file not specified';
end

fig = show_image( im );
drawnow;

figure( fig );
P = ginput(2);

pixeldistance = sqrt( ( P(1,1) - P(2,1) ).^2 + ( P(1,2) - P(2,2) ).^2 );

realdistance = input('Enter real distance in micro-meters : ');

micrometer_per_pixel = realdistance / pixeldistance;

%calculate an error estimate, assuming a one pixel offset error on each click ( a minimum ! ):
perturbed_value = realdistance / ( pixeldistance - 2 );
error_on_value = abs( micrometer_per_pixel - perturbed_value );


fprintf( 'one pixel = %.4f +/- %.4f micro-meters', micrometer_per_pixel, error_on_value);

end

