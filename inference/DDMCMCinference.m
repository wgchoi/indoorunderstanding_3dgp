function [spg, maxidx, cache, history] = DDMCMCinference(x, iclusters, params, init, anno)
% x :   1. scene type, [confidence value]
%       2. layout proposals, [poly, confidence value]
%       3. detections, [x, y, w, h, p, confidence]
%		4. R, T
%		5. image name
% y :   parse graph samples

if nargin < 5
    includeloss = false;
    anno = [];
else
    includeloss = true;
end
%%
params.model.w = getweights(params.model);

%% prepare buffer
spg = parsegraph(params.numsamples);
count = 1;

%% initialize the sample
if (nargin < 4) || (isempty(init))
    [spg(count), cache] = initialize(spg(1), x, iclusters, params.model);
else
    phi = features(init.pg, x, iclusters, params.model);
    init.pg.lkhood = dot(phi, params.model.w);
    
    spg(:) = init.pg;
    if(isfield(init, 'cache'))
        cache = init.cache;
    else
        cache = initCache(spg(count), x, iclusters, params.model);
    end
end
%% initialize cache
[moves, cache] = preprocessJumpMoves(x, iclusters, cache, params);
%%
history = zeros(8, 2);
%% weighting the acceptance constant
if(~isfield(params, 'accconst'))
    params.accconst = 1.0;
end

maxidx = 1;
maxval = spg(1).lkhood;
if(includeloss)
    spg(1).loss = lossall2(anno, x, iclusters, spg(1), params);
    maxval = maxval + spg(1).loss;
end

while(count < params.numsamples)
    %% sample a new tree
    info = MCMCproposal(spg(count), iclusters, moves, cache, params);
    if(info.move == 0), continue; end % error in sample
	%% compute the acceptance ratio
	[lkhood, newgraph] = computeAcceptanceRatio(spg(count), info, cache, x, iclusters, params);
    lar = lkhood;
    %% loss value
    if(includeloss)
        newgraph.loss = lossall2(anno, x, iclusters, newgraph, params);
        lar = lar + params.accconst * (newgraph.loss - spg(count).loss);
    end
    %% accept or reject
    count = count + 1;
	if(lar > log(rand()))
        spg(count) = newgraph;
        history(info.move, 1) = history(info.move, 1) + 1;
        % update cache
        cache = updateCache(cache, info, iclusters);
        % assertion check
        allset = union(spg(count).childs, getObjIndices(spg(count), iclusters));
        assert(isempty(setdiff(find(cache.inset),allset)));
        assert(length(union(find(cache.inset), allset)) == length(allset));
    else
        spg(count) = spg(count - 1);
        history(info.move, 2) = history(info.move, 2) + 1;
    end
    % show2DGraph(spg(count), x, iclusters);
    % drawnow;
    % pause(0.2);
    if(includeloss)
        if(spg(count).lkhood + spg(count).loss > maxval)
            maxval = spg(count).lkhood + spg(count).loss;
            maxidx = count;
        end
    else
        if(spg(count).lkhood > maxval)
            maxval = spg(count).lkhood;
            maxidx = count;
        end
    end
end

% if(~includeloss)
%     disp(['max sample at ' num2str(maxidx) ' with lk : ' num2str(maxval)])
%     spg(maxidx)
% end

a = 1;

end

function cache = updateCache(cache, info, iclusters)
switch(info.move)
    case 4 % add
        if(iclusters(info.did).isterminal)
            cache.inset(info.did) = true;
        else
            cache.inset(info.did) = true;
            cache.inset(iclusters(info.did).chindices) = true;
        end
    case 5 % delete
        if(iclusters(info.sid).isterminal)
            cache.inset(info.sid) = false;
        else
            cache.inset(info.sid) = false;
            cache.inset(iclusters(info.sid).chindices) = false;
        end
    case 6 % switch
        if(iclusters(info.did).isterminal)
            cache.inset(info.did) = true;
        else
            cache.inset(info.did) = true;
            cache.inset(iclusters(info.did).chindices) = true;
        end
        if(iclusters(info.sid).isterminal)
            cache.inset(info.sid) = false;
        else
            cache.inset(info.sid) = false;
            cache.inset(iclusters(info.sid).chindices) = false;
        end
end
end

function [graph, cache] = initialize(graph, x, iclusters, model)
[~, graph.scenetype] = max(x.sconf);
[~, graph.layoutidx] = max(x.lconf);

cache = mcmccache(length(iclusters), length(x.lconf));
obts = [];
for i = 1:length(iclusters)
    assert(iclusters(i).isterminal);
    if(isnan(iclusters(i).angle))
        continue;
    end
    % if no conflict with existing clusters
    % if confidence is larger than 0
    oid = x.dets(iclusters(i).chindices, 1);
    
    lk = [x.dets(iclusters(i).chindices, 8), 1] * model.w_oo((oid-1)*2+1:(2*oid));
    lk = lk + [sum(x.intvol(i, cache.inset)), sum(x.orarea(i, cache.inset))] * model.w_ioo;
    if(lk > 0)
        graph.childs(end+1) = i;
        cache.inset(i) = true;
        obts = [obts, min(x.cubes{i}(2, :))];
    end
end
if(~isempty(obts))
    graph.camheight = -mean(obts);
else
    graph.camheight  = 1.0;
end

phi = features(graph, x, iclusters, model);
graph.lkhood = dot(phi, model.w);
%% init cache
cache.playout = exp(x.lconf .* model.w_or);
cache.playout = cache.playout ./ sum(cache.playout);
cache.clayout = cumsum(cache.playout);

cache.padd = exp(x.dets(:, end));
end

function cache = initCache(pg, x, iclusters, model)

cache = mcmccache(length(iclusters), length(x.lconf));
cache.inset(pg.childs) = true;
for i = 1:length(pg.childs)
    if(~iclusters(pg.childs(i)).isterminal)
        cache.inset(iclusters(pg.childs(i)).chindices) = true;
    end
end

%% init cache
cache.playout = exp(x.lconf .* model.w_or);
cache.playout = cache.playout ./ sum(cache.playout);
cache.clayout = cumsum(cache.playout);

cache.padd = zeros(1, length(iclusters));
%%  need to consider clustsers!
for i = 1:length(iclusters)
    if(iclusters(i).isterminal)
        cache.padd(i) = exp(x.dets(iclusters(i).chindices, end));
    else
        cache.padd(i) = exp(sum(x.dets(iclusters(i).chindices, end)));
    end
end

end