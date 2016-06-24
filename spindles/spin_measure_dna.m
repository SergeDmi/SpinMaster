function dna_threshold = spin_measure_dna(opt)

% function opt = spin_measure_dna(method, opt)
%
% Process DNA images from spindle-arrays.
% The radius should be specified as field of opt: opt.radius
%
% F. Nedelec, March. 2008



if nargin < 1  ||  ~isfield(opt, 'radius')
    error('A radius must be provided as field of the second argument');
end
fprintf('%s ---------------------------> Radius = %i pixels\n', mfilename, opt.radius);


%% define a circular mask
circle = mask_circle(2*opt.radius);


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

show(DNA);

try
%  use otsu's method by default
t = graythresh(DNA.data) * max(max(DNA.data));
catch ME
    disp('missing function graythresh');
    t = DNA.back;
end

%  ask for manual threshold
dna_threshold = manual_threshold(DNA.data, t);


%% Measure fluorescence for each region

fprintf('%s ---------------------------> Measuring each region\n', mfilename);

if opt.visual > 0
    show_image(DNA);
    hAxes = gca;
end

scale = 1e-6;
res = zeros(nRegions, 2);

for p = 1:nRegions
    
     if opt.auto_center
        %re-center on the beads
        bea = image_crop(DNA.data, rec, 0) > dna_threshold;
        cen = weighted_center(bea) + rec(1:2);
        rec = make_square(cen, opt.radius);
        regions(p, 2:5) = rec;
     end
     
     rec = regions(p,2:5);

     dna = image_crop(DNA.data, rec, DNA.back);
     %base = image_background(dna);  %local background
     %dna = mask .* ( dna - base ) .* ( dna > base );
         
     res(p, 1) = scale * double( sum(sum(dna)) );
     res(p, 2) = sum(sum( dna > dna_threshold ));
     
     if opt.visual > 0
         rec = regions(p, 2:5);
         rectangle('Parent', hAxes, 'EdgeColor', 'g',...
             'Position', [rec(2), rec(1), rec(4)-rec(2), rec(3)-rec(1)]);
         drawnow;
     end
     
end

%% Save threshold

if 1
    export.dna_threshold = dna_threshold;
    update_structure(export, 'spin_variables.m', 'opt');
    fprintf('Saved dna_threshold=%i in "%s"\n', dna_threshold, 'spin_variables.m');
end


%% Save the results

fprintf('%s ---------------------------> Saving results\n', mfilename);

filename = 'results_dna.txt';
fid = fopen(filename, 'wt');
fprintf(fid, '%% %s\n', date);
fprintf(fid, '%% radius = %.2f\n', opt.radius);
fprintf(fid, '%% scale = %.4e\n', scale);
fprintf(fid, '%% threshold = %.4e\n', dna_threshold);
fprintf(fid, '%% image = %s\n', DNA.file_name);

fprintf(fid, '\n');
fprintf(fid, '%% IDR  left  bot. right   top   DNA-fluo  DNA-area\n');

for p = 1:nRegions
    fprintf(fid, '%5i ', regions(p,:));
    fprintf(fid, ' %9.3f', res(p,:));
    fprintf(fid, '\n');
end
fclose(fid);
fprintf('Saved results in "%s"\n', filename);


end

%% accessory functions


function res = resize_rectangle(rect, wh)
lx  = round( ( rect(1) + rect(3) ) / 2 - wh(1) );
ly  = round( ( rect(2) + rect(4) ) / 2 - wh(2) );
res = [ lx, ly, lx+2*wh(1)-1, ly+2*wh(2)-1 ];
end