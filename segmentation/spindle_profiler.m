function [profiles] = analyze_intens_onespind( points , image  )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
if nargin<1
    error('No arguments given');
elseif    nargin<1 || isempty(image)
    error('You must provide an image');
end
Sc=size(points);
if Sc(2)~=2
    error('Wrong points array size');
end
ns=Sc(1)-1;
% Image size
sI=size(image);
Nx=sI(1);
Ny=sI(2);
% Finding the distances from point to segment
[Distsegs,Proj]=dist_abs_segments(sI,points);
Distsegs=round(Distsegs);
% Correct image bg, make image double
minim=min(min(image));
dimage=double(image-minim);
% Now computing the interesting information
wheight=zeros(Nx,Ny,ns);
win=zeros(Nx,Ny,ns);
normD=abs(Distsegs);
mindist=min(normD,[],3);
% Finding which segment contributes to each pixel (may be contribtd twice)
for i=1:ns
    %wheight(:,:,i)= (normD(:,:,i)==mindist).*(Proj(:,:,i)>0);
    wheight(:,:,i)= (normD(:,:,i)==mindist) ;
    win(:,:,i)=wheight(:,:,i).*dimage;
end
normD=normD.*wheight;
profiles=cell(1,ns);
for i=1:ns
    md=max(max(normD(:,:,i)));
    intens=zeros(1,2*md+1);
    for l=-md:md
        isd=(Distsegs(:,:,i)==l);
        intens(1,md+l+1)=sum(sum(isd.*win(:,:,i),1),2)./max(sum(sum(isd,1),2),1);
    end
    profiles{i}=intens;
end
end

