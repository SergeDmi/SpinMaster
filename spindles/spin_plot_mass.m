function spin_plot_mass(opt)

% function spin_plot_mass
%
% Display results of the analysis stored in "results_mass.txt"
%
% F. Nedelec,   Feb. 2008

%% Load DNA

if nargin < 1
    opt.visual = 0;
end

if opt.visual > 3
    spin_plot_mass_all
end

try
    dna.data = load('results_dna.txt');
catch
    error('File "results_dna.txt" not found');
end
dna.fluo = dna.data(:, 6);
dna.area = dna.data(:, 7);

try
    res = load('results_beads.txt');
    dna.beads = res(:, 6);
catch
    dna.beads = [];
end

% transform Fluorescence into meaningful units
dna.cal = spin_calibrated_dna('DNA fluorescence');
%figure, plot(dna.fluo, dna.cal.val, '.');


%% Load Tubulin images

TUB = spin_load_images('tub', [], setfield(opt, 'load_pixels', 0));

tub.time = zeros(1,length(TUB));
tub.gain = zeros(1,length(TUB));

for i = 1:length(TUB)
    tub.time(1,i) = TUB(i).time;
    if isfield(TUB(i), 'gain')
        tub.gain(1,i) = TUB(i).gain;
    else
        tub.gain(1,i) = 1;
    end
end

%%shift time by 3 minutes to match nucleation time
% tub.time = tub.time-3; %only for Cell's paper

clear TUB;

%% Load Tubulin fluoresccence

try
    res = load('results_mass.txt');
    %we skip Region ID and coordinates in the first 5 columns
    tub.fluo = res(:, 6:size(res,2));
catch
    error('File "results_mass.txt" not found');
end


try
    res = load('results_area.txt');
    tub.area = res(:, 6);
catch
    error('File "results_area.txt" not found');
end


%% Plot time - tubulin


