function obj = det2obj(det)
obj = object(); % struct('id', id, 'pose', [], 'poly', [], 'bbs', [], 'cube', [], 'mid', []);

% assuming compatible pose dimensino.
assert(length(det.pose) == 2);

obj.id = det.id;
obj.pose = det.pose;
obj.bbs = bbox2rect(det.bbox);
obj.feat= det.score;

end