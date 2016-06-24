function spin_show_images(opt)

% function spin_show_images(opt)
%
% show the images loaded by spin_load_images
% If 'regions' is specified, it should be an array of size N * 5
% containing [ id, x0, y0, x1, y1 ]
%
% F. Nedelec, March. 2008


if nargin < 1
    opt = [];
end

%% Display DNA

DNA = spin_load_images('dna', [], opt);


if isempty(DNA)
    fprintf(2, 'WARNING: Could not find a DNA image\n');
else
    check_size_consistency(DNA);
    show_stack(DNA);
end

%% Display TUB

TUB = spin_load_images('tub', [], opt);

if isempty(TUB)
    fprintf(2, 'WARNING: Could not find a TUB image\n');
else
    check_size_consistency(TUB);
    show_stack(TUB);
end


%%

    function check_size_consistency(stk)
        
        sz = size(stk(1).data);
        
        for i = 2:length(stk)
            if any( sz ~= size(stk(i).data) )
                fprintf(2, 'WARNING: "%s" has a different size!!!\n', stk(i).file_name);
            end
        end

    end

end