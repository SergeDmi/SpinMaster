function [ints,j,i] = analyze_profile( profile)
% Analyses an intensity profile yielding intens. and width of highest peak
%   Does smooth stuff
% S. Dmitrieff, december 2012
ints=0;
wid=0;
if nargin<1 
    error('No profile given')
end
lp=length(profile);
midle=ceil(lp/2);

% ----------------------->
% correlation length :
% ----------------------/
corr_func=correlation_function(profile,lp/2);
wid_C=first_zero(corr_func);
[~,wid_C2]=min(corr_func);
mea_C=0;


%figure;
%plot(1:length(corr_func),corr_func)
%figure
%plot((1:lp) - midle,profile,'k-')

%rep=figure;
%hold all
%plot((1:lp) - midle,profile,'k-')
%disp(['From corr func : w=' num2str(i)])


% ----------------------->
% adaptative thresholding  : start small
% ----------------------/
sm_size=0;
sm_step=2;
sm_max=lp/4;
thresh=0.28;
j=8*sm_size+sm_step;
i=0;

while abs(j-i) > 5*sm_size && sm_size<sm_max
    sm_size=min(sm_size+sm_step,sm_max);
    smp=smooth(profile,sm_size);
    [i,j]=find_boundaries(smp,thresh);
end

%figure(rep)
%plot((1:lp)-lp/2,smp,'m-')
%disp(['From adapt. thresh : w=' num2str(j-i)])
ints=sum(profile(j:i));
ic=i-lp/2;
jc=j-lp/2;
midT=(ic+jc)/2;

%figure(rep);
%plot([ic,ic],[min(profile),max(profile)],'r')
%plot([jc,jc],[min(profile),max(profile)],'r')


% Finding edges of smoothed prof
dmp=diff(smp);
[~,j]=max(dmp);
[~,i]=min(dmp);
wid_E=(i-j)*2;
ints_E=sum(profile(j:i));
mea_E=(i+j)/2 - midle ;
%figure(rep)
%plot([i-lp/2,i-lp/2],[min(profile),max(profile)],'b')
%plot([j-lp/2,j-lp/2],[min(profile),max(profile)],'b')

% Using this information for center of corrfunc
%plot([midT-wid_C,midT-wid_C],[min(profile),max(profile)],'g')
%plot([midT+wid_C,midT+wid_C],[min(profile),max(profile)],'g')
% Using this information for center of corrfunc
%plot([midT-wid_C2,midT-wid_C2],[min(profile),max(profile)],'g--')
%plot([midT+wid_C2,midT+wid_C2],[min(profile),max(profile)],'g--')



i=ic;
j=jc;
% ----------------------------------
% Checking if thresholding didn't mess up
% ----------------------------------------

if abs(i-j)>4*wid_C
    i=+wid_C/2;
    j=-wid_C/2;
    ints=sum(profile(round(lp/2-wid_C):round(lp/2+wid_C)));
end


% -----------------------------
% ---------------------
% -----------


    function [i,j]=find_boundaries(prof,thresh)
    [mp,pos]=max(prof);
    ct_left=(mp - min(prof(1:pos)))*thresh;
    ct_right=(mp - min(prof(pos:end)))*thresh;
    i=pos;
    while smp(i)>ct_right && i<lp
        i=i+1;
    end
    j=pos;
    while smp(j)>ct_left && j>1
        j=j-1;
    end
    
    
    end
        

end
