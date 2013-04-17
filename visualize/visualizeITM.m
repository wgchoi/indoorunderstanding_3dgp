function visualizeITM(rule, omodel, figid)
if nargin < 2
    omodel = objmodels();
    cla
else
    figure(figid);
    clf
end

fontsize = 20;
for i = 1:length(rule.parts)
    drawpart(rule.parts(i), omodel, i, fontsize);
end
for i = 1:length(rule.parts)
    part = rule.parts(i);
    oid = part.citype;
    text(part.dx, part.dz, [' ' num2str(i) ':' omodel(oid).name ' '], ...
        'HorizontalAlignment','center', 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2, 'fontsize', fontsize);
end
axis off

h = xlabel('x');
set(h, 'fontsize', fontsize); 
h = ylabel('z');
set(h, 'fontsize', fontsize); 

end


function drawpart(part, omodel, idx, fontsize)

oid = part.citype;
col = 'rgbykmcrgbykmcrgbykmcrgbykmc';

if(1) % omodel(oid).ori_sensitive)
    rect = [-omodel(oid).width(1) / 2, omodel(oid).depth(1) / 2; ...
            omodel(oid).width(1) / 2, omodel(oid).depth(1) / 2; ...
            omodel(oid).width(1) / 2, -omodel(oid).depth(1) / 2; ...
            -omodel(oid).width(1) / 2, -omodel(oid).depth(1) / 2];

    R = rotationMat(part.da);
    rect = repmat([part.dx; part.dz], 1, 4) + R * rect';

    h = mapshow(rect(1, :), rect(2, :), 'DisplayType','polygon','Marker','.', ...
                'LineStyle','-', 'linewidth', 8, 'facecolor', col(oid));
%     set(h,'edgecolor','k', 'linewidth',5, 'FaceAlpha', 0.9);
%     hold on
%     plot(rect(1, [1 2]), rect(2, [1 2]), 'w', 'linewidth', 2);
%     hold off
else
    radius = sqrt((omodel(oid).width(1) / 2)^2 + (omodel(oid).depth(1) / 2)^2);
    rect = [-radius + part.dx, -radius + part.dz, radius + part.dx, radius + part.dz];
    rect(3:4) = rect(3:4) - rect(1:2);    
    h = rectangle('Position', rect, 'Curvature', [1,1], 'FaceColor', col(oid), 'LineStyle','-', 'linewidth', 8)
    set(h,'edgecolor','k', 'linewidth',5, 'FaceAlpha', 0.6);
end

end