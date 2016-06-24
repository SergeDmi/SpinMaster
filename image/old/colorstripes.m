function cmap = colorstripes( n )


cmap = zeros( 256, 3 );

colors = [ 1 1 1; 0 0 1; 0 1 0; 1 0 0];
sc = size( colors, 1);

for i=1:256
   
   c = mod( floor(i*n/255), sc ) + 1;
   cmap( i, : ) = colors( c, : );
   
end
   
colormap( cmap );

