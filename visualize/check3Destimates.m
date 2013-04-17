function check3Destimates(x)
for i = 1:length(x.projs)
    figure(1);
    clf;
    imshow(x.imfile);
    rectangle('position', bbox2rect(x.dets(i, 4:7)), 'edgecolor', 'b', 'linewidth', 3);
    draw2DCube(x.projs(i).poly, x.projs(i).rt, 1);
    pause;
end
end