function area = spin_measure_area(opt)

% function area = spin_measure_area
%
% Process images for the lattice experiment, measuring the area 
% covered by the tubulin signal, summed over time
%
% F. Nedelec, Feb. 2008


if ~isfield(opt, 'radius')
    error('A radius must be provided as field of the second argument');
end


%% Get regions to analyse
regions  = load_regions;
nRegions = size(regions,1);

% resize regions:
for p = 1:nRegions
    regions(p,2:5) = resize_rectangle( regions(p,2:5), [opt.radius, opt.radius] );
end


%% Load images

fprintf('%s ---------------------------> Loading images\n', mfilename);

TUB = spin_load_images('tub', [], opt);

%% calculate the sum of TUB signal

fprintf('%s ---------------------------> Summing images\n', mfilename);

TUB_MAX = TUB(1).data;
for i = 2 : length(TUB);
    TUB_MAX = max(TUB_MAX, TUB(i).data);
end

fprintf('%s ---------------------------> Manual thresholding\n', mfilename);

if opt.visual > 0

    show_image(TUB_MAX);
    hAxes = gca;
    
end

threshold = manual_threshold(TUB_MAX);


%% calculate area

fprintf('%s ---------------------------> Measuring area\n', mfilename);

area = zeros(nRegions, 1);

% define a circular mask
circle = mask_circle(2*opt.radius);

for p = 1:nRegions
    
    crop = image_crop(TUB_MAX, regions(p,2:5), 0);
    area(p) = sum(sum((crop .* circle) > threshold));
    
    if opt.visual > 0
        rec = regions(p, 2:5);
        if area(p) < 10
            color = 'r';
        else
            color = 'g';
        end
        rectangle('Parent', hAxes, 'EdgeColor', color, ...
                  'Position', [rec(2), rec(1), rec(4)-rec(2), rec(3)-rec(1)]);
        drawnow;    
    end
    
end


%% Save the results

fprintf('%s ---------------------------> Saving results\n', mfilename);


filename = 'results_area.txt';
fid = fopen(filename, 'wt');
fprintf(fid, '%% %s\n', date);
fprintf(fid, '%% circular regions\n');
fprintf(fid, '%% radius = %.2f\n', opt.radius);
fprintf(fid, '%% threshold = %i\n', threshold);

if ~isempty(TUB)
    for n = 1:length(TUB)
        fprintf(fid, '%% tub_image%i %s\n', n, TUB(n).file_name);
    end
end

fprintf(fid, '\n');
fprintf(fid, '%% IDR  left  bot. right   top   area \n');

for p = 1:nRegions
    fprintf(fid, '%5i ', regions(p,:));
    fprintf(fid, ' %6i',   area(p));
    fprintf(fid, '\n');
end
fclose(fid);
fprintf('Saved results in "%s"\n', filename);

end

%% sub-functions

function res = resize_rectangle(rect, wh)
lx  = round( ( rect(1) + rect(3) ) / 2 - wh(1) );
ly  = round( ( rect(2) + rect(4) ) / 2 - wh(2) );
res = [ lx, ly, lx+2*wh(1)-1, ly+2*wh(2)-1 ];
end


