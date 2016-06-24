function [ back, sigma ] = image_background( im, opt )

% [ back, sigma ] = image_background( im )
% [ back, sigma ] = image_background( im, verbose )
%
% Automatically find the pixel-value of the background, for images that are
% predominantly black.
%
% In that case, the histogram of the image has a peak in the low values,
% of Gaussian shape which correspond to the background pixels.
% image_background returns the mean and the sigma of this peak
%
% if verbose=2, a plot is made with histogram and detected values
%
% TODO: automatically detect when the method fails
%
% F. Nedelec, 2005 - April 2008

%compatibility with tiffread
filename = inputname(1);

if ( isfield( im, 'data') )
    im = im(1).data;
	if isfield(im, 'filename')
		    filename = im.filename;
	end
end


verbose = 0;
if nargin >1
    if isnumeric(opt)
        verbose = opt;
    else
        filename = opt;
    end
end


h = image_histogram(im);
%remove under-exposed pixels, where there might be a peak:
h(1) = 0;

sum_bg=sum(h);
filt_sig = 10;
while sum_bg>0.9*sum(h) & filt_sig<numel(im)/8
    filt_sig=filt_sig*2;
    %% calculate a Gaussian filter:
    filt = exp( -( (-2*filt_sig:2*filt_sig) / filt_sig ) .^ 2 );
    filt = filt ./ sum( filt );
    % convolve by the filter to get a smooth profile:
    hs = double( conv( h, filt ) );
    %crop to the same size as h
    hs = hs( 2*filt_sig+(1:numel(h)) );
    %% find the maximum in the smoothed histogram

    %[ hsmax, upper ] = max(hs);

    % iteratively search for the first maximum
    %back = 1;
    %while  back < upper  &&  hs(back+1) >= hs(back)
    %    back = back + 1;
    %end
    [ ~, back ] = max(hs);
    sum_bg=sum(h(1:back));
end

if sum_bg < numel(im) / 10
    fprintf(['  Less than 10%% background pixels in "', filename, '"\n']);
elseif    sum_bg > 0.9* numel(im)
    fprintf(['  More than 90%% background pixels in "', filename, '"\n']);
end
%% Make a figure to debug things

if verbose > 0
    fprintf('Background detected at : %.2f\n', back);
end


if verbose > 1
    x = (0:size(h)-1)';
    figure('Name','image_background', 'Position', [100 150 800 300]);
    axes('Position', [0.05 0.1 0.9 0.8] );
    hold on;
    xlim([0 size(h,1)]);
    set(gca, 'ytick', [])
    
    plot(x, h, 'g.' );
    plot(x, hs, 'k:', 'linewidth', 1);
    
    plot([back, back], ylim, 'b-', 'linewidth', 2);
    plot([upper, upper], ylim, 'k:');
    
    text(back, hsmax, sprintf(' %i', back), 'FontSize', 18 );
    title('Histogram of pixel values');

end



%% Gaussian fit of the distribution of dark pixels

    function f = gauss(x, a)
        f = exp( -(x-a(1)).^2 / a(2) );
    end

    function err = gauss_err(a)
        f = gauss(rx, a);
        s = sum(ry.*f) / sum(f.*f);
        err = sum( abs(f*s-ry) );   %robust fitting
        %err = norm( f*s-ry );      %least-square fitting
    end

if nargout > 1
    
    % Gaussian fit to obtain the variance of the black pixel values
    
    rwd = fix(back*0.8);
    ri = max(back-rwd, 1) : min(back+rwd, length(hs));
    rh = h(ri);
    
    rx = (ri-1)';
    ry = rh / sum(rh);
    esp = sum(rx.*ry);
    var = sum(rx.*rx.*ry);
    sigma = sqrt(var-esp*esp);
    
    if verbose > 0
        fprintf('Histogram  : mean %.2f, sigma %.2f\n', back, sigma);
    end

    [ pamG, pval, flag ] = fminsearch(@gauss_err, [ esp, 2*(var-esp*esp) ]);
    
    %if the fit is successful, we change our estimate of sigma:
    if flag == 1
        f     = gauss(rx, pamG);
        fitG  = f * ( sum(rh) * sum(ry.*f) / sum(f.*f) );

        backG = pamG(1);
        sigma = sqrt(pamG(2)/2);

        if verbose > 0
            fprintf('Gauss   fit: mean %.2f, sigma %.2f\n', backG, sigma);
        end
    end
        
    if verbose > 1
        %make an inset figure:
        axes('Position', [0.5 0.25 0.4 0.62]);
        plot( rx, h(1+rx), 'g.');
        hold on;
        plot( rx, hs(1+rx), 'b--');
        if exist('fitG', 'var')
            plot( rx, fitG, 'k-');
        end
        plot([back, back], ylim, 'k-');
        if exist('sigma', 'var')
            w = sqrt(2) * sigma;
            plot([back-w, back-w], ylim, 'k:');
            plot([back+w, back+w], ylim, 'k:');
        end
    end
end

%% Exit here, unless the debug level is = 2

if verbose < 2
    return
end

%% Gamma fit (could be appropriate for low photon counts)
    

    function g = gamma_dis(x, a)
        %a is of dimension 2: a = { k, theta }
        %gamma density function
        g = exp( (a(1)-1)*log(x) - x/a(2) - a(1)*log(a(2)) ) / gamma(a(1));
    end

    function err = gamma_err(a)
        f = gamma_dis(rx, a);
        s = sum(ry.*f) / sum(f.*f);
        err = sum( abs(f*s-ry) );   %robust fitting
        %err = norm( f*s-ry );      %least-square fitting
    end

if nargout > 1
    
    [ pamP, pval, flag ] = fminsearch(@gamma_err, [ 5, esp/5 ]);
    
    if flag == 1

        f      = gamma_dis(rx, pamP);
        fitP   = f * ( sum(rh) * sum(ry.*f) / sum(f.*f) );
       
        %backP  = pamP(1) * pamP(2);  %mean-value
        sigmaG = sqrt(pamP(1)) * pamP(2); %sigma
        [mval, id] = max(f);
        backG  = rx(id);  %position of peak

        if verbose > 0
            fprintf('Gamma   fit: mean %.2f, sigma %.2f\n', backG, sigmaG);
        end
 
        if verbose > 1
            plot( rx, fitP, 'r-');
        end

    end
    
end



%% Poisson fit

    function p = poisson(x, a)
        n = x ./ a(2);
        % discrete poisson distribution over n,
        p = exp( n .* ( 1 - log( n ./ a(1) ) ) + 0.5*log(n) );
    end

    function err = poisson_err(a)
        f = poisson(rx, a);
        s = sum(ry.*f) / sum(f.*f);
        err = sum( abs(f*s-ry) );   %robust fitting
        %err = norm( f*s-ry );      %least-square fitting
    end

if nargout > 1

    [ pamS, pval, flag ] = fminsearch(@poisson_err, [ esp / 10, 10 ]);

    
    if flag == 1
        
        grain  = pamS(2);
        backP  = pamS(2) * pamS(1);      %mean
        sigmaP = pamS(2) * sqrt(pamS(1));
       
        f      = poisson(rx, pamS);
        fitS   = f * ( sum(rh) * sum(ry.*f) / sum(f.*f) );

        if verbose
            fprintf('Poisson fit: mean %.2f, sigma %.2f, grain %.2f\n', backP, sigmaP, grain);
        end
        
        if verbose > 1
            plot( rx, fitS, 'b-');
        end

    end

end

end

