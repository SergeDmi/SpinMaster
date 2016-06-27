%% User manual for SpinMaster
% 1 - Use startup.m to add the scripts to the Matlab path
%     Run matned/spindles/spin_master_poles
% 2 - Go to the folder where the stacks are stored (as an image *.tif)
%     This folder should also contain an image for DNA (reference image)
% 3 - Click "Create list" to generate a list of images from the stack
%     Click "Select base" to select the DNA image
% 4 - Click "Set regions" and follow instructions
% 4 bis : Click "Edit regions" to correct auto-generated regions        (*)
% 5 - Click "Set poles" to create generate spindle centers in each region 
% 5 bis : Edit the centers (by moving them when clicking "Edit poles")  (*)
% 6 - Click "Make folders" to generate one folder per time point
% 7 - Click "Click all" to click all spindle poles at all times
% 7 alt. type click_folder(n) to click the spindles at time n           (*)
% 8 - Click "Analyze"
%
%% (*) How to use the object editor :
%
% * Press enter to jump from one point to the next
% * Press "*" to switch between object selection and point selection
% * Use arrows to move point/object (shift+arrows to move faster)
% * Use left click to add an object
% * Use shift + left click to add a point to selected object 
% (if a point is selected, shit+left click will add a point to the object
%  parent to the selected point)
% * Use the pop-up menu to save/quit/erase
% * Use "Esc" to save+quit 