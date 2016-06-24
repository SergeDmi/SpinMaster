function [ sel, nTimes ] = spin_select_bipolar

% function sel = spin_select_bipolar
%
% returns a selection of structures, which are bipolar according to the
% Fourier analysis
%
%


try
    data = load('results_fourier.txt');
catch
    error('File "results_fourier.txt" not found');
end


%number of records, including DNA
nTimes = ( size(data, 2) - 5 ) / 2;

% bipolar tubulin structures for all time-points!
inx = 6 + 2*(1:nTimes-1);
sel = all( data(:,inx) == 2, 2 );
