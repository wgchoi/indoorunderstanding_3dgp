function valid = latentITMCheckDist2Human(pg, x, iclusters, iidx)

iset = iclusters(iidx).chindices;
oids = [iclusters(iset).ittype];

objidx = getObjIndices(pg, iclusters);

% find idx in cluster
hid = find(oids == 7);
hloc = x.hobjs(iset(hid)).locs(:, 14);

% find location by rescaling
hloc = hloc .* pg.objscale(objidx == iset(hid));

objs = setdiff(1:length(oids), hid);
valid = false;

for i = 1:length(objs)
    ii = find(objidx == iset(objs(i)));
    oloc = x.hobjs(iset(objs(i))).locs(:, 14);
    oloc = oloc .* pg.objscale(ii);
    
%     if(abs(x.hobjs(iset(hid)).cubes(2, 1, 14)* pg.objscale(objidx == iset(hid)) - x.hobjs(iset(objs(i))).cubes(2, 1, 14).* pg.objscale(ii)) > 0.3)
%         x.hobjs(iset(hid)).cubes(2, 1, 14)* pg.objscale(objidx == iset(hid))
%         x.hobjs(iset(objs(i))).cubes(2, 1, 14).* pg.objscale(ii)
%         assert(0);
%         keyboard;
%     end
    
    dist = sqrt(sum((hloc([1 3]) - oloc([1 3])).^2));
    
    if(dist < 0.8)
        valid = true;
    end
end
end