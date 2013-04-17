function [cornerr gtcorner estcorner] = getCornerr(gtPolyg,Polyg,imsz)
% Input:
%   1) gtPolyg:     grouth-truth polygons
%   2) Polyg:       estimated polygons
%   3) imsz:        image size (tested using data.x.imsz)
% Output:
%   1) cornerr:     corner error
%   2) gtcorner:    corners of ground truth
%   3) estcorner:   corners of estimation
%
% Notes:
%   1: ground  2: center  3: right  4: left  5: top
%   corner existence: 123, 124, 235, 245

diag_dist = norm(imsz);
image_corners = [imsz(2) imsz(1);0 imsz(1);imsz(2) 0;0 0];  % lr,ll,ur,ul

% Check existence of corners in GT and estimation
CHK = [1 2 3;1 2 4;2 3 5;2 4 5];

corner_exist_gtPolyg = zeros(1,size(CHK,1));
corner_exist_Polyg = zeros(1,size(CHK,1));

for chk = 1:size(CHK,1)
    countg = 0;
    countp = 0;
    for chkwall = 1:size(CHK,2)
        if ~isempty(gtPolyg{CHK(chk,chkwall)})
            countg = countg + 1;
        end
        if ~isempty(Polyg{CHK(chk,chkwall)})
           countp = countp + 1;
        end
    end
    if countg == size(CHK,2)
        corner_exist_gtPolyg(chk) = 1;
    end
    if countp == size(CHK,2)
       corner_exist_Polyg(chk) = 1;
    end
end

% Assume there is a center, get the corners of GT
center_gt = gtPolyg{2};
if isempty(center_gt)
    fprintf('No center exist for ground truth! Could cause errors!!\n');
    cornerr = NaN;
    return
end

NUMgtcorner = sum(corner_exist_gtPolyg ~= 0);  %  Get number of corners in GT

sep_gt = corner_exist_gtPolyg(1)+corner_exist_gtPolyg(3);

if (NUMgtcorner == 2 && (sep_gt == 0 || sep_gt == 2)) || NUMgtcorner == 1
    
    % if number of corners = 2 with ambiguous cases and 1, get corners for both possible cases
    CornerPosGT = zeros(2,4,2);
    tmp_flag = 1;
    for tmp_id = 2:4
        if ~isempty(gtPolyg{tmp_id})
            center_gt_new = gtPolyg{tmp_id};
            for INDcorner = 1:4
                tmp1 = repmat(permute(center_gt_new,[3 1 2]),[4 1 1]);
                tmp2 = repmat(permute(image_corners,[1 3 2]),[1 size(center_gt_new,1) 1]);
                dist2imgcorner = sqrt(sum((tmp1 - tmp2).^2,3));
                [~,id] = min(dist2imgcorner(INDcorner,:));
                CornerPosGT(:,INDcorner,tmp_flag) = center_gt_new(id,:)';
            end
            tmp_flag = tmp_flag+1;
        end
    end
    
%     % if number of corners = 2 with ambiguous cases and 1, get the new center with greatest area
%     area_tmp = zeros(1,3);
%     for tmp_id = 2:4
%         if ~isempty(gtPolyg{tmp_id})
%             area_tmp(tmp_id-1)=polyarea([gtPolyg{tmp_id}(:,1);gtPolyg{tmp_id}(1,1)], ...
%                 [gtPolyg{tmp_id}(:,2);gtPolyg{tmp_id}(1,2)]);
%         end
%     end
%     [~,id] = max(area_tmp);
%     id = id+1;
%     
%     center_gt_new = gtPolyg{id};
%     for INDcorner = 1:4
%         tmp1 = repmat(permute(center_gt_new,[3 1 2]),[4 1 1]);
%         tmp2 = repmat(permute(image_corners,[1 3 2]),[1 size(center_gt_new,1) 1]);
%         dist2imgcorner = sqrt(sum((tmp1 - tmp2).^2,3));
%         [~,id] = min(dist2imgcorner(INDcorner,:));
%         CornerPosGT(:,INDcorner) = center_gt_new(id,:)';
%     end
    
else
    
    % if number of corners = 4 3 0 and 2 with assertive cases
    if NUMgtcorner == 0
        %fprintf('No corners in ground truth!!\n');
    end
    
    CornerPosGT = zeros(2,4);
    for INDcorner = 1:4
        tmp1 = repmat(permute(center_gt,[3 1 2]),[4 1 1]);
        tmp2 = repmat(permute(image_corners,[1 3 2]),[1 size(center_gt,1) 1]);
        dist2imgcorner = sqrt(sum((tmp1 - tmp2).^2,3));
        [~,id] = min(dist2imgcorner(INDcorner,:));
        CornerPosGT(:,INDcorner) = center_gt(id,:)';
    end
    
