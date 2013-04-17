function [objs] = testGeometryInDetection(room, objmodels, dets)

objs = object(length(dets));

nanlist = false(1, length(dets));

for i = 1:length(dets)
    obj = det2obj(dets(i));
    model = objmodels(obj.id);
    
    [f, loc, mid] = optimizeOneObjectMModel(room.h, room.K, room.R, obj, model);
    
    angle = get3DAngle(room.K, room.R, obj.pose, loc(2));            
    obj.cube = get3DObjectCube(loc, model.width(mid), model.height(mid), model.depth(mid), angle);
    obj.mid = mid;
    obj.feat(2) = f;
    
    objs(i) = obj;
    
    nanlist(i) = (sum(sum(isnan(obj.cube))) > 0 || loc(3) > 0);
end
% objs(nanlist) = [];
end

