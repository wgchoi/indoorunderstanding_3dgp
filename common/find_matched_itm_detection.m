function [dets, overlap]= find_matched_itm_detection(type, itms, bbox, azimuth)

dets = [];
overlap = 0;
if(1)
    tidx = find(itms(:, 1) == type);
    
    % itmpose = itms(tidx, 3);
    itmbox = itms(tidx, 4:7);
    itmscores = itms(tidx, end);
    
    % az = floor(azimuth / pi * 180);
    % poseidx = find_interval(az, 8);
    % idx = find(itmpose == poseidx);
    idx = 1:size(itmbox, 1);
    
    ov = boxoverlap(itmbox(idx, :), bbox);
    [val, maxidx] = max(ov);
    if(val > 0.7)
        dets = itmscores(idx(maxidx));
        overlap = val;
    end
else
    obsidx = itms.obs_idx(type);
    if(obsidx == 0) % no detector trained
        return;
    end

    itmbox = itms.bbox{obsidx};
    if(isempty(itmbox))
        return;
    end
    top = itms.top2{obsidx};
    itmbox = itmbox(top, :);

    az = floor(azimuth / pi * 180);
    poseidx = find_interval(az, 8);
    idx = find(itmbox(:, 5) == poseidx);

    ov = boxoverlap(itmbox(idx, 1:4), bbox);
    [val, maxidx] = max(ov);
    if(val > 0.7)
        dets = itmbox(idx(maxidx), :);
        overlap = val;
    end
end
end