function [dist, D] = signed_dist_segpt(A,B,C )
%Give the signed distance from pt C to segment AB
%   
AB=B-A;
U=AB/norm(AB);
V=[-U(1) U(2)];
M=[V;U];
D=(inv(M)*(dot(V,A)*[1;0]+dot(U,C)*[0;1]))';
dist=dot((D-C),V);
x=dot((D-A),U);
if x<0
    dist=sign(dist)*norm(A-C);
elseif x>norm(AB);
    dist=sign(dist)*norm(C-B);
end

end

