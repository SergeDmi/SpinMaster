function [spindles] = spin_click_poles(image,opt)
% Spin_click_poles is depreciated, use edit_poles instead.
% poles = spin_save_clicks(image)
%
% use regions on the image to get the poles in each region clicked
% %npmax : maximum number of poles to be considered
% %any higher polarity can be stored under npmax too.
%
% S. Dmitrieff Nov 2012


%% Init.
filename='spindles.txt';
regfilename='regions.txt';
if nargin < 1  || isempty(image)
    error('You must provide an image');
else
    if nargin<2
        defopt=spin_default_options;
        npmax=defopt.max_polarity;
    else
        if isfield(opt,'max_polarity');
            npmax=opt.max_polarity;
        else
            defopt=spin_default_options;
            npmax=defopt.max_polarity;
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

%% First import the regions

regions=load_objects(regfilename);
n_reg=size(regions,1);
%Create a structure type to store region state, center, number of poles
spindles=load_objects(filename);
xmax=size(image,1);
ymax=size(image,2);


%% User guide:
disp('Press: "c" to redo the click');
disp('       "d" to discard this spot');
disp('       "space" to end this spot');
disp(['Only the first ', num2str(npmax), ' clicks will be saved']);

%% Then plot each region and ask for coordinates
for n=1:n_reg
    coords=regions(n,2:5);
    
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
    [points,state ]=spin_click_region(im,npmax,pos_center,n);
    spindle.id=n;
    if state>0
        correction=ones(state,1)*coords(1:2);
        points=points+correction;
    end
	spindle.points=points;
    spindles=cat(2,spindles,spindle);
end
save_objects(spindles,'spindles.txt');
end


