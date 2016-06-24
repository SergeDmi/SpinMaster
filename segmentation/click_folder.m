function click_folder(fold,kind,opt)
% [analysis] = time_analyze(opt)
% reads analysis files and compiles them
% S. Dmitrieff, March 2013



if nargin==0
    error('No folder name given');
end

if isinteger(fold) || isfloat(fold)
    fold=num2str(fold);
end

if nargin<2
    kind='tub';
elseif ~isfloat(kind)
    kind='tub';
end

if nargin<3
    opt=spin_default_options;
elseif ~isfield(opt,'max_polarity');
    opt=spin_default_options;
end


%% Building the arrays

cd(fold);
image=load_image('kind','tub');
if isempty(image)
    image=image_base();
end
edit_poles(image);


%edit_objects(image,{},'spindles.txt','star');
cd '..';





end
