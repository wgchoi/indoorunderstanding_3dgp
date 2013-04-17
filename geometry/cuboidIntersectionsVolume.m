function [volume] = cuboidIntersectionsVolume(cube1, cube2, bshow)
if nargin < 3
    bshow = false;
end

% assuming that the cuboid has no rotation along z axis
y1 = [min(cube1(2, :)); max(cube1(2, :))];
y2 = [min(cube2(2, :)); max(cube2(2, :))];
dy = min(y1(2), y2(2)) - max(y1(1), y2(1));

if(dy < 0)
    volume = 0;
else
    rt1 = cube1([1 3], [1 2 6 5 1]);
    rt2 = cube2([1 3], [1 2 6 5 1]);
    [xi, yi] = polybool('intersection',rt1(1, :), rt1(2, :), rt2(1, :), rt2(2, :));
    xi(isnan(xi)) = []; yi(isnan(yi)) = [];
    
    volume = dy * polyarea(xi, yi);
    if(bshow)
        clf;
        mapshow(rt1(1, :), rt1(2, :), 'DisplayType','polygon','Marker','*','LineStyle','-')
        mapshow(rt2(1, :), rt2(2, :), 'DisplayType','polygon','Marker','+', 'LineStyle','--')
        mapshow(xi,yi,'DisplayType','point','Marker','o');
        grid on;
    end
end

end