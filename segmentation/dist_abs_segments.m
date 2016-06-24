function [ Da,Pa ] = dist_abs_segments( Sim, segments )
% Returns signed dist and projections of points in image to segments
%   Sim  stores the dimension of the image and segments contains ns
%   segments.
%   Returns Da, the Sim(1)*Sim(2)*ns array of distances and Pa, the array
%   of the projections of all points on all the segment.
%   If the projection is outside the segment, gives the minimal distance
%   to a segment end (A or B).

if nargin<2
    error('Not enough arguments');
end
Sseg=size(segments);
if Sseg(2)~=2
    error('Wrong segment array size');
elseif size(Sim)~=[2,2]
    error('Wrong image array size'),
end
segs=segments';
% 1- Variables
ns=Sseg(1)-1;
Nx=Sim(1);Ny=Sim(2);
S=Nx*Ny;
Da=zeros(Nx,Ny,ns);
Pa=zeros(Nx,Ny,ns);
lengths=segments_lengths(segments);
add_length=[0 lengths(1:end-1)];

% 2- Computations
for i=1:ns
    a=segs(:,i);
    b=segs(:,i+1);
    iAB=b-a;
    nAB=norm(iAB);
    % > Computing the director vecto u and its normal v
    u=iAB'/nAB;
    v=[-u(2),u(1)];    
    % > Creation of the points arrays - might be suboptimal.
    P=zeros(2,S);
    for j=1:Ny
        P(1,(j-1)*Nx+1:j*Nx)=1:Nx;
        P(2,(j-1)*Nx+1:j*Nx)=j*ones(1,Nx);
    end
    A=a*ones(1,S);
    B=b*ones(1,S);
    % > Creation of vectors Points -> A (PA) and Points -> B (PB), and norms.
    PA=A-P;
    PB=B-P;
    nPA=sqrt(PA(1,:).^2+PA(2,:).^2);
    nPB=sqrt(PB(1,:).^2+PB(2,:).^2);
    % > Computing the signs
    Signs=sign(v*PA);
    % > Computing the distances
    Projs=-u*PA;
    vects=PA+u'*Projs;
    Dists=sqrt(vects(1,:).^2+vects(2,:).^2).*Signs;
    Dists=((Projs>=0).*(Projs<=nAB)).*Dists+(Projs<0).*nPA.*Signs+(Projs>nAB).*nPB.*Signs;
    % > Reordering in array, might be suboptimal
    for j=1:Ny
        Da(:,j,i)=Dists((j-1)*Nx+1:j*Nx);
        Pa(:,j,i)=Projs((j-1)*Nx+1:j*Nx) + add_length(i);        
    end
end

end

