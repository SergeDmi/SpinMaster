function spin_plot_beads(opt)

% spots = spin_plot_beads(kind)
%
% display the regions on the given image, or on the current image
%
% F. Nedelec, Jan. 2008


% ------------- read ----------------

try
    res = load('results_beads.txt');
catch
    return
end

% ------------ display --------------

im = spin_load_images('dna',1);
show_image(im);

hold on;

% format [ idr, x_inf, y_inf, x_sup, y_sup, bead-count ]
for n = 1:size(res,1)
    
    region = res(n,2:5);
    beads  = res(n,6);
    image_drawrect(region, 'g-', num2str(beads));
        
end

end