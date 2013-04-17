function [ composite ] = findCompositionalTemplates(isolated, rule)
composite = graphnodes(1000);
numclusters = 0;

%%% find indices of each part type
indices = cell(rule.numparts, 1);
for i = 1:rule.numparts
    indices{i} = findTypedClusters(isolated, rule.parts(i).citype);
end

%%% find all possible sets of combinations.
sets = recFindSets(indices);
tempnode = graphnodes(1);

tempnode.isterminal = 0;
tempnode.ittype = rule.type;
tic;
fprintf(['total ' num2str(size(sets, 2)) ' number of candidates, took ']);
for i = 1:size(sets, 2)
    tempnode.chindices = sets(:, i);
    
    tempnode.angle = 0;
    tempnode.loc = zeros(1, 3); 
    tempnode.angle = atan2(isolated(tempnode.chindices(2)).loc(3) - isolated(tempnode.chindices(1)).loc(3), isolated(tempnode.chindices(2)).loc(1) - isolated(tempnode.chindices(1)).loc(1));
    for j = 1:rule.numparts
        % take average
        tempnode.loc = tempnode.loc  + isolated(tempnode.chindices(j)).loc ./ rule.numparts;
    end
    [potential, feat] = computeCompositePotential(tempnode, isolated(tempnode.chindices), rule);
    if(rule.threshold < potential)
        numclusters = numclusters + 1;
        composite(numclusters) = tempnode;
    end
end
disp([toc() 'seconds to process a rule.']);
composite(numclusters+1:end) = [];
end

function idx = findTypedClusters(isolated, type)
idx = false(1, length(isolated));
for i = 1:length(isolated)
    idx(i) = isolated(i).ittype == type;
end
idx = find(idx);
end

function [ sets ] = recFindSets(indices)
if(isempty(indices))
    sets = zeros(0, 1);
    return;
end

subsets = recFindSets(indices(2:end));
sets = zeros(length(indices), length(indices{1}) * size(subsets, 2));
for i = 1:length(indices{1})
    idx = (1:size(subsets, 2)) + ((i-1) * size(subsets, 2));
    sets(:, idx) = [i * ones(1, size(subsets, 2)); subsets];
end

end