if ( 1 )
    figure('Name', 'Background subtracted fluorescence');
    plot( tub.time, tub.fluo );
    xlabel('Time (min)', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Tubulin', 'FontSize', 16, 'FontWeight', 'bold');
end


%% Plot Beads -> Tubulin Fluo with 4 categories dependin on bead count

if ( size(dna.beads,1) == size(tub.fluo,1) ) 
    
    for c=1:5
        k = num2str(c);
        eval(['beads',k,'=[];']);
    end

    for n = 1:length(tub.time);
                
        for c=1:5
            k = num2str(c);
            eval(['val',k,'=[];']);
        end
 
        for p = 1:size(tub.fluo,1)
            
            bd=dna.beads(p);
            if bd < 9
                c = 1;
            elseif bd < 13
                c = 2;
            elseif bd < 18
                c = 3;
            else
                c = 4;
            end
            
            k = num2str(c);
            cmd = ['val',k,'=cat(1,val',k,', tub.fluo(p,n));'];
            eval(cmd);
                    
            if n == 1
                eval(['beads',k,'=cat(2,beads',k,', bd);']);
            end

        end

        for c=1:4
            k = num2str(c);
            eval(['avg(n,',k,')=mean(val',k,');']);
            eval(['dev(n,',k,')=std(val',k,');']); %/sqrt(length(val',k,'));
        end
    end
    
    for c=1:4
        k = num2str(c);
        eval(['bd=mean(beads',k,');']);
        cmd = ['fprintf(''%i spots in category %i: avg %.1f beads\n'', length(val',k,'), c, bd)'];
        eval(cmd);
    end
    
    figure('Name', 'Background subtracted fluorescence');
    plot( tub.time, tub.fluo, '--b');
    set(gca, 'Box', 'on', 'FontSize', 24);
    xlabel('Time (min)', 'FontSize', 30);
    ylabel('Tubulin (a.u.)', 'FontSize', 30);
    xlim([0, 40]);
    ylim([0, 15]);
    hold on;
   
    if 1
        ms=14;
        syb = 'odv^s';
        for i = 1:4
          plot(tub.time, avg(:,i), 'k-', 'LineWidth', 2);
          plot(tub.time, avg(:,i), ['k',syb(i)], 'MarkerSize', ms, 'LineWidth', 1, 'MarkerFaceColor', 'k');
            %errorbar(tub.time, avg(:,i), std(:,i));
        end
    end

    %save the experimental (average) data
    fid = fopen('time-mass.txt', 'wt');
    fprintf(fid, 'mean:\n');
    for t=1:size(tub.time,1)
        fprintf(fid, '%5.0f', tub.time(t));
        for c=1:size(avg,2)
            fprintf(fid, ', %10f ', avg(t,c));
        end
        fprintf(fid, ';\n');
    end

    fprintf(fid, 'standard-deviation:\n');
    for t=1:size(tub.time,1)
        fprintf(fid, '%5.0f', tub.time(t));
        for c=1:size(avg,2)
            fprintf(fid, ', %10f ', dev(t,c));
        end
        fprintf(fid, ';\n');
    end

    fclose(fid);
    fprintf('saved results in file time_mass.txt\n');
    
end


%% Plot dna - tubulin

if ( 0 )
    figure('Name', 'Background subtracted');
    plot( dna.fluo, tub.fluo, '.');
    xlabel('DNA (a.u.)', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Tubulin (a.u.)', 'FontSize', 16, 'FontWeight', 'bold');
end


if ( 1 )
    %make a plot where the color indicates time
    figure('Name', 'Color-coded time');
    hold on;
    nTimes = length(tub.time);
    for n = 1:nTimes
        x = (nTimes-n)/nTimes;
        rgb = [ x x x ];         %color is a function of time
        plot( dna.cal.val, tub.fluo(:,n), 'o', 'MarkerSize', 8, 'MarkerFaceColor', rgb, 'MarkerEdgeColor', 'k');
    end
    set(gca, 'FontSize', 16, 'FontWeight', 'bold');
    xlabel(['DNA (', dna.cal.dest, ')'], 'FontSize', 18, 'FontWeight', 'bold');
    ylabel('Tubulin (a.u.)', 'FontSize', 18, 'FontWeight', 'bold');
end


%% Make a nicer plot with X = calibrated DNA fluorescence

if ( 1 )

    figure('Name', 'Transformed DNA fluorescence');
    hold on;
     
    nTimes = length(tub.time);
    for n = 1:nTimes
        for p = 1:size(tub.fluo,1)
            
            face = [ 1 1 1 ];
            edge = [ 0 0 0 ];
            if tub.area(p) < 10
                %face = [ 1 0 0 ];
                edge = [ 1 0 0 ];
            end
            if dna.area(p) < 10 || ( p < size(dna.beads,1) && dna.beads(p) == 0 )
                %face = [ 0 0 1 ];
                edge = [ 0 0 1 ];
            end
 
            plot( dna.cal.val(p), tub.fluo(p,n), 'o', 'LineWidth', 2, ...
                'MarkerSize', 8, 'MarkerFaceColor', face, 'MarkerEdgeColor', edge);
         
        end
    end
    %xlim([0 32]);
    set(gca, 'Box', 'on', 'FontSize', 24);
    xlabel(dna.cal.dest, 'FontSize', 30);
    ylabel('Tubulin (a.u.)', 'FontSize', 30);
    
end



%% Make a nice plot, if the beads were counted

if size(dna.beads,1) == size(tub.fluo,1)

    figure('Name', 'Transformed DNA fluorescence');
    hold on;
    
    %commandwindow;
    %dna_per_bead = input('Amount of DNA per beads (pico-grams)?');
    a = inputdlg('Amount of DNA per beads (pico-grams)?','Input',1,{'5'});
    dna_per_bead = str2double( a{1} );
 
    nTimes = length(tub.time);
    for n = 1:nTimes
        x = (nTimes-n)/nTimes;
        for p = 1:size(tub.fluo,1)
            
            face = [ x x x ];
            edge = [ 0 0 0 ];
            if tub.area(p) < 10
                face = [ 1 1 1 ];
                edge = [ 1 0 0 ];
            end
            if dna.area(p) < 10 || ( p < size(dna.beads,1) && dna.beads(p) == 0 )
                face = [ 1 1 1 ];
                edge = [ 0 0 1 ];
            end
 
            plot(dna_per_bead*dna.beads(p), tub.fluo(p,n), 'o',...
                'MarkerSize', 8, 'MarkerFaceColor', face, 'MarkerEdgeColor', edge);
         
        end
    end
    set(gca, 'FontSize', 16, 'FontWeight', 'bold');
    xlabel('DNA (pico-grams)', 'FontSize', 18, 'FontWeight', 'bold');
    ylabel('Tubulin (a.u.)', 'FontSize', 18, 'FontWeight', 'bold');
else
    disp('Bead count not available');
end

end