function [Faces, Corners] = getRoomFaces(Polyg, h, w, K, R)
checkLayoutAnnotation(Polyg, [h w]);
%%
DistfromSurface = zeros(5,1);
visplanes = zeros(1,5);

% Normals of floors walls ceiling in World
SurfaceNormals=[0 1 0; 0 0 1; 1 0 0; 1 0 0; 0 1 0];
camera_ht = 1; % unit height

for i=1:numel(Polyg)
    if numel(Polyg{i}) > 0
        visplanes(i) = 1;
    end
end

corners = [1 h;1 1;w 1;w h];
numV = size(Polyg{2}, 1);
if numV >= 4
    dists = (corners(:,1) * ones(1,numV) - ones(4,1) * Polyg{2}(:,1)') .^ 2 + ...
            (corners(:,2) * ones(1,numV) - ones(4,1) * Polyg{2}(:,2)') .^ 2;
    
    [vv,ii] = min(dists,[],2);
    
    %%%% ?? 
    corner_bl = Polyg{2}(ii(1),:);
    corner_tl = Polyg{2}(ii(2),:);
    corner_tr = Polyg{2}(ii(3),:);
    corner_br = Polyg{2}(ii(4),:);
end

DistfromSurface(1) = camera_ht;
DistOn(1) = 1;

% find lower corners and distance to faces
if (visplanes(1) && visplanes(2) && ~visplanes(3) && ~visplanes(4))
    %  case
    % |         |
    % |   c     |
    % |         |
    % -----------
    % |   f     |
    bct = getBndyBtwFaces(Polyg{2}, Polyg{1});

    assert(~isempty(bct));
    
    Nc = SurfaceNormals(1,:)';
    
    dc = -camera_ht;
    homo_coords = (K * R) \ [bct(1); bct(2); 1]; % Intersect the Ray from camera to the pixel
    len = dc ./ dot(Nc, homo_coords); % with the floor plane
    corner_T = len * homo_coords;
    
    DistfromSurface(1) = -1 * corner_T(2);
    DistfromSurface(2) = -1 * corner_T(3);
    DistOn([1 2]) = 1;
elseif (visplanes(1) && visplanes(2) && visplanes(3) && ~visplanes(4) && exist('corner_br','var'))
    %  case
    % |       | |
    % |   c   |r|
    % |       | |
    % --------- |
    % |   f    \| 
    
    Nc = SurfaceNormals(1,:)'; % floor normal
    dc = -camera_ht;
    
    homo_coords = (K * R) \ [corner_br(1); corner_br(2); 1];
    len = dc ./ dot(Nc, homo_coords);
    
    corner_BR = len * homo_coords;

    DistfromSurface(1) = -1 * corner_BR(2);
    DistfromSurface(2) = -1 * corner_BR(3);
    DistfromSurface(3) = -1 * corner_BR(1);
    
    DistOn([1 2 3])=1;
elseif (visplanes(1) && visplanes(2) && ~visplanes(3) && visplanes(4) && exist('corner_bl','var'))
    %  case
    % | |        |
    % |l|   c    |
    % | |        |
    % | ---------|
    % |/   f     | 
    Nc = SurfaceNormals(1,:)'; % floor normal
    dc = -camera_ht;
    
    homo_coords = (K * R) \ [corner_bl(1); corner_bl(2); 1];
    len = dc ./ dot(Nc, homo_coords);
    corner_BL = len * homo_coords;
    
    DistfromSurface(1) = -1*corner_BL(2);
    DistfromSurface(2) = -1*corner_BL(3);
    DistfromSurface(4) = -1*corner_BL(1);
    
    DistOn([1 2 4])=1;
elseif (visplanes(1) && visplanes(2) && visplanes(3) && visplanes(4) && exist('corner_br','var') && exist('corner_bl','var'))
    %  case
    % | |       | |
    % |l|   c   |r|
    % | |       | |
    % | --------- |
    % |/   f     \| 
    Nc = SurfaceNormals(1,:)'; % floor normal
    dc=-camera_ht;
    
    % camera is 000 floor is below it
    homo_coords = (K * R) \ [corner_bl(1); corner_bl(2); 1];  % Intersect the Ray from camera to the pixel
    len = dc ./ dot(Nc, homo_coords); % with the floor plane
    corner_BL = len * homo_coords; % Bottom left corner in 3D

    DistfromSurface(1) = -1 * corner_BL(2);
    DistfromSurface(2) = -1 * corner_BL(3);
    DistfromSurface(4) = -1 * corner_BL(1);
    DistOn([1 2 4])=1;
    
    homo_coords = (K * R) \ [corner_br(1); corner_br(2); 1];
    len = dc ./ dot(Nc, homo_coords);
    corner_BR = len * homo_coords;
    
    DistfromSurface(3) = -1 * corner_BR(1);
    DistOn(3)=1;
end

% find upper corners and distance to faces
if (visplanes(2) && visplanes(5) && visplanes(4) && exist('corner_tl', 'var'))
    %  case
    % |\   ceil   |
    % | -----------
    % | |         |
    % |l|   c     |
    % | |         |
    Nc = SurfaceNormals(2, :)'; % center wall's normal

    homo_coords = (K * R) \ [corner_tl(1); corner_tl(2); 1];
    
    len = (-1 * DistfromSurface(2)) ./ dot(Nc, homo_coords);
    
    corner_TL = len * homo_coords;
    
    DistfromSurface(5) = - 1 * corner_TL(2);
    
    DistOn(5) = 1;
elseif (visplanes(2) && visplanes(5) && visplanes(3) && exist('corner_tr','var'))
    %  case
    % |   ceil  /|
    % ---------- |
    % |        | |
    % |   c    |r|
    % |        | |
    Nc = SurfaceNormals(2,:)'; % center wall's normal

    homo_coords = (K * R) \ [corner_tr(1); corner_tr(2); 1];
    
    len = (-1 * DistfromSurface(2)) ./ dot(Nc, homo_coords);
    
    corner_TR = len * homo_coords;

    DistfromSurface(5) = -1 * corner_TR(2);
    
    DistOn(5) = 1;
elseif (visplanes(2) && visplanes(5) && ~visplanes(3) && ~visplanes(4))
    %  case
    % |   ceil  |
    % -----------
    % |         |
    % |   c     |
    % |         |
    bct = getBndyBtwFaces(Polyg{5}, Polyg{2});
    assert(~isempty(bct));
    
    Nc = SurfaceNormals(2, :)';
    dc = -1 * DistfromSurface(2);
    
    homo_coords = (K * R) \ [bct(1); bct(2); 1];  %Intersect the Ray from camera to the pixel

    len = dc ./ dot(Nc, homo_coords); % with the floor plane
    
    corner_T = len * homo_coords;
    DistfromSurface(5) = -1 * corner_T(2);
    
    DistOn(5) = 1;
end
%%
Faces = nan(5, 4);
for i = 1:size(Faces, 1)
    if(visplanes(i))
        Faces(i, 1:3) = SurfaceNormals(i, :) ./ norm(SurfaceNormals(i, :));
        Faces(i, 4) = DistfromSurface(i);
    end
end
%% bottom corners on the image
Corners = nan(2, 4);
if (visplanes(1) && visplanes(2))
    corners = [1 h; w h];
    numV = size(Polyg{2}, 1);
    
    dists = (corners(:,1) * ones(1,numV) - ones(2,1) * Polyg{2}(:,1)') .^ 2 + ...
            (corners(:,2) * ones(1,numV) - ones(2,1) * Polyg{2}(:,2)') .^ 2;
    
    [~,ii] = min(dists,[],2);
    
    Corners(:, 2) = Polyg{2}(ii(1),:);
    Corners(:, 3) = Polyg{2}(ii(2),:);
    
    if (visplanes(3))
        dists = (Polyg{3}(:,1) * ones(1, size(Polyg{1}, 1)) - ones(size(Polyg{3}, 1), 1) * Polyg{1}(:,1)') .^ 2 + ...
                (Polyg{3}(:,2) * ones(1, size(Polyg{1}, 1)) - ones(size(Polyg{3}, 1), 1) * Polyg{1}(:,2)') .^ 2;
            
        [i1, i2] = find(dists < 100);
        if(~isempty(i1))
            p = [Polyg{3}(unique(i1), :); Polyg{1}(unique(i2), :)];
            Corners(:, 4) = mean(p, 1);
        end
    end
    
    if (visplanes(4))
        dists = (Polyg{4}(:,1) * ones(1, size(Polyg{1}, 1)) - ones(size(Polyg{4}, 1), 1) * Polyg{1}(:,1)') .^ 2 + ...
                (Polyg{4}(:,2) * ones(1, size(Polyg{1}, 1)) - ones(size(Polyg{4}, 1), 1) * Polyg{1}(:,2)') .^ 2;
            
        [i1, i2] = find(dists < 100);
        if(~isempty(i1))
            p = [Polyg{4}(unique(i1), :); Polyg{1}(unique(i2), :)];
            Corners(:, 1) = mean(p, 1);
        end
    end
end

end
