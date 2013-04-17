function [gtx, tobjs, mobjs] = get_ground_truth_observations(x, anno)%, model)

dets = zeros(0, 8);

tobjs = zeros(1, 7);
mobjs = zeros(1, 7);

for i = 1:length(anno.obj_annos)
    tobjs(anno.obj_annos(i).objtype) = tobjs(anno.obj_annos(i).objtype) + 1;
    
    bbox = zeros(0, 4);
    for j = 1:length(x.hobjs)
        if(x.hobjs(j).oid == anno.obj_annos(i).objtype)
            bbox(end+1, :)= x.hobjs(j).bbs(:, 14)'; 
        end
    end
    gtbox = [anno.obj_annos(i).x1 anno.obj_annos(i).y1 anno.obj_annos(i).x2 anno.obj_annos(i).y2];
    
    ov = boxoverlap(bbox, gtbox);
    
    [val, idx] = max(ov);
    if(val > 0.5) % && anglediff(anno.obj_annos(i).azimuth, x.hobjs(idx).azimuth) < pi / 6)
        continue;
    end
    
    mobjs(anno.obj_annos(i).objtype) = mobjs(anno.obj_annos(i).objtype) + 1;
    
    dets(end+1, 1) = anno.obj_annos(i).objtype;
    dets(end, 2) = anno.obj_annos(i).subid;
    dets(end, 3) = discretize_angle(anno.obj_annos(i).azimuth);
    dets(end, 4:7) = gtbox;
end
dets(:, end) = -1.25;
if isempty(dets)
    gtx.hobjs = struct( 'oid', {}, 'locs', {}, ...
            'cubes', {}, ...
            'polys', {}, ...
            'bbs', {}, ...
            'ovs', {}, ...
            'diff', {}, ...
            'azimuth', {}, 'angle', {});
    gtx.dets = dets;
else
    [hobjs, invalid_idx] = generate_object_hypotheses(x.imfile, x.K, x.R, x.yaw, objmodels(), dets, 0);

    hobjs(invalid_idx) = [];
    dets(invalid_idx, :) = [];

    gtx.hobjs = hobjs;
    gtx.dets = dets;
end

if isfield(anno, 'hmn_annos')
    dets = zeros(length(anno.hmn_annos), 8);
    
    dets = zeros(0, 8);
    for i = 1:length(anno.hmn_annos)
        tobjs(7) = tobjs(7) + 1;
        
        bbox = zeros(0, 4);
        for j = 1:length(x.hobjs)
            if(x.hobjs(j).oid == 7)
                bbox(end+1, :)= x.hobjs(j).bbs(:, 14)'; 
            end
        end
        gtbox = [anno.hmn_annos(i).x1 anno.hmn_annos(i).y1 anno.hmn_annos(i).x2 anno.hmn_annos(i).y2];

        ov = boxoverlap(bbox, gtbox);

        [val, idx] = max(ov);
        if(val > 0.5) % && anglediff(anno.obj_annos(i).azimuth, x.hobjs(idx).azimuth) < pi / 6)
            continue;
        end
        
        mobjs(7) = mobjs(7) + 1;
        
        if(i <= length(anno.hmns{1}))
            x1 = anno.hmns{1}(i).head_bbs(1) - anno.hmns{1}(i).head_bbs(3);
            x2 = anno.hmns{1}(i).head_bbs(1) + 2 * anno.hmns{1}(i).head_bbs(3);
        else
            idx = i - length(anno.hmns{1});
            x1 = anno.hmns{2}(idx).head_bbs(1) - anno.hmns{2}(idx).head_bbs(3);
            x2 = anno.hmns{2}(idx).head_bbs(1) + 2 * anno.hmns{2}(idx).head_bbs(3);
        end
        dets(end+1, 1) = 7;
        dets(end, 2) = anno.hmn_annos(i).subid;
        dets(end, 3) = discretize_angle(anno.hmn_annos(i).azimuth);
        dets(end, 4:7) = [x1 anno.hmn_annos(i).y1 x2 anno.hmn_annos(i).y2];
    end
    dets(:, end) = -1.5;
    [hobjs, invalid_idx] = generate_object_hypotheses(x.imfile, x.K, x.R, x.yaw, objmodels(), dets, 1);

    hobjs(invalid_idx) = [];
    dets(invalid_idx, :) = [];

    gtx.hobjs(end+1:end+length(hobjs)) = hobjs;
    gtx.dets = [gtx.dets; dets];
end
% gticlusters = clusterInteractionTemplates(gtx, model);
end



function dangle = discretize_angle(angle)
dp = -2*pi:pi/4:2*pi;
dangle = get_closest(dp, angle);
if(dangle < 0)
    dangle = dangle + 2 * pi;
end
end
