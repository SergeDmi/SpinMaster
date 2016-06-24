function opt=select_dna(opt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
list=image_list();
nim=numel(list);
disp('Choose file from list :');
for n=1:nim
    [~, fname, ~] = fileparts(list(n).file_name);
    disp([num2str(n) '- ' fname]);
end
disp('First choose DNA file :');
dna=floor(input('Your choice :     '));
if dna
    fid = fopen('image_base.m', 'w');
    fprintf(fid, 'function image = image_base()\n');
    fprintf(fid, '%% Please, choose the reference image\n');
    fprintf(fid, '%% by setting "base" below\n');
    fprintf(fid, '\n');
    fprintf(fid, 'list = image_list;\n');
    fprintf(fid, '\n');
    fprintf(fid, 'base = list(%s);\n',num2str(dna));
    fprintf(fid, '\n');
    fprintf(fid, 'image = spin_load_pixels(base);\n');
    fprintf(fid, '\n');
    fprintf(fid, 'end\n');
    fclose(fid);
    [~, fname, ~] = fileparts(list(dna).file_name);
    opt.base=dna;
    opt.regions_filename=sprintf('regions_%s.txt',fname);
else
    disp('Unchanged image file');
end
rehash;
end

