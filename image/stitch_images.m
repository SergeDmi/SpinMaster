function stitch_images()
% Stiches image of similar type together
% Assumes images to be of the same size
% assume images in image list to be grouped by kind
rehash;
fname='stiched_image';
list = image_list;
base = list(1);
image = spin_load_pixels(base);
si=size(image.data);
kind=image.kind;
nim=numel(list)/2;
lx=si(1);
ly=si(2);
[ny,nx]=guess_best_shape(nim);
IMdna=zeros(nx*lx,ly*ny);
IMtub=zeros(nx*lx,ly*ny);
i=1;
j=1;
for k=1:nim
    if kind=='tub'
        baseT = list(k);
        baseD = list(nim+k);
    else
        baseT = list(nim+k);
        baseD = list(k);
    end
    imageT = spin_load_pixels(baseT);
    IMtub(lx*(i-1)+1:lx*i,ly*(j-1)+1:ly*j)=imageT.data;       
    imageD = spin_load_pixels(baseD);
    IMdna(lx*(i-1)+1:lx*i,ly*(j-1)+1:ly*j)=imageD.data;
    
    if i<nx
        i=i+1;
    else
        i=1;
        j=j+1;
    end
end
BIMtub=mat2gray(IMtub);
imwrite(BIMtub,[fname '_tub.tif'],'Compression','none');
BIMdna=mat2gray(IMdna);
imwrite(BIMdna,[fname '_dna.tif'],'Compression','none');
make_image_list();
edit image_list.m;
edit image_base.m;

rehash;
end

function [nx,ny]=guess_best_shape(nim)
n=sqrt(nim);
if n==floor(n)
    nx=n;ny=n;
elseif ~isprime(nim)
    nx=ceil(n);
    ny=ceil(nim/nx);
    while nx*ny~=nim
        nx=nx+1;
        ny=ceil(nim/nx); 
    end
else
    nx=ceil(n);
    NX=[nx:nx+floor(nx/4)];
    NY=ceil(nim./NX);
    [~,ix]=min(NX.*NY);
    nx=NX(ix);
    ny=NY(ix);
end
end