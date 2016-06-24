function spin_set_images(paths)

% function spin_set_images()
%
% create a matlab function 'image_list.m' that can give a list of images
%
% F. Nedelec, Oct 2012

warning('spin_set_images:deprecated', 'spin_set_images.m is deprecatd: use matned/image/make_image_list.m');

%% Find image files

if nargin < 1
    paths =  { '.', '..' };
end

for u = 1:numel(paths);
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
    warning('the pre-existing "%s" was renamed "%s.back"\n', output, output);
catch
end

fid = fopen(output, 'w');


%% Process images

fprintf(fid, 'function im = image_list\n\n');
fprintf(fid, 'global im;\n');
fprintf(fid, 'im = [];\n\n');

for u = 1 : numel(images);
    
    image=images{u};
    try
        list_image(image, fid);
    catch err
        fprintf('Error with %s\n', image);
        rethrow(err);
    end
    
end

fprintf(fid, '\n\n');
fprintf(fid, 'end\n\n');

fprintf(fid, '%%%%\n');
fprintf(fid, 'function rec = add(kind, name, varargin)\n');
fprintf(fid, 'global im;\n');
fprintf(fid, 'parser = inputParser;\n');
fprintf(fid, 'parser.addParamValue(''index'',    1);\n');
fprintf(fid, 'parser.addParamValue(''channel'',  1);\n');
fprintf(fid, 'parser.addParamValue(''time'',     0);\n');
fprintf(fid, 'parser.addParamValue(''position'', 0);\n');
fprintf(fid, 'parser.addParamValue(''isbase'',   0);\n');
fprintf(fid, 'parser.addParamValue(''back'',     0);\n');
fprintf(fid, 'parser.parse(varargin{:});\n');
fprintf(fid, 'rec = parser.Results;\n');
fprintf(fid, 'rec.file_name = name;\n');
fprintf(fid, 'rec.kind = kind;\n');
fprintf(fid, 'im = cat(2, im, rec);\n');
fprintf(fid, 'end\n');
fclose(fid);

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

%%
fprintf('Two files created: "image_list.m" and "image_base.m"\n');

end


%%
function cnt = list_image(filename, fid)

im = tiffread(filename);

for indx = 1 : numel(im)
    
    data = im(indx).data;
    
    nChannel = 1;
    if iscell(data)
        nChannel = size(data);
        fprintf('Multichannel image: %s\n', filename);
    end

    for channel = 1 : nChannel
        
        typeo=type_obs(filename);
        
        if iscell(data)
            back = image_background(data{channel});
        else
            back = image_background(data);
        end
        
        
        % store image
        fprintf(fid, 'add(''%s'', ''%s'' ', typeo, filename);
        fprintf(fid, ',''index'',%i ', indx);
        if channel ~= 1
            fprintf(fid, ',''channel'',%i ', channel);
        end
        fprintf(fid, ',''time'',%i ', 0);
        fprintf(fid, ',''position'',%i ', 0);
        fprintf(fid, ',''back'',%i);\n', back);
    end
    
end
end


%%
function images = find_images(path)

images = {};
files = dir(path);

for i = 1:numel(files)
    if files(i).isdir
        continue
    end
    filename = [path '/' files(i).name];
    [~, ~, ext] = fileparts(filename);
    if strcmp(ext, '.tif')
        images = cat(1, images, filename);
    elseif strcmp(ext, '.lsm')
        images = cat(1, images, filename);
    elseif strcmp(ext, '.stk')
        images = cat(1, images, filename);
    end
end
end
%%
function typeobs=type_obs(filename)
    [~, fname, ~] = fileparts(filename);
    tocheck='dna';
    typeobs='tub';
    if regexp(fname,tocheck,'ignorecase')
        typeobs='dna';
    end
end


