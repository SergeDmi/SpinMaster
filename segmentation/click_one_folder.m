function click_one_folder(fold)
% [analysis] = time_analyze(opt)
% reads analysis files and compiles them
% S. Dmitrieff, March 2013



if nargin==0
    error('No folder name given');
end

if isinteger(fold)
    fold=num2str(fold);
end

%% Building the arrays

cd(fold);
image=load_image('kind','tub');
edit_poles(image);
cd '..';





end
