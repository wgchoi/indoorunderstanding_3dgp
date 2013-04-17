function [itm_examples, clusters, viewset] = cluster_itm_examples(itm_examples, params)

distmap = inf(length(itm_examples), length(itm_examples));
for i = 1:length(itm_examples)
    for j = i+1:length(itm_examples)
        distmap(i, j) = get_itm_example_dist(itm_examples(i), itm_examples(j));
        distmap(j, i) = distmap(i, j);
        %pdist(cnt) = get_layout_dist(itm_examples(i), itm_examples(j));
        %cnt = cnt + 1;
    end
end
% find duplication..
[itm_examples, ~, distmap] = remove_duplicate_itm_examples(itm_examples, distmap);

% initialize with view point - 8 views
viewset = cell(1, 8);
for i = 1:length(viewset)
    viewset{i} = i;
end

if(isfield(params.model, 'humancentric') && params.model.humancentric)
    for j = 2:length(itm_examples)
        assert(all(itm_examples(j).objtypes == itm_examples(j-1).objtypes))
    end
    refobj = -1;
    om = objmodels();
    for i = 1:length(itm_examples(1).objtypes)
        oid = itm_examples(1).objtypes(i);
        if(om(oid).ori_sensitive)
            refobj = i;
            break;
        end
    end
end

clusters = 1:length(itm_examples);
for i = 1:length(itm_examples)
    if(isfield(params.model, 'humancentric') && params.model.humancentric)
        if(refobj > 0)
            az = itm_examples(i).objazs(refobj);
        else
            az = itm_examples(i).azimuth;
        end
    else
        az = itm_examples(i).azimuth ;
    end
    clusters(i) = find_interval(az / pi * 180, 8);
end

return;

nparts = size(itm_examples(1).objboxes, 2);
res = true;
while(res)
    [res, clusters, viewset] = agglomerative_clustering(clusters, viewset, distmap, 1.5 * nparts);
end

% idx = unique(clusters);
% for i = 1:length(idx)
%     clusters(clusters == idx(i)) = i;
% end
% 
% return;
% 
% for i = 2:length(itm_examples)
%     call = unique(clusters);
%     for j = 1:length(call)
%         if(call(j) == clusters(i))
%             continue;
%         end
%         tidx = clusters == call(j);
%         alldist = distmap(i, tidx);
% 
%         if(sum(alldist < nparts) > length(alldist) * 0.8)
% %             if(all(alldist < 2 * nparts))
%             clusters(i) = call(j);
%             break;
%         end
%     end
% end

end


function [res, clusters, viewset] = agglomerative_clustering(clusters, viewset, distmap, maxdist)

cidx = unique(clusters);
maxsim = 0.7; % at least 75% of clsuters should be similar
maxidx = [];

res = false;

for i = 1:length(cidx)
    for j = i+1:length(cidx)
        cid1 = clusters == cidx(i);
        cid2 = clusters == cidx(j);
        
        % mindist1 = min(distmap(cid1, cid2), [], 1);
        mindist2 = min(distmap(cid1, cid2), [], 2);
        %sim = (sum(mindist1 < maxdist) + sum(mindist2 < maxdist)) / (length(mindist1) + length(mindist2));
        sim = sum(mindist2 < maxdist) / length(mindist2);
        
        mindist1 = min(distmap(cid1, cid2), [], 1);
        sim = min(sim, sum(mindist1 < maxdist) / length(mindist1));
        
        if(sim > maxsim)
            maxsim = sim;
            maxidx = [cidx(i), cidx(j)];
            
            res = true;
        end
    end
end

if(res)
    clusters(clusters == maxidx(2)) = maxidx(1);
    viewset{maxidx(1)} = [viewset{maxidx(1)}, viewset{maxidx(2)}];
    viewset{maxidx(2)} = [];
end

end