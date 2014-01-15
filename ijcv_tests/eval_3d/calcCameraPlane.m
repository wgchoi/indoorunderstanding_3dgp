function [ CamPlane ] = calcCameraPlane( imsz, f )
% v1: (+,+), v2: (+,-), v3: (-,-), v4: (-,+)
% order: v1-v2, v2-v3, v3-v4, v4-v1

% [img_row,img_col,~] = size(img);
img_row = imsz(1);
img_col = imsz(2);

CamPlane = cell(1,1);
camera_v1 = [ img_col/2, img_row/2, f]';
camera_v2 = [ img_col/2,-img_row/2, f]';
camera_v3 = [-img_col/2,-img_row/2, f]';
camera_v4 = [-img_col/2, img_row/2, f]';
CamPlane{1} = [cross(camera_v1,camera_v2)/norm(cross(camera_v1,camera_v2));0];
CamPlane{2} = [cross(camera_v3,camera_v2)/norm(cross(camera_v3,camera_v2));0];
CamPlane{3} = [cross(camera_v4,camera_v3)/norm(cross(camera_v4,camera_v3));0];
CamPlane{4} = [cross(camera_v4,camera_v1)/norm(cross(camera_v4,camera_v1));0];

end

