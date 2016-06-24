function [ MSD,MSDerr,bins,counts ] = msd_timed( vals,times,mode )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
lp= length(vals);
if nargin<2
    error('Not enough input data');
end
if nargin<3
    angular=0;
elseif strcmp(mode,'angular') || mode==1;
    angular=1;
end
if lp~=length(times)
    error('Values and times must have the same size');
end
tmax=max(times);
tmin=min(times);
DT=tmax-tmin;
go_full=1;
if lp==DT+1
    cutoff=lp-1;
    counts=zeros(1,cutoff);
    MSD=zeros(1,cutoff);
    MSDerr=zeros(1,cutoff);
    if length(times)==length(tmin:tmax)
        if sum((times'-(tmin:tmax)).^2)==0
            %print 'clean'
            for i=1:cutoff
                if angular
                    sd=abs(vals(1:(lp-i)) - vals((1+i):lp) );
                    sd=min(abs(sd-2*pi),sd).^2; 
                    MSD(i)=sum( sd );
                    MSDerr(i)=sum( (vals(1:(lp-i)) - vals((1+i):lp) ).^4 );
                else
                    MSD(i)=sum( (vals(1:(lp-i)) - vals((1+i):lp) ).^2 );
                    MSDerr(i)=sum( (vals(1:(lp-i)) - vals((1+i):lp) ).^4 );
                end
                counts(i)=lp-i;
            end
            go_full=0;
            bins=1:cutoff;
        end
    end
end
if go_full==1
    bins=1:DT;
    cutoff=length(bins);
    counts=zeros(1,cutoff);
    MSD=zeros(1,cutoff);
    MSDerr=zeros(1,cutoff);
    sd=zeros(cutoff,lp-1);
    dd=zeros(cutoff,lp-1);
    for i=1:lp-1
        n=lp-i;
        if angular
            sd(i,1:n)=abs(vals(1:(lp-i)) - vals((1+i):lp) ) ;
            sd(i,1:n)=min(abs(sd(i,1:n)-2*pi),sd(i,1:n)).^2; 
        else
            sd(i,1:n)=(vals(1:(lp-i)) - vals((1+i):lp) ).^2 ;
        end
        dd(i,1:n)= times((1+i):lp) - times(1:(lp-i));
    end
    %ison=true(cutoff,lp-1);
    for i=1:cutoff
        
        ison=logical( dd == bins(i) ); %*temp
        %ison(:,:)= dd == bins(i) ; %*temp
        counts(i)=sum(sum(ison));
        %MSD(i)=sum(sum(sd(ison)))/max(1,counts(i));
        MSD(i)=sum(sum(sd(ison)));
        %MSDerr(i)=sqrt(sum(sum(sd(ison).^2))/max(1,counts(i))-MSD(i)^2);
        MSDerr(i)=sum(sum(sd(ison).^2));
        %MSD(i)=mean(mean(sd(logical(dd==bins(i)))));
        
    end
end
%counts=min(1,counts);
end

