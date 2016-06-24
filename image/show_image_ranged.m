function [ hImage, mag, scaled ] = show_image( im, varargin )

% function [ hImage, magnification, pixels ] = show_image_ranged ( im, ... )
%
% Display picture "im" in 16-bit gray levels.
% - The image is displayed in a new figure, unless a handle to a figure, axes,
%   or to an image object is provided, in which case the image is displayed
%   in these axes/figure/image.
% - The color range is set automatically, unless it is specified as [ c_min, c_max ]
% - The image is displayed so as to fit in the screen, unless a magnification
%   is specified in 2 consecutive arguments as ( 'magnification', value )
%
% Color images can be specified as cells with 'red', 'green' and 'blue' components,
% or as a single matrix im(1:h, 1:w, 1:3) containing the red, green and blue
% panels of size h=heigth x w=width.
%
% show_image(...) returns a handle to the matlab image object, the
% magnification, and the scaled pixel values. The handle can be returned in
% a subsequent call to change the displayed image.
%
% show_image_ranged() add the possibility of displaying only a fraction of
% the image by giving the corners xmin,ymin (top left) and xmax ymax
% (bottom right).
% In the arguments, this writes
% (...,'xmin',xmin,'ymin',ymin,'xmax',xmax,'ymax',ymax,...)
%
% F. Nedelec, 2004-2008. This version : S. Dmitrieff, Nov 2012


figname    = inputname(1);

%% compatibility with tiffread grayscale image
if  isfield(im, 'data') 
    if isfield(im, 'filename')
        figname = im.filename;
    end
    if ( length(im) > 1 ) 
        disp('show_image displaying picture 1 only');
    end
    im = im(1).data;
end

%% compatibility with tiffread color image
if  iscell(im)    
    tmp = im;
    im = zeros([size(tmp{1}), 3]);
    try
        for c = 1:numel(tmp)
            im(:,:,c) = tmp{c};
        end
    catch
        disp('show_image failed to assemble RGB image');
    end
    clear tmp;
end

if isempty(im)
    error('the image variable is empty');
end

if any( size(im) < 2 )
    error('image is too small to be displayed');
end

%% set default values

hFig       = [];
hImage     = [];
hAxes      = [];
indexed    = 0;
ims        = size(im);
showTicks  = 0;
mag        = [];
highlight  = [];
cLim       = [];
resizable  = 1;
resizeAxes = 0;
coords = [1 1 ims(1) ims(2)];
%% parse input

i = 1;
while i <= nargin-1
    
    cmd = varargin(i);
    cmd = cmd{1};
    if ischar( cmd )
        try
            switch lower(cmd)
                case 'name'
                    i = i + 1;
                    figname = varargin{i};
                case 'nofigure'
                    hFig  = get(0,'CurrentFigure');
                    hAxes = gca;
                case 'resizeaxes'
                    resizeAxes = 1;
                case 'ticks'
                    showTicks = 1;
                case 'highlight'
                    i = i + 1;
                    highlight=varargin{i};
                case 'indexed'
                    indexed=1;
                case 'zoom'
                    i = i + 1;
                    mag=varargin{i};
                case 'mag'
                    i = i + 1;
                    mag=varargin{i};
                case 'magnification'
                    i = i + 1;
                    mag=varargin{i};
                case 'crange'
                    i = i + 1;
                    cLim=varargin{i};
                case 'range'
                    i = i + 1;
                    cLim=varargin{i};
                case 'xmin'
                    i=i+1;
                    coords(1)=double(varargin{i});
                case 'ymin'
                    i=i+1;
                    coords(2)=double(varargin{i});
                case 'xmax'
                    i=i+1;
                    coords(3)=double(varargin{i});
                case 'ymax'
                    i=i+1;
                    coords(4)=double(varargin{i});
                otherwise
                    disp( ['unknown option "', varargin{i}, '"'] );
            end
        catch
            error(['Missing value after argument "',cmd,'"']);
        end
        
    elseif  isnumeric(cmd)
        
        if numel(cmd)==1 && ishandle(cmd)
            switch get(cmd, 'Type')
                case 'axes'
                    hAxes = cmd;
                    hFig  = get(hAxes, 'Parent');
                    %try to find the image in the children
                    h = findobj(get(hAxes, 'Children'), 'Type', 'image');
                    if ~isempty(h)
                        if numel(h) > 1
                            disp('Found more than one image handle: using first one');
                        end
                        hImage = h(1);
                    end
                    resizable  = 0;
                case 'figure'
                    hFig = cmd;
                    h = findobj(get(hFig, 'Children'), 'Type', 'axes');
                    if ~isempty(h)
                        hAxes = h(1);
                    end
                case 'image'
                    hImage  = cmd;
                    hAxes   = get(hImage, 'Parent');
                    hFig    = get(hAxes, 'Parent');
                    resizable  = 0;
            end
        elseif numel(cmd)==2
            cLim = cmd;
        end
        
    else
        error(['ignored argument "', inputname(i), '"']);
    end
    i = i + 1;
