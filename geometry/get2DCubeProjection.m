function [poly, rect] = get2DCubeProjection(K, R, cube)
poly = zeros(2, size(cube, 2));
for i = 1:size(cube, 2)
    P = K * R * cube(:, i);
    poly(:, i) = P(1:2) ./ P(3);
end
rect = poly2rect(poly);
end