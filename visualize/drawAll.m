function drawAll(img, polyg, room, objs, models, fid1, fid2)

figure(fid1); clf; figure(fid2); clf;

ShowGTPolyg(img, polyg, fid1);
drawCube(room, polyg, fid2);    
drawObjects(room, objs, models, fid2, fid1);

end