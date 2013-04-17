
function [Learners,Patches] = PurgePatches(Learners, Patches)

for i = 1 : length(Learners)
  dim(i) = GetDim(Learners{i});
end

udim=sort(unique(dim));

for i=1:length(Learners)
    newdim=find(udim==dim(i));
    Learners{i}=SetDim(Learners{i},newdim);
end

startindex=1;
for i=1:length(Patches)
    endindex=size(Patches{i},2)+startindex;
    x=find(udim>=startindex&udim<endindex);
    Patches{i}=Patches{i}(:,udim(x)-startindex+1);
    startindex=endindex;
end
startindex=2;   
