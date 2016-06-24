function spindles=edit_pole(image,opt)

% spots = show_regions(kind)
%
% display the regions on the given image, or on the current image
%
% F. Nedelec, Jan. 2008

def=spin_default_options();
filename=def.poles_filename;
regions_filename='regions.txt';
npmax=def.max_polarity;
if ~nargin   || isempty(image)
    error('You must provide an image');
else
    if nargin==2
        if isfield(opt,'max_polarity');
            npmax=opt.max_polarity;
        end
        if isfield(opt,'poles_filename')
            filename=opt.poles_filename;
        end
        if isfield(opt,'regions_filename')
            regions_filename=opt.regions_filename;
        end
    end
    % compatibility with tiffread grayscale image
    if  isfield(image, 'data') 
        if ( length(image) > 1 ) 
            disp('show_image displaying picture 1 only');
        end
        image = image(1).data;
    end
    % compatibility with tiffread color image
    if  iscell(image)    
        tmp = image;
        image = zeros([size(tmp{1}), 3]);
        try
            for c = 1:numel(tmp)
                image(:,:,c) = tmp{c};
            end
        catch
            disp('show_image failed to assemble RGB image');
        end
        clear tmp;
    end
end

show_poles(opt);
spindles=load_spindles(filename);
regions=load_regions(regions_filename);
centers=region_centers(regions);
n_spin=numel(spindles);
n_reg =numel(regions);
i=input('Enter the number of the region to edit. \n >>>    ');
try
    if i<1 || i>n_reg; 
        error('You must provide a valid region number');
    end
catch
    error('You must provide a valid region number');
end
hFig = gcf;
close(hFig);

n=1;
while i~=spindles(n).id
    i=i+1;
    if i>n_spin
        spinles(n).id=i;
    end
end

xmax=size(image,1);
ymax=size(image,2);
coords=regions(i,2:5);
center=centers(i);

coords=max(coords,1);
coords(3)=min(coords(3),xmax);
coords(4)=min(coords(4),ymax);

im=image(coords(1):coords(3),coords(2):coords(4));
[points,state ]=spin_click_region(im,npmax,center,i);
correction=[];
for i=1:state
    correction=[correction ; [coords(1) coords(2)]]; %#ok<AGROW>
end
spindles(n).pts=points+correction;       
save_objects(spindles,filename);

end
