function objects = load_objects(file_name)

% Load objects from file
%
% Syntax:
%          objects = load_objects(file_name)
%
% See also
% save_objects, load_objects and edit_objects
%
% F. Nedelec, Feb. 2008 - 2012
% S. Dmitrieff 2012-2014

if nargin < 1
    file_name = 'objects.txt';
end 

%test

fid = fopen(file_name, 'rt');

if fid == -1
    error('Could not find file "%s"\n', file_name);
end

objects = {};

line = fgets(fid);

while line ~= -1
    
    [id, ~, err, indx] = sscanf(line, '%d', 1);
    
    if isempty(err)  &&  ~isempty(id)
        
        line = line(indx:length(line));
        info = '';
        if line(1) == ','
            line = line(2:length(line));
            [info, ~, err, indx] = sscanf(line, '%s', 1);
            l=length(info);
            if info(l) ~= ','
                error('missing comma');
            end
            if l>1
                info=info(1:l-1);
            else
                info='';
            end
            line = line(indx+1:length(line));
        end
    end
    
    if isempty(err)  &&  ~isempty(id)
        
        pts = sscanf(line, '%f')';
        
        obj.id = id;
        obj.info = info;
        obj.pts = pts;
        obj.points = reshape(pts, 2, length(pts)/2)';
        
        objects = cat(1, objects, obj);
        
    end
    
    line = fgets(fid);
    
end
fclose(fid);

%fprintf('%i objects loaded from %s\n', length(objects), file_name);

 
end
