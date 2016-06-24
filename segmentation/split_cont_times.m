function [obj]=split_cont_times(a,dt)
% Finds all consecutives sub arrays of a timed array
% Data is on the first line and time on the second line
d=diff(a);
l=length(d);
counts=1:l+1;
st=1;
o=logical(d~=dt);
target=counts(o);
nd=sum(o);
obj=cell(nd,1);
for i=1:nd
    obj{i}=st:target(i);
    st=target(i)+1;
end
end