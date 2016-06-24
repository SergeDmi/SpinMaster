function cal = spin_calibrated_dna(kind, debug)

% function cal = spin_calibrated_dna(kind, debug)
% return a calibrated amount of DNA, with a description
% 
% F. nedelec

if nargin < 2
    debug = 0;
end

%%
try
    dna = load('results_dna.txt');
catch
    error('File "results_dna.txt" not found');
end

if size(dna,2) ~= 7
    error('Format of "result_dna.txt" not supported');
end



%%provide a default behavior:
cal.orig = 'DNA fluorescence';
cal.dest = 'DNA fluorescence (a.u.)';
cal.fit  = [ 1 0 ];
cal.dna  = dna(:,6);
cal.val  = dna(:,6);


%%
try
    beads = load('results_beads.txt');
    ncal = size(beads,1);
catch
    warning('Bead count not available ("results_beads.txt" not found)');
    return;
end



%%
if strcmp(kind, 'DNA fluorescence')
    cal.orig = 'DNA fluorescence';
    indx = 6;
elseif  strcmp(kind, 'DNA area')
    cal.orig = 'DNA area';
    indx = 7;
else
    error('Unknown calibration requested');
end


if any( beads(:,1) ~= dna(1:ncal, 1) )
    error('missmatch in ROI index');
end


cal.dest = 'Est. Number of beads';

cal.dna  = dna(:, indx);
cal.fit  = polyfit(cal.dna(1:ncal), beads(:,6), 1);
cal.val  = polyval(cal.fit, cal.dna);


if cal.fit(1) < 0 
    error('The calibration seems invalid: the slope is negative');
end
    
fprintf('Calibrated with "%s" = %f * "%s"  %+f\n', cal.dest, cal.fit(1), cal.orig, cal.fit(2));


if debug >= 1

    figure;
    size( cal.dna(1:ncal) )
    size( beads)
    
    plot( cal.dna(1:ncal), beads(:,6), '.');
    hold on;
    
    a = axis;
    plot([a(1), a(2)], [ polyval(cal.fit, a(1)), polyval(cal.fit, a(2)) ], 'k:', 'LineWidth', 2);
    
    xlabel(cal.orig);
    ylabel(cal.dest);
    title(sprintf('Fit = %f * x %+f\n', cal.fit(1), cal.fit(2)));

end


end