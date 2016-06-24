function plot_seg_rms( blo , mea , rms )
%Plot line defined by blo and contour defined by mea and rms
 x1=blo(1,1);
 x2=blo(2,1);
 y1=blo(1,2);
 y2=blo(2,2);
 plot([y1,y2],[x1,x2],'b')
 if x2~=x1
     no=[1 (y2-y1)/(x2- x1)];
     no=no/norm(no);
     v=[-no(2) no(1)];
 end
 Up=blo-(mea+rms)*ones(2,1)*v/2;
 Dn=blo-(mea-rms)*ones(2,1)*v/2;
 x1=Up(1,1);
 x2=Up(2,1);
 y1=Up(1,2);
 y2=Up(2,2);
 plot((y1+y2)/2,(x1+x2)/2,'r*')
 x1=Dn(1,1);
 x2=Dn(2,1);
 y1=Dn(1,2);
 y2=Dn(2,2);
 plot((y1+y2)/2,(x1+x2)/2,'r*')

end

