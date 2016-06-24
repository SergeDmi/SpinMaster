function [ opt,val ] = check_options( field,opt,lock )
% Check if options contains 'field', 
% If not, loads default options if lock==0
% Else returns empty value
if nargin==0
    error('No field given');
elseif nargin==1
    [opt,val]=check_options(field,[],0);
elseif nargin==2
    [opt,val]=check_options(field,opt,0);
else
    if ~isfield(opt,field)
        if lock
             val=[];
        else
            [opt,val]=check_options(field,spin_default_options,1);
        end
    else
        val=opt.(field);
    end
end

end

