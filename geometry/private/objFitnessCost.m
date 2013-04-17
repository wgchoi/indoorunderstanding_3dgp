function [cost] = objFitnessCost(xz, camh, K, R, obj, pose, model, mid)
assert(length(xz) == 2);
assert(isfield(pose, 'az'));
%%%%
location = zeros(3, 1);
location(1) = xz(1);
location(3) = xz(2);
location(2) = -(camh - model.height(mid) / 2);
%%%%
% angle = get3DAngle(K, R, obj.pose, -camh);
angle = getObjAngleFromCamView(location, pose);
[cube] = get3DObjectCube(location, model.width(mid), model.height(mid), model.depth(mid), angle);
[ppoly, prt] = get2DCubeProjection(K, R, cube);
%%%%
rt = obj.bbs;
%%%%
rt(1:2) = rt(1:2) + rt(3:4) / 2;
prt(1:2) = prt(1:2) + prt(3:4) / 2;
cost = sum( ( rt(1:2) - prt(1:2) ) .^ 2 );
cost = cost + sum( ( rt(3:4) - prt(3:4) ) .^ 2 );
%%%%
cost = 1000 * cost ./ (rt(4) * rt(4));

end