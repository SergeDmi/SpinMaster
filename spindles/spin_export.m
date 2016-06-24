function [ tub ] = spin_export(what, opt)

%function [ output ] = spin_export( what, opt )
% Export data to coma-separated values

if nargin < 2
    opt.time_shift = 0;
end

%% Load DNA

try
    dna.data = load('results_dna.txt');
catch
    error('File "results_dna.txt" not found');
end

dna.fluo = dna.data(:, 6);
dna.area = dna.data(:, 7);

%% Load Tubulin images to get time

TUB = spin_load_images('tub', [], setfield(opt, 'load_pixels', 0));

tub.time = zeros(1,length(TUB));

for i = 1:length(TUB)
    tub.time(1,i) = TUB(i).time - opt.time_shift;
end

clear TUB;

%% Load Tubulin fluoresccence

try
    res = load('results_mass.txt');
    %we skip Region ID and coordinates in the first 5 columns
    tub.fluo = res(:, 6:size(res,2));
catch
    error('File "results_mass.txt" not found');
end

%% Load tubulin area

try
    res = load('results_area.txt');
    tub.area = res(:, 6);
catch
    error('File "results_area.txt" not found');
end



%% Plot all time - tubulin


if strcmp(what, 'mass')

    figure('Name', 'Background subtracted fluorescence');
    plot( tub.time, tub.fluo );
    xlabel('Time (min)', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Tubulin', 'FontSize', 16, 'FontWeight', 'bold');
    
    
    figure('Name', 'Background subtracted fluorescence');
    plot( tub.area, mean(tub.fluo, 2), 'o');
    xlabel('Area covered by tubulin (pixel^2)', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Tubulin Fluorescence', 'FontSize', 16, 'FontWeight', 'bold');

end

%% Plot only spots with non-zero tubulin area

if strcmp(what, 'mass')
    
    sel = logical( tub.area > 0 );

    
    figure('Name', [ 'Top ' num2str(sum(sel)) ' spots']);
    plot( tub.time, tub.fluo(sel,:) );
    xlabel('Time (min)', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Tubulin Fluorescence', 'FontSize', 16, 'FontWeight', 'bold');
    
    
    figure('Name', ['Average time-profile of ' num2str(sum(sel)) ' spots']);
    plot( tub.time, mean(tub.fluo(sel,:), 1) );
    xlabel('Time (min)', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Tubulin', 'FontSize', 16, 'FontWeight', 'bold');


end


end
