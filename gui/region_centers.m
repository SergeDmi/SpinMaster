function [ centers ] = region_centers( regions )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin<1
    error('No regions provided ');
end

n_reg=size(regions,1);
centers=zeros(n_reg,2);
for n=1:n_reg
    coords=regions(n,2:5);
    centers(n,:)=[(coords(1)+coords(3))/2,(coords(4)+coords(2))/2];
end

end

