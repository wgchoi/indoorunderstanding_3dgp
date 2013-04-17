function [viewidx, hogidx] = itm_view_idx(ptn, azimuth)

viewidx = find_interval(azimuth / pi * 180, 8);
hogidx = -1;

for i = 1:length(ptn.hogview)
    if(any(ptn.hogview{i} == viewidx))
        hogidx = i;
        viewidx = ptn.hogview{i}(1);
        return;
    end
end

end