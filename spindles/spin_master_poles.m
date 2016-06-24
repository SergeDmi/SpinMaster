function spin_master

% Open a dialog to easily start the macros used to analyse
% spindle morphologies
%
%
% F. Nedelec, Feb., March 2008 - August 2010 - 2012


%default options:
opt = spin_default_options;

%size of the buttons
bwidth   = 120;
bheight  = 38;
FontSize = 12;

%number of buttons
nButtons = [ 8, 4 ];

sFig = [200 200 nButtons(2)*bwidth+16 nButtons(1)*(bheight+5)+20];

%pick a random color
color = rand(1,3);
while sum(color) < 1
    color = rand(1,3);
end

rehash;

%make figure
hFig = figure('Position', sFig,...
    'Name', 'Spin-Master', 'MenuBar', 'none', 'Resize', 'off', ...
    'NumberTitle', 'off', 'NextPlot', 'new',...
    'HandleVisibility', 'callback', 'Color', color);


%% the 'Close' button
h = button(9,1, 'Close All', @callback_close);
set(h, 'Tag', 'close-button');
%%Other topside buttons
button(9,2, 'Stitch images',  'stitch_images();');
button(9,3, 'Localize Options',  'copyfile(which(''spin_default_options.m''), ''spin_options.m'');');
button(9,4, 'Edit Options',  'edit spin_options.m;');

%% create buttons, and define the associated actions:
button(7,1, 'Show Images',  'spin_show_images(opt);');
button(6,1, 'Select Base',  'edit image_base.m;');
button(5,1, 'Create List',  'make_image_list;');
button(4,1, 'Edit List',    'edit image_list.m;');


button(7,2, 'Show Regions', 'show_regions(image_base, load_regions);');
button(6,2, 'Set Regions',  'set_regions_grid(image_base, opt);');
button(5,2, 'Edit Regions', 'edit_regions(image_base);');
button(4,2, 'Make folders', 'make_time_folders(opt);');


button(5,3, 'Set Poles',        'set_centers(image_base,opt);');
button(4,3, 'Edit poles',        'edit_objects(image_base(),[],''spindles.txt'',2);');

button(5,4, 'Click All',        'click_folders(opt);');
button(4,4, 'Analyze',    'analyze_spindles(image_base,[],opt);');



button(2,1, 'Measure DNA',  'spin_measure_dna(opt);');
button(2,2, 'Measure Mass', 'spin_measure(''mass'', opt);');
button(2,3, 'Measure Area', 'spin_measure_area(opt);');
button(2,4, 'Plot Mass',    'spin_plot_mass(opt);');

button(1,1, 'Count Beads',  'spin_measure(''beads'', opt);');
button(1,2, 'Plot Beads',   'spin_plot_beads(opt);');
button(1,3, 'Plot Calib.',  'spin_calibrated_dna(''DNA fluorescence'', 1);');
button(1,4, 'Export Mass',  'spin_export_mass(opt);');


drawnow

%% function to make buttons:

    function h = button(i, j, name, action)
        h = uicontrol(hFig, 'Style', 'pushbutton',...
            'Position',[ 8+bwidth*(j-1) 8+bheight*(i-1) bwidth bheight ],...
            'String', name, 'FontSize', FontSize);
        if ischar(action)
            set(h, 'Callback', {@callback, action});
        else
            set(h, 'Callback',action);
        end

        if strncmp(name, 'Plot', 4)  ||  strncmp(name, 'Show', 4)
            set(h, 'ForegroundColor', [0 0 1]);
        end
    end


%% Callbacks

    function callback_close(hObject, eventdata)
        if strcmp(get(hObject, 'String'), 'Close All')
            figs = setdiff( get(0,'Children'), hFig );
            delete(figs);
        end
        set_state(1);
    end


    function callback(hObject, eventdata, action)
        set_state(0);
        opt = spin_load_options;
        %commandwindow;
        try
            eval(action);
        catch ME
            if opt.catch_exceptions
                fprintf(2, 'xxxxxxxxxxxxxxxxxxxxx Error xxxxxxxxxxxxxxxxxxxx\n');
                fprintf(2, 'Function %s\n', ME.stack(1).name);
                fprintf(2, 'File %s\n', ME.stack(1).file);
                disp(ME.message);
                fprintf(2, '------------------------------------------------\n');
            else
                rethrow(ME);
            end
        end
        set_state(1);
    end


    function set_state(state)
        hlist = findobj(get(hFig, 'Children'), 'Type', 'uicontrol');
        
        for ii = 1:size(hlist,1)
            h = hlist(ii);
            if strcmp(get(h, 'Tag'), 'close-button')
                if state
                    set(h, 'String', 'Close All');
                else
                    set(h, 'String', 'Reset');
                end
            else
                if state
                    set(h, 'Enable', 'on');
                else
                    set(h, 'Enable', 'off');
                end
            end
        end
        
        refresh(hFig);
    end

end


