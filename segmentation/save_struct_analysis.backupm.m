function save_struct_analysis(A,tp)

if ~isstruct(A)
    error('You must provide a structure.');
end
if nargin~=2
    tp=0;
end
    
ana_fname='analysis.txt';
names = fieldnames(A) ;
fid = fopen(ana_fname, 'wt');
nf=numel(names);
for i=1:nf
    name=names{i};
    data = A.(name);
    val=data.value;
    say=data.name;
    if isfield(data,'stddev')
        err=data.stddev;
    else
        err=[];
    end
    % If cell 
    fprintf(fid,['%% -------- ' say '\n']);
    if iscell(val)
        nc=numel(val);
        for n=1:nc
            arr=val{n};
            if ~isempty(arr)
                fprintf(fid,['%% For ' num2str(n-1) '-polar spindles' '\n']);
                for i=1:size(arr,1)
                    fprintf(fid,num2str(arr(i,:)));
                    fprintf(fid,'\n');
                end
                
            end
            der=err{n};
            if ~isempty(der)
                fprintf(fid,['%% Std error' '\n']);
                for i=1:size(der,1)
                    fprintf(fid,num2str(der(i,:)));
                    fprintf(fid,'\n');
                end
            end
        end
    else
        if ~isempty(arr)
            for i=1:size(arr,1)
                fprintf(fid,num2str(arr(i,:)));
                fprintf(fid,'\n');
            end
        end
        if ~isempty(err)
            fprintf(fid,['%% Std error' '\n']);
            for i=1:size(err,1)
                fprintf(fid,num2str(err(i,:)));
                fprintf(fid,'\n');
            end
        end
    end
end


end
function printarray(M)
for i=1:size(M,1)
    fprintf(fid,num2str(M(i,:)));
    fprintf(fid,'\n');
end
end
