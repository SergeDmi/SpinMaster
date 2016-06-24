function [t] = get_time(img_obj,di)
% Gives the time at which an image was taken
name=img_obj.file_name;
%FInd the beginning time
i=max(strfind(name,'min')-4);

if i>1
    while isstrprop(name(i-1),'digit')
        i=i-1;
    end
end

if i>0
    s=[];
    while isstrprop(name(i),'digit')
        s=[s name(i)];
        i=i+1;
    end
    t0=str2num(s);
else
    t0=1;
end
t=t0+(img_obj.index-1)/di;
end