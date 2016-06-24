function [ clickets ] = click_intermediates( image , opt )
%Find points between poles and center
%   2 possible modes
% S. Dmitrieff, dec 2012
if nargin<1
    error('You must provide an image')
elseif isempty(image)
    error('You must provide a valid image')
end
if nargin==2 
    if isfield(opt,'seg_number')
        nc=opt.seg_number;
    else
        defopt=spin_default_options;
        nc=defopt.seg_number;
    end
end

spindles=load_object('spindles.txt');

% Getting clicks
disp('Input methods for clicks :');
disp( '0) Manually enter points.');
disp( '1) Auto points');
is_auto=input('Your choice    ');
   

for n = 1:n_spin
    sp=spindles{n};
	poles=sp.points;
    sip=size(poles);
    state=sip(1);
	if state>0
		r=sp.id;
		coords=regions(r,2:5);
        center=[(coords(1)+coords(3))/2,(coords(4)+coords(2))/2];
        pos_center=center - [coords(1),coords(2)];
        if coords(1)<1
            pos_center(1)=pos_center(1)+coords(1)-1;
            coords(1)=1;
        end
        if coords(2)<1
            pos_center(2)=pos_center(2)+coords(2)-1;
            coords(2)=1;
        end
        coords(3)=min(coords(3),xmax);
        coords(4)=min(coords(4),ymax);
        im=image(coords(1):coords(3),coords(2):coords(4));
        im=im-image_background(im);
        % 1 > Mono- and bi- polar spindles
        if state<=npmax 
            %Getting the clicks
            lengs=zeros(state,nc);
            for s=1:state
                clicks=zeros(nc+1,2);
                clicks(nc+1,:)=poles(s,:);
                clicks(1,:)=pos_center;
                if is_auto
                    dc=(poles(s,:)-pos_center)/nc;
                    for i=1:nc-1
                        clicks(i+1,:)=clicks(i,:)+dc;
                    end
                else
                    show_image(im);
                    st=0;
                    while st~=nc-1
                        [points,st]=spin_click_region(im,nc-1,pos_center,r,poles(1,:));
                    end
                    clicks(2:nc,:)=points;
                end
            end
        clickets(n).pts=clicks;
        clickets(n).id=r;
        end
    end
end

