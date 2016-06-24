function [ res, self, info ] = spin_measure_ellipse(dna, tub, opt, self)

% function [ res, self, info ] = spin_measure_ellipse(dna, tub, self)
% Analyse spindle shape by fitting an ellipse
%
% F. Nedelec, April 2008


self = [];

if nargout > 2
    for i = 0:size(tub,3)
        if i == 0
            nb = 'B';
        else
            nb = num2str(i);
        end
        info{5*i+1} = ['cenX', nb];
        info{5*i+2} = ['cenY', nb];
        info{5*i+3} = ['angle', nb];
        info{5*i+4} = ['major', nb];
        info{5*i+5} = ['minor', nb];
    end
end


im = dna - opt.dna_threshold;
im = im .* ( im > 0 );

[cen, ell] = fit_ellipse( im, 0 );
res = [cen ell];


for inx = 1:size(tub,3)
    
    im = tub(:,:,inx);
    [ back, sigma ] = image_background(im);

    top = max(max( im ));

    % TODO we have to define the good threshold
    threshold = back + 2 * sigma;
    %im_cen = ( [1,1] + [size(tub,1), size(tub,2)] ) / 2;

    im = ( im - threshold ) .* ( im > threshold );

    [cen, ell] = fit_ellipse(im, inx);
    res = cat(2, res, [cen ell]);

end


    function [cen, ell] = fit_ellipse(im, axi)
        
        [cen, mom, ell] = weighted_sums(im);

        if ~isempty(opt.hAxes)

            ax = opt.hAxes(axi+1);
            draw_ellipse(cen, ell, ax);
            
            angle = ell(1) + pi/2;
            %draw minor axis (should be the metaphase plate:
            ma = ell(3) * [ cos(angle), sin(angle) ];
            pt = [ cen, cen ] + [ -ma, ma ];
            plot(ax, pt([2,4]), pt([1,3]), 'y:');
            
        end

    end


end