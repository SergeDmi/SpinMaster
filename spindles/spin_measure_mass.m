function [ res, self, info ] = spin_measure_mass(dna, tub, opt, self)

% function [ res, self, info ] = spin_measure_mass(dna, tub, opt, self)
% Analyse spindle total fluorescence
%
% F. Nedelec, August 2010

% arbitrary scaling to make the numbers more human-friendly:

self = [];

if nargout > 2
    for n = 1:size(tub,3)
        info{n} = ['mass', num2str(n)];
    end
end


for t = 1:size(tub,3)
    crop = tub(:,:,t) .* ( tub(:,:,t) > 0 );  %only keep positive values
    res(t) = double( sum(sum(crop)) );
end

end



