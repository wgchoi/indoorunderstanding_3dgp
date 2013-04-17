function avg = getAverageObjectsBottom(pg, x)
obts = [];
for j = pg.childs(:)'
    obts = [obts, min(x.cubes{j}(2, :))];
end
avg = mean(obts);
end