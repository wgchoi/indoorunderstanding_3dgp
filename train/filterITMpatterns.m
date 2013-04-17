function params = filterITMpatterns(params, hit, ptnsets, mincount)

retain = find(hit >= mincount);
itmptns = params.model.itmptns(retain);
for i = 1:length(retain)
    itmptns(i) = reestimateITM(itmptns(i), ptnsets{retain(i)}, true);
end
params = appendITMtoParams(params, itmptns);

end