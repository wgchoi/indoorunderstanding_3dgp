function [r, objs] = gen3DRoomFromGT(img, gtPolyg, objs, poses)
%% find camera position and room layout (up to scale)
vp = getVPfromGT(img, gtPolyg);
if 1
    vp = ordervp(vp, size(img, 1), size(img, 2));
else
    vp = order_vp(vp); % v, h, m
end
[K, R, F] = get3Dcube(img, vp, gtPolyg);

%% find object location and room scale
objmodel = objmodels();
[camh, objs] = jointInfer3DObjCubes(K, R, objs, poses, objmodel);

%% form output
r = room();
r.K = K;
r.R = R; 
r.F = F;
r.h = camh;

r.sz = [size(img, 1), size(img, 2)];
r.vp = vp;
end