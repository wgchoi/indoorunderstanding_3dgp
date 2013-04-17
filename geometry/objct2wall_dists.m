function [d, cubediag] = objct2wall_dists(faces, cube, camheight)
% distance from center points of the cube to each wall on the floor
% positive means inclusion.
if(any(isnan(cube)))
    d = 1000*ones(3,1);
    cubediag = 0.1;    
    return;
end

d = -inf(3, 1);

pts = cube(:, [1 6]);

cpt = mean(pts, 2);
cubediag = sqrt(sum((pts(:, 2) - pts(:, 1)).^2));

cz = -camheight * faces(2, end);
rx = -camheight * faces(3, end);
lx = -camheight * faces(4, end);

if(~isnan(lx))
    d(1) = lx - cpt(1);
end
if(~isnan(cz))
    d(2) = cz - cpt(3);
end
if(~isnan(rx))
    d(3) = cpt(1) - rx;
end

end