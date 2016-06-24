function struct = update_structure(struct, file_name, struct_name)

% saved_struct = update_structure(struct, file_name, struct_name)
%
% modify a matlab structure from an ascii file
% 1. The structure is loaded from file,
% 2. Values are modified as specified in argument `struct'
% 3. The updated structure is saved to file
%
%
% See also
% save_structure, load_structure
%
% F. Nedelec, 21 Nov. 2012


if nargin < 1 || ~isstruct(struct)
    error('First argument must be a structure');
end

if nargin < 2
    error('Second argument must be a file name');
end

%%

if ~isempty(dir(file_name))
    
    opt = load_structure(file_name);
    
    names = fieldnames(struct);

    for f = 1:length(names)
        n = names{f};
        opt.(n) = struct.(n);
    end
    
    struct = opt;
    
end


if nargin == 3
    save_structure(struct, file_name, struct_name);
else
    save_structure(struct, file_name);
end


end

