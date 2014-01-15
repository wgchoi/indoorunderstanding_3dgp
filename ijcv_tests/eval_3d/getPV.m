function [ P, V ] = getPV( f, p, y, r, Polyg, imsz, h, base_face )
% get polytope and volume

R = angle2dcm(r*pi/180, y*pi/180, p*pi/180);
nx = R*[1 0 0]';
ny = R*[0 1 0]';
nz = R*[0 0 1]';
NORMS = {ny,nz,nx,nx,ny};

Polyg = adjustGTPolyg(Polyg, y);

switch base_face
    case 1
        Plane = calcBox3DPlane_gnd(Polyg, NORMS, h, f, imsz);
    case 2
        Plane = calcBox3DPlane_cw(Polyg, NORMS, h, f, imsz);
end

CamPlane = calcCameraPlane(imsz, f);
[H, K]   = getHKRep(Plane, CamPlane);

H(:,1) = -H(:,1);
H = H(:,[1 3 2]);
P = polytope(H,K);
V = volume(P);

end

