%Copyright (C) 2010 Varsha Hedau, University of Illinois at Urbana Champaign.
%See readme distributed with this code for terms of use.

function [pts_c]=warpimg3D(img,h,w,DistfromSurface,SurfaceNormals,visplanes,Polyg,R,K,fignum)



clear pts_dummy pts_c;
%for id=1:numel(visplanes)

for planeid=1:5%numel(visplanes)
    
    if visplanes(planeid)
        %planeid=visplanes(id);
        N=SurfaceNormals(planeid,:)';
        Nc = R*N;
        dc=DistfromSurface(planeid);
        
        mask = poly2mask(max(min(Polyg{planeid}(:,1),h),1),max(min(Polyg{planeid}(:,2),w),1),h,w);
        mask1=mask;
        se = strel('square',10);
        mask1 = imdilate(mask1,se);
        disp_img{planeid}=img;
        for i=1:3
            disp_img{planeid}(:,:,i) = double(img(:,:,i)).*mask1 + 255*(~mask1);
        end
        [y1,x1] = find(mask1);
        disp_img{planeid}=disp_img{planeid}(min(y1):max(y1),min(x1):max(x1),:);
        [y,x] = find(mask);
        [x,y] = meshgrid(min(x):max(x),min(y):max(y));
        homo_coords = inv(K)*[x(:)';y(:)';ones(size(x(:)'))];
        len = dc ./ (Nc'*homo_coords);
        pts_c{planeid} = repmat(len,3,1).*homo_coords;
        
        pts_dummy{planeid}=R'*pts_c{planeid};% warp in world with origin at cam
        pts_x{planeid} = reshape(pts_dummy{planeid}(1,:),size(x));
        pts_y{planeid} = reshape(pts_dummy{planeid}(2,:),size(x));
        pts_z{planeid} = reshape(pts_dummy{planeid}(3,:),size(x));
    end
end

clear pts_dummy;

if exist('fignum','var')
    figure(fignum);hold on;   plot3(0,0,0,'*r');%camera at [0 0 0];
    for planeid= 1:5%numel(visplanes)
        if visplanes(planeid)
            if planeid==5  %dont warp ceiling
                continue;
            end
            if numel(Polyg{planeid})>0
                warp(pts_x{planeid},pts_y{planeid},pts_z{planeid},disp_img{planeid});%warp in world system
            end
        end
    end
    axis equal
    axis off
end
