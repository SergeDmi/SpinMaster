function save_structure(struct, file_name, struct_name)

% Save a matlab structure in a text file
%
% Syntax:
%     save_structure(struct, file_name)
%     save_structure(struct, file_name, struct_name)
%
% 
% The second form generates a valid matlab script that if executed
% would create or modify a matlab structure called 'struct_name'
%
% See also
% load_structure, update_structure
%
% F. Nedelec, 20 Nov. 2012

if nargin < 1 || ~isstruct(struct)
    error('First argument must be a structure');
end

if nargin < 2
    error('Second argument must be a file name');
end

%%
fid = fopen(file_name, 'wt');

if fid == -1
    return;
    error('Could not open file "%s"\n', file_name);
end

fprintf(fid, '%% matlab structure %s\n', inputname(1));
fprintf(fid, '%% automatically generated %s\n\n', date);


names = fieldnames(struct);

for f = 1:length(names)
    
    n = names{f};
    v = struct.(n);
    if isnumeric(v)
        vs = mat2str(v);
    else
        vs = v;
    end
    if nargin == 3
        fprintf(fid, '%s.%s = %s;\n', struct_name, n, vs);
    else
        fprintf(fid, '%16s = %s;\n', n, vs);
    end
    
end

fclose(fid);


    function res = mat2str(m)
        if numel(m) == 1
            res = num2str(m);
        else
            res = '[';
            sep = '';
            [ sz1, sz2 ] = size(m);
            for i = 1:sz1
                for j = 1:sz2
                    res = [res, sep, num2str(m(i,j))];
                    sep = ' ';
                end
                sep = '; ';
            end
            res = strcat(res, ']');
        end
    end
end

