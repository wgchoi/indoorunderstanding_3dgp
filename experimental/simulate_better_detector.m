function [x] = simulate_better_detector(x, anno, oid, scale, addval, minval)

idx = find([anno.obj_annos(:).objtype]' == oid);
for i = 1:length(idx)
    bbox = [anno.obj_annos(idx(i)).x1, anno.obj_annos(idx(i)).y1, anno.obj_annos(idx(i)).x2, anno.obj_annos(idx(i)).y2];
    
    did = find(x.dets(:, 1) == oid);
    
    ov = boxoverlap(x.dets(did, 4:7), bbox);
    did2 = find(ov > 0.5);
    
    x.dets(did(did2), 8) = (x.dets(did(did2), 8) - minval) * scale + minval + addval;
end