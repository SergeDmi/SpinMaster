function hAxes = show_tile(images, tile)

% Show multiple images next to each other in a single figure
%
% F. Nedelec, October 2008


%%
nb = length(images);

if nargin < 2
    tile(2) = ceil( sqrt( nb ) );
    tile(1) = ceil( nb / tile(2) );
end

mag = best_zoom( tile .* size(images(1).data) );
ims = round( mag .* size(images(1).data) );
hAxes = tile_axes(nb, ims, tile);

for n=1:nb;
    
   show_image(images(n), 'Handle', hAxes(n));
   drawnow;

end


%%
    function hAxes = tile_axes(nb, sz, tile)
        hAxes = zeros(nb,1);
        hFig  = figure('MenuBar','None', 'Position', [30 100 tile(1)*sz(2) tile(2)*sz(1)]);
        for ii = 0:nb-1
            ny = fix( ii / tile(1) );
            px = ii - tile(1)*ny;
            py = tile(2) - 1 - ny;
            hAxes(ii+1) = axes('Units', 'pixels', 'Position', [1+px*sz(2) 1+py*sz(1) sz(2) sz(1)] );
            set(hAxes(ii+1), 'Visible','off');
        end
    end

    function mag = best_zoom(ims)
        scrn = get(0,'ScreenSize');
        mag  = min( (scrn([4,3]) - [128 20]) ./ ims(1:2) );

        if mag > 1 ;  mag = floor(mag);      end
        if mag > 5 ;  mag = 5;               end
        if mag < 1 ;  mag = 1 / ceil(1/mag); end
    end

end

