function make_inherited_list(images)

% Create a list with one image
%
% Syntax:
%            make_image_list(image)
%
% Creates a file 'image_list.m' in the current working directory,
% that is a valid matlab function returning a list of one image,
% with meta-data associated in a vector of structs,
%
% 
% S. Dmitrieff March  2013


%% Define images

if nargin < 1
    error('Not enough arguments');
elseif isempty(images)
    error('Empty argument');
elseif ~isfield(images(1),'back')
    error('Invalid argument : must be a list of image_list items')
end

nim=numel(images);



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

for i=1:nim
    list_image(fid,images(i));
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





%%
function cnt = list_image(fid,im)
% store image parameters
%fprintf(fid, 'add(''%s'', ''%s'' ', im.kind, ['../' im.file_name]);
iname=im.file_name;
iname=strrep(iname,'./','../');
fprintf(fid, 'add(''%s'', ''%s'' ', im.kind, iname);
fprintf(fid, ',''index'',%i ', im.index);
fprintf(fid, ',''channel'',%i ', im.channel);
fprintf(fid, ',''time'',%i ', im.time);
fprintf(fid, ',''position'',%i ', im.position);
fprintf(fid, ',''back'',%i', im.back);
fprintf(fid, ');\n');
end


end



