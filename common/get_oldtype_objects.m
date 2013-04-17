function [objs, poses] = get_oldtype_objects(obj_annos, models)
numtypes = length(models);

objs = cell(1, numtypes );
poses = cell(1, numtypes );

for i = 1:length(obj_annos)
    assert(obj_annos(i).objtype <= numtypes );

    otype = obj_annos(i).objtype;
    if(otype == 0)
        % ignore
        continue;
    end    
    obj = struct('id', otype, 'pose', [], 'poly', [], 'bbs', []);
    obj.bbs = [obj_annos(i).x1, obj_annos(i).y1, obj_annos(i).x2 - obj_annos(i).x1, obj_annos(i).y2 - obj_annos(i).y1];
    objs{otype}(end + 1) = obj;
    
    pose = struct('subid', obj_annos(i).subid, 'az', obj_annos(i).azimuth, 'el', obj_annos(i).elevation);
    poses{otype}(end + 1) = pose;
end

end