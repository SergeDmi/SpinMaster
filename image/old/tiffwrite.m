function tiffwrite(filename, im)

global rows_per_strip BOS file;

rows_per_strip = 6;

nbframe = size(im,2)

BOS='l';

[ file, message ] = fopen(filename,'w', BOS);

%write header:
if ( BOS=='l' )
   fwrite(file, 'II', 'uchar', BOS);
else
   fwrite(file, 'MM', 'uchar', BOS);
end	

fwrite(file, 42, 'uint16', BOS);
fwrite(file, 1, 'uint32', BOS);

width  = size(im(1).data,1);
height = size(im(1).data, 2);	   

%writing image data:
for i=1:nbframe
   if (( width ~= size(im(i).data,1) ) | ( height ~= size(im(i).data,2) ))
      disp('error in data');
   end
   [strip_offset, strip_bytes] = write_strip(im(i).data);
   disp(['write image ', num2str(i)]);
end

%writing strip offset data:
info_273_pos = ftell(file);
fwrite(file, strip_offset, 'uint32', BOS);

%writing strip bytes data:
info_279_pos = ftell(file);
fwrite(file, strip_bytes, 'uint32', BOS);

%writing metamorph info 33629
info_33629_pos = ftell(file);
fwrite(file, im(1).metainfo2, 'uint32', BOS);

%writing metamorph info 33630
info_33630_pos = ftell(file);
fwrite(file, im(1).metainfo3, 'uint32', BOS);

%writing strip bytes data:
info_270_pos = ftell(file);
fwrite(file, im(1).info, 'uchar', BOS);

%writing 'software' info
info_305_pos = ftell(file);
fwrite(file, im(1).software, 'uint32', BOS);

%writing 'datetime' info
info_306_pos = ftell(file);
fwrite(file, im(1).datetime, 'uint32', BOS);

%writing 'datetime' info
info_33628_pos = ftell(file);
fwrite(file, im(1).metainfo1, 'uint32', BOS);

%writing 'datetime' info
info_33631_pos = ftell(file);
fwrite(file, im(1).metainfo4, 'uint32', BOS);


ifd_pos = ftell(file);


fwrite(file, 20, 'uint16', BOS);    %number of entries:

fwrite(file, [254 4], 'uint16', BOS);
fwrite(file, [1 im(1).NewSubfiletype], 'uint32', BOS);

fwrite(file, [256 4], 'uint16', BOS);
fwrite(file, [1 width], 'uint32', BOS);

fwrite(file, [257 4], 'uint16', BOS);
fwrite(file, [1 height], 'uint32', BOS);

fwrite(file, [258 3], 'uint16', BOS);
fwrite(file, 1, 'uint32', BOS);
fwrite(file, [16 0], 'uint16', BOS);

fwrite(file, [259 3], 'uint16', BOS);
fwrite(file, 1, 'uint32', BOS);
fwrite(file, [1 0], 'uint16', BOS);

fwrite(file, [262 3], 'uint16', BOS);
fwrite(file, 1, 'uint32', BOS);
fwrite(file, [im(1).photo_type 0], 'uint16', BOS);

fwrite(file, [270 2], 'uint16', BOS);
fwrite(file, [length(im(1).NewSubfiletype) info_270_pos], 'uint32', BOS);

fwrite(file, [273 4], 'uint16', BOS);
fwrite(file, [ length(strip_offset) info_273_pos], 'uint32', BOS);

fwrite(file, [278 4], 'uint16', BOS);      %   rows_per_strip
fwrite(file, [1 rows_per_strip], 'uint32', BOS);

fwrite(file, [279 4], 'uint16', BOS); 	   	%	strip_bytes
fwrite(file, [length(strip_bytes) info_279_pos], 'uint32', BOS);

fwrite(file, [282 5], 'uint16', BOS);
fwrite(file, 1, 'uint32', BOS);
fwrite(file, im(1).x_res, 'uint16', BOS);

fwrite(file, [283 5], 'uint16', BOS);
fwrite(file, 1, 'uint32', BOS);
fwrite(file, im(1).y_res, 'uint16', BOS);

fwrite(file, [296 3], 'uint16', BOS);
fwrite(file, 1, 'uint32', BOS);
fwrite(file, [im(1).res_unit 0], 'uint16', BOS);

fwrite(file, [305 4], 'uint16', BOS);
fwrite(file, [length(im(1).software) info_305_pos], 'uint32', BOS);

fwrite(file, [306 4], 'uint16', BOS);
fwrite(file, [length(im(1).datetime) info_306_pos], 'uint32', BOS);

fwrite(file, [317 3], 'uint16', BOS); %predictor
fwrite(file, 1, 'uint32', BOS);
fwrite(file, [1 0], 'uint16', BOS);

fwrite(file, [33628 4], 'uint16', BOS);
fwrite(file, [length(im(1).metainfo1) info_33628_pos], 'uint32', BOS);

fwrite(file, [33629 5], 'uint16', BOS);
fwrite(file, [nbframe info_33629_pos], 'uint32', BOS);

fwrite(file, [33630 5], 'uint16', BOS);
fwrite(file, [nbframe info_33630_pos], 'uint32', BOS);

fwrite(file, [33631 4], 'uint16', BOS);
fwrite(file, [nbframe info_33631_pos], 'uint32', BOS);



fwrite(file, 0,'uint32', BOS);

%writing ifd position
fseek(file, 4, 'bof');
fwrite(file, ifd_pos, 'uint32', BOS);

fclose(file);

function [ strip_offset, strip_bytes ] = write_strip( data )

global file BOS rows_per_strip;

fwrite(file, data, 'uint16', BOS);
bytes_per_row = 2 * size(data, 1) * rows_per_strip;
nb_strip = ceil( size(data, 2) / rows_per_strip );
strip_bytes = bytes_per_row * ones(nb_strip, 1);
strip_offset = 8 + bytes_per_row * [ 0:nb_strip-1 ]';
strip_bytes(nb_strip) = 2*size(data,1)*size(data, 2) - ( nb_strip-1) * bytes_per_row;

return