function [patterns, labels, hit, ptnsets] = latent_completion(patterns, labels, params, updateITM, VERBOSE)

model = params.model;

if(VERBOSE > 0)
    fprintf('starting latent completion [%d] ... ', length(patterns)); tic();
end

parfor i = 1:length(patterns)
% for i = [45 90]
    initrand();
    
    if(updateITM)
        composites = graphnodes(1);
        composites(:) = [];

        x = patterns(i).x;
        isolated = patterns(i).isolated;
        pg = labels(i).pg;
        
        for j = 1:length(model.itmptns)
            % get candidates from gt..
            gtcand = findITMCandidates(x, isolated, params, model.itmptns(j), pg.childs, pg.subidx, 0);
            % get valid candidates
            [cand, x] = findITMCandidates(x, isolated, params, model.itmptns(j));
            % get random candidates as negative sets!
            [randcand] = findRandomITMCandidates(x, isolated, params, model.itmptns(j), 30);
            %%%%%% duplicate check! %%%%%%%%%%%%%%%%%
            [idx1] = find_common_idx(gtcand, cand);
            gtcand(idx1) = [];
            cand = [gtcand; cand];
            [idx1] = find_common_idx(randcand, cand);
            randcand(idx1) = [];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            composites = [composites; cand; randcand];
        end
        patterns(i).composite = composites;
        patterns(i).iclusters = [patterns(i).isolated; patterns(i).composite];
    end
    
    try
        labels(i).lcpg = latentITMcompletion(labels(i).pg, patterns(i).x, patterns(i).iclusters, params);
    catch em
        i
        em
		em.message
		em.stack(1)
		em.stack(end)
        assert(0);
    end
    if(VERBOSE > 2)
        disp(['pattern ' num2str(i) ' processed'])
    end
end

if nargout >= 2
    hit = zeros(1, length(model.itmptns));
    ptnsets = cell(1, length(model.itmptns));
    for i = 1:length(labels)
        for j = 1:length(labels(i).lcpg.childs)
            idx = labels(i).lcpg.childs(j);
            if(~patterns(i).iclusters(idx).isterminal)
                pidx = params.model.itm_map(patterns(i).iclusters(idx).ittype);
                % pidx = patterns(i).iclusters(idx).ittype - model.nobjs;                
                hit(pidx) = hit(pidx) + 1;                
                ptnsets{pidx}(end+1) = patterns(i).iclusters(idx);
            end
        end
    end
end

if(VERBOSE > 0)
    fprintf(' done! '); toc();
end

end

function [idx1, idx2] = find_common_idx(candset1, candset2)

idx1 = [];
idx2 = [];

for i = 1:length(candset1)
    for j = 1:length(candset2)
        if(candset1(i).ittype == candset2(j).ittype && ...
                all(candset1(i).chindices(:) == candset2(j).chindices(:)))
            idx1(end+1) = i;
            idx2(end+1) = j;
            break;
        end
    end
end

end
