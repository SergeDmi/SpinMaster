function res = object_length(objects)

% return the length of given objects, which the sum of the length of their
% segments
%
%
%
% F. Nedelec, Dec. 2012

res = [];

nbo = size(objects, 1);

for i = 1:nbo
   
    d = diff(objects{i}.points, 1, 1);
    l = sqrt( d(:,1).^2 + d(:,2).^2 );
    res = cat(1, res, sum(l));
    
end
