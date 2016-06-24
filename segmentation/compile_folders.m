function [analysis] = compile_folders(tiling,opt)
% [analysis,profiles] = analyze_spindles(image, opt, tiling)
% Triggers analysis of spindle contours or backbones (according to opt)
% Tiling contains the tiling of the image (used for background removal)
% S. Dmitrieff, March 2013

if nargin==0
    tiling=[];
    opt=spin_default_options();
elseif nargin < 2
    opt=spin_default_options();
end



if isempty(tiling)
    answer=inputdlg({'Number of images horizontally', 'Number of images vertically'},...
        'Input',2,{'3','3'});
    vsize = str2double(answer{1});
    hsize = str2double(answer{2});
else
    vsize=tiling(1);
    hsize=tiling(2);
end 


try load('times.mat','listind');
catch
    error('Could not load times.mat');
end

for i=listind(1,:)
    if i>0
        fold_name=num2str(i);
        cd(fold_name);
        image=load_image('kind','tub');
        analyze_backbones(image,[vsize hsize],opt);
        cd '..';
    end
end


end
