function [ i ] = first_zero( vect )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
lv=length(vect);
i=1;
while vect(i)*vect(i+1)>0 && i<lv
    i=i+1;
end

end

