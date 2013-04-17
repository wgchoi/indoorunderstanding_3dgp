function draw2DConvexHull(poly, fignum)
K = convhull(poly(1, :), poly(2, :));

figure(fignum);
hold on;
for i = 1:(length(K)-1)
    plot([poly(1, K(i)) poly(1, K(i+1))], [poly(2, K(i)) poly(2, K(i+1))], 'r.-');
end
hold off;

end