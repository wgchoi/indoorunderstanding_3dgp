function loss = lossall2(anno, x, iclusters, pg, params)

if isfield(x, 'lloss')
    loss = x.lloss(pg.layoutidx);
else
    loss = layout_loss(anno.gtPolyg, x.lpolys(pg.layoutidx, :));
end

if isfield(anno, 'scenetype')
    loss = loss + 5 * (anno.scenetype ~= pg.scenetype);
end
%
idx = getObjIndices(pg, iclusters);
if(strcmp(params.losstype, 'exclusive'))
    loss = loss + object_loss(anno.obj_annos, x.dets(idx, [1 4:7 3]));
elseif(strcmp(params.losstype, 'isolation'))
    hit = false(size(x.dets, 1), 1);
    hit(idx) = true;    
    K = params.fncost;    
    loss = loss + sum(anno.oloss(hit, 1)) + K * sum(anno.oloss(~hit, 2));
end

end