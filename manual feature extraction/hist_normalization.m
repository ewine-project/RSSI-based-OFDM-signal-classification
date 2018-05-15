function [stat,interval,cdfstat, max_bound, min_bound]=hist_normalization(rdata,numofstep,pdf_bool)
if(nargin < 5)
    max_bound=max(rdata);
    min_bound=min(rdata);
end
step=(max_bound-min_bound)/numofstep;
% interval=[min_bound:step:max_bound];
interval = [0:1/numofstep:1];
stat = zeros(1,numofstep);
cdfstat = zeros(1,numofstep);

rndata = (rdata - min_bound ) / (max_bound - min_bound);


for i=1:numofstep
    stat(i)=sum((rndata<interval(i+1)) & (rndata >= interval(i)));
    cdfstat(i) = sum(stat)/length(rndata);
end
% stat(numofstep) = sum(rndata>=max_bound);
cdfstat(numofstep) = sum(stat)/length(rndata);
if(pdf_bool==1)
    area = sum(stat);
    stat = stat ./ area;
end 
interval=interval+step/2;
interval=interval(1:end-1);
