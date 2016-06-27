function click_folders(opt)
% click_folders(opt)
% Allows user to click all poles in all folders
% S. Dmitrieff, March 2013


if nargin==0
    opt=spin_default_options();
elseif isempty(opt)
    opt=spin_default_options();
end

%% Building the arrays

try load('times.mat','listind');
    for i=listind(1,:)
        if i>0
            fold_name=num2str(i);
            click_folder(fold_name);
        end
    end
catch
    image=load_image('kind','tub');
    edit_poles(image);
end





end
