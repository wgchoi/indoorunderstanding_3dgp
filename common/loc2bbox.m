function [pbbox, ppoly] = loc2bbox(loc, pose, K, R, model, mid)

% angle = get3DAngle(K, R, pose, -loc(2));
angle = getObjAngleFromCamView(loc, pose);
[cube] = get3DObjectCube(loc, model.width(mid), model.height(mid), model.depth(mid), angle);
[ppoly, pbbox] = get2DCubeProjection(K, R, cube);

end