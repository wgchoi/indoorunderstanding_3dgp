function [ptns, comps, indsets] = learn_itm_patterns(patterns, labels, params, VERBOSE, cachefile)
if nargin < 5
    cachefile = 'itmpatterns';
end
%%
if ~exist('cache', 'dir')
    mkdir('cache');
end

cand_data = true(1, length(patterns));
numobjs = zeros(1, length(patterns));
for i = 1:length(patterns)
    numobjs(i) = length(labels(i).pg.childs);
    cand_data(i) = numobjs(i) > 1;
end

allptns = ITMrule(1);
allptns(:) = [];
allcomposites = {};
alldidx = {};

% lets ignore..... way to expensive....
if(isfield(params.model, 'humancentric') && params.model.humancentric)
    cand_data(numobjs > 10) = false;
else
    cand_data(numobjs > 6) = false;
end

rid = 100;

%% ITM proposal
if(VERBOSE > 0)
    disp('ITM proposal begin!!');
end

if exist(fullfile('cache/', [cachefile '.mat']), 'file') || exist(fullfile('cache/', cachefile), 'file')
    load(fullfile('cache/', cachefile));
    
    %%%% temporary
    if(~isfield(allcomposites{1}(1), 'subidx'))
        for i = 1:length(allcomposites)
            for j = 1:length(allcomposites{i})
                allcomposites{i}(j).subidx = 14 * ones(1, length(allcomposites{i}(j).chindices));
            end
        end
    end
else
    while(any(cand_data))
        idx = find(cand_data);
        [~, maxid] = sort(-numobjs(cand_data));
        idx = idx(maxid(1));

        ptns = proposeITM(labels(idx).pg, patterns(idx).x, patterns(idx).isolated, params);
        for i = 1:length(ptns)
            ptns(i).type = rid;
            rid = rid + 1;
        end
        if(VERBOSE > 1), tic(); end
        % large one first
        for j = length(ptns):-1:1
            composite = graphnodes(0);
            didx = [];
            tidx = find(cand_data);

            ptn = ptns(j);
            %%% redundancy check
            redundant = 0;
            for k = 1:length(allptns)
                if(compareITM(ptn, allptns(k)) < 9)
                    redundant = 1;
                    break;
                end
            end
            if(redundant), continue;  end

            %%% match examples
            for tt = 1:length(tidx)
                k = tidx(tt);
                temp = findITMCandidates(patterns(k).x, patterns(k).isolated, params, ptn, labels(k).pg.childs, labels(k).pg.subidx);
                composite(end+1:end+length(temp)) = temp;
                didx(end+1:end+length(temp)) = k .* ones(1, length(temp));
            end

            %%% match threshold
            if(length(composite) > params.minITMmatch)
                ptn = reestimateITM(ptn, composite);
                allptns(end+1) = ptn;
                allcomposites{end+1} = composite;
                alldidx{end+1} = didx;
    %             for k = 1:length(didx)
    %                 did = didx(k);
    %                 if(length(labels(did).pg.childs) == length(composite(k).chindices))
    %                     cand_data(did) = false;
    %                 end
    %             end
                if(VERBOSE > 1)
                    fprintf('+');
                end
            else
                if(VERBOSE > 1)
                    fprintf('.');
                end
            end
        end

        cand_data(idx) = false;

        if(VERBOSE > 1)
            fprintf([num2str(idx) ' is done (remain : ' num2str(sum(cand_data)) ' patterns : ' num2str(length(allptns)) '). ']); 
            toc();
        end
        save(fullfile('cache/', cachefile), 'allptns', 'allcomposites', 'alldidx');
    end
end
if(VERBOSE > 0)
    disp(['ITM proposal done!!' num2str(length(allptns)) ' patterns discovered']);
end
%% regroup candidates
allcomp2 = {};
alldidx2 = {};
for i = 1:length(allptns)
    fprintf('.');
    composite = graphnodes(0);
    didx = [];

    ptn = allptns(i);
    %%% match examples
    for j = 1:length(patterns)
        temp = findITMCandidates(patterns(j).x, patterns(j).isolated, params, ptn, labels(j).pg.childs, labels(j).pg.subidx);
        composite(end+1:end+length(temp)) = temp;
        didx(end+1:end+length(temp)) = j .* ones(1, length(temp));
    end
    
    allcomp2{i} = composite;
    alldidx2{i} = didx;
end
fprintf(' itm collection done.\n');
%% agglomerative clustering
ptns = allptns;
comps = allcomp2;
indsets = alldidx2;
if(VERBOSE > 1)
    disp(['initially ' num2str(length(ptns)) ' number of patterns'])
end
while(1)
    [clustered, ptns, comps, indsets] = clusterITMpatterns(patterns, ptns, comps, indsets, params);
    if(~clustered)
        break;
    end
end
if(VERBOSE > 0)
    disp([num2str(length(ptns)) ' number of patterns after clustering'])
end

% reorder and assign itm id
hit = zeros(1, length(ptns));
for i = 1:length(ptns)
    ptns(i).type = (params.model.nobjs + i);
    hit(i) = length(indsets{i});
end
save(fullfile('cache/', cachefile), '-append', 'ptns', 'comps', 'indsets');

end