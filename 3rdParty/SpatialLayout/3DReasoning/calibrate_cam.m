%Function to compute camera intrinsic and Rotation matrix from three orthogonal vanishing points of the world.
%vp-vanishing points
%h,w-height and width of the image
%K,R-Camera intrinsic and Rotation matrix

%Copyright (C) 2010 Varsha Hedau, University of Illinois at Urbana Champaign.
%See readme distributed with this code for terms of use.
function [K R]=calibrate_cam(vp,h,w)

K=[];
R=[];
% VP=vpdata.vp;
% vp=[VP(1) VP(2);VP(3) VP(4);VP(5) VP(6)];
% [vp P]=ordervp(vp,h,w,vpdata.p);
infchk = vp(:,1) > 50 * w | vp(:,2) > 50 * h;

%Get camera matrices K and R
if sum(infchk)==0
    v1 = vp(1,:);
    v2 = vp(2,:);
    v3 = vp(3,:);
    
    Mats_11 = v1(:,1)+v2(:,1);
    Mats_12 = v1(:,2)+v2(:,2);
    Mats_13 = v1(:,1).*v2(:,1)+v1(:,2).*v2(:,2);
    Mats_21 = v1(:,1)+v3(:,1);
    Mats_22 = v1(:,2)+v3(:,2);
    Mats_23 = v1(:,1).*v3(:,1)+v1(:,2).*v3(:,2);
    Mats_31 = v3(:,1)+v2(:,1);
    Mats_32 = v3(:,2)+v2(:,2);
    Mats_33 = v3(:,1).*v2(:,1)+v3(:,2).*v2(:,2);

    A_11 = Mats_11-Mats_21; A_12 = Mats_12-Mats_22;
    A_21 = Mats_11-Mats_31; A_22 = Mats_12-Mats_32;
    b_1 = Mats_13-Mats_23; b_2 = Mats_13-Mats_33;
    detA = A_11.*A_22-A_12.*A_21;
    u0 = (A_22.*b_1-A_12.*b_2)./detA;
    v0 = (A_11.*b_2-A_21.*b_1)./detA;

    temp = Mats_11.*u0+Mats_12.*v0-Mats_13-u0.*u0-v0.*v0;
    f = (temp).^(0.5);
end

if sum(infchk)==1
    ii=find(infchk==0);
    v1 = vp(ii(1),:);
    v2 = vp(ii(2),:);
    r=((w/2-v1(:,1)).*(v2(:,1)-v1(:,1))+(h/2-v1(:,2)).*(v2(:,2)-v1(:,2)))./((v2(:,1)-v1(:,1)).^2+(v2(:,2)-v1(:,2)).^2);

    u0= v1(:,1) + r.*(v2(:,1)-v1(:,1));
    v0= v1(:,2) + r.*(v2(:,2)-v1(:,2));

    temp=u0.*(v1(:,1)+v2(:,1))+v0.*(v2(:,2)+v1(:,2))-(v1(:,1).*v2(:,1)+v2(:,2).*v1(:,2)+u0.^2+v0.^2);
    f = (temp).^(0.5);
end


if exist('f','var') & exist('u0','var') & exist('v0','var') 
    K = [f 0 u0; 0 f v0; 0 0 1];
    
    vecx = inv(K) * [vp(2,:) 1]';
    vecx = vecx / norm(vecx);
    if (vp(2,1) < u0)
        vecx = -vecx;
    end
    vecz = inv(K) * [vp(3,:) 1]';
    vecz = -vecz / norm(vecz);
    vecy = cross(vecz, vecx);
    R = [vecx,vecy,vecz];
end

if sum(infchk) == 2
%     if infchk(2) == 1
%         vp(2,:) = vp(2,:) ./ norm(vp(2,:));
%     end
%     if infchk(1) == 1
%         vp(1,:) = vp(1,:) ./ norm(vp(1,:));
%     end
%     if infchk(3) == 1
%         vp(3,:) = vp(3,:) ./ norm(vp(3,:));
%     end
%     u0=[vp(1,1)*vp(2,2)*vp(3,2)-vp(2,1)*vp(1,2)*vp(3,2)]/[vp(1,1)*vp(2,2)-vp(2,1)*vp(1,2)];
%     v0=[vp(1,2)*vp(2,1)*vp(3,1)-vp(2,2)*vp(1,1)*vp(3,1)]/[vp(1,2)*vp(2,1)-vp(2,2)*vp(1,1)];
    u0 = w / 2; v0 = h / 2;
    
    if (infchk(2) == 1)
        vecx = [vp(2,:) 0]';
        vecx = vecx ./ norm(vecx);
        if (vp(2, 1) < u0)
            vecx = -vecx;
        end
    end
    if (infchk(1) == 1)
        vecy = [vp(1,:) 0]';
        vecy = vecy ./ norm(vecy);
         if (vp(1, 2) > v0)
            vecy = -vecy;
        end
        
    end
    if (infchk(3) == 1)
        vecz = [vp(3,:) 0]';
        vecz = -vecz ./ norm(vecz);
    end
    
    if exist('vecx','var') && exist('vecy','var')
        vecz = cross(vecx, vecy);
    elseif exist('vecy','var') && exist('vecz','var')
        vecx = cross(vecy, vecz);
    else
        vecy = cross(vecz, vecx);
    end
    R=[vecx, vecy, vecz];
    f=500;
    K = [f 0 u0; 0 f v0; 0 0 1];
end

return;
