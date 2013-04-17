function [composite] = findRandomITMCandidates(x, isolated, params, rule, maxnum, cidx)
%%% find random ITM candidates..
%%% having only good candidates would make the training impossible..
%%% we should have those that are not consistent in spatial configuration.
if(nargin < 6)
    % candidate childs
    % in case of training, gives gt detections.
    cidx = 1:length(isolated);
end

%%%% due to inconsistent reference to detections...
%%%% ensure they are the same.. TODO : fix it!
assert(length(isolated) == size(x.dets, 1));

composite = graphnodes(maxnum);
numclusters = 0;

%%% find indices of each part type
indices = cell(rule.numparts, 1);
for i = 1:rule.numparts
    indices{i} = findTypedClusters(isolated(cidx), rule.parts(i).citype);
end

%%% find all possible sets of combinations.
sets = recFindSets(indices);

ridx = randperm(size(sets, 2));
tempnode = graphnodes(1);
tempnode.isterminal = 0;
tempnode.ittype = rule.type;
w = getITMweights(rule);

for i = 1:size(sets, 2)
    idx = ridx(i);
    
    if(~isfield(x, 'hobjs'))
        if(any(any(isnan(x.locs(cidx(sets(:, idx)), :)))))
            continue;
        end
    end
    
    if(isfield(rule.parts(1), 'subtype'))
        matched = true;
        for j = 1:length(rule.parts)
            % for human
            if(rule.parts(j).subtype > 0)
                if(x.dets(cidx(sets(j, idx)), 2) ~= rule.parts(j).subtype)
                    matched = false;
                    break;
                end
            end
        end
        if(~matched)
            continue;
        end
    end
    
    [ifeat, cloc, theta, azimuth, dloc, dpose] = computeITMfeature(x, rule, cidx(sets(:, idx)), 14 * ones(1, length(sets(:, idx))), params, true);
    
    if(isempty(dloc))
        % non-valid
        continue;
    end
    
    tempnode.chindices = cidx(sets(:, idx));
    tempnode.angle = theta;
    tempnode.azimuth = azimuth;
    tempnode.loc = cloc; 
    tempnode.feats = ifeat;
    tempnode.dloc = dloc;
    tempnode.dpose = dpose;
   
    numclusters = numclusters + 1;
    composite(numclusters) = tempnode;
    
    if(numclusters >= maxnum)
        break;
    end
end
% if(numclusters > 0)
%     disp([num2str(toc(), '%.3f') ' seconds to process a rule. found ' num2str(numclusters) ' ITM!']);
% end
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

cnt = 0;
for i = 1:length(indices{1})
    temp = subsets;
    newidx = indices{1}(i);
    if(~isempty(temp))
        % compatibility filtering
        temp(:, any(temp == newidx, 1)) = [];
    end
    
    idx = (1:size(temp, 2)) + cnt;
    sets(:, idx) = [newidx * ones(1, size(temp, 2)); temp];
    cnt = cnt + size(temp, 2);
end
sets(:, cnt+1:end) = [];

end


function [ sets ] = recFindSets2(indices, dists, angdiff, parts)
if(isempty(indices))
    sets = zeros(0, 1);
    return;
end

subsets = recFindSets2(indices(2:end), dists, angdiff, parts(2:end));
sets = zeros(length(indices), length(indices{1}) * size(subsets, 2));

md = zeros(length(parts)-1, 1);
ma = zeros(length(parts)-1, 1);
for i = 2:length(parts)
    md(i-1) = norm([parts(1).dx - parts(i).dx, parts(1).dz - parts(i).dz]);
    ma(i-1) = anglediff(parts(1).da, parts(i).da);
end

cnt = 0;
for i = 1:length(indices{1})
    temp = subsets;
    newidx = indices{1}(i);
    if(~isempty(temp))
        % compatibility filtering
        for k = 1:size(temp, 1)
            % about 1 meter
            temp(:, dists(newidx, temp(k, :)) < md(k) - 1) = [];
            temp(:, dists(newidx, temp(k, :)) > md(k) + 1) = [];
            % abour 60 degree
            temp(:, angdiff(newidx, temp(k, :)) < ma(k) - 1) = [];
            temp(:, angdiff(newidx, temp(k, :)) > ma(k) + 1) = [];
        end
        temp(:, any(temp == newidx, 1)) = [];
    end
    
    idx = (1:size(temp, 2)) + cnt;
    sets(:, idx) = [newidx * ones(1, size(temp, 2)); temp];
    cnt = cnt + size(temp, 2);
end
sets(:, cnt+1:end) = [];

end