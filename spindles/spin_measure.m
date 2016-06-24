function spin_measure(method, opt)

% function res = spin_measure(method, opt)
%
% Process images for the lattice experiment, using a circular mask
% The radius should be specified as field of opt: opt.radius
%
% F. Nedelec, March. 2008 - August 2010


if nargin < 2  ||  ~isfield(opt, 'radius')
    error('A radius must be provided as field of the second argument');
end
fprintf('%s ---------------------------> Radius = %i pixels\n', mfilename, opt.radius);


%% define a circular mask

if opt.use_mask
    opt.mask = mask_circle(2*opt.radius);
end

%% Get regions to analyse

fprintf('%s ---------------------------> Loading regions\n', mfilename);

regions  = load_regions;
nRegions = size(regions,1);

% resize regions:
for p = 1:nRegions
    regions(p,2:5) = resize_rectangle( regions(p,2:5), [opt.radius, opt.radius] );
end

%% Load images, show DNA to display regions

fprintf('%s ---------------------------> Loading DNA\n', mfilename);

DNA = spin_load_images('dna', 1, opt);

if isempty(DNA)
    error('Could not find any DNA image');
end

if opt.visual == 1
    show_image(DNA);
    hAxes = gca;
end

%% Loading tubulin images:

fprintf('%s ---------------------------> Loading TUB\n', mfilename);

if ~strcmp(method, 'dna')
    TUB = spin_load_images('tub', [], opt);
    nTimes = length(TUB);
else
    TUB = [];
    nTimes = 0;
end

%% prepare a figure to show the images

if opt.visual > 2
    D = 2*opt.radius+1;
    [ opt.hFig, opt.hAxes ] = tile_axes(nTimes+1, [D, D]);
else
    opt.hFig  = [];
    opt.hAxes = [];
end

drawnow;

%% prepare variables, and function pointer

res  = [];
self = [];  %data provided and returned to the analyse function
func = eval( ['@spin_measure_',method] );

%make a structured object 'more' to provide additional information:
opt.dna_back = DNA.back;


% Call 'func' for each spot, and each time-point
for p = 1:nRegions
    
    rec = regions(p,2:5);
    
    if opt.auto_center
        %re-center on the beads
        bea = image_crop(DNA.data, rec, 0) > opt.dna_threshold;
        cen = weighted_center(bea) + rec(1:2);
        rec = make_square(cen, opt.radius);
        regions(p, 2:5) = rec;
    end

    opt.region = regions(p,1:5);
    opt.info = ['region ', num2str(p)];

    dna = image_crop(DNA.data, rec, DNA.back);
    %base = image_background(dna);  %local background
    
    if opt.use_mask
        dna = opt.mask .* dna + ( 1-opt.mask ) * DNA.back;
    end
    
    if isempty(TUB)
        tub = [];
    else
        tub = zeros([2*opt.radius, 2*opt.radius, nTimes]);       
        opt.tub_back = zeros(nTimes, 1);
        
        for t = 1:nTimes
            
            if opt.local_background == 1
                crop = image_crop(TUB(t).data, rec);
                if opt.visual>1
                    back = image_background(crop, TUB(t).file_name);
                else 
                    back = image_background(crop);
                end
            else
                back = TUB(t).back;
            end
            
            % This crop will always give the same image size:
            crop = image_crop(TUB(t).data, rec, back);

            opt.tub_back(t) = back;
            
            if opt.use_mask
                tub(:,:,t) = opt.mask .* ( crop - back );
            else
                tub(:,:,t) = crop - back;
            end
            
        end
    end
    
    if opt.visual > 2
        % display images:
        cla(opt.hAxes(1));
        show_image(dna, 'Handle', opt.hAxes(1));
                   
        clims = image_auto_colors(tub);
        clim = [ min(clims(:,1)), mean(clims(:,2)) ];
        
        for t = 1:nTimes
            cla(opt.hAxes(t+1));
            show_image(tub(:,:,t), 'ColorRange', clim, 'Handle', opt.hAxes(t+1));
        end
        drawnow;
    end

    
    %call the analysis function. self is set and returned by the function
    if isempty(self)
        [ data, self, info ] = func(dna, tub, opt, self);
    else
        [ data, self ] = func(dna, tub, opt, self);
    end

    %we stop if no data was returned
    if isempty(data) || strcmp(data, 'exit')
        break
    end

    if isempty(res)
        res = data;
    else
        res = cat(1, res, data);
    end

        
    if opt.visual == 1
        rec = regions(p, 2:5);
        rectangle('Parent', hAxes, 'EdgeColor', 'g',...
                  'Position', [rec(2), rec(1), rec(4)-rec(2), rec(3)-rec(1)]);
        drawnow;
    end
        
    if opt.visual > 3
        k = waitforbuttonpress;
        if k
            if 'q' == get(gcf, 'CurrentKey');
                break;
            end
        end
    end