end

% Assume there is a center, get the corners of estimation
center_est = Polyg{2};
if isempty(center_est)
    fprintf('No center exist for estimation! Could cause errors!!\n');
    cornerr = NaN;
    return
end

NUMestcorner = sum(corner_exist_Polyg ~= 0);  %  Get number of corners in GT

sep_est = corner_exist_Polyg(1)+corner_exist_Polyg(3);

if (NUMestcorner == 2 && (sep_est == 0 || sep_est == 2)) || NUMestcorner == 1
    
    % if number of corners = 2 with ambiguous cases and 1, get corners for both possible cases
    CornerPosEst = zeros(2,4,2);
    tmp_flag = 1;
    for tmp_id = 2:4
        if ~isempty(Polyg{tmp_id})
            center_est_new = Polyg{tmp_id};
            for INDcorner = 1:4
                tmp1 = repmat(permute(center_est_new,[3 1 2]),[4 1 1]);
                tmp2 = repmat(permute(image_corners,[1 3 2]),[1 size(center_est_new,1) 1]);
                dist2imgcorner = sqrt(sum((tmp1 - tmp2).^2,3));
                [~,id] = min(dist2imgcorner(INDcorner,:));
                CornerPosEst(:,INDcorner,tmp_flag) = center_est_new(id,:)';
            end
            tmp_flag = tmp_flag+1;
        end
    end
    
else
    
    % if number of corners = 4, 3, 0, or 2 with assertive cases
    if NUMestcorner == 0
        %fprintf('No corners in ground truth!!\n');
    end
    
    CornerPosEst = zeros(2,4);
    for INDcorner = 1:4
        tmp1 = repmat(permute(center_est,[3 1 2]),[4 1 1]);
        tmp2 = repmat(permute(image_corners,[1 3 2]),[1 size(center_est,1) 1]);
        dist2imgcorner = sqrt(sum((tmp1 - tmp2).^2,3));
        [~,id] = min(dist2imgcorner(INDcorner,:));
        CornerPosEst(:,INDcorner) = center_est(id,:)';
    end
    
end

if size(CornerPosGT,3) == 1 && size(CornerPosEst,3) == 1
    % if for both GT and estimation, number of corners = 4, 3, 0, or 2 with assertive cases
    Dist = sqrt(sum((CornerPosGT - CornerPosEst).^2,1));
    cornerr = (sum(Dist)/4)/diag_dist;
    gtcornid = 1;
    estcornid = 1;
elseif size(CornerPosGT,3) == 1 && size(CornerPosEst,3) == 2
    % if GT is assertive, but estimation is ambiguous
    Dist = sqrt(sum((repmat(CornerPosGT,[1 1 2]) - CornerPosEst).^2,1));
    err_cand = permute((sum(Dist,2)/4)/diag_dist,[1 3 2]);
    gtcornid = 1;
    [cornerr,estcornid] = min(err_cand);
elseif size(CornerPosGT,3) == 2 && size(CornerPosEst,3) == 1
    % if GT is ambiguous, but estimation is assertive
    Dist = sqrt(sum((CornerPosGT - repmat(CornerPosEst,[1 1 2])).^2,1));
    err_cand = permute((sum(Dist,2)/4)/diag_dist,[1 3 2]);
    [cornerr,gtcornid] = min(err_cand);
    estcornid = 1;
else
    % if both GT and estimation is ambiguous
    err_cand = zeros(2,2);
    for a = 1:2
        for b = 1:2
            Dist = sqrt(sum((CornerPosGT(:,:,a) - CornerPosEst(:,:,b)).^2,1));
            err_cand(a,b) = (sum(Dist)/4)/diag_dist;
        end
    end
    [cornerr,mid] = min(err_cand(:));
    if mid == 1
        gtcornid = 1;
        estcornid = 1;
    elseif mid == 2
        gtcornid = 2;
        estcornid = 1;
    elseif mid == 3
        gtcornid = 1;
        estcornid = 2;
    else
        gtcornid = 2;
        estcornid = 2;
    end
end

CornerPosGT_tmp = CornerPosGT(:,:,gtcornid)';
gtcorner = CornerPosGT_tmp(:);

CornerPosEst_tmp = CornerPosEst(:,:,estcornid)';
estcorner = CornerPosEst_tmp(:);

end
