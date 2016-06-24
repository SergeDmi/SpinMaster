function [ output ] = spin_export_mass(opt)

%function [ output ] = spin_export( what, opt )
% Export data to coma-separated values
% F. Nedelec, August 5th 2010

if nargin < 1
    opt.time_shift = 0;
else
    fprintf('Time-shift = %i\n', opt.time_shift);
end

%% Load DNA

try
    data = load('results_dna.txt');
    dna.fluo = data(:, 6);
    dna.area = data(:, 7);
    clear data;
catch
    error('File "results_dna.txt" not found');
end

%% Load Tubulin images to get time

TUB = spin_load_images('tub', [], setfield(opt, 'load_pixels', 0));

tub.time = zeros(1,length(TUB));

for i = 1:length(TUB)
    tub.time(1,i) = TUB(i).time - opt.time_shift;
end

clear TUB;

%% Load Tubulin fluoresccence

try
    data = load('results_mass.txt');
    %we skip Region ID and coordinates in the first 5 columns
    tub.fluo = data(:, 6:size(data,2));
    clear data;
catch
    error('File "results_mass.txt" not found');
end


%% Load tubulin area

try
    data = load('results_area.txt');
    tub.area = data(:, 6);
    clear data;
catch
    error('File "results_area.txt" not found');
end



%% Plot all time - tubulin


figure('Name', 'Background subtracted fluorescence');
plot( tub.time, tub.fluo );
xlabel('Time (min)', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Tubulin', 'FontSize', 16, 'FontWeight', 'bold');


figure('Name', 'Background subtracted fluorescence');
plot( tub.area, mean(tub.fluo, 2), 'o');
xlabel('Area covered by tubulin (pixel^2)', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Tubulin Fluorescence', 'FontSize', 16, 'FontWeight', 'bold');


%% Plot only productive spots = non-zero tubulin area

%select spots with non-zero tubulin fluorescence area:
sel = logical( tub.area > 10 );


figure('Name', [ 'Top ' num2str(sum(sel)) ' spots']);
plot( tub.time, tub.fluo(sel,:) );
xlabel('Time (min)', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Tubulin Fluorescence', 'FontSize', 16, 'FontWeight', 'bold');


%% Plot average of productive spots

output = zeros(length(tub.time), 2);
output(:,1) = tub.time;
output(:,2) = mean(tub.fluo(sel,:),1);


hold on;
plot(output(:,1), output(:,2), 'k', 'LineWidth', 4);
xlabel('Time (min)', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Tubulin', 'FontSize', 16, 'FontWeight', 'bold');


%% Export average to CSV file



filename = ['export_mass.csv'];
fid = fopen(filename, 'wt');
fprintf(fid, '%% Time  Average-total-fluorescence\n');
 

nCol = size(output,2);
for t = 1:size(output,1)
    for p = 1:nCol-1
        fprintf(fid, '%10.2f,  ', output(t,p));
    end
    fprintf(fid, '%10.2f\n', output(t,nCol));
end
fclose(fid);
fprintf('%s ---> Saved %s\n', mfilename, filename);



end
