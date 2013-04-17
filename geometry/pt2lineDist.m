function d = pt2lineDist(pt, line)
d = abs(det([line(:, 2) - line(:, 1), line(:, 1) - pt])) / norm(line(:, 2) - line(:, 1));
%%% d = abs(cross(line(:, 2) - line(:, 1), pt - line(:, 1))) / norm( line(:, 2) - line(:, 1) );
end