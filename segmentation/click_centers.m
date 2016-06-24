function click_centers(image,opt)
% [analysis] = time_analyze(opt)
% reads analysis files and compiles them
% S. Dmitrieff, March 2013



%if nargin==0
%    error('No folder name given');
%end

%if isinteger(fold) || isfloat(fold)
%    fold=num2str(fold);
%end

%% Building the arrays


filename='spindles.txt';
regfilename='regions.txt';
if nargin < 1  || isempty(image)
    image=load_image('kind','dna');
    if isempty(image)
        image=image_base();
    end
end


if nargin<2
    opt=spin_default_options;
elseif ~isfield(opt,'max_polarity');
    opt=spin_default_options;
end


dummy={};
if ~exist(filename,'file')
    save_objects(dummy,filename);
end



%edit_poles(image);
regions=load_objects(regfilename);
spindles=load_objects(filename);
n_reg=numel(regions);
n_spin=numel(spindles);

for n=1:n_reg
    region=regions{n};
    idx=index_by_info(num2str(region.id),spindles);
    if idx>0 && idx<=n_spin
        spindle=spindles{idx};
        spindle=click_one_spind(image,opt,region,spindle);
    else
        n_spin=n_spin+1;
        idx=n_spin;
        image
        opt
        region
        spindle=click_one_spind(image,opt,region,{});
        spindle.id=n;
        spindle.info=num2str(n);
    end
    spindles{idx}=spindle;
end
save_objects(spindles,filename);
    

edit_objects(image,{},'spindles.txt','star');


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
