function [volume] = cuboidRoomIntersection(faces, camheight, cuboid)
% faces : 1. floor
%         2. center
%         3. right
%         4. left
%         5. ceiling
% doesn't like nan cuboid
if(isnan(cuboid))
    volume = 1000*ones(5,1);
    return;
end
% volume = cuboidRoomIntersectionVer1(faces, camheight, cuboid);
% volume = cuboidRoomIntersectionVer2(faces, camheight, cuboid);
volume = cuboidRoomIntersectionVer3(faces, camheight, cuboid);

end


function [volume] = cuboidRoomIntersectionVer3(faces, camheight, cuboid)
volume = zeros(5, 1);
% floor
if(~isnan(faces(1, :)))
    y = -camheight;
    if(cuboid(2, 1) > y)
        volume(1) = 0;
    else
        volume(1) = y - cuboid(2, 1);
    end
end
[d1, d2] = obj2wallFloorDist(faces, cuboid, camheight);
volume(2:4) = max(d1, 0) + max(d2, 0);
% ceiling
if(~isnan(faces(5, :)))
    y = -camheight * faces(5, end);
    if(cuboid(2, 3) < y)
        volume(5) = 0;
    else
        volume(5) = cuboid(2, 3) - y;
    end
end

end

function [volume] = cuboidRoomIntersectionVer2(faces, camheight, cuboid)
volume = zeros(5, 1);
% floor
if(~isnan(faces(1, :)))
    y = -camheight;
    if(cuboid(2, 1) > y)
        volume(1) = 0;
    else
        dy = y - cuboid(2, 1);
        rt = cuboid([1 3], [1 2 6 5 1]);
        volume(1) = dy * polyarea(rt(1, :), rt(2,:));
    end
end
[d1, d2] = obj2wallFloorDist(faces, cuboid, camheight);
volume(2:4) = max(d1, 0) + max(d2, 0);
% ceiling
if(~isnan(faces(5, :)))
    y = -camheight * faces(5, end);
    if(cuboid(2, 3) < y)
        volume(5) = 0;
    else
        dy = cuboid(2, 3) - y;
        rt = cuboid([1 3], [1 2 6 5 1]);
        volume(5) = dy * polyarea(rt(1, :), rt(2,:));
    end
end

end

function [volume] = cuboidRoomIntersectionVer1(faces, camheight, cuboid)
volume = zeros(5, 1);
% floor
if(~isnan(faces(1, :)))
    y = -camheight;
    if(cuboid(2, 1) > y)
        volume(1) = 0;
    else
        dy = y - cuboid(2, 1);
        rt = cuboid([1 3], [1 2 6 5 1]);
        volume(1) = dy * polyarea(rt(1, :), rt(2,:));
    end
end
% center
if(~isnan(faces(2, :)))
    z = -camheight * faces(2, end);
    if(min(cuboid(3, :)) > z)
        volume(2) = 0;
    else
        dz = cuboid(2, 3) - cuboid(2, 1);
        rt1 = cuboid([1 3], [1 2 6 5 1]);
        x1 = min(rt1(1, :))-1; x2 = max(rt1(1, :))+1;
        rt2 = [x1, x2, x2, x1, x1; z, z, z - 5, z - 5, z];
        [xi, yi] = polybool('intersection',rt1(1, :), rt1(2, :), rt2(1, :), rt2(2, :));
        xi(isnan(xi)) = []; yi(isnan(yi)) = [];
        volume(2) = dz * polyarea(xi, yi);
    end
end
% right
if(~isnan(faces(3, :)))
    x = -camheight * faces(3, end);
    if(min(cuboid(1, :)) < x)
        volume(3) = 0;
    else
        dx = cuboid(2, 3) - cuboid(2, 1);
        rt1 = cuboid([1 3], [1 2 6 5 1]);
        z1 = min(rt1(2, :)); z2 = max(rt1(2, :));
        rt2 = [x, x + 5, x + 5, x, x; z1, z1, z2, z2, z1];
        [xi, yi] = polybool('intersection',rt1(1, :), rt1(2, :), rt2(1, :), rt2(2, :));
        xi(isnan(xi)) = []; yi(isnan(yi)) = [];
        volume(3) = dx * polyarea(xi, yi);
    end
end
% left
if(~isnan(faces(4, :)))
    x = -camheight * faces(4, end);
    if(min(cuboid(1, :)) > x)
        volume(4) = 0;
    else
        dx = cuboid(2, 3) - cuboid(2, 1);
        rt1 = cuboid([1 3], [1 2 6 5 1]);
        z1 = min(rt1(2, :)); z2 = max(rt1(2, :));
        rt2 = [x, x - 5, x - 5, x, x; z1, z1, z2, z2, z1];
        [xi, yi] = polybool('intersection',rt1(1, :), rt1(2, :), rt2(1, :), rt2(2, :));
        xi(isnan(xi)) = []; yi(isnan(yi)) = [];
        volume(4) = dx * polyarea(xi, yi);
    end
end
% ceiling
if(~isnan(faces(5, :)))
    y = -camheight * faces(5, end);
    if(cuboid(2, 3) < y)
        volume(5) = 0;
    else
        dy = cuboid(2, 3) - y;
        rt = cuboid([1 3], [1 2 6 5 1]);
        volume(5) = dy * polyarea(rt(1, :), rt(2,:));
    end
end

end