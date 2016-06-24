function [ pts, odr ] = reorder_points( points, oldpoints )
%Orders an array of point by minimizing the distance with another array
%   The distance is the sum of the squarred norms
S=size(points);
if S~=size(oldpoints)
    error('Non matching arrays');
end
n=S(1);
p=perms(1:n)';
np=size(p,2);
dist=zeros(1,np);
for i=1:np
    d=points(p(:,i),:)-oldpoints(:,:);
    dist(i)=sum(sum(d.^2));
end
[~,i]=min(dist);
odr=p(:,i);
pts=points(odr,:);
end

