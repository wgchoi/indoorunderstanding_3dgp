%%% get camera parameters and the major visible faces
%%% get 3D (ROOM) Cube
function [K, R, F] = get3Dcube(img, vp, polyg)
% addpath('3DReasoning');
[K, R]=calibrate_cam(vp, size(img, 1), size(img, 2));
F = getRoomFaces(polyg, size(img, 1), size(img, 2), K, R);
% 
% [room_ht room_wt SurfaceNormals DistfromSurface DistOn visplanes corners3D K R] = ...
%     getWallCorners(polyg, vp, size(img, 1), size(img, 2), K, R);
% 
% % F(1, :) => floor : ax + by + cz + d = 0
% % floor, center, right, left, ceiling
% % if nan not known.
% F = nan(5, 4);
% for i = 1:size(F, 1)
%     if(visplanes(i))
%         F(i, 1:3) = SurfaceNormals(i, :) ./ norm(SurfaceNormals(i, :));
%         F(i, 4) = -DistfromSurface(i);
%     end
% end
end