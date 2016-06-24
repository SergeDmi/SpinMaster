function [ opt,npmax ] = check_options_npmax( opt )
% Check if options are ok, otherwise load them, and return options & npmax
if nargin==0
    opt=[];
end
[opt,npmax]=check_options('max_polarity',opt);
end

