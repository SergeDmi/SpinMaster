function [ points,state ] = spin_click_region(image, pMax , center, n_sp , adpt)

% function [points,state] = spin_click_regions(image,pMax,center_n_sp)
% Analyse spindle shape with mouse-clicks
%
% S. Dmitrieff, Nov. 2012

if nargin<1 || isempty(image)
   error('You must provide an image');
end
if nargin<2
    pMax=4;
end
if nargin<3
    center=[(1+size(image,1))/2,1+size(image,2)/2];
end
if nargin<4
    n_sp=1;
end
if nargin < 5
    adpt=0;
end

show_image(image);
text( center(2), center(1), sprintf('%i',n_sp), 'Color', 'b', 'FontSize', 14);
if adpt
    plot(gca,adpt(2),adpt(1),'g*');
end
% We click the images one by one:
inx = 1;
state=0;
points=[];

while inx < pMax+2
    % Waits for extra click even if pMax points are clicked
    % Makes sure there is no mistake on the last point
    g = mouse_points(1);
    hFig = gcf;
    k = get(hFig , 'CurrentCharacter');
    if g
        inx=inx+1;
        points=[points ; g(1), g(2)]; 
        state=state+1; 
        plot(gca,g(2),g(1),'r*')
    elseif k == 'c'
        %redo the clicking
        inx=1;
        state=0;
        points=[];
        hFig = gcf;
        close(hFig);        
        show_image(image);
        text( center(2), center(1), sprintf('%i',n_sp), 'Color', 'b', 'FontSize', 14);
        if adpt
            plot(gca,adpt(2),adpt(1),'g*');
        end
    elseif k == ' '
        hFig = gcf;
        close(hFig);
        return;
    elseif k == 'd'
        points = [];
        state=-1;
        hFig = gcf;
        close(hFig);
        return;
    end
end

% We keep only the pMax first points
state=pMax;
points=points(1:pMax,:);
% And we close
hFig = gcf;
close(hFig);


end
