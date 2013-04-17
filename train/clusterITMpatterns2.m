function newptns = clusterITMpatterns2(ptns)
smat = inf(length(ptns), length(ptns));
res = false;

for i = 1:length(ptns)
    for j = i+1:length(ptns)
        smat(i, j) = compareITM(ptns(i), ptns(j));
    end
end

[id1, id2]=find(smat < 0.1);
newptns = ptns;
newptns(id2) = [];
