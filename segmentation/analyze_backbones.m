function analyze_backbones(image,tiling,opt)

% spindles = save_regions(spindles, filename)
% Save the spindles to file filename or 'spindles.txt'(default)
% S. Dmitrieff, Nov 2012

filename='spindles.txt';
regfilename='regions.txt';
if nargin<2 
    tiling=[];
    opt=[];
elseif nargin < 3
    opt=[];
end
[~,maxang]=check_options('max_bipo_ang',opt);
[opt,npmax]=check_options('max_polarity',opt);

if  isfield(image, 'data') 
    if ( length(image) > 1 ) 
        disp('show_image displaying picture 1 only');
    end
    image = image(1).data;
end
% compatibility with tiffread color image
if  iscell(image)    
    tmp = image;
    image = zeros([size(tmp{1}), 3]);
    try
        for c = 1:numel(tmp)
            image(:,:,c) = tmp{c};
        end
    catch
        disp('show_image failed to assemble RGB image');
    end
    clear tmp;
end
if isfield(opt,'radius')
    rad=opt.radius;
else
    defopt=spin_default_options();
    rad=defopt.radius;
end
if isempty(tiling)
    answer=inputdlg({'Number of images horizontally', 'Number of images vertically'},...
        'Input',2,{'3','3'});
    vsize = str2double(answer{1});
    hsize = str2double(answer{2});
else
    vsize=tiling(1);
    hsize=tiling(2);
end 

image=flatten_background(image,[hsize vsize]);
SI=size(image);

spindles=load_objects(filename);
regions=load_objects(regfilename);
n_reg=numel(regions);
n_spindles=numel(spindles);

sp_int=cell(1,npmax+1);
sp_anglen=cell(1,npmax+1);
%sp_pts=cell(1,npmax+1);
spind_count=zeros(1,npmax+1);

%Good bipolar spindles
bipos_int=cell(3,3);
bipos_anglen=cell(3,3);

analysis=[];
n_bipos=1;
%% Analysis of spindles
for i=1:n_spindles
    spindle=spindles{i};
    points=spindle.points;
    np=size(points,1);
    if np>0
        center=points(1,:);
        spind_count(np)=spind_count(np)+1;
        k=spind_count(np);
        sp_int{np}{k}.id=spindle.id;
        coords=[center center]-[rad rad -rad -rad];
        %Get the region
        regn=spindle.id;
        ix=object_index(regn,regions);
        if (ix>0) && ix < n_reg
            coordreg=round(regions{ix}.pts);
            %Check if region is correct
            if isin(center,coordreg)
                coords=coordreg;
            else 
                disp('Center not in expected region');
            end
        end
        coords(1)=max( round(coords(1)) , 1);
        coords(2)=max( round(coords(2)) , 1);
        coords(3)=min( round(coords(3)) , SI(1));
        coords(4)=min( round(coords(4)) , SI(2));
        
        intens=spin_measure_mass([],image(coords(1):coords(3),coords(2):coords(4)));
        sp_int{np}{k}.points=[intens 0];
        sp_anglen{np}{k}.id=spindle.id;
        %sp_pts{np}{k}.id=spindle.id;
        if np>1
            lengths=aster_lengths(points)';
            angles = aster_angles(points)';
            sp_anglen{np}{k}.points=[angles lengths];
            %sp_pts{np}{k}.points=points(2:np,:)-ones(np-1,1)*center;
            
            %% Only bipolar spindles
            if np==3
                ang=abs(abs(angles(1)-angles(2))-pi);
                if maxang>ang
                    % This looks like a bipolar spindle
                    bipos_anglen{np}{n_bipos}.points=[angles lengths];
                    bipos_int{np}{n_bipos}.points=[intens 0];
                    bipos_anglen{np}{n_bipos}.id=spindle.id;
                    bipos_int{np}{n_bipos}.id=spindle.id;
                    n_bipos=n_bipos+1;
                end
            end
            
            
        else
            sp_anglen{np}{k}.points=[0 0];
            %sp_pts{np}{k}.points=[0 0];
        end
    end
end

%Saving
for i=1:npmax
    if spind_count(i)>0
        fname=[num2str(i-1) '_polar_'];
        fname_int=[fname 'intens.txt'];
        fname_anglen=[fname 'angle_length.txt'];
        %fname_pts=[fname 'points.txt'];
        save_objects(sp_anglen{i},fname_anglen);
        save_objects(sp_int{i},fname_int);
        %save_objects(sp_pts{i},fname_pts);
        if i==3
            bname='bipolar_';
            bname_int=[bname 'intens.txt'];
            bname_anglen=[bname 'angle_length.txt'];
            save_objects(bipos_anglen{i},bname_anglen);
            save_objects(bipos_int{i},bname_int);
        end
    end
end


%Utilities
    function res = object_index(ids,objects)
        res=0;
        for idx = 1 : numel(objects)
            if any( objects{idx}.id == ids )
                res = idx;
            end
        end
    end

    function in=isin(point,regpoints)
        in=0;
        if ( point(1) < max(regpoints([1,3])) )   && (point(1) > min(regpoints([1,3]))) && (point(2) < max(regpoints([2,4]))) && (point(2) > min(regpoints([2,4])))
            in=1;
        end
    end


end
