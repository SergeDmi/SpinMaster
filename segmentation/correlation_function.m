function [ G ] = correlation_function( data , cutoff )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
lp= length(data);

if cutoff>lp
    cutoff=lp-1;
else
    cutoff=floor(cutoff);
end
G=zeros(1,cutoff);
data=data-mean(data);
for i=1:cutoff
    G(i)=sum( data(1:(lp-i)).*data((1+i):lp))/(lp-i);
end

end

