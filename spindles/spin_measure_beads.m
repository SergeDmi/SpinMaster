function [ res, self, info ] = spin_measure_beads(dna, tub, opt, self)

%function [ res, self, info ] = spin_measure_beads(dna, tub, opt, self)
%
% Ask the user to enter the number of beads.
%
% F. Nedelec, March. 2008


if nargout > 2
   info = { 'nBeads' }; 
end


if isempty(self)
    try
        load('results_beads.txt');
        fprintf( 'Warning: there is already a calibration file\n');
        n = input('  Do you want to overwrite it (yes/no) ?', 's');
        if ~strcmpi(n, 'yes')
            res = 'exit';
            return;
        end
    catch
    end
    self = show_image(dna, 'Magnification', 4);
else
    show_image(dna, 'Handle', self);
end



res = 0;
n = input('Number of beads (number/q) ? ', 's');
if n == 'q'
    res = [];
elseif ~isempty(n)
    res = str2double(n);
end

end