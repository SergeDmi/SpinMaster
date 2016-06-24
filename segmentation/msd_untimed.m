function [ MSD,MSDvar,bins,counts ] = msd_untimed( vals,mode )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin<1
    error('Not enough input data');
end
angular=0;
if nargin==2
    if strcmp(mode,'angular') || mode==1;
        angular=1;
    end
end
lp=length(vals);
cutoff=lp-1;
counts=zeros(1,cutoff);
MSD=zeros(1,cutoff);
MSDvar=zeros(1,cutoff);
bins=1:cutoff; 
for i=bins
    sd=vals(1:(lp-i)) - vals((1+i):lp) ;
    if angular
        sd=abs(sd);
        sd=min(abs(sd-2*pi),sd);
    end
    %MSD(i)=sum(sd.^2 )/(lp-i);
    MSD(i)=sum(sd.^2 );
    MSDvar(i)=sum(sd.^4);
    counts(i)=lp-i;
end

end

