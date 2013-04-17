function dets = rawdets2dets(raw, id, poses)

for i = 1:size(raw, 1)
    ct = bbox2ct(raw(i, 1:4));
    pose = [ct; ct + poses(raw(i, 5), :)];
    dets(i) = struct('id', id, 'pose', pose, 'bbox', raw(i, 1:4), 'score', raw(i, 6));
end

end
