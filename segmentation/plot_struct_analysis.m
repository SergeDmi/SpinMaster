function plot_struct_analysis(A)
if nargin==0
    error('You must provide data');
end

if iscell(A);
    for na=1:numel(A)
        plot_struct_analysis(A{na});
    end
elseif ~isstruct(A)
    error('You must provide a structure.');
else
    if isfield(A,'file_name')
        ana_fname=A.file_name;
    else
        ana_fname='analysis.txt';
    end
    
    names = fieldnames(A) ;
    nf=numel(names);
    for i=1:nf
        name=names{i};
        data = A.(name);
        if isfield(data,'value')
            figure;
            
            val=data.value;
            say=data.name;
            legs={};
            if isfield(data,'stddev')
                err=data.stddev;
            else
                err=[];
            end
            if isfield(data,'count')
                cnt=data.count;
            else
                cnt=[];
            end
            
            % If cell
            if iscell(val)
                hold all;
                nc=numel(val);
                for n=1:nc
                    arr=val{n};
                    if ~isempty(arr)
                        legs{n-1}=[num2str(n-1) '-polar'];
                        plotarray(arr);
                    end
                end
                labelarray(ana_fname,say,legs,'');
                
                %if strfind(say,'MSD')
                %    figure
                %    hold all;
                %    legs={};
                %    for n=1:nc
                %        arr=val{n};
                %        if ~isempty(arr)
                %            legs{n-1}=[num2str(n-1) '-polar'];
                %            plotarray(sqrt(arr));
                %        end
                %    end
                %    labelarray(ana_fname,say,legs,'sqrt ');
                %end
            else
                if ~isempty(val)
                    if strfind(say,'Histogram')
                        if strfind(say,'angle')
                            h=polar(val(1,:),val(2,:));
                            x = get(h,'Xdata');
                            y = get(h,'Ydata');
                            g=patch(x,y,'y');
                        else
                            ylabel('Count');
                            if strfind(say,'acentricity')
                                xlabel('Acentricity abs(l1-l2)/(l1+l2)')
                            end
                            bar(val(1,:),val(2,:),'b');
                            legs{1}='Count';
                            if ~isempty(err)
                                hold all
                                for b=1:length(val(1,:))
                                    plot([val(1,b) val(1,b)],[val(2,b)-err(2,b) val(2,b)+err(2,b)],'r','Linewidth',2);
                                end
                                %st=val(2,:)-err(2,:);
                                %bar(val(1,:),st,'b');
                                %legs{1}='Std. dev.';
                                legs{2}='Std. dev.';
                            end
                        end
                        labelarray(ana_fname,say,legs,'');
                    else
                        bararray(val);
                        legs{1}=say;
                        if ~isempty(err)
                            
                            hold all
                            if size(val,1)==1
                                val=[1:length(val);val];
                                err=[1:length(val);err];
                            end
                            for b=1:length(val(1,:))
                                if isempty(cnt)
                                    plot([val(1,b) val(1,b)],[val(2,b)-err(2,b) val(2,b)+err(2,b)],'r','Linewidth',2);
                                    legs{2}='Std. dev.';
                                else
                                    plot([val(1,b) val(1,b)],[val(2,b)-err(2,b) val(2,b)+err(2,b)],'g','Linewidth',2);
                                    plot([val(1,b) val(1,b)],[val(2,b)-err(2,b)/sqrt(cnt(b)) val(2,b)+err(2,b)/sqrt(cnt(b))],'r','Linewidth',2);
                                    
                                    legs{3}='Std err';
                                    legs{2}='Std dev';
                                end
                            end
                            %st=val(2,:)-err(2,:);
                            %bar(val(1,:),st,'b');
                            %legs{1}='Std. dev.';
                            
                        end
                        labelarray(ana_fname,say,legs,'');
                        if strfind(say,'MSD')
                            figure
                            if size(val,1)==1
                                bararray(sqrt(val));
                            else
                                bararray([val(1,:);sqrt(val(2,:))]);
                            end
                            legs{1}=say;
 
                            labelarray(ana_fname,say,legs,'sqrt ');
                        end
                        
                    end
                    
                    %if ~isempty(err)
                    %    fprintf(fid,['%% Std error' '\n']);
                    %    plotarray(err,fid);
                    %end
                    %if ~isempty(cnt)
                    %    fprintf(fid,['%% Count' '\n']);
                    %    plotarray(cnt,fid);
                    %end
                end
               
            end

        end
    end
end
end

function labelarray(fname,tell,leg,tag)
if strfind(fname,'bipo')
    titre=[tag tell ' - Good bipolar spindles'];
else
    titre=[tag tell ' - all spindles'];
end
title(titre);
if strfind(titre,'MSD')
    xlabel('time (min)')
    if strfind(tell,'length')
        if strfind(tag,'sqrt')
            ylabel('px')
        else
            ylabel('px^2')
        end
    elseif strfind(tell,'angle')
        if strfind(tag,'sqrt')
            ylabel('rad')
        else
            ylabel('rad^2')
        end
    end
end
try
    legend(leg);
catch
    disp(leg);
end

end

function plotarray(M)
s=size(M);
if s(1)>s(2)
    M=M';
    s=size(M);
end
if s(1)==1
    plot(1:s(2),M(1,:));
elseif s(1)==2
    plot(M(1,:),M(2,:));
else
    error('Unrecognized data format')
end

end


function bararray(M)
s=size(M);
if s(1)>s(2)
    M=M';
    s=size(M);
end
if s(1)==1
    bar(1:s(2),M(1,:));
elseif s(1)==2
    bar(M(1,:),M(2,:));
else
    error('Unrecognized data format')
end

end
