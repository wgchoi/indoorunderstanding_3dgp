function [F, K, R] = getFacesFromPoly(imsz, vp, K, R, polyg)
assert(0);
% use getRoomFaces instead!
[room_ht room_wt SurfaceNormals DistfromSurface DistOn visplanes corners3D K R] = ...
    getWallCorners(polyg, vp, imsz(1), imsz(2), K, R);

% F(1, :) => floor : ax + by + cz + d = 0
% floor, center, right, left, ceiling
% if nan not known.
F = nan(5, 4);
for i = 1:size(F, 1)
    if(visplanes(i))
        F(i, 1:3) = SurfaceNormals(i, :) ./ norm(SurfaceNormals(i, :));
        F(i, 4) = -DistfromSurface(i);
    end
end

end