end
    

im=im(coords(1):coords(3),coords(2):coords(4),:);
ims=size(im);

%% Adjust color range for display

if isempty(cLim)
    
        
    % match bottom/top ~1% of pixel values
    for d = 1 : size(im,3)
        
        cLim(d,1) = double( min(min(im(:,:,d))) );
        cLim(d,2) = double( max(max(im(:,:,d))) );
        
        hs = cumsum(image_histogram(im(:,:,d)));
        ss = hs(numel(hs));
        
        cB = find(hs>ss*0.01, 1, 'first');
        cT = find(hs<ss*0.995, 1, 'last');

        
        if cB < cT
            cLim(d,1) = cB;
            cLim(d,2) = cT;
        end
         
        %fprintf('Auto color range %d [ %.2f, %.2f ]\n', d,
        %cLim(d,1),cLim(d,2) )
    end
    
    
elseif numel(cLim) == 1
    
    % use to set minimal value
    cLim(1,1) = cLim(1);
    cLim(1,2) = double( max(max(im(:,:,1))) );
    %fprintf('Auto color range [ %.2f, %.2f ]\n', cLim(1,1), cLim(1,2));
    
elseif all( size(cLim) == [ 1 2 ] )
    
    % use the provided color range for all components of the image:
    for d = 2 : size(im,3)
        cLim(d,1:2) = cLim(1,1:2);
    end
    
end

%% Calculate magnification

    function mag = best_zoom(ims)
        scrn = get(0,'ScreenSize')
        
        mag  = min( (scrn([4,3]) - [128 20]) ./ ims(1:2) );
    
        if mag > 1 ;  mag = floor(mag);      end
        if mag > 5 ;  mag = 5;               end
        if mag < 1 ;  mag = 1 / ceil(1/mag); end
    end

if  isempty(mag)
    mag = best_zoom(ims);
    %fprintf('size %i %i : zoom %f \n', ims(1), ims(2), mag);
end

%% Make figure

if isempty( hFig )
    %make the figure as large as possible in the screen
    scrn = get(0,'ScreenSize');
    pos  = [ 10, scrn(4)-mag*ims(1)-60,  mag*ims(2),  mag*ims(1) ];
    hFig = figure('Position', pos, 'MenuBar', 'None', 'Units', 'pixels');
else
    set(0, 'CurrentFigure', hFig);
end

% use file name to set figure name:
set(hFig, 'Name', sprintf('%s [%.0f, %.0f]', figname, cLim(1), cLim(2)));

%% Make axes

if isempty( hAxes )
    
    %make axes in the center of the figure, with the appropriate size:
    fpos = get(hFig, 'Position');
    apos = [ 1 + fix( 0.5*( fpos([3,4]) - mag*ims([2,1]) ) ) mag*ims([2,1]) ];
    hAxes = axes('Units', 'Pixels', 'Position', apos);

