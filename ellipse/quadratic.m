function im = quadratic( rec, c, threshold )

% im = quadratic( rec, c, threshold )
%
% Calculates im(x,y) = a*x^2 + b*y^2 + c*x*y + d*x + e*y + f
% over the rectangular space specified in rec = [x_inf, y_inf, x_sup, y_sup]
% with parameters provided in c = [ a, b, c, d, e, f ]
%
% If the optional argument threshold is provided (for example =0),
% values below threshold are set to threshold
%
% F. Nedelec 

if numel(rec) == 4
    vx  = (rec(1):rec(3))';
    hy  =  rec(2):rec(4);
elseif numel(rec) == 2
    vx  = (1:rec(1))';
    hy  =  1:rec(2);
else
    error('First argument should specify a rectangle');
end

if numel(c) ~= 6
    error('Second argument should specify the 6 terms of a quadratic');
end

v1  = ones( size( vx ) );
h1  = ones( size( hy ) );

im = ( vx.^2 ) * ( c(1)*h1 ) + ( c(2)*v1 ) * ( hy.^2 ) + ( c(3)*vx ) * hy...
   + ( c(4)*vx ) * h1 + ( c(5)*v1 ) * hy + ( c(6)*v1 ) * h1;

if nargin > 2
   im = ( im > threshold ) .* ( im - threshold ) + threshold;
end

end

