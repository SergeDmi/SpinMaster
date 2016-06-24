function [ Da,Sa ] = dist_points_segment( points ,iA,iB )
% Returns dist and signs of points of an Nx*Ny image to a segment [AB]
%   Returns Dist, the Nx*Ny array of distances and Signs, the array of
%   signs of all points in a Nx*Ny image to the segment [AB]
%   If the projection is outside the segment, gives the minimal distance
%   to a segment end (A or B).


%1 Variables
%S=Nx*Ny;
%Making sure A and B are column vectors
a=[iA(1);iA(2)];
b=[iB(1);iB(2)];
iAB=iB-iA;
iU=iAB/norm(iAB);
%Computing the director vecto u and its normal v
u=[iU(1),iU(2)];
v=[-iU(2),iU(1)];
nAB=norm(iAB);
%Creation of the points arrays - might be suboptimal.
P=zeros(2,S);
for j=1:Ny
    P(1,(j-1)*Nx+1:j*Nx)=1:Nx;
    P(2,(j-1)*Nx+1:j*Nx)=j*ones(1,Nx);
end
A=a*ones(1,S);
B=b*ones(1,S);
%Creation of vectors Points -> A (PA) and Points -> B (PB), and norms.
PA=A-P;
PB=B-P;
nPA=sqrt(PA(1,:).^2+PA(2,:).^2);
nPB=sqrt(PB(1,:).^2+PB(2,:).^2);

%2 Computing the signs
Signs=sign(v*PA);

%3 Computing the distances
Projs=-u*PA;
vects=PA+u'*Projs;
Dists=sqrt(vects(1,:).^2+vects(2,:).^2);
Dists=((Projs>=0).*(Projs<=nAB)).*Dists+(Projs<0).*nPA+(Projs>nAB).*nPB;

Da=zeros(Nx,Ny);
Sa=zeros(Nx,Ny);

%Reordering in array, might be suboptimal
for j=1:Ny
    Da(:,j)=Dists((j-1)*Nx+1:j*Nx);
    Sa(:,j)=Signs((j-1)*Nx+1:j*Nx);
end

end

