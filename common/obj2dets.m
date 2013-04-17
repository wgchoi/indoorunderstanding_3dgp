function det = obj2dets(obj)
det.id = obj.id;
det.pose = obj.pose;
det.bbox = rect2bbox(obj.bbs);
det.score = obj.feat;
end
