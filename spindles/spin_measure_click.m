function [ res, self, info ] = spin_measure_click(dna, tub, opt, self)

% function [ res, self , info] = spin_measure_click(dna, tub, opt, self)
% Analyse spindle shape with mouse-clicks
%
% F. Nedelec, March 2008

%max number of clicks
pMax = 5;

%build the info string:
if nargout > 2
    info = [];
    for i = 1:size(tub,3)
        nb = num2str(i);
        inf{1} = ['nPoints', nb];
        for n = 1:pMax
            inf{2*n}   = ['X', nb, '_', num2str(n)];
            inf{2*n+1} = ['Y', nb, '_', num2str(n)];
        end
    info = cat(2, info, inf);
    end
    
end

%set private data
if isempty(self)
    mag = 5;
    W = max(size(dna));
    D = mag * W;
    figure('Name', 'Click!', 'MenuBar','None', 'Position', [400 150 D, D]);
    self = axes('Units', 'pixels', 'Position', [1 1 D D] );
    
    %user guide:
    disp('Press: "c" to redo the click');
    disp('       "n" to skip this spot');
    disp('       "q" to quit');
    disp('       "space" to go to the next image');
    disp(['Only the first ', num2str(pMax), ' clicks will be saved']);
end


% We click the images one by one:
inx = 1;
res = zeros(1, size(tub,3) * (pMax*2+1));

while inx <= size(tub,3)
    
    im = tub(:,:,inx) - mean(mean(tub(:,:,inx)));

    %clear figure
    cla(self);
    show_image(im, 'Handle', self);
    g = mouse_points(pMax);
    k = get(get(self, 'Parent'), 'CurrentCharacter');

    if k == 'c'
        %redo the clicking
    elseif k == 'n'
        return;
    elseif k == 'q'
        res = [];
        return;
    else
        %allow for pMax points max:
        np  = min(pMax, size(g,1));
        res((inx-1)*(pMax*2+1) + 1) = np;
        res((inx-1)*(pMax*2+1) + (2:1+2*np ) ) = reshape(g', 2*np, 1);
        inx = inx + 1;
    end
    
end

end
