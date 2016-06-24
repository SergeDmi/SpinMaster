function spin_set_images

% function spin_set_images(position)
%
% store information on the images in a file 'images.txt'
%
% F. Nedelec, Feb 2008


%% Find image files
dirlist =  { './'; '../' };
for ndir = 1:length(dirlist);
    fdir = dirlist{ndir};
    files = dir([fdir,'*.lsm']);
    if size(files,1) == 0
        disp(['No image found in directory ', fdir]);
        continue;
    else
        break;
    end
end

if size(files,1) == 0
    error('No images found');
end


%% Process images
cnt = 0;
for u = 1 : size(files, 1);

    if ~ files(u).isdir
        
        name  = [fdir, files(u).name];
        kind  = 'tub';

        %check for DNA
        e = strfind(lower(files(u).name), 'dna');
        if ~isempty(e)
            fprintf('Guessing that "%s" has DNA\n', name);
            kind = 'dna';
        end
            
        % attempt to find time information:
        time = find_time_new(name);
        if isempty(time)
            user_input = input(['enter time for "', name,'" or "enter" to skip it: '], 's');
            time = str2num(user_input);
            if isempty(time)
                kind = 'skip';
                time = -1;
            end
        else
            fprintf('Time(%s) = %d\n', name, time);
        end

        % attempt to find position information:
        pos = find_position(name);
        if isempty(pos)
            pos = -1;
        end
        
        % load the first image in the file:
        im = tiffread(name, 1);
        
        nb_im = 1;
        if iscell(im.data)
            nb_im = length(im.data);
        end
        
        for indx = 1 : nb_im
            
            % find background:
            if iscell(im.data)
                back = image_background(im.data{indx});
            else
                back = image_background(im.data);
            end

            % store image
            cnt = cnt + 1;
            res(cnt).name = name;
            res(cnt).indx = indx;
            res(cnt).kind = kind;
            res(cnt).time = time;
            res(cnt).pos  = pos;
            res(cnt).back = back;
            res(cnt).gain = 1;

            
            if  ( nb_im > 1 ) && ( indx == 1 )
                fprintf('Guessing that "%s" has DNA in channel 1\n', name);
                res(cnt).kind = 'dna';
            end
        end

    end

end


%% sort images by time:
[time, indx] = sort(cat(1, res.time));


%save the results
fid = fopen('images.txt', 'w');
fprintf(fid, '%%%-40s  index    kind      time  background   gain    position\n', 'file');
for i = 1:cnt
    u = indx(i);
    fprintf(fid, '%-40s  %3i    %5s    %6i   %6i   %6i   %6i\n',...
        res(u).name, res(u).indx, res(u).kind, res(u).time, res(u).back, res(u).gain,  res(u).pos);
end
fclose(fid);
fprintf( 'Listed %i files in "images.txt"\n', cnt);

%open file in editor:
open images.txt;

end





function time = find_time(name)
time = [];
e = strfind(name, 'min');
if ~isempty(e)
    s = e(1);
    while  s > 1  &&  isstrprop(name(s-1),'digit')
        s = s - 1;
    end
    time = sscanf(name(s:e+2), '%i min');
end
end

function time = find_time_new(name)
time = [];
s = min( strfind(name, '_') );
if ~isempty(s)
    s = s+1;
    e = s;
    while  e < size(name,2)  &&  isstrprop(name(e),'digit')
        e = e + 1;
    end
    time = sscanf(name(s:e-1), '%i');
end
end

function pos = find_position(name)
pos = [];
e = strfind(name, 'pos');
if ~isempty(e)
    s = e(1);
    while  s > 1  &&  isstrprop(name(s-1),'digit')
        s = s - 1;
    end
    pos = sscanf(name(s:e), '%i');
end

if name(1) == 'R'
    s = 2;
    while  s <= length(name)  &&  isstrprop(name(s),'digit')
        s = s + 1;
    end
    pos = sscanf(name(2:s-1), '%i');
end
end
            

