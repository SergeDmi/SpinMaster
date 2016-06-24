function c = fit_quadratic( im, w )

% c = fit_quadratic( im, mask )
%
% calculate the coefficients of the best fit for im,
% by  fit(x,y) = a*x^2 + b*y^2 + c*x*y + d*x + e*y + f
% returns c = [ a, b, c, d, e, f ]
%
% optional argument mask specifies the pixels that should be used for the fit
% 
% F. Nedelec


if  nargin < 2
    % by default, use all pixels
    w = ones(size(im));
end


%horizontal/vertical lines:
hx    = 1:size(im,1);
hxx   = hx .^ 2;
hxxx  = hxx .* hx ;
hxxxx = hxx .* hxx;

vy    = (1:size(im,2))';
vyy   = vy .^ 2;
vyyy  = vyy .* vy;
vyyyy = vyy .* vyy;

%sums of pixels coordinates:
s1     = sum( sum( w ));

sx     = sum( hx * w );
sy     = sum( w * vy );

sxx    = sum( hxx * w );
sxy    = hx * w * vy;
syy    = sum( w * vyy );

sxxx   = sum( hxxx * w );
sxxy   = hxx * w * vy;
sxyy   = hx * w * vyy;
syyy   = sum( w * vyyy );

sxxxx  = sum( hxxxx * w );
sxxxy  = hxxx * w * vy;
sxxyy  = hxx * w * vyy;
sxyyy  = hx * w * vyyy;
syyyy  = sum( w * vyyyy );



% sums of pixels values:
if ( isfield(im, 'data') ) 
    im = double( im.data );         
end
imw    = im .* double(w);

szxx   = sum( hxx * imw );
szyy   = sum( imw * vyy );
szxy   = hx * imw * vy;
szx    = sum( hx * imw );
szy    = sum( imw * vy );
sz     = sum(sum( imw ));


%matrix 
S = [ sxxxx, sxxyy, sxxxy, sxxx, sxxy, sxx;...
      sxxyy, syyyy, sxyyy, sxyy, syyy, syy;...
      sxxxy, sxyyy, sxxyy, sxxy, sxyy, sxy;...
      sxxx,  sxyy,  sxxy,  sxx,  sxy,  sx;...
      sxxy,  syyy,  sxyy,  sxy,  syy,  sy;...
      sxx,   syy,   sxy,   sx,   sy,   s1];


%invert the matrix to get the best fit:
c = ( inv(S) * [ szxx, szyy, szxy, szx, szy, sz ]' )';

end
   