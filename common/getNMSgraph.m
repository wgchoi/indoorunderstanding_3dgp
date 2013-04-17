function pg = getNMSgraph(pg, x, icluster, conf)
objidx = getObjIndices(pg, icluster);
assert(length(conf) == size(x.dets, 1));

classes = 1:7;
dets = x.dets(objidx, :);
conf = conf(objidx);

allpick = [];
for i = 1:length(classes)
    clsidx = find(dets(:, 1) == classes(i));
    boxes = [dets(clsidx, 4:7), dets(clsidx, 3), conf(clsidx)];

    pick = nms(boxes, 0.5);

    allpick = [allpick; clsidx(pick)];
end
remove_idx = setdiff(1:length(objidx), allpick);
remove_idx = objidx(remove_idx);

i = 1;
while(i <= length(pg.childs))
    cl = icluster(pg.childs(i));
    for j = 1:length(remove_idx)
        if(any(cl.chindices == remove_idx(j)))
            temp = setdiff(cl.chindices, remove_idx(j));
            remove_idx(j) = [];
            pg.childs(i) = []; 
            i = i - 1;
            pg.childs = [pg.childs, temp];
            break;
        end
    end
    i = i + 1;
end
% ridx = [];
% aidx = [];
% for j = 1:length(remove_idx)
%     if(any(pg.childs == remove_idx(j)))
%     else
%     end
% end

end