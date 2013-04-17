function pg = GreedyInference(x, iclusters, params, initpg, anno)
% [spg, maxidx, cache, history] = DDMCMCinference(x, iclusters, params, init, anno)
if nargin < 5
    includeloss = false;
    anno = [];
else
    includeloss = true;
end
%% consider upto 50 layouts
% x.lconf(51:end) = [];
% x.lpolys(51:end, :) = [];
% x.faces(51:end) = [];

%%
params.model.w = getweights(params.model);
%% initialize the sample
pg = initpg;
pg.childs = [];

phi = features(pg, x, iclusters, params.model);
pg.lkhood = dot(phi, params.model.w);
if(includeloss)
    pg.loss = lossall2(anno, x, iclusters, pg, params);
end
cache = initCache(pg, x, iclusters, params.model);

if(isfield(params, 'quicklearn') && params.quicklearn)
    quickrun = true;
else
    quickrun = false;
end
%% initialize cache
if(strcmp(params.inference, 'greedy'))
    [moves, cache] = preprocessJumpMoves(x, iclusters, cache);
end
iter = 0;
while(iter < 10)
    iter = iter + 1;
    
    addidx = find(~cache.inset);
    
    temp = zeros(4, 10000);
    count = 1;
    
    for i = 1:length(addidx)
        if(~iclusters(addidx(i)).isterminal)
            if( any( cache.inset(iclusters(addidx(i)).chindices) ) )
                continue;
            end
        end
        
        newgraph = pg;
        newgraph.childs(end + 1) = addidx(i);
        
        if(isfield(params.model, 'commonground') && params.model.commonground)
            newgraph = findConsistent3DObjects(newgraph, x, iclusters, quickrun);
        else
            mh = getAverageObjectsBottom(newgraph, x);
            if(~isnan(mh))
                newgraph.camheight = -mh;
            else
                newgraph.camheight = 1.5;
            end
        end
                
        temp(1, count) = 1;
        phi = features(newgraph, x, iclusters, params.model);
        temp(2, count) = dot(phi, params.model.w) - pg.lkhood;
        if(includeloss)
            newgraph.loss = lossall2(anno, x, iclusters, newgraph, params);
            temp(2, count) = temp(2, count) + newgraph.loss - pg.loss;
        end
        temp(3, count) = addidx(i);
        count = count + 1;
    end
    
    if(strcmp(params.inference, 'greedy'))
        swidx = find(cache.inset);
        for i = 1:length(swidx)
            delidx = swidx(i);
            addset = cache.swset{delidx};

            tempidx = find(pg.childs == delidx, 1);

            for j = 1:length(addset)
                newgraph = pg;
                if(cache.inset(addset(j)))
                    continue;
                end
                newgraph.childs(tempidx) = addset(j);

                if(isfield(params.model, 'commonground') && params.model.commonground)
                    newgraph = findConsistent3DObjects(newgraph, x, iclusters, quickrun);
                else
                    mh = getAverageObjectsBottom(newgraph, x);
                    if(~isnan(mh))
                        newgraph.camheight = -mh;
                    else
                        newgraph.camheight = 1.5;
                    end
                end

                temp(1, count) = 2;
                phi = features(newgraph, x, iclusters, params.model);
                temp(2, count) = dot(phi, params.model.w)  - pg.lkhood;
                if(includeloss)
                    newgraph.loss = lossall2(anno, x, iclusters, newgraph, params);
                    temp(2, count) = temp(2, count) + newgraph.loss - pg.loss;
                end
                temp(3, count) = delidx;
                temp(4, count) = addset(j);

                count = count + 1;
            end
        end
    end
    temp(:, count:end) = [];
    
    temp = temp(:, temp(2, :) > 0);
    
    if(isempty(temp))
        % no more addition.
        break;
    end
    [~, select] = max(temp(2, :));
    
    if(temp(1, select) == 1)
        addidx = temp(3, select);
        assert(~cache.inset(addidx));
        
        newgraph = pg;
        newgraph.childs(end + 1) = addidx;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(iclusters(addidx).isterminal)
            cache.inset(addidx) = true;
        else
            cache.inset([iclusters(addidx).chindices(:)', addidx]) = true;
        end
    elseif(temp(1, select) == 2)
        delidx = temp(3, select);
        addidx = temp(4, select);
        
        assert(cache.inset(delidx));
        assert(~cache.inset(addidx));
        
        newgraph = pg;
        newgraph.childs(find(newgraph.childs == delidx, 1)) = addidx;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cache.inset(delidx) = false;
        cache.inset(addidx) = true;
    end
    
    if(isfield(params.model, 'commonground') && params.model.commonground)
        newgraph = findConsistent3DObjects(newgraph, x, iclusters, quickrun);
    else
        mh = getAverageObjectsBottom(newgraph, x);
        if(~isnan(mh))
            newgraph.camheight = -mh;
        else
            newgraph.camheight = 1.5;
        end
    end
%     obts = [];
%     for j = newgraph.childs(:)'
%         obts = [obts, min(x.cubes{j}(2, :))];
%     end
%     mh = getAverageObjectsBottom(newgraph, x);
%     if(~includeloss)
%         newgraph.camheight = -mh;
%     end
%     newgraph.camheight = -mean(obts);
    phi = features(newgraph, x, iclusters, params.model);
    newgraph.lkhood = dot(phi, params.model.w);
    if(includeloss)
        newgraph.loss = lossall2(anno, x, iclusters, newgraph, params);
    end

    pg = newgraph;    
    %% layout adjustment
    maxval = pg.lkhood;
    if(includeloss)
        maxval = maxval + pg.loss;
    end
    for i = 1:min(50, length(x.lconf))
        newgraph = pg;
        newgraph.layoutidx = i;

        phi = features(newgraph, x, iclusters, params.model);
        newgraph.lkhood = dot(phi, params.model.w);
        val = newgraph.lkhood;
        if(includeloss)
            newgraph.loss = lossall2(anno, x, iclusters, newgraph, params);
            val = val + newgraph.loss;
        end

        if(maxval < val)
            pg = newgraph;
            maxval = val;
        end
    end
end

%% layout adjustment
maxval = pg.lkhood;
if(includeloss)
    maxval = maxval + pg.loss;
end
for i = 1:length(x.lconf)
    newgraph = pg;
    newgraph.layoutidx = i;
    
    phi = features(newgraph, x, iclusters, params.model);
    newgraph.lkhood = dot(phi, params.model.w);
    val = newgraph.lkhood;
    if(includeloss)
        newgraph.loss = lossall2(anno, x, iclusters, newgraph, params);
        val = val + newgraph.loss;
    end
    
    if(maxval < val)
        pg = newgraph;
        maxval = val;
    end
end
end

function cache = initCache(pg, x, iclusters, model)
cache = mcmccache(length(iclusters), length(x.lconf));

cache.inset(pg.childs) = true;
%% init cache
cache.playout = exp(x.lconf .* model.w_or);
cache.playout = cache.playout ./ sum(cache.playout);
cache.clayout = cumsum(cache.playout);

cache.padd = exp(x.dets(:, end) .* model.w_oo(1));
end