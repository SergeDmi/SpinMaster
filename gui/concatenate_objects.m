function obj1=concatenate_objects(varargin)
%Recursively concatenates any number of objects

if nargin < 1
    obj1={};
elseif 1 < nargin
    nobj=nargin;
    obj1=varargin{1};
    while nobj > 2
        obj2=varargin{2};
        varargin(2)=[];
        obj1=concatenate_objects(obj1,obj2);
        nobj=nobj-1;
    end
    obj2=varargin{2};
    if isempty(obj1)
        obj1=obj2;
    else
        m1=0;
        n1=numel(obj1);
        for k=1:n1
            m1=max(m1,obj1{k}.id);
        end
        n2=numel(obj2);
        for k=1:n2
            n1=n1+1;
            obj1{n1}=obj2{k};
            obj1{n1}.id=obj1{n1}.id+m1;
        end
    end
end

end
