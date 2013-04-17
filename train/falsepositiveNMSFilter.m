function [removeidx] = falsepositiveNMSFilter(x, fpidx, maxperclass)

classes = unique(x.dets(:, 1));

retainidx = [];
for i = 1:length(classes)
    oneclass = find(x.dets(fpidx, 1) == classes(i));
    bbox = [x.dets(oneclass, 4:7), x.dets(oneclass, end)];
    pick = nms(bbox, 0.75);
    pick = oneclass(pick);
    
    pick = fpidx(pick);
    pick = pick(1:min(length(pick), maxperclass));
    
    retainidx =[retainidx ; pick];
end

removeidx = setdiff(fpidx, retainidx);
assert(length(intersect(fpidx, retainidx)) == length(retainidx));

% disp(['remove ' num2str(length(removeidx)) '/' num2str(length(fpidx))])

end