elseif resizeAxes
    
    set(hAxes, 'Units', 'Pixels');
    pos = get(hAxes, 'Position');
    set(hAxes, 'Position', [ pos(0:1), mag*ims([2,1]) ]);
    
end

%flip the image up/down to display it correctly
set(hAxes, 'YDir','reverse', 'View', [0 90] );
%fix axes: disable the auto-resize, and adjust the range
set(hAxes, 'DataAspectRatio',[1 1 1], 'PlotBoxAspectRatio', [mag mag 1]);
set(hAxes, 'XLimMode', 'manual', 'XLim', [1 ims(2)]);
set(hAxes, 'YLimMode', 'manual', 'YLim', [1 ims(1)]);

if showTicks
    set(hAxes, 'xtick', 0:100:ims(2) );
    set(hAxes, 'ytick', 0:100:ims(1) );
    set(hAxes, 'XColor', 'y', 'YColor', 'y');
else
    set(hAxes, 'Visible','off');
end

hold(hAxes, 'on');

%% Display image

if indexed
    scale  = double( 2^16-1 ) / ( cLim(2)-cLim(1) );
    scaled = 1+( double(im) - cLim(1) ) * scale;
    if isempty( hImage )
        hImage = image('Parent', hAxes, 'CData', scaled(coords(1):coords(3),coords(2):coords(4)));
        cmap = gray( 2^16 );
        colormap( cmap );
        disp('test 0a');
    else
        disp('test 0b');
        set(hImage, 'cdata', scaled(coords(1):coords(3),coords(2):coords(4)));
    end
else
    scaled = zeros(size(im));
    for d = 1 : size(im,3)
        scale  = 1.0 / double( cLim(d,2)-cLim(d,1) );
        scaled(:,:,d) = ( double(im(:,:,d)) - cLim(d,1) ) .* scale;
    end
    if isempty( hImage )
        %hImage = image('Parent', hAxes, 'CData', scaled(coords(1):coords(3),coords(2):coords(4)), 'CDataMapping', 'scaled');
        hImage = image('Parent', hAxes, 'CData', scaled, 'CDataMapping', 'scaled');
        colormap( gray );
        set(hAxes, 'CLim', [0, 1]);
        disp('test 1')
    else
        disp('test 2');
        set(hImage, 'CData', scaled(coords(1):coords(3),coords(2):coords(4)), 'CDataMapping', 'scaled');
    end
end

%% highlight high-value pixels

if ~isempty(highlight)
    %set the background color to yellow:
    set(hFig, 'Color', [1 1 0]);
    %make sat==1 for pixels above hightlight:
    sat = ( im >= highlight );
    %make these pixels fully transparent, to show the background color
    set(hImage, 'AlphaData', 1-sat, 'AlphaDataMapping', 'none');
    fprintf('Highlighted %i pixels above %i\n', sum(sum(sat)), highlight );
end



%% Store information in the UserData

data.magnification = mag;
data.color_range   = cLim;
data.image_size    = ims;
set(hImage, 'UserData', data);

    function resize_callback(hObject, eventData)
        h = get(hFig, 'Children');
        %do not resize if image contains a scrollpanel
        if isempty(findobj(h, 'Type', 'uipanel'))
            %keep the image in top-left corner if the figure is resized
            fpos = get(hFig, 'Position');
            mag  = min( fpos(3)/ims(2), fpos(4)/ims(1) );
            %fprintf('resize %i %i : zoom %f \n', fpos(3), fpos(4), mag);
            apos = [ 1, 1+fpos(4)-mag*ims(1), mag*ims(2), mag*ims(1) ];
            set(hAxes,'Units', 'Pixels', 'Position', apos);
            data.magnification = mag;
            set(hImage, 'UserData', data);
        end
    end


if resizable
    set(hFig, 'ResizeFcn', {@resize_callback});
else
    set(hFig, 'Resize', 'off');
end


end


