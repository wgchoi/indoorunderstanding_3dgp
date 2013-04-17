% function angle3 = get3DAngle(K, R, ct, pose, ref)
function angle3 = get3DAngle(K, R, pose, ref)
assert(0, 'obsolete function. use getObjAngleFromCamView instead');
if nargin < 5
	ref = -1;
end
% 
% pt1 = ct;
% pt2 = ct + [-sin(pi/4 * (pose - 1)); cos(pi/4 * (pose - 1))] * 10;
pt1 = pose(1, :)';
pt2 = pose(2, :)';

ray1 = (K * R) \ [pt1; 1];
ray2 = (K * R) \ [pt2; 1];

ray1 = ray1 ./ ray1(2) * ref;
ray2 = ray2 ./ ray2(2) * ref;

v = ray2 - ray1;
angle3 = atan2(v(3), v(1)) + pi / 2;

return;

end
