function show_poles(opt)

% show_poles(opt)
%
% display the poles, using the options in opt
%
% S. Dmitrieff, Nov 2012

filename='spindles.txt';
regions_filename='regions.txt';
if nargin
    if isfield(opt,'poles_filename')
        filename=opt.poles_filename;
    end
    if isfield(opt,'regions_filename')
        regions_filename=opt.regions_filename;
    end
end

regions=load_regions(regions_filename);
show_regions(image_base,regions);
spindles=load_objects(filename);
centers=region_centers(regions);

n_reg=size(regions,1);
n_spin=numel(spindles);
for i=1:n_reg
    plot(gca,centers(i,2),centers(i,1),'b*');
end
for i=1:n_spin
    pts=spindles{i}.pts;
    k=length(pts)/2;
    id=spindles{i}.id;
    center=centers(id,:);
    if k==1
        poles=pts;
        plot(gca,poles(2),poles(1),'r*')
        plot(gca,[poles(2) center(2)],[poles(1) center(1)],'b')
    elseif k>1
        poles=zeros(k,2);
        for j=1:k
            poles(j,1)=pts(2*j-1);
            poles(j,2)=pts(2*j);
        end
        poles
        plot(gca,poles(:,2),poles(:,1),'r*')
        plot(gca,poles(:,2),poles(:,1),'r')
        plot(gca,[poles(1,2) poles(end,2)],[poles(1,1) poles(end,1)],'r')
    end
end
        

end
