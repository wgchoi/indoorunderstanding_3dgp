function [spg, maxidx, h, allclusters] = infer_top(x, iclusters, params, y)

h = [];
allclusters = [];
isolated = iclusters;

if(strncmp(params.model.feattype, 'itm_v', 5))
    composites = graphnodes(1);
    composites(:) = [];
    for j = 1:length(params.model.itmptns)
        % get valid candidates
        % [temp, x] = findITMCandidates(x, isolated, params, params.model.itmptns(j));
        [temp, x] = findITMCandidates(x, isolated, params, params.model.itmptns(j), 1:length(isolated), 14 * ones(1, length(isolated)), 0, 1.0);
        composites = [composites; temp;];
    end
    iclusters = [isolated; composites];
    
    if(isfield(params.model, 'itmhogs') && params.model.itmhogs)
        %%% append hog observations
        pattern.x = x;
        pattern.iclusters = iclusters;
        pattern.isolated = isolated;
        pattern.composite = composites;

        pattern = itm_observation_response(pattern, params.model);

        iclusters = pattern.iclusters;
        isolated = pattern.isolated;
        composites = pattern.composite;

        clear pattern;
    end
end
        
assert(length(iclusters) < 10000);

maxipg = y;
maxipg.lkhood = -inf;
maxpg = y;
maxpg.lkhood = -inf;

if(params.pmove(6) > 0)
    x = preprocessClusterOverlap(x, iclusters);
end

if(isfield(params, 'ignorescene') && params.ignorescene)
    sidx = y.scenetype;
else
    sidx = 1:params.model.nscene;
end

for i = sidx
    pg = y;
    pg.scenetype = i;
    
    if(strcmp(params.inference, 'mcmc'))
        init.pg = pg;
        [spg, maxidx, ~, h] = DDMCMCinference(x, iclusters, params, init);
    elseif(strcmp(params.inference, 'greedy'))
        initpg = pg;
        [spg] = GreedyInference(x, iclusters, params, initpg);
        maxidx = 1;
    elseif(strcmp(params.inference, 'combined'))
        init.pg = pg;
        [init.pg] = GreedyInference(x, iclusters, params, init.pg);
        [spg, maxidx, ~, h] = DDMCMCinference(x, iclusters, params, init);
    else
        assert(0);
    end
    
    if(maxipg.lkhood < spg(1).lkhood)
        maxipg = spg(1);
    end
    
    if(maxpg.lkhood  < spg(maxidx).lkhood)
        maxpg = spg(maxidx);
    end
end

if(isfield(params, 'retainAll3DGP') && params.retainAll3DGP)
    spg = [maxipg; maxpg]; 
    maxidx = 2;
    allclusters = iclusters;
    return;
end

if(strncmp(params.model.feattype, 'itm_v', 5))
    pgi = maxipg;
    itmidx = find(pgi.childs > length(isolated));
    if(~isempty(itmidx))
        idx = pgi.childs(itmidx);

        allclusters = [isolated; iclusters(idx)];
        pgi.childs(itmidx) = length(isolated) + (1:length(idx));
    else
        allclusters = isolated;
    end
    
    pgmax = maxpg;
    itmidx = find(pgmax.childs > length(isolated));
    if(~isempty(itmidx))
        idx = pgmax.childs(itmidx);

        pgmax.childs(itmidx) = length(allclusters) + (1:length(idx));
        allclusters = [allclusters; iclusters(idx)];
    end
    
    spg = [pgi; pgmax];
    maxidx = 2;
else
    spg = [maxipg; maxpg]; 
    maxidx = 2;
    allclusters = isolated;
end
end

