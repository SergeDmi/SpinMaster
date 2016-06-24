function [ seglen ] = segments_lengths(points)
% Returns signed dist and projections of points in image to segments
%   Sim  stores the dimension of the image and segments contains ns
%   segments.
%   Returns Da, the Sim(1)*Sim(2)*ns array of distances and Pa, the array
%   of the projections of all points on all the segment.
%   If the projection is outside the segment, gives the minimal distance
%   to a segment end (A or B).

if nargin<1
    error('Not enough arguments');
end
Sp=size(points);
if Sp(2)~=2
    error('Wrong segment array size');
elseif Sp(1)<2;
    error('Not enough points to make segments');
end
seglen=zeros(1,Sp(1)-1);
for i=1:Sp(1)-1
    seglen(i)=norm(points(i,:)-points(i+1,:));
end

end

