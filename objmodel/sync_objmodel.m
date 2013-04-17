function out = sync_objmodel(anno, imfile)
om = objmodels();

out = anno;
out.objmodel = om;
out.objtypes = {};
out.objs = {};
out.poses = {};
if(isfield(out, 'obj_annos'))
    out.obj_annos(:) = [];
else
    out.obj_annos = struct('im', {}, 'objtype', {}, 'subid', {}, 'x1', {}, 'y1', {}, 'x2', {}, 'y2', {}, 'azimuth', {}, 'elevation', {});
end

for i = 1:length(anno.objtypes)
    idx = -1;
    for j = 1:length(om)
        if(strcmp(anno.objtypes{i}, om(j).name))
            idx = j;
            break;
        end
    end
    
    if(idx > 0)
        out.objtypes{idx} = anno.objtypes{i};
        if isfield(anno, 'objs')
            out.objs{idx} = anno.objs{i};
        end
        if isfield(anno, 'poses')
            if length(anno.poses) >= i
                out.poses{idx} = anno.poses{i};
            else
                out.poses{idx} = [];
                assert(isempty(anno.objs{i}));
            end
        elseif isfield(anno, 'obj_poses')
            if length(anno.obj_poses) >= i
                out.poses{idx} = anno.obj_poses{i};
            else
                out.poses{idx} = [];
                assert(isempty(anno.objs{i}));
            end
        end
        if isfield(anno, 'obj_annos')
            for j = 1:length(anno.obj_annos)
                if(anno.obj_annos(j).objtype == i)
                    temp = anno.obj_annos(j);
                    temp.objtype = idx;
                    out.obj_annos(end+1) = temp;
                end
            end
        else
            temp = struct('im', imfile, ...
                    'objtype', idx, ...
                    'subid', cell(length(out.poses{idx}), 1), 'x1', 0, 'y1', 0, 'x2', 0, 'y2', 0, 'azimuth', 0, 'elevation', 0);
            
            for j = 1:length(out.poses{idx})
                temp(j).subid = out.poses{idx}(j).subid;
                temp(j).azimuth = out.poses{idx}(j).az;
                temp(j).elevation = out.poses{idx}(j).el;
                temp(j).x1 = out.objs{idx}(j).bbs(1);
                temp(j).y1 = out.objs{idx}(j).bbs(2);
                temp(j).x2 = out.objs{idx}(j).bbs(3) + out.objs{idx}(j).bbs(1) - 1;
                temp(j).y2 = out.objs{idx}(j).bbs(4) + out.objs{idx}(j).bbs(2) - 1;
            end
            
            out.obj_annos(end+1:end+length(temp)) = temp;
        end
    end
end

if(isfield(out, 'hmns'))
    out.hmn_annos = struct('im', {}, 'subid', {}, 'x1', {}, 'y1', {}, 'x2', {}, 'y2', {}, 'azimuth', {}, 'elevation', {});
    
    for i = 1:length(out.hmns)
        temp = struct('im', imfile, 'subid', i, 'x1', cell(length(out.hmns{i}), 1), 'y1', 0, 'x2', 0, 'y2', 0, 'azimuth', 0, 'elevation', 0);

        for j = 1:length(out.hmns{i})            
            temp(j).azimuth = out.hmn_poses{i}(j).az;
            temp(j).elevation = out.hmn_poses{i}(j).el;
            temp(j).x1 = out.hmns{i}(j).entr_bbs(1);
            temp(j).y1 = out.hmns{i}(j).entr_bbs(2);
            temp(j).x2 = out.hmns{i}(j).entr_bbs(3) + out.hmns{i}(j).entr_bbs(1) - 1;
            temp(j).y2 = out.hmns{i}(j).entr_bbs(4) + out.hmns{i}(j).entr_bbs(2) - 1;
        end

        out.hmn_annos(end+1:end+length(temp)) = temp;
    end
end

end