function [obj]=breakdown(a,obj,n0,val)
% Finds all consecutives indexes for which array a = val
a=(a==val);
[~,obj,~]=beatdown(a,obj,n0);
end

function [a,obj,n0]=beatdown(a,obj,n0)
% Recursively finds all consecutives indexes for which array a = 1
l=length(a);
no=numel(obj);
if l>0
    ts=ffirst(a,1);
    if ts
        a=a(ts:end);
        l=l-ts+1;
        n0=n0+ts-1;
        te=ffirst(a,0)-1;
        if te==-1
            pts=(1:l)+n0-1;
            n0=l+1;
            a=[];
            obj{no+1}=pts;
        else
            pts=(1:te)+n0-1;
            n0=te+n0;
            a=a(te+1:end);
            obj{no+1}=pts;
            [a,obj,n0]=beatdown(a,obj,n0);
        end
    end
end
end


function i=ffirst(a,val)
if isempty(a)
    i=0;
else
    n=length(a);
    i=1;
    while a(i)~=val
        i=i+1;
        if i>n
            i=0;
            break;
        end
    end
end
end