function [cube, overlap] = fitCube(K, R, cube, bb, poly)

% cube size -> width, height in image
ppoly = get2DCubeProjection(K, R, cube);
bbox = poly2bbox(ppoly);
% cube location.

end
