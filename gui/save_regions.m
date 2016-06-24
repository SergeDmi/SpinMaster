function regions = save_regions(regions, filename)

% regions = save_regions(regions, filename)
%
% load the regions from the file 'regions.txt'
%
% F. Nedelec, Feb. 2008

if nargin < 2
    filename = 'regions.txt';
end


fid = fopen(filename, 'wt');
fprintf(fid, '%% dimension %i\n', 5);
fprintf(fid, '%% %s\n', date);
fprintf(fid, '%% regions of interest:\n');
fprintf(fid, '%% IDR     x_inf      y_inf      x_sup      y_sup\n');
for n = 1:size(regions,1)
    fprintf(fid, '%4i  %9.2f  %9.2f  %9.2f  %9.2f\n',...
        regions(n,1), regions(n,2), regions(n,3), regions(n,4), regions(n,5));
end
fclose(fid);
fprintf('Regions saved in %s\n', filename);
    

end
