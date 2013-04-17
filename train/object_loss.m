function loss = object_loss(obj_annos, dets)
%%% loss function for object detections!
% dets = [type, x1, y1, x2, y2, angle(in rad)]
% missed detection : loss 2
% false positive : loss 2
% tp : possibly loss 1 if pose is not classified correctly
ovth = 0.5;

or = zeros(length(obj_annos), size(dets, 1));
for i = 1:length(obj_annos)
    for j = 1:size(dets, 1)
        if(dets(j, 1) == obj_annos(i).objtype)
            or(i, j) = boxoverlap([obj_annos(i).x1 obj_annos(i).y1 obj_annos(i).x2 obj_annos(i).y2], dets(j, 2:5));
        end
    end
end

%% loss from missed detections
hit = find(sum(or > ovth , 2) > 0);
loss = 2 * (size(or, 1) - length(hit));
%% loss from matched detections
tps = [];
for i = 1:length(hit)
    gid = hit(i);
    [val, idx] = max(or(gid, :));
    if(val > ovth)
        loss = loss + 1 * anglediff(obj_annos(gid).azimuth, dets(idx, end)) / pi;
        or(:, idx) = 0;
        tps(end+1) = idx;
    else
        % taken by some detection
        loss = loss + 2;
    end
end

%% loss from false positives
loss = loss + 2 * (size(or, 2) - length(tps));
end