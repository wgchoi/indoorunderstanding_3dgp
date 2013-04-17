function visualizeITMcomposite(x, iclusters, idx)

pg = parsegraph();
pg.childs = idx;
pg = findConsistent3DObjects(pg, x, iclusters);
show2DGraph(pg, x, iclusters);

end