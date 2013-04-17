function x = precomputeOverlapArea(x)

x.orarea = sparse(size(x.dets, 1), size(x.dets, 1));
for i = 1:size(x.dets, 1)
    for j = i+1:size(x.dets, 1)
        [~, inter, aarea, barea] = boxoverlap(x.dets(i, 4:7), x.dets(j, 4:7));
        x.orarea(i, j) = inter / aarea;
        x.orarea(j, i) = inter / barea;
    end
end
assert(max(max(x.orarea)) <= 1);
assert(min(min(x.orarea)) >= 0);

x.orpolys = sparse(size(x.dets, 1), size(x.dets, 1));

if(isfield(x, 'hobjs'))
    assert(length(x.hobjs) == size(x.dets, 1));
    x.orpolys = sparse(length(x.hobjs), length(x.hobjs));
    % not using these...
    return;
end

assert(length(x.projs) == size(x.dets, 1));
for i = 1:length(x.projs)
    for j = i+1:length(x.projs)
        if(x.orarea(i, j) == 0)
            continue;
        end
        % copmuting the overlap between bottom faces of two objects.
        % [1 2 5 6] are the bottom 4 points!!! 
        % see get3DObjectCube.m and get2DCubeProjection.m
        % k = convhull(x.projs(i).poly(1, :), x.projs(i).poly(2, :));
        k = [1 2 6 5];
        x1 = x.projs(i).poly(1, k);
        y1 = x.projs(i).poly(2, k);
        aarea = polyarea(x1, y1);
%         k = convhull(x.projs(j).poly(1, :), x.projs(j).poly(2, :));
        x2 = x.projs(j).poly(1, k);
        y2 = x.projs(j).poly(2, k);
        barea = polyarea(x2, y2);
        
        [aa, bb] = poly2cw(x1, y1);
        [cc, dd] = poly2cw(x2, y2);
        [xi, yi] = polybool('intersection', aa, bb, cc, dd);
        xi(isnan(xi)) = []; yi(isnan(yi)) = [];
        inter = polyarea(xi, yi);
        
        x.orpolys(i, j) = inter / aarea;
        x.orpolys(j, i) = inter / barea;
    end
end
x.orpolys(x.orpolys > 1) = 1;
% assert(max(max(x.orpolys)) <= 1.01);
assert(min(min(x.orpolys)) >= 0);
end