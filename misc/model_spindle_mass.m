function pam = model_spindle_mass(pam)

% To fit the fluorescence mass generated around DNA-spots
% Francois Nedelec, OCtober 1st 2008
%
% Format figure for PDF:  18x7cm font size = 6pt

[ exper, beads ] = experiment;
times = exper(:,1);
tspan = [ 0 40 ];

if nargin < 1
    
    options = optimset('Display', 'off');  %use 'iter' for monitoring

    %model D : decay 
    pamD = [0.1, 0.2];
    pamD = fminsearch(@ecart, pamD, options);
    fprintf('ModelD: best fit for [ %f %f ]\n', pamD(1), pamD(2));

    %model K : enzyme
    pamK = [0.1, 0.01, 0.1];
    pamK = fminsearch(@ecart, pamK, options);
    fprintf('ModelK: Best fit for [ %f %f %f ]\n', pamK(1), pamK(2), pamK(3));

    %model A : autocatalitic
    pamA = [0.1, 0.01, 0.1, 0.001];
    pamA = fminsearch(@ecart, pamA, options);
    fprintf('ModelA: Best fit for [ %f %f %f %f ]\n', pamA(1), pamA(2), pamA(3), pamA(4));

   
    
    figure('Position', [200 200 1200 400]);
    axes('Position', [0.06 0.15 0.27 0.7 ]);
    make_plot(pamD);
    ax = axes('Position', [0.33+0.04 0.15 0.27 0.7 ]);
    make_plot(pamK);
    set(ax,'YTickLabel', ''); ylabel('');
    ax = axes('Position', [0.66+0.04 0.15 0.27 0.7 ]);
    make_plot(pamA);
    set(ax,'YTickLabel', ''); ylabel('');

    setprint(0.9);
else

    make_plot(pam);
    figure;

end


%%
    function dm = derivate(t, m)
        if numel(pam) == 2
            dm(1,1) = pam(1) - pam(2) * m(1);
            dm(2,1) = 0;
        elseif numel(pam) == 3
            dm(1,1) = pam(1) - m(2);
            dm(2,1) = pam(2)*m(1) - pam(3)*m(2);
        elseif numel(pam) == 4
            dm(1,1) = pam(1) + pam(4)*m(1) - m(2);
            dm(2,1) = pam(2)*m(1) - pam(3)*m(2);
        end
    end

%%
    function res = five(p)
        pam_save = p;
        pam = p;
        res = times;
        for b = beads
            pam(1) = b * pam_save(1);
            [t,m] = ode45(@derivate, tspan, [0; 0]);
            sol = interp1(t,m,times);
            res = cat(2, res, sol(:,1) );
        end
        pam = pam_save;
    end


%%
    function make_plot(p)
        
        s = five(p);
        for b = 2:size(s,2)
            plot(s(:,1), s(:,b), 'k-', 'LineWidth', 2);
            hold on;
        end
        ylim([0 18]);
        xlim([0 40]);

        xlabel('Time (min)', 'FontSize', 18, 'FontWeight', 'bold');
        ylabel('Fluorescence (a.u.)', 'FontSize', 18, 'FontWeight', 'bold');
        set(gca,'FontSize', 18);
        
        
        [ m, b, d ] = experiment;
        ms=6;
        syb = ' odv^s';
        for i = 2:5
            plot(m(:,1), m(:,i), ['k',syb(i)], 'MarkerSize', ms, 'MarkerFaceColor', 'k');
            errorbar(m(:,1), m(:,i), d(:,i)/2, 'k:');
        end
        
        gen   = num2str(p(1),2);
        sigma = num2str(1/p(2),2);
        
        if numel(p) == 2
            msg = ['g=',gen,'a.u. \tau=',sigma,'min.'];
            %text(2,16.5, '{dm}/{dt} = g c - m / \tau', 'FontSize', 14, 'FontWeight', 'bold');
            %title('Decay');
        end
        if numel(p) == 3
            tau   = num2str(1/p(3),2);
            msg = ['g=',gen,' a.u.  \sigma=',sigma,' min.^2  \tau=',tau,' min.' ];
            %text(2,17.2, '{dm}/{dt} = g c - k', 'FontSize', 14, 'FontWeight', 'bold');
            %text(2,16.1, '{dk}/{dt} = m / \sigma - k / \tau', 'FontSize', 14, 'FontWeight', 'bold');
            %title('Enzymatic destruction');
        end
        if numel(p) == 4
            tau   = num2str(1/p(3),2);
            auto  = num2str(p(4),2);
            msg = ['g=',gen,'au, \sigma=',sigma,'min^2, \tau=',tau,' min, a=', auto, '/min'];
            %text(2,17.2, '{dm}/{dt} = g c + a m - k', 'FontSize', 14, 'FontWeight', 'bold');
            %text(2,16.1, '{dk}/{dt} = m / \sigma - k / \tau', 'FontSize', 14, 'FontWeight', 'bold');
            %title('Autocatalytic');
        end
        text(2,16, msg, 'FontSize', 10);
        %text(2,14, 'c = 4.5, 10.8, 14.6, 23.8 beads', 'FontSize', 10);
 
    end


%%
    function e = ecart(p)
        dv = five(p) - experiment;
        e = sum(sum( dv .* dv ));
        %e = sum(sum( abs(dv) ));
    end

%%
    function [ m, b, d ] = experiment

        m = [
            4,   0.722469,   0.837048,   0.762250,   2.868417;
            8,   0.909937,   2.796095,   4.538312,   9.146083;
            11,   1.535187,   4.509429,   6.662937,  10.818417;
            14,   1.982250,   5.210190,   7.496562,  11.588250;
            16,   2.368188,   6.112429,   8.605375,  13.284833;
            19,   2.143844,   6.102000,   8.591437,  13.430917;
            22,   2.616750,   6.068714,   8.273125,  12.201083;
            24,   2.202469,   5.726333,   7.718875,  11.513250;
            27,   2.198531,   5.597952,   7.503250,  10.786250;
            30,   2.215344,   5.637476,   7.289375,  10.259083;
            33,   2.143531,   5.658476,   7.348813,  10.113667;
            36,   2.188219,   5.676810,   7.606437,  10.004000;
            39,   2.146031,   5.941190,   7.716125,   9.837167 ];

        %shift time by 3 minutes:
        m(:,1) = m(:,1) - 3;

        b = [ 4.5, 10.8, 14.6, 23.8 ];

        if ( 0 )
            %SEM
        d = [
            4,   0.067200 ,   0.148014 ,   0.078773 ,   0.586730 ;
            8,   0.176115 ,   0.452676 ,   0.471614 ,   0.843924 ;
            11,   0.241539 ,   0.408700 ,   0.366820 ,   0.736620 ;
            14,   0.249471 ,   0.327118 ,   0.368440 ,   0.649522 ;
            16,   0.288905 ,   0.328039 ,   0.449865 ,   0.625782 ;
            19,   0.321713 ,   0.306804 ,   0.541012 ,   0.691373 ;
            22,   0.282574 ,   0.297255 ,   0.512619 ,   0.593945 ;
            24,   0.276418 ,   0.284025 ,   0.474516 ,   0.653637 ;
            27,   0.274004 ,   0.269213 ,   0.461772 ,   0.594544 ;
            30,   0.254788 ,   0.285942 ,   0.425697 ,   0.628944 ;
            33,   0.278201 ,   0.265673 ,   0.427841 ,   0.569726 ;
            36,   0.283969 ,   0.264624 ,   0.438059 ,   0.605274 ;
            39,   0.302020 ,   0.294381 ,   0.409878 ,   0.634470 ];
        else
            %standard-deviation
        d = [
            4,   0.380139 ,   0.678286 ,   0.315092 ,   2.032492 ;
            8,   0.996259 ,   2.074424 ,   1.886455 ,   2.923438 ;
            11,   1.366349 ,   1.872897 ,   1.467279 ,   2.551726 ;
            14,   1.411223 ,   1.499042 ,   1.473760 ,   2.250011 ;
            16,   1.634294 ,   1.503263 ,   1.799459 ,   2.167774 ;
            19,   1.819884 ,   1.405953 ,   2.164048 ,   2.394986 ;
            22,   1.598478 ,   1.362194 ,   2.050478 ,   2.057485 ;
            24,   1.563658 ,   1.301566 ,   1.898062 ,   2.264265 ;
            27,   1.550003 ,   1.233689 ,   1.847089 ,   2.059561 ;
            30,   1.441300 ,   1.310352 ,   1.702786 ,   2.178726 ;
            33,   1.573742 ,   1.217466 ,   1.711365 ,   1.973590 ;
            36,   1.606372 ,   1.212660 ,   1.752235 ,   2.096729 ;
            39,   1.708482 ,   1.349022 ,   1.639512 ,   2.197869 ];
        end
    end

end


