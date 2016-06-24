function [spindles] = edit_poles(image,opt)
% poles = edit_poles(image,opt)
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
    image=image_base();
end

if nargin<2
    opt=spin_default_options;
elseif ~isfield(opt,'max_polarity');
    opt=spin_default_options;
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
   

%% First import the regions

regions=load_objects(regfilename);
n_reg=size(regions,1);
%Create a structure type to store region state, center, number of poles
spindles=load_objects(filename);
n_spin=numel(spindles);


%% Then plot each region and ask for coordinates
for n=1:n_reg
    region=regions{n};
    idx=index_by_info(num2str(region.id),spindles);
    if idx>0 && idx<=n_spin
        spindle=spindles{idx};
    else
        n_spin=n_spin+1;
        idx=n_spin;
        spindle.points=[];
        spindle.id=n;
        spindle.info=num2str(n);
    end
    spindle=click_one_spind(image,opt,region,spindle);
    spindles{idx}=spindle;
end
save_objects(spindles,filename);







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


