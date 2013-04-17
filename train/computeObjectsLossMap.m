function oloss = computeObjectsLossMap(anno, x)

GT = [];
Det = x.dets(:, [4:7 1]);
for j = 1:length(anno.obj_annos)
    obj_anno = anno.obj_annos(j);
    GT(j, :) = [obj_anno.x1 obj_anno.y1 obj_anno.x2 obj_anno.y2 obj_anno.objtype];
end

GT(GT(:, end) > 2, :) = [];

oloss = computeloss(Det, GT);

end
