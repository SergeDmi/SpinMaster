function hImage = show_stack( stack )

% function show_stack( mov )
%
% Display movie frames with a slider and autoscaling
%
% F. Nedelec, Jan 2009 - Nov 2012

figName = 'Stack';

if isfield(stack, 'kind')
    figName = stack(1).kind;
elseif isfield(stack, 'file_name')
    figName = stack(1).file_name;
end

indx = 1;

%% display first image:

hImage = show_image(stack, 'Index', indx);
set(hImage, 'EraseMode', 'none');

hFig = gcf;
fPos = get(hFig, 'Position');

%extend figure vertically to make space for slider:
set(hFig,  'Position', fPos + [0 0 0 30], 'Name', figName);

% shift image upward
%set(gca, 'Units', 'pixels', 'Position', [100 0 fPos(3:4)]);

set(hFig,  'KeyPressFcn',           {@callback_key_down});


hSlider = [];

if ( length(stack) > 1 )
    
    hSlider = uicontrol(hFig, 'Style', 'slider',...
        'Position',[ 20 0 fPos(3)-50 22 ],...
        'Min', 1, 'Max', length(stack), 'Value', 1,...
        'SliderStep', [ 1/length(stack), 1/length(stack) ],...
        'Callback',{@callback_slider});
    
    handle.listener(hSlider, 'ActionEvent', @callback_slider);

end

hTimer = timer('TimerFcn', {@callback_timer}, 'Period', 0.1, 'ExecutionMode', 'fixedSpacing');

refresh(hFig);

    function update_image(i)
        if 0 < i  &&  i <= length(stack)
            indx = i;
            show_image(stack, 'Index', indx, 'Handle', hImage);
            set(hFig, 'Name', sprintf('Image %i', indx));
            refresh(hFig);
        end
    end


    function set_image(i)
        if ~isempty(hSlider)
            set(hSlider, 'Value', i);
        end
        update_image(i);
   end
 

    function callback_timer(hObject, eventData)
        if indx < length(stack)
            set_image(indx+1);
        else
            stop(hTimer);
        end
    end


    function callback_slider(hObject, eventData)
        if ~ isempty(hSlider)
            i = round( get(hSlider, 'Value') );
        else
            i = 1;
        end
        if i ~= indx
            update_image(i);
        end
    end


    function callback_key_down(hObject, eventData)
        if eventData.Character == 'z'
            set_image(1);
        elseif eventData.Character == ' '
            if strcmp(get(hTimer, 'Running'), 'on')
                stop(hTimer);
            else
                if indx == length(stack)
                    set_image(1);
                end
                start(hTimer);
            end
        elseif strcmp(eventData.Key, 'leftarrow')
            if 1 < indx
                set_image(indx-1);
            end
        elseif strcmp(eventData.Key, 'rightarrow')
            if indx < length(stack)
                set_image(indx+1);
            end
        end
    end

end

