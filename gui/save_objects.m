function save_objects(objects, file_name, info)

% Save objects to a file, which by default is 'objects.txt'
%
% Syntax:
%            save_objects(objects, file_name)
%            save_objects(objects)
%
% The objects are saved in a column-based text file.
%
% See also
%      edit_objects, load_objects and show_objects
%
% F. Nedelec, 2012
% S. Dmitrieff 2012-2014

if nargin < 1
    file_name = 'objects.txt';
end

fid = fopen(file_name, 'wt');
fprintf(fid, '%% %s\n', date);

if nargin > 2
    if ~ischar(info)
        error('3rd argument should be info string');
    end
    fprintf(fid, '%% %s\n', info);
end

fprintf(fid, '%% id pt1_X pt1_Y ...\n');
fprintf(fid, '\n');

for n = 1:length(objects)
    if isfield(objects{n},'points')
        fprintf(fid, '%4i,', objects{n}.id);
        if isfield(objects{n},'info')
            fprintf(fid, ' %s,', objects{n}.info);
        else
            fprintf(fid, ' ,');
        end
        for d = 1:size(objects{n}.points, 1)
            fprintf(fid, '  %9.5f', objects{n}.points(d, 1:2));
        end
        fprintf(fid, '\n');
    end
end
fclose(fid);

fprintf('%i objects saved in %s\n', length(objects), file_name);


end
