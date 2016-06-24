function opt = spin_load_options(verbose)


% Load options present in current working directory,
% or load default options
%
% F. Nedelec, 20 Nov. 2012

if nargin < 1
    verbose = 0;
end


%% Load options

f = dir('spin_options.m');

if ~ isempty(f)
    
    if verbose
        fprintf(2,'Loading local options from %s\n', f.name);
    end
        
    opt = spin_options;
    
else
    
    if verbose
        fprintf(2,'Loading default options\n');
    end
    
    opt = spin_default_options;

end

%% add local variables

f = dir('spin_variables.m');

if ~ isempty(f)
    
    if verbose
        fprintf(2,'and variables from %s\n', f.name);
    end

    run('./spin_variables.m');

end

end