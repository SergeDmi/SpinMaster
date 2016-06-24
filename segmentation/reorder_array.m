function [ pts, odr ] = reorder_array( apoints )
%Orders an array of points by minimizing pt-pt distance between each time
% Ex : apoints =[1 1 ; 2 2] , [2 2 ; 1 1]
% Yields   pts =[1 1 ; 2 2] , [1 1 ; 2 2]
%          odr =[1 2 ; 2 1]
s=size(apoints);
if s(2)~=2
    error('Invalid points array');
end
if length(s)>2
    nt=s(3);
else
    nt=1;
end
n=s(1);
odr=zeros(n,nt);
pts=zeros(s);
if n==1 || nt==1
    pts=apoints;
    for t=1:nt
        odr(:,t)=1:n;
    end
else
    points_old=apoints(:,:,1);
    pts(:,:,1)=points_old;
    odr(:,1)=1:n;
    for t=2:nt
        points=apoints(:,:,t);
        [points_old,odr(:,t)]=reorder_points(points,points_old);
        pts(:,:,t)=points_old;
    end
end

end

