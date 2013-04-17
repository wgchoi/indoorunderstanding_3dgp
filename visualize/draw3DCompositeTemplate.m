function draw3DCompositeTemplate(node, childs, objmodels)
figid = 1;
try
    close(figid);
end
figure(figid);
hold on
scatter3(node.loc(1), node.loc(2), node.loc(3), 150, 'k', 'linewidth', 4);
plot3([node.loc(1) node.loc(1) + 0.1 * cos(node.angle)], [node.loc(2) node.loc(2)], [node.loc(3) node.loc(3) + 0.1 * sin(node.angle)], 'k-', 'linewidth', 5)
hold off
for i = 1:length(childs)
    model = objmodels(childs(i).ittype);    
    hold on;
    plot3([node.loc(1) childs(i).loc(1)], [node.loc(2) childs(i).loc(2)], [node.loc(3) childs(i).loc(3)], 'b--', 'linewidth', 2)
    hold off;
    [cube] = get3DObjectCube(childs(i).loc(:), model.width(1), model.height(1), model.depth(1), childs(i).angle);
    text(childs(i).loc(1), childs(i).loc(2) + 1, childs(i).loc(3), ['obj ' num2str(i)], 'backgroundcolor', 'w');
    draw3Dcube(cube, figid);
end

xlabel('x'); ylabel('y'); zlabel('z');
view([180 0]); axis equal
grid on;

end