
%Copyright (C) 2010 Varsha Hedau, University of Illinois at Urbana Champaign.
%See readme distributed with this code for terms of use.

function [Xc Yc Zc Xc_floor Yc_floor Zc_floor Xc_dummy ...
    Yc_dummy Zc_dummy]=createVoxelgrid(pts_c,Polyg,R,K,h,w,camera_ht)

pts_dummy=R'*pts_c{1};
clear pts_c;

minX = max([min(pts_dummy(1,:)) -50]);
maxX = min([max(pts_dummy(1,:)) 50]);
dX = 1;
minZ = max([min(pts_dummy(3,:)) -50]);
maxZ = min([max(pts_dummy(3,:)) 50]);
dZ = 1;
[Xc_dummy Zc_dummy] = meshgrid(minX:dX:maxX,minZ:dZ:maxZ);
Xc_dummy=Xc_dummy(:);
Zc_dummy=Zc_dummy(:);
Yc_dummy=-camera_ht*ones(length(Xc_dummy),1);

img_points = K*R*[Xc_dummy';Yc_dummy';Zc_dummy'];
img_points = img_points./(repmat(img_points(3,:),3,1));
xs = round(img_points(1,:));
ys = round(img_points(2,:));
tokeep = find(xs>1 & ys>1 & xs<=w & ys<=h);
xs = xs(tokeep);
ys = ys(tokeep);
Xc_dummy = Xc_dummy(tokeep);
Yc_dummy = Yc_dummy(tokeep);
Zc_dummy = Zc_dummy(tokeep);
floormask=poly2mask(Polyg{1}(:,1),Polyg{1}(:,2),h,w);
% floormask = imdilate(floormask,ones(round(h/20)));
tokeep = sub2ind([h,w],ys,xs);
tokeep = find(floormask(tokeep));
Xc_dummy = Xc_dummy(tokeep);
Yc_dummy = Yc_dummy(tokeep);
Zc_dummy = Zc_dummy(tokeep);

dY=1;
Yc_incr=[0:dY:10]';
Xc_dummy=repmat(Xc_dummy,[numel(Yc_incr) 1]);
Zc_dummy=repmat(Zc_dummy,[numel(Yc_incr) 1]);
Yc_dummy1=[];
for l=1:length(Yc_incr)
 Yc_dummy1=[Yc_dummy1;Yc_dummy + diag(eye(length(Yc_dummy))*Yc_incr(l))];
end
Yc_dummy=Yc_dummy1;
Yc_dummy1=[];

Xc_dummy_floor=Xc_dummy;
Yc_dummy_floor=-camera_ht*ones(length(Xc_dummy_floor),1);
Zc_dummy_floor=Zc_dummy;

%grid points
pts_dummy=[Xc_dummy Yc_dummy Zc_dummy]';
pts_c=R*pts_dummy;
Xc=pts_c(1,:);Xc=Xc(:);
Yc=pts_c(2,:);Yc=Yc(:);
Zc=pts_c(3,:);Zc=Zc(:);

%their projection on floor
pts_dummy_floor=[Xc_dummy_floor Yc_dummy_floor Zc_dummy_floor]';
pts_c_floor=R*pts_dummy_floor;
Xc_floor=pts_c_floor(1,:);Xc_floor=Xc_floor(:);
Yc_floor=pts_c_floor(2,:);Yc_floor=Yc_floor(:);
Zc_floor=pts_c_floor(3,:);Zc_floor=Zc_floor(:);
