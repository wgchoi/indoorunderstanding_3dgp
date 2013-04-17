function [d1, d2] = obj2wallFloorDist(faces, cube, camheight)
% distance from two points of the cube to each wall on the floor
% positive means inclusion.
d1 = -inf(3, 1); d2 = -inf(3, 1);

rt = cube(:, [1 2 6 5 1]);

cz = -camheight * faces(2, end);
rx = -camheight * faces(3, end);
lx = -camheight * faces(4, end);

if(~isnan(lx))
    temp = sort(rt(1, :));
    d1(1) = lx - temp(1);
    d2(1) = lx - temp(2);
end
temp = sort(rt(3, :));
d1(2) = cz - temp(1);
d2(2) = cz - temp(2);

if(~isnan(rx))
    temp = sort(rt(1, :), 'descend');
    d1(3) = temp(1) - rx;
    d2(3) = temp(2) - rx;
end

end