function pos=convert_anglen_pos(anglen)
%Converts poles described by (ang,len) to (x,y)
s=size(anglen);
pos=zeros(s);
if length(s)>2
    nt=s(3);
else
    nt=1;
end
for t=1:nt
    pos(:,:,t)=[anglen(:,2,t) anglen(:,2,t)].*[cos(anglen(:,1,t)) sin(anglen(:,1,t))];
end
end