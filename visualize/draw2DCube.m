function draw2DCube(poly, rect, fignum, name, col, fontsize)
if (nargin < 5)
    col = 'm';
end

idx= [1 2; 2 4; 4 3; 3 1; ...
    5 6; 6 8; 8 7; 7 5; ...
    2 6; 4 8; ...
    1 5; 3 7 ];

% idx = [1 2; 2 6; 6 5; 5 1] - only bottom
if fignum > 0
    figure(fignum);
end
hold on;
for i = 1:size(idx, 1)
    plot([poly(1, idx(i, 1)) poly(1, idx(i, 2))], [poly(2, idx(i, 1)) poly(2, idx(i, 2))], [col '.-'], 'linewidth', 4);
end
%plot([poly(1, 5) poly(1, 6)], [poly(2, 5) poly(2, 6)], 'w-.', 'linewidth', 2);
%plot(poly(1,1), poly(2,1), 'r.', 'MarkerSize', 40);

%rectangle('position', rect, 'edgecolor', 'c', 'linewidth', 2);

if(nargin == 5)
    text(rect(1), rect(2), name, 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2, 'fontsize', fontsize);
end
hold off;

end