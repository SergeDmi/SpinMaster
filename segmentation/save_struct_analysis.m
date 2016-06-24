function save_struct_analysis(A)
if nargin==0
    error('You must provide data');
end

if iscell(A);
    for na=1:numel(A)
        save_struct_analysis(A{na});
    end
elseif ~isstruct(A)
    error('You must provide a structure.');
else
    if isfield(A,'file_name')
        ana_fname=A.file_name;
    else
        ana_fname='analysis.txt';
    end
    
    names = fieldnames(A) ;
    fid = fopen(ana_fname, 'wt');
    nf=numel(names);
    for i=1:nf
        name=names{i};
        data = A.(name);
        if isfield(data,'value')
            val=data.value;
            say=data.name;
            if isfield(data,'stddev')
                err=data.stddev;
            else
                err=[];
            end
            if isfield(data,'count')
                cnt=data.count;
            else
                cnt=[];
            end
            
            % If cell
            fprintf(fid,['%% -------- ' say '\n']);
            if iscell(val)
                nc=numel(val);
                for n=1:nc
                    arr=val{n};
                    if ~isempty(arr)
                        fprintf(fid,['%% For ' num2str(n-1) '-polar spindles' '\n']);
                        printarray(arr,fid);
                        
                    end
                    if ~isempty(err) 
                        der=err{n};
                        if ~isempty(der)
                            fprintf(fid,['%% Std dev' '\n']);
                            printarray(der,fid);
                        end
                    end
                    if ~isempty(cnt)
                        cou=cnt{n};
                        if ~isempty(cou)
                            fprintf(fid,['%% Count' '\n']);
                            printarray(cou,fid);
                        end
                    end
                end
            else
                if ~isempty(val)
                    printarray(val,fid);
                end
                if ~isempty(err)
                    fprintf(fid,['%% Std dev' '\n']);
                    printarray(err,fid);
                end
                if ~isempty(cnt)
                    fprintf(fid,['%% Count' '\n']);
                    printarray(cnt,fid);
                end
            end
        end
    end
end


end

function printarray(M,fd)
s=size(M);
if s(1)>s(2)
    M=M';
end
for i=1:size(M,1)
    fprintf(fd,num2str(M(i,:)));
    fprintf(fd,'\n');
end
end
