function opt=select_image(opt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
list=image_list();
nim=numel(list);
disp('Choose file from list :');
for n=1:nim
    [~, fname, ~] = fileparts(list(n).file_name);
    disp([num2str(n) '- ' fname]);
end
i=floor(input('Your choice : '));

%fprintf('Also set as region file ? \n 1) Yes \n 0) No \n');
%choice=input('Your choice    ');
if i
    if i>0 && i<=nim
        fid = fopen('image_base.m', 'w');
        fprintf(fid, 'function image = image_base()\n');
        fprintf(fid, '%% Please, choose the reference image\n');
        fprintf(fid, '%% by setting "base" below\n');
        fprintf(fid, '\n');
        fprintf(fid, 'list = image_list;\n');
        fprintf(fid, '\n');
        fprintf(fid, 'base = list(%s);\n',num2str(i));
        fprintf(fid, '\n');
        fprintf(fid, 'image = spin_load_pixels(base);\n');
        fprintf(fid, '\n');
        fprintf(fid, 'end\n');
        fclose(fid);
        [~, fname, ~] = fileparts(list(i).file_name);
        opt.base=i;
        %if choice
        %    opt.regions_filename=sprintf('regions_%s.txt',fname);
        %end
        opt.poles_filename=sprintf('spindles_%s.txt',fname);
        opt.analysis_filename=sprintf('analysis_%s.txt',fname);
    end
else
    disp('Unchanged image file');
end
rehash
end

