function [ Af ] = fourier_modes_timed( vals,times,mode )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
lp= length(vals);
if nargin<2
    error('Not enough input data');
end
if nargin<3
    angular=0;
elseif strcmp(mode,'angular') || mode==1;
    angular=1;
end
if lp~=length(times)
    error('Values and times must have the same size');
end

sit=split_cont_times(times,1);
ns=numel(sit);
Af=cell(1,ns);

for i=1:ns
    signal=vals(sit{i});
    l=length(signal);
    w=0:(l-1);
    Af{i}=[fft(signal);w/l];
end
end

