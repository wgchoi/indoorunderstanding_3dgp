%function to get wall corners and room dimensions in 3D
%Polyg-walls, floor ceiling polygons
%vp-vanishing points
%K,R-Camera matrix and Rotation matrix


%Copyright (C) 2010 Varsha Hedau, University of Illinois at Urbana Champaign.
%See readme distributed with this code for terms of use.

function [room_ht room_wt SurfaceNormals DistfromSurface DistOn visplanes corners3D K R]=getWallCorners(Polyg,vp,h,w,K,R)

corners3D=[];
corner_BL=[];
corner_BR=[];
corner_TL=[];
corner_TR=[];
DistfromSurface=zeros(5,1);
DistOn=zeros(5,1);
visplanes=zeros(1,5);


%Normals of floors walls ceiling in World
SurfaceNormals=[0 1 0;0 0 1;1 0 0;1 0 0;0 1 0];
camera_ht = 1; % unit height


room_ht=[];
room_wt=[];

%[K R]=calibrate_cam(vp,h,w);

if numel(K) > 0 & numel(R) > 0
    for i=1:numel(Polyg)
        if numel(Polyg{i}) > 0
            visplanes(i)=1;
        end
    end


    %get 4 corners of middle wall
    corners = [1 h;1 1;w 1;w h];
    numV = size(Polyg{2},1);
    if numV >= 4
        dists = (corners(:,1)*ones(1,numV)-ones(4,1)*Polyg{2}(:,1)').^2 + ...
            (corners(:,2)*ones(1,numV)-ones(4,1)*Polyg{2}(:,2)').^2;
        [vv,ii] = min(dists,[],2);
        corner_bl = Polyg{2}(ii(1),:);
        corner_tl = Polyg{2}(ii(2),:);
        corner_tr = Polyg{2}(ii(3),:);
        corner_br = Polyg{2}(ii(4),:);
    end


    %% Get distances from different surfaces
    DistfromSurface(1)=camera_ht;
    DistOn(1)=1;


    if visplanes(1) & visplanes(2) & ~visplanes(3) & ~visplanes(4)
        [bndy]=getbndybetfaces(Polyg{2},Polyg{1});
        if numel(bndy) >0
            N=SurfaceNormals(1,:)';
            Nc = R*N;
            dc=-camera_ht;
            % camera is 000 floor is below it
            homo_coords=inv(K)*[bndy(1);bndy(3);1];  %Intersect the Ray from camera to the pixel
            len = dc ./ (Nc'*homo_coords);%with the floor plane
            corner_T=len*homo_coords;
            corner_T = R' * corner_T;
            DistfromSurface(2) = -1*corner_T(find(SurfaceNormals(2,:)));
            DistOn(2)=1;
        end

    elseif  visplanes(1) & visplanes(2) & visplanes(3) & ~visplanes(4) & exist('corner_br','var')

        N=SurfaceNormals(1,:)';
        Nc = R*N; dc=-camera_ht;
        homo_coords=inv(K)*[corner_br(1);corner_br(2);1];
        len = dc ./ (Nc'*homo_coords);
        corner_BR=len*homo_coords;
        corner_BR = R' * corner_BR;
        DistfromSurface(1) = -1*corner_BR(2);
        DistfromSurface(2) = -1*corner_BR(3);
        DistfromSurface(3) = -1*corner_BR(1);
        DistOn([1 2 3])=1;


    elseif visplanes(1) & visplanes(2) & ~visplanes(3) & visplanes(4) & exist('corner_bl','var')
        N=SurfaceNormals(1,:)';
        Nc = R*N;
        dc=-camera_ht;
        % camera is 000 floor is below it
        homo_coords=inv(K)*[corner_bl(1);corner_bl(2);1];  %Intersect the Ray from camera to the pixel
        len = dc ./ (Nc'*homo_coords);%with the floor plane
        corner_BL=len*homo_coords;%Bottom left corner in 3D
        corner_BL = R' * corner_BL;
        DistfromSurface(1) = -1*corner_BL(2);
        DistfromSurface(2) = -1*corner_BL(3);
        DistfromSurface(4) = -1*corner_BL(1);
        DistOn([1 2 4])=1;
        corners3D{1}=corner_BL;
    elseif visplanes(1) & visplanes(2) & visplanes(3) & visplanes(4) & ...
            exist('corner_br','var') & exist('corner_bl','var')
        N=SurfaceNormals(1,:)';
        Nc = R*N;
        dc=-camera_ht;
        % camera is 000 floor is below it
        homo_coords=inv(K)*[corner_bl(1);corner_bl(2);1];  %Intersect the Ray from camera to the pixel
        len = dc ./ (Nc'*homo_coords);%with the floor plane
        corner_BL=len*homo_coords;%Bottom left corner in 3D
        corner_BL = R' * corner_BL;
        DistfromSurface(1) = -1*corner_BL(2);
        DistfromSurface(2) = -1*corner_BL(3);
        DistfromSurface(4) = -1*corner_BL(1);
        DistOn([1 2 4])=1;
        homo_coords=inv(K)*[corner_br(1);corner_br(2);1];
        len = dc ./ (Nc'*homo_coords);
        corner_BR=len*homo_coords;
        corner_BR = R' * corner_BR;
        DistfromSurface(3) = -1*corner_BR(1);
        DistOn(3)=1;
    end




    if  visplanes(2) & visplanes(5) & visplanes(4) & exist('corner_tl','var')
        N=SurfaceNormals(2,:)';
        Nc = R*N;
        homo_coords=inv(K)*[corner_tl(1);corner_tl(2);1];
        len = (-1*DistfromSurface(2)) ./ (Nc'*homo_coords);
        corner_TL=len*homo_coords;
        corner_TL = R' * corner_TL;
        DistfromSurface(5) =-1*corner_TL(2);
        DistOn(5)=1;


    elseif visplanes(2) & visplanes(5) & visplanes(3) & exist('corner_tr','var')
        N=SurfaceNormals(2,:)';
        Nc = R*N;
        homo_coords=inv(K)*[corner_tr(1);corner_tr(2);1];
        len = (-1*DistfromSurface(2))./ (Nc'*homo_coords);
        corner_TR=len*homo_coords;
        corner_TR = R' * corner_TR;
        DistfromSurface(5) =-1*corner_TR(2);
        DistOn(5)=1;

    elseif visplanes(2) & visplanes(5) & ~visplanes(3) & ~visplanes(4)
        [bndy]=getbndybetfaces(Polyg{5},Polyg{2});
        N=SurfaceNormals(2,:)';
        Nc = R*N;
        dc=-1*DistfromSurface(2);
        if numel(bndy) > 0
            % camera is 000 floor is below it
            homo_coords=inv(K)*[bndy(1);bndy(3);1];  %Intersect the Ray from camera to the pixel
            len = dc ./ (Nc'*homo_coords);%with the floor plane
            corner_T=len*homo_coords;
            corner_T = R' * corner_T;
            DistfromSurface(5) = -1*corner_T(find(SurfaceNormals(5,:)));
            DistOn(5)=1;
        end

    end


    DistfromSurface=-DistfromSurface;
    corners3D{1}=corner_BL;
    corners3D{2}=corner_TL;
    corners3D{3}=corner_TR;
    corners3D{4}=corner_BR;
    %% Room height & width




    if numel(corners3D{1})> 0 & numel(corners3D{2})> 0
        room_ht=sqrt((corners3D{1}(1)-corners3D{2}(1))^2+(corners3D{1}(2)-corners3D{2}(2))^2+(corners3D{1}(3)-corners3D{2}(3))^2);
    elseif  numel(corners3D{3})> 0 & numel(corners3D{4})> 0
        room_ht=sqrt((corners3D{3}(1)-corners3D{4}(1))^2+(corners3D{3}(2)-corners3D{4}(2))^2+(corners3D{3}(3)-corners3D{4}(3))^2);
    elseif visplanes(1) & visplanes(2) & visplanes(5)

        [bndy]=getbndybetfaces(Polyg{2},Polyg{1});
        if numel(bndy) >0
            N=SurfaceNormals(1,:)';
            Nc = R*N;
            dc=-camera_ht;
            % camera is 000 floor is below it
            p1x=(bndy(1)+bndy(2))/2;
            p1y=(bndy(3)+bndy(4))/2;
            homo_coords=inv(K)*[p1x;p1y;1];  %Intersect the Ray from camera to the pixel
            len = dc ./ (Nc'*homo_coords);%with the floor plane
            corner_T1=len*homo_coords;
            corner_T1 = R' * corner_T1;
        end
        [bndy]=getbndybetfaces(Polyg{2},Polyg{5});
        if numel(bndy) > 0 & exist('p2x','var')
            [p2x p2y]=IntersectLines([p1x vp(1,1) p1y vp(1,2)],bndy);
            N=SurfaceNormals(2,:)';
            Nc = R*N;
            dc=-1*DistfromSurface(2);
            homo_coords=inv(K)*[p2x;p2y;1];  %Intersect the Ray from camera to the pixel
            len = dc ./ (Nc'*homo_coords);%with the floor plane
            corner_T2=len*homo_coords;
            corner_T2 = R' * corner_T2;
            room_ht=sqrt((corner_T1(1)-corner_T2(1))^2+(corner_T1(2)-corner_T2(2))^2+(corner_T1(3)-corner_T2(3))^2);
        end
    else


    end


    if numel(corners3D{1})> 0 & numel(corners3D{4})> 0
        room_wt=sqrt((corners3D{1}(1)-corners3D{4}(1))^2+(corners3D{1}(2)-corners3D{4}(2))^2+(corners3D{1}(3)-corners3D{4}(3))^2);
    elseif numel(corners3D{2})> 0 & numel(corners3D{3})> 0
        room_wt=sqrt((corners3D{2}(1)-corners3D{3}(1))^2+(corners3D{2}(2)-corners3D{3}(2))^2+(corners3D{2}(3)-corners3D{3}(3))^2);
    elseif visplanes(4) & visplanes(2) & visplanes(3)

        [bndy]=getbndybetfaces(Polyg{2},Polyg{4});
        if numel(bndy) >0
            N=SurfaceNormals(2,:)';
            Nc = R*N;
            dc=-1*DistfromSurface(2);
            % camera is 000 floor is below it
            p1x=(bndy(1)+bndy(2))/2;
            p1y=(bndy(3)+bndy(4))/2;
            homo_coords=inv(K)*[p1x;p1y;1];  %Intersect the Ray from camera to the pixel
            len = dc ./ (Nc'*homo_coords);%with the floor plane
            corner_T1=len*homo_coords;
            corner_T1 = R' * corner_T1;
        end
        [bndy]=getbndybetfaces(Polyg{2},Polyg{3});
        if numel(bndy) > 0 & exist('p1x','var')
            [p2x p2y]=IntersectLines([p1x vp(2,1) p1y vp(2,2)],bndy);
            N=SurfaceNormals(2,:)';
            Nc = R*N;
            dc=-1*DistfromSurface(2);
            homo_coords=inv(K)*[p2x;p2y;1];  %Intersect the Ray from camera to the pixel
            len = dc ./ (Nc'*homo_coords);%with the floor plane
            corner_T2=len*homo_coords;
            corner_T2 = R' * corner_T2;
            room_wt=sqrt((corner_T1(1)-corner_T2(1))^2+(corner_T1(2)-corner_T2(2))^2+(corner_T1(3)-corner_T2(3))^2);
        end
    else

    end


end


return;

% if numel(find(ismember(visplanes,[1 2])))==2
% [bndy]=getbndybetfaces(Polyg{2},Polyg{1})
% if numel(bndy) >0
%      N=SurfaceNormals(1,:)';
%         Nc = R*N;
%         dc=-camera_ht;
%         % camera is 000 floor is below it
%         homo_coords=inv(K)*[bndy(1);bndy(3);1];  %Intersect the Ray from camera to the pixel
%         len = dc ./ (Nc'*homo_coords);%with the floor plane
%         corner_T=len*homo_coords;
%         corner_T = R' * corner_T;
%         DistfromSurface(2) = -1*corner_T(find(SurfaceNormals(2,:)));
%         DistOn(2)=1;
%
% end
% end
%
%
% if numel(find(ismember(visplanes,[1 3])))==2
% [bndy]=getbndybetfaces(Polyg{3},Polyg{1});
% if numel(bndy) > 0
%        N=SurfaceNormals(1,:)';
%        Nc = R*N;
%         dc=-camera_ht;
%         % camera is 000 floor is below it
%         homo_coords=inv(K)*[bndy(1);bndy(3);1];  %Intersect the Ray from camera to the pixel
%         len = dc ./ (Nc'*homo_coords);%with the floor plane
%         corner_T=len*homo_coords;
%         corner_T = R' * corner_T;
%         DistfromSurface(3) = -1*corner_T(find(SurfaceNormals(3,:)));
%         DistOn(3)=1;
%  end
% end
%
% if numel(find(ismember(visplanes,[1 4])))==2
% [bndy]=getbndybetfaces(Polyg{4},Polyg{1});
% if numel(bndy) > 0
%        N=SurfaceNormals(1,:)';
%        Nc = R*N;
%         dc=-camera_ht;
%         % camera is 000 floor is below it
%         homo_coords=inv(K)*[bndy(1);bndy(3);1];  %Intersect the Ray from camera to the pixel
%         len = dc ./ (Nc'*homo_coords);%with the floor plane
%         corner_T=len*homo_coords;
%         corner_T = R' * corner_T;
%         DistfromSurface(4) = -1*corner_T(find(SurfaceNormals(4,:)));
%         DistOn(4)=1;
%  end
% end
%
% num1=numel(find(ismember(visplanes,[5 2])));
% num2=numel(find(ismember(visplanes,[5 3])));
% num3=numel(find(ismember(visplanes,[5 4])));
%
% if num1==2 | num2==2 | num3==2
%     if num1==2 & DistOn(2)==1
%     [bndy]=getbndybetfaces(Polyg{5},Polyg{2});
%     N=SurfaceNormals(2,:)';
%     dc=-1*DistfromSurface(2);
%     elseif num2==2 & DistOn(3)==1
%     [bndy]=getbndybetfaces(Polyg{5},Polyg{3});
%     N=SurfaceNormals(3,:)';
%     dc=-1*DistfromSurface(3);
%     elseif num3==2 & DistOn(4)==1
%     [bndy]=getbndybetfaces(Polyg{5},Polyg{4});
%     N=SurfaceNormals(4,:)';
%     dc=-1*DistfromSurface(4);
%     else
%
%     end
%
% if numel(bndy) > 0
%        Nc = R*N;
%         % camera is 000 floor is below it
%         homo_coords=inv(K)*[bndy(1);bndy(3);1];  %Intersect the Ray from camera to the pixel
%         len = dc ./ (Nc'*homo_coords);%with the floor plane
%         corner_T=len*homo_coords;
%         corner_T = R' * corner_T;
%         DistfromSurface(5) = -1*corner_T(find(SurfaceNormals(5,:)));
%         DistOn(5)=1;
%  end
% end




