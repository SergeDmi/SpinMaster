function res = load_structure(file_name)

%%  Load a matlab structure from an ascii file
%
% Syntax:
%      res = load_structure(file_name)
%
%
% See also:
% save_structure,  update_structure
%
% F. Nedelec, 20 Nov. 2012

if nargin < 1
    error('missing file name');
end


%%

res = [];
fid = fopen(file_name, 'rt');

if fid == -1
    error('Could not find file "%s"\n', file_name);
end
    
line = fgets(fid);

while line ~= -1
    
    cmd = strtrim(line);
            
    %get next line:
    line = fgets(fid);

    if isempty(cmd) || cmd(1) == '%'
        continue;
    end

    [var, rem] = strtok(cmd, '.');
    
    if isempty(rem)
        [fld, val] = strtok(cmd, '=');
    else
        [fld, val] = strtok(rem(2:length(rem)), '=');
    end

    fld = strtrim(fld);
    val = strtrim(val(2:length(val)));

    if isempty(fld)
        continue;
    end
    
    if isempty(val)
        error('missing value for field "%s"', fld);
    end
    
    %fprintf(2, '|%s|.|%s|=|%s|\n', var, fld, val);

    try
        %var.(fld) = val;
        eval(['res.',fld,'=',val,';']);
    catch
        disp(fld)
        error('Invalid field assignment');
    end
    
end

fclose(fid);

 
end
