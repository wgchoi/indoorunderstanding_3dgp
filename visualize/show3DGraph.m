function show3DGraph(pg, x, iclusters, figid)
% imshow(x.imfile);
if nargin < 4
    figid = 1001;
end
figure(figid); 
clf;

room.F = x.faces{pg.layoutidx};
room.K = x.K; room.R = x.R; room.h = pg.camheight;

drawCube(room, x.lpolys(pg.layoutidx, :), figid);

col = 'rgbykmcrgbykmcrgbykmcrgbykmc';

cnt = 1;
for i = 1:length(pg.childs)
     idx = pg.childs(i);
     if(iclusters(idx).isterminal)
        oid = iclusters(idx).ittype;
        if(isfield(x, 'hobjs'))
            id1 = iclusters(idx).chindices;
            id2 = iclusters(idx).subidx;
            
            draw3Dcube(pg.objscale(cnt) * x.hobjs(id1).cubes(:, :, id2), figid, col(oid));
            cnt = cnt + 1;
        elseif isfield(pg, 'objscale')
            draw3Dcube(pg.objscale(cnt) * x.cubes{idx}, figid, col(oid));
            cnt = cnt + 1;
        else
            draw3Dcube(x.cubes{idx}, figid, col(oid));
        end
     else
        childs = iclusters(idx).chindices;
        locs = zeros(length(childs), 3);
        for j = 1:length(childs)
            oid = iclusters(childs(j)).ittype;
            if(isfield(x, 'hobjs'))
                id1 = iclusters(childs(j)).chindices;
                id2 = iclusters(childs(j)).subidx;
                
                draw3Dcube(pg.objscale(cnt) * x.hobjs(id1).cubes(:, :, id2), figid, col(oid));
                locs(j, :) = pg.objscale(cnt) * x.hobjs(id1).locs(:, id2);
                cnt = cnt + 1;
            elseif isfield(pg, 'objscale')
                draw3Dcube(pg.objscale(cnt) * x.cubes{childs(j)}, figid, col(oid));
                locs(j, :) = pg.objscale(cnt) * x.locs(childs(j), 1:3);
                cnt = cnt + 1;
            else
                draw3Dcube(x.cubes{childs(j)}, figid, col(oid));
                locs(j, :) = x.locs(childs(j), 1:3);
            end
            
            % bbs(j, :) = drawObject(x, childs(j), oid, om, fig2d);
        end
        draw3DITMLink(locs);
     end
end

end

function draw3DITMLink(locs)
ct = mean(locs, 1);
for i = 1:size(locs, 1)
    line([ct(1) locs(i, 1)], [ct(2) locs(i, 2)], [ct(3) locs(i, 3)], 'LineWidth',8, 'Color', 'k', 'linestyle', '-.');
    line([ct(1) locs(i, 1)], [ct(2) locs(i, 2)], [ct(3) locs(i, 3)], 'LineWidth',4, 'Color', 'w', 'linestyle', '-.');
end

end