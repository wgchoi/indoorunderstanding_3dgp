function draw3DObjects(objs, objmodels, figid)
figure(figid);
for i = 1:length(objs)
    model = objmodels(objs(i).ittype);    
    [cube] = get3DObjectCube(objs(i).loc(:), model.width(1), model.height(1), model.depth(1), objs(i).angle);
    text(objs(i).loc(1), objs(i).loc(2) + 1, objs(i).loc(3), ['obj ' num2str(i)], 'backgroundcolor', 'w');
    draw3Dcube(cube, figid);
end
xlabel('x'); ylabel('y'); zlabel('z');
view([180 0]); axis equal
grid on;
end