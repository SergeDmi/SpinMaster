function [spindles,counts] = spin_save_clicks(image,npmax)

% poles = spin_save_clicks(image)
%
% use regions on the image to get the poles in each region clicked
% %npmax : maximum number of poles to be considered
% %any higher polarity can be stored under npmax too.
%


% S. Dmitrieff Nov 2012

if nargin < 1  || isempty(image)
    error('You must provide an image');
else
    if nargin<2
        npmax=4;
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

regions=load_regions();
n_reg=size(regions,1);
%Create a structure type to store region state, center, number of poles
spindles=struct('state',-1,'center',[],'poles',[]);
spindles(n_reg).state=-1;
counts=cell(1,npmax+2); % Saves the regions in each state ; redundant but allows faster access


    

%% Then plot each region and ask for coordinates
for n=1:n_reg
    coords=regions(n,2:5);
    spindles(n).center=[(coords(1)+coords(3))/2,(coords(4)+coords(2))/2];
    coords=max(coords,1);
    im=image(coords(1):coords(3),coords(2):coords(4));
    [points,state ]=spin_click_region(im,npmax);
    spindles(n).state=state;
    counts{state+2}=[counts{state+2} n];
    correction=[];
    for i=1:state
        correction=[correction ; [coords(1) coords(3)]]; %#ok<AGROW>
    end
    spindles(n).poles=points+correction;
end
   
save_spindles(spindles);
%% 




end


