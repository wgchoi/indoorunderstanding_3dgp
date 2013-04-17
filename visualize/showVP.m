function showVP(img, vp)
figure(1000);
imagesc(img);
hold on;
plot(vp(1,1),vp(1,2),'r.','MarkerSize',30);
plot(vp(2,1),vp(2,2),'g.','MarkerSize',30);
plot(vp(3,1),vp(3,2),'b.','MarkerSize',30);
hold off

end