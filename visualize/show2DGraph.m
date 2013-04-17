function show2DGraph(pg, x, icluster, fig2d, bnms, conf)

if nargin < 4
    fig2d = -1;
    bnms = false;
    conf = [];
elseif nargin < 5
    bnms = false;
    conf = [];
end

om = objmodels();
img = imread(x.imfile);
if(fig2d > 0)
    ShowGTPolyg2(img, x.lpolys(pg.layoutidx, :), fig2d)
else
    ShowGTPolyg2(img, x.lpolys(pg.layoutidx, :))
end
fontsize = size(img, 1) / 25;

if(bnms)
    objidx = getObjIndices(pg, icluster);
    assert(length(conf) == size(x.dets, 1));
    
    classes = 1:7;
    dets = x.dets(objidx, :);
    conf = conf(objidx);
    
    allpick = [];
    for i = 1:length(classes)
        clsidx = find(dets(:, 1) == classes(i));
        boxes = [dets(clsidx, 4:7), dets(clsidx, 3), conf(clsidx)];
        
        pick = nms(boxes, 0.5);
        
        allpick = [allpick; clsidx(pick)];
    end
    
    allpick = objidx(allpick);
    
    for i = 1:length(allpick)
        oid = icluster(allpick(i)).ittype;
        if(isfield(x, 'hobjs'))
            id1 = icluster(allpick(i)).chindices;
            id2 = icluster(allpick(i)).subidx;

            drawObject2(x, id1, id2, oid, om, fig2d, fontsize);
        else
            drawObject(x, allpick(i), oid, om, fig2d, fontsize);
        end
        % drawObject(x, allpick(i), oid, om, fig2d, fontsize);
    end
    
    for i = 1:length(pg.childs)
        idx = pg.childs(i);

        if(~icluster(idx).isterminal)
            childs = icluster(idx).chindices;
            bbs = zeros(length(childs), 4);
            for j = 1:length(childs)
                bbs(j, :) = x.dets(childs(j), 4:7);
            end
            drawITMLink(bbs);
        end
    end
else
    for i = 1:length(pg.childs)
        idx = pg.childs(i);

        if(icluster(idx).isterminal)
            oid = icluster(idx).ittype;
            if(isfield(x, 'hobjs'))
                id1 = icluster(idx).chindices;
                id2 = icluster(idx).subidx;
                    
                drawObject2(x, id1, id2, oid, om, fig2d, fontsize);
            else
                drawObject(x, idx, oid, om, fig2d, fontsize);
            end
        else
            childs = icluster(idx).chindices;
            bbs = zeros(length(childs), 4);
            for j = 1:length(childs)
                oid = icluster(childs(j)).ittype;
                
                if(isfield(x, 'hobjs'))
                    id1 = icluster(childs(j)).chindices;
                    id2 = icluster(childs(j)).subidx;
                    
                    bbs(j, :) = drawObject2(x, id1, id2, oid, om, fig2d, fontsize);
                else
                    bbs(j, :) = drawObject(x, childs(j), oid, om, fig2d, fontsize);
                end
            end
            drawITMLink(bbs);
        end
    end
end
if(pg.scenetype > 0)
    roomtype = {' bedroom ' ' livingroom ' ' diningroom '};
    str = roomtype{pg.scenetype};
    text(10, 20, str, 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2, 'fontsize', 25);
end
end

function drawITMLink(bbs)
objct = zeros(size(bbs, 1), 2);
for i = 1:size(bbs, 1)
    objct(i, :) = bbox2ct(bbs(i, :));
end
ct = mean(objct, 1);
for i = 1:size(bbs, 1)
    line([ct(1) objct(i, 1)], [ct(2) objct(i, 2)], 'LineWidth',8, 'Color', 'k', 'linestyle', '-.');
    line([ct(1) objct(i, 1)], [ct(2) objct(i, 2)], 'LineWidth',4, 'Color', 'w', 'linestyle', '-.');
    rectangle('position', [objct(i, 1) - 10, objct(i, 2) - 10, 20, 20], 'Curvature', .8, 'facecolor', 'w', 'edgecolor', 'k', 'linewidth', 4);
end
rectangle('position', [ct(1) - 10, ct(2) - 10, 20, 20], 'Curvature', .8, 'facecolor', 'c', 'edgecolor', 'k', 'linewidth', 4);

end

function [bbox] = drawObject(x, idx, oid, om, fig2d, fontsize)

col = 'rgbykmcrgbykmcrgbykmcrgbykmc';

rectangle('position', bbox2rect(x.dets(idx, 4:7)), 'linewidth', 2, 'edgecolor', 'm');
[poly, rt] = get2DCubeProjection(x.K, x.R, x.cubes{idx});
draw2DCube(poly, rt, fig2d, om(x.dets(idx, 1)).name, col(oid), fontsize);

bbox = x.dets(idx, 4:7);

end


function [bbox] = drawObject2(x, idx, subidx, oid, om, fig2d, fontsize)
col = 'rgbykmcrgbykmcrgbykmcrgbykmc';
draw2DCube(x.hobjs(idx).polys(:, :, subidx), bbox2rect(x.hobjs(idx).bbs(:, subidx)), fig2d, om(x.dets(idx, 1)).name, col(oid), fontsize);
bbox = x.hobjs(idx).bbs(:, subidx);
end
