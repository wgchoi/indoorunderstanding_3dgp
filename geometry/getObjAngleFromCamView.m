% function angle3 = getObjAngleFromCamView(K, R, pose, ref)
function angle3 = getObjAngleFromCamView(loc, pose)

caminobj = -[loc(1); loc(3); loc(2)];
az = -pose.az + pi / 2;
ydir = [cos(az), sin(az); -sin(az), cos(az)] * caminobj(1:2);
angle3 = atan2(ydir(2), ydir(1));

end
