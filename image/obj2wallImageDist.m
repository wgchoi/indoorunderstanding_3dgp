function [d1, d2] = obj2wallImageDist(corners, objpoly)
% compute the distance to all faces. left, center, right
% bottom back side of an object is specified by [objpoly(:, 5), objpoly(:, 6)];
d1 = inf(3, 1); d2 = inf(3, 1);
if(~isnan(corners(1,1)))
    d1(1) = pt2lineDist(objpoly(:, 5), corners(:, [1, 2]));
    d2(1) = pt2lineDist(objpoly(:, 6), corners(:, [1, 2]));
end
d1(2) = pt2lineDist(objpoly(:, 5), corners(:, [2, 3]));
d2(2) = pt2lineDist(objpoly(:, 6), corners(:, [2, 3]));
if(~isnan(corners(1, 4)))
    d1(3) = pt2lineDist(objpoly(:, 5), corners(:, [3 4]));
    d2(3) = pt2lineDist(objpoly(:, 6), corners(:, [3 4]));
end
d1 = d1 ./ norm(objpoly(:, 5) - objpoly(:, 6));
d2 = d2 ./ norm(objpoly(:, 5) - objpoly(:, 6));
end