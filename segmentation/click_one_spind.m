function [spindle] = click_one_spind(image,opt,region,spindle)
% spindle = click_one_spind(image,opt)
%
% cliking the poles of individual spindles
%
% S. Dmitrieff Nov 2012


%% Init.
filename='spindles.txt';
regfilename='regions.txt';

if nargin<3
    error('You must give a region to click ');
end

if  isempty(image)
    image=image_base();
end



if isfield(opt,'max_polarity');
    npmax=opt.max_polarity;
else
    defopt=spin_default_options;
    npmax=defopt.max_polarity;
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
   
if nargin<4
    spindles={};
end

if isempty(region) || ~isfield(region,'pts')
    error('Invalid region entry ');
elseif isempty(region.pts)
    error('No region coordinated ');
end
%% First import the regions

xmax=size(image,1);
ymax=size(image,2);


%% Cropping region and asking for coordinates
coords=region.pts;
center=[(coords(1)+coords(3))/2,(coords(4)+coords(2))/2];
pos_center=center - [coords(1),coords(2)];
if coords(1)<1
    pos_center(1)=pos_center(1)+coords(1)-1;
    coords(1)=1;
end
if coords(2)<1
    pos_center(2)=pos_center(2)+coords(2)-1;
    coords(2)=1;
end
coords(3)=min(coords(3),xmax);
coords(4)=min(coords(4),ymax);
im=image(coords(1):coords(3),coords(2):coords(4));
% Finding spindle
if ~isfield(spindle,'points')
    spindles={};
elseif ~isempty(spindle.points)
    nl=size(spindle.points,1);
    for i=1:nl
        spindle.points(i,:)=spindle.points(i,:)-[coords(1) coords(2)];
    end
    spindles={spindle};
else
    spindles={};
end
results={};
while numel(results)~=1
    results=edit_objects(im,spindles,[],'star');
end

spindle=results{1};


% Translate back points
if ~isempty(spindle.points)
    nl=size(spindle.points,1);
    for i=1:nl
        spindle.points(i,:)=spindle.points(i,:)+[coords(1) coords(2)];
    end
end




%Utilities
    function res = index_by_info(ids,objects)
        res=0;
        for ix = 1 : numel(objects)
            if isfield(objects{ix},'info');
                if strcmp(ids,objects{ix}.info)
                    res = ix;
                end
            end
        end
    end



end


