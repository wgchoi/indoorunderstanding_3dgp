function [pg] = latentITMcompletion(pg, x, iclusters, params)
%%% greedy way to find the ITM in GT parse graph!
%%% nothing to be done.
if(length(pg.childs) < 2)
    return;
end
model = params.model;
assert(isfield(model, 'itmptns'));
assert(strcmp(model.feattype, 'itm_v0') || strcmp(model.feattype, 'itm_v1') || strcmp(model.feattype, 'itm_v2') || strcmp(model.feattype, 'itm_v3'));

%%% assume that the composite candidates are given.
if(1)
    isterminal = false(1, length(iclusters));
    for i = 1:length(iclusters)
        isterminal(i) = iclusters(i).isterminal;
    end
    isol_idx = find(isterminal);
    comp_idx = find(~isterminal);
else
%     isolated = iclusters;
%     
%     composites = graphnodes(1);
%     composites (:) = [];
%     for i = 1:length(model.itmptns)
%         ptn = model.itmptns(i);
%         temp = findITMCandidates(x, isolated, params, ptn, pg.childs);
%         composites(end+1:end+length(temp)) = temp;
%     end
%     iclusters = [isolated; composites];
end

%%% no itm in the pg yet.
for i = 1:length(pg.childs)
    assert(iclusters(pg.childs(i)).isterminal);
end

update = true;
while(update)
    pg.lkhood = dot(getweights(model), features(pg, x, iclusters, model));
    % not allowing obj-sharing.. need to fix when it comes to allowing
    % sharing!
    
    objs = [];
    for i = 1:length(pg.childs)
        % only consider remaining objs
        if(iclusters(pg.childs(i)).isterminal)
            objs(end+1) = pg.childs(i);
        end
    end
    
    maxpg = pg;
    update = false;
    for i = 1:length(comp_idx)
        iset = intersect(objs, iclusters(comp_idx(i)).chindices);
        % missing objects..
        if(length(iset) < length(iclusters(comp_idx(i)).chindices))
            continue;
        end
        
        
        temp = pg;
        temp.childs = setdiff(temp.childs, iset);
        temp.childs(end+1) = comp_idx(i);
        temp = findConsistent3DObjects(temp, x, iclusters, true); 
        if(isfield(params, 'ignorefarobj') && params.ignorefarobj)
            if(~latentITMCheckDist2Human(temp, x, iclusters, comp_idx(i)))
                continue;
            end
        end
        temp.lkhood = dot(getweights(params.model), features(temp, x, iclusters, params.model)); 
        
        if(maxpg.lkhood < temp.lkhood)
            update = true;
            maxpg = temp;
        end
    end
    
    pg = maxpg;
end

end