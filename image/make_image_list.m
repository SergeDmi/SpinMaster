function make_image_list(paths)

% Create a list of images
%
% Syntax:
%            make_image_list()
%            make_image_list(paths)
%
% Creates a file 'image_list.m' in the current working directory,
% that is a valid matlab function returning a list of images,
% with meta-data associated in a vector of structs,
%
% The images are those found in directories specified by 'paths'.
% By defaults, paths includes the current working directory and its parent.
%
% F. Nedelec, Oct-Nov 2012


%% Find image files

if nargin < 1
    paths = { '.', '..' };
end

for u = 1:length(paths);
    images = find_images(paths{u});
    if ~isempty(images)
        break;
    end
end

if isempty(images)
    error('No images found');
end

%% Open output

output = 'image_list.m';

try
    movefile(output, [output, '.back']);
    fprintf(2, 'The pre-existing "%s" was renamed "%s.back"\n', output, output);
catch
end

fid = fopen(output, 'w');


%% Process images

fprintf(fid, 'function im = image_list\n\n');
fprintf(fid, 'im = [];\n\n');

for u = 1 : length(images);
    
    image=images{u};
    try
        list_image(image, fid);
    catch err
        fprintf('Error with %s\n', image);
        rethrow(err);
    end
    fprintf(fid, '\n');
    
end

fprintf(fid, '\n\n');

fprintf(fid, '%%%%\n');
fprintf(fid, '    function rec = add(kind, name, varargin)\n');
fprintf(fid, '        parser = inputParser;\n');
fprintf(fid, '        parser.addParamValue(''index'',    1);\n');
fprintf(fid, '        parser.addParamValue(''channel'',  1);\n');
fprintf(fid, '        parser.addParamValue(''time'',     0);\n');
fprintf(fid, '        parser.addParamValue(''position'', 0);\n');
fprintf(fid, '        parser.addParamValue(''back'',     0);\n');
fprintf(fid, '        parser.parse(varargin{:});\n');
fprintf(fid, '        rec = parser.Results;\n');
fprintf(fid, '        rec.file_name = name;\n');
fprintf(fid, '        rec.kind = kind;\n');
fprintf(fid, '        im = cat(1, im, rec);\n');
fprintf(fid, '    end\n\n');
fprintf(fid, 'end\n');
fclose(fid);

fprintf(2, 'Created "image_list.m"\n');

%%

fid = fopen('image_base.m', 'w');

fprintf(fid, 'function image = image_base()\n');
fprintf(fid, '%% Please, choose the reference image\n');
fprintf(fid, '%% by setting "base" below\n');
fprintf(fid, '\n');
fprintf(fid, 'list = image_list;\n');
fprintf(fid, '\n');
fprintf(fid, 'base = list(1);\n');
fprintf(fid, '\n');
fprintf(fid, 'image = spin_load_pixels(base);\n');
fprintf(fid, '\n');
fprintf(fid, 'end\n');
fclose(fid);

fprintf(2, 'Created "image_base.m"\n');

end


%%

function res = guess_kind(filename)
    [~, fname, ~] = fileparts(filename);
    tocheck='dna';
    res='tub';
    if regexp(fname,tocheck,'ignorecase')
        res='dna';
    end
end

function res = guess_position(filename)
res = 0;
end

function res = guess_time(filename)
res = 0;
end


%%
function cnt = list_image(filename, fid)

im = tiffread(filename);

for i = 1 : length(im)
    
    data = im(i).data;
    indx = im(i).index;
    
    nChannel = 1;
    if iscell(data)
        nChannel = size(data);
        fprintf('Multichannel image: %s\n', filename);
    end

    for channel = 1 : nChannel
        
        if iscell(data)
            back = image_background(data{channel});
        else
            back = image_background(data);
        end
        
       
        % store image parameters
        fprintf(fid, 'add(''%s'', ''%s'' ', guess_kind(filename), filename);
        fprintf(fid, ',''index'',%i ', indx);
        if channel ~= 1
            fprintf(fid, ',''channel'',%i ', channel);
        end
        fprintf(fid, ',''time'',%i ', guess_time(filename));
        fprintf(fid, ',''position'',%i ', guess_position(filename));
        fprintf(fid, ',''back'',%i', back);
        fprintf(fid, ');\n');
        
    end
end

end


%%

function res = find_images(path)

res = {};
files = dir(path);

for i = 1:length(files)
    if files(i).isdir
        continue
    end
    filename = [path '/' files(i).name];
    [~, ~, ext] = fileparts(filename);
    if strcmp(ext, '.tif')
        res = cat(1, res, filename);
    elseif strcmp(ext, '.lsm')
        res = cat(1, res, filename);
    elseif strcmp(ext, '.stk')
        res = cat(1, res, filename);
    end
end

end