end

if ~isempty(opt.hFig)
    close(opt.hFig);
    opt = rmfield(opt, {'hFig', 'region', 'info', 'dna_back', 'tub_back'});
end

%% Exit maybe

if strcmp(data, 'exit')
    return;
end
 
if isempty(data)
    k = questdlg('Do you want to save the results?', 'Confirm', 'Yes', 'No', 'No');
    if  ~strcmp(k, 'Yes')
        return;
    end
end

%% Save results

if ~ isempty(res)

    filename = ['results_',method,'.txt'];
    fid = fopen(filename, 'wt');
    fprintf(fid, '%% %s\n', date);
    fprintf(fid, '%% spin_measure:\n');
    
    %print all options (the fields of opt):
    fields = fieldnames(opt);
    for f = 1:size(fields,1)
        field_name  = fields{f};
        field_value = getfield(opt, fields{f});
        if size(field_value,1) == 1
            if isa(field_value, 'char')
                fprintf(fid, '%%   opt.%s = %s\n', field_name, field_value);
            else
                fprintf(fid, '%%   opt.%s = %s\n', field_name, num2str(field_value));
            end
        end
    end
    fprintf(fid, '%% dna_image  %s\n', DNA.file_name);
    
    if ~isempty(TUB)
        for n = 1:length(TUB)
            fprintf(fid, '%% tub_image%i %s\n', n, TUB(n).file_name);
        end
    end
    fprintf(fid, '\n');
    
    
    fprintf(fid, '%% IDR  left  bot. right   top ');
    for p = 1:length(info)
       fprintf(fid, ' %15s', info{p});
    end
    fprintf(fid, '\n\n');
    
    for p = 1:size(res,1)
        fprintf(fid, '%5i ', regions(p,:));
        fprintf(fid, ' %15.2f', res(p,:));
        fprintf(fid, '\n');
    end
    fclose(fid);
    fprintf('%s ---> ', mfilename)
    fprintf('Saved %ix%i values in "%s"\n', size(res,1), size(res,2), filename);

end

end

%% Accessory

function rec = make_square(cen, rad)
lx  = round( cen(1)-rad );
ly  = round( cen(2)-rad );
rec = [ lx, ly, lx+2*rad-1, ly+2*rad-1 ];
end


function rec = resize_rectangle(rec, wh)
lx  = round( ( rec(1) + rec(3) ) / 2 - wh(1) );
ly  = round( ( rec(2) + rec(4) ) / 2 - wh(2) );
rec = [ lx, ly, lx+2*wh(1)-1, ly+2*wh(2)-1 ];
end


function [ hFig, hAxes ] = tile_axes(nb, sz)
    tile(2) = ceil( nb / 7 );
    tile(1) = ceil( nb / tile(2) );

    hAxes = zeros(nb,1);
    hFig  = figure('Name', 'Spots', 'MenuBar','None', 'Position', [30 100 tile(1)*sz(2) tile(2)*sz(1)]);
    for ii = 0:nb-1
        ny = fix( ii / tile(1) );
        px = ii - tile(1)*ny;
        py = tile(2) - 1 - ny;
        hAxes(ii+1) = axes('Units', 'pixels', 'Position', [1+px*sz(2) 1+py*sz(1) sz(2) sz(1)] );
    end
end
