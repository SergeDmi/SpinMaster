function regions = load_regions(filename)

% regions = load_regions()
%
% load the regions from the file 'regions.txt'
%
% F. Nedelec, Feb. 2008

regions = [];

if nargin < 1
    filename = 'regions.txt';
end

fid = fopen(filename, 'rt');

if  fid < 0 
    error('Could not open file "regions.txt"');
end

line = fgets(fid);

while line ~= -1
    
    [id, ~, err, indx] = sscanf(line, '%d', 1);
    
    if isempty(err)  &&  ~isempty(id)
        
        pts = sscanf(line(indx:length(line)), '%f')';
        
        if length(pts) == 4
            rec = make_rectangle(pts);
            reg = double( [ id, rec] );
            regions = cat(1, regions, reg);
        end
    end
    
    line = fgets(fid);
    
end

fclose(fid);


    function rec = make_rectangle(pts)
        pX = sort([pts(1), pts(3)]);
        pY = sort([pts(2), pts(4)]);
        rec = [pX(1), pY(1), pX(2), pY(2)];
    end

end
