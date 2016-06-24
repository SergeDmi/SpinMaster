function [ arr,count ] = bin_fourier_modes( Af,ntmax)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
nv=numel(Af);
count=zeros(1,ntmax);
arr=zeros(2,ntmax);
arr(2,:)=1:ntmax;
for i=1:nv
    af=Af{i};
    T=ceil(1./af(2,:));
    arr(1,T)=arr(1,T)+af(1,:);
    count(1,T)=count(1,T)+1;
end
arr(1,:)=arr(1,:)./count; 
end

