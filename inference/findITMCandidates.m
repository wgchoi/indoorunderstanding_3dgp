function [composite, x] = findITMCandidates(x, isolated, params, rule, cidx, sidx, threshold, angcut)
if(nargin < 5)
    % candidate childs
    % in case of training, gives gt detections.
    cidx = 1:length(isolated);
    sidx = 14 * ones(1, length(isolated));
    if(~isfield(x, 'dists') || size(x.dists, 1) ~= size(x.dets, 1))
        x = precomputeDistances(x);
    end
    threshold = 0;
    maxnum = 1000;
    
    angcut = 1.6;
elseif(nargin < 7)
    threshold = -1;
    maxnum = inf;
    angcut = 1.6;
elseif (nargin < 8)
    maxnum = inf;
    angcut = 1.6;
else
    % testing scenario....
    maxnum = 1000;
end

%%%% due to inconsistent reference to detections...
%%%% ensure they are the same.. TODO : fix it!
assert(length(isolated) == size(x.dets, 1));

composite = graphnodes(1000);
numclusters = 0;

%%% find indices of each part type
indices = cell(rule.numparts, 1);
for i = 1:rule.numparts
    indices{i} = findTypedClusters(isolated(cidx), rule.parts(i).citype);
end

%%% find all possible sets of combinations.
if(isfield(x, 'dists'))
    sets = recFindSets2(indices, x.dists, x.angdiff, rule.parts, angcut);
else
    sets = recFindSets(indices);
end
tempnode = graphnodes(1);

if(~isempty(sets))
%     for i = 1:size(sets, 2)
%         for j = i+1:size(sets, 2)
%             if(all(sets(:, i) == sets(:, j)))
%                 keyboard;
%             end
%         end
%     end
end

tempnode.isterminal = 0;
tempnode.ittype = rule.type;
w = getITMweights(rule);
for i = 1:min(size(sets, 2), maxnum)
%     objtypes(end + 1) = iclusters(iidx).ittype;
%     objlocs(end + 1, :) = x.locs(iidx, 1:3) .* pg.objscale(i);
%     objcubes{end + 1} = x.cubes{iidx} .* pg.objscale(i);
%     objpose(end + 1) = x.locs(iidx, 4) ;
    if(isfield(x, 'locs') && any(any(isnan(x.locs(cidx(sets(:, i)), :)))))
        continue;
    end
    
    if(isfield(rule.parts(1), 'subtype'))
        matched = true;
        
        for j = 1:length(rule.parts)
            % for human
            if(rule.parts(j).subtype > 0)
                if(x.dets(cidx(sets(j, i)), 2) ~= rule.parts(j).subtype)
                    matched = false;
                    break;
                end
            end
        end
        
        if(~matched)
            continue;
        end
    end
    
    [ifeat, cloc, theta, azimuth, dloc, dpose] = computeITMfeature(x, rule, cidx(sets(:, i)), sidx(sets(:, i)), params, true);
    
    if(isempty(dloc))
        % non-valid
        continue;
    end
    
    tempnode.chindices = cidx(sets(:, i));
    tempnode.angle = theta;
    tempnode.azimuth = azimuth;
    tempnode.loc = cloc; 
    
    tempnode.feats = ifeat;
    tempnode.dloc = dloc;
    tempnode.dpose = dpose;
    
    
    % assert(0); % make sure it is correct!!!!!
%     camangle = atan2(-locs(1, 3), -locs(1, 1)); 
%     tempnode.azimuth = camangle - theta;
    
    if(threshold < dot(w, ifeat))
        numclusters = numclusters + 1;
        composite(numclusters) = tempnode;
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


function [ sets ] = recFindSets2(indices, dists, angdiff, parts, angcut)
if nargin < 5
    angcut = 1.6;
end

if(isempty(indices))
    sets = zeros(0, 1);
    return;
end

subsets = recFindSets2(indices(2:end), dists, angdiff, parts(2:end), angcut);
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
            % about 90 degree
            temp(:, angdiff(newidx, temp(k, :)) < ma(k) - angcut) = [];
            temp(:, angdiff(newidx, temp(k, :)) > ma(k) + angcut) = [];
        end
        temp(:, any(temp == newidx, 1)) = [];
    end
    
    idx = (1:size(temp, 2)) + cnt;
    sets(:, idx) = [newidx * ones(1, size(temp, 2)); temp];
    cnt = cnt + size(temp, 2);
end
sets(:, cnt+1:end) = [];

end