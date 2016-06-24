function [ res, self, info ] = spin_measure_back(dna, tub, opt, self)

% function [ res, self, info ] = spin_measure_tub(dna, tub, self)
% Analyse spindle shape by total fluorescence
%
% F. Nedelec, June 2010


self = [];

if nargout > 2
    for n = 1:size(tub,3)
        info{n} = ['back', num2str(n)];
    end
end


for t = 1:size(tub,3)
    res(t) = image_background(tub(:,:,t), opt.info);
end

end