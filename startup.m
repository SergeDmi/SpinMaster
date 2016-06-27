%%---------------startup file F. Nedelec 2010

% Copy this file to ~/Documents/MATLAB and it will be run automatically

owd = pwd;

%%---------------update path:
% ------------------------------------------------------
matdir = '~/code/matned';
% Replace matdir whith the location of the matned suite
if isdir(matdir)
    cd(matdir);

    cwd = pwd;
    files = dir;
    cnt = 0;

    for i=3:size(files)
    
        name = files(i).name;
        if isdir(name) && isempty(strfind(name ,'old'))...
            && (name(1) ~= '@') && (name(1) ~= '.')
            addpath( [ cwd, '/', name ] );
            cnt = cnt + 1;
        end 
    
    end

    fprintf(1,'Added %i subdirectories of %s to path\n', cnt, cwd);

    cd(owd);

end
