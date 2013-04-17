function [sets] = generate_itm_trainsets(patterns, labels, params, ptns)
% mine positive sets
%par

names = {'sofa' 'table' 'chair' 'bed' 'diningtable' 'sidetable' 'person'};

for i = 1:length(ptns)
    disp(['processing ' num2str(i)]);
    %pos = struct('itm_examples', {}, 'clusters', {}, 'viewset', {});
    [pos.itm_examples, pos.clusters, pos.viewset] = generate_positive_itm_trainset(patterns, labels, params, ptns(i));
    sets(i).pos = pos;
    
    sets(i).objnames = {};
    for j = 1:length(ptns(i).parts)
        sets(i).objnames{j} = names{ptns(i).parts(j).citype};
    end
    % not using negative...
    continue;
    
    [didx, composite] = collect_itm_instances(patterns, [], params, ptns(i));
    [idx, loss] = find_negative_itms(patterns, labels, didx, composite, ptns(i));
    
    disp([num2str(sum(loss == 0)) ' positives are retrived']);
    
    loss = loss(idx);
    [itm_examples] = get_itm_examples(patterns, labels, didx(idx), composite(idx));
    % [itm_examples, remove_idx] = remove_duplicate_itm_examples(itm_examples);
    % loss(remove_idx) = [];
    %neg = struct('itm_examples', {}, 'clusters', {}, 'viewset', {});
    neg.itm_examples = itm_examples;
    neg.loss = loss;
    disp([num2str(length(loss)) ' negative sets']);
    sets(i).neg = neg;
end

end

function [idx, loss] = find_negative_itms(patterns, labels, didx, composite, ptn)

loss = zeros(1, length(composite));
for i = 1:length(composite)
    gtobjs= labels(didx(i)).pg.childs;
    itm_objs = composite(i).chindices;
    
    for j = 1:length(ptn.parts)
        assert(patterns(didx(i)).x.hobjs(itm_objs(j)).oid == ptn.parts(j).citype);
    end
    
    for j = 1:length(itm_objs)
         loss(i) = loss(i) + 1 - any(gtobjs == itm_objs(j));
    end
end
idx = find(loss > 0);
end

function [itm_examples, clusters, viewset] = generate_positive_itm_trainset(patterns, labels, params, ptn)

[didx, composite] = collect_itm_instances(patterns, labels, params, ptn);
[itm_examples] = get_itm_examples(patterns, labels, didx, composite);
[itm_examples, clusters, viewset] = cluster_itm_examples(itm_examples, params);
disp([num2str(length(itm_examples)) ' positives exists']);
% data-mining from PASCAL
pascal_examples = find_itm_from_pascal(itm_examples, ptn);
[pascal_clusters] = test_flipped_example(itm_examples, clusters, pascal_examples);
pascal_examples(pascal_clusters < 0) = [];
pascal_clusters(pascal_clusters < 0) = [];

itm_examples = [itm_examples, pascal_examples];
clusters = [clusters, pascal_clusters];
% mining
[flipped_examples] = get_flipped_itm_examples(itm_examples);
[flipped_clusters] = test_flipped_example(itm_examples, clusters, flipped_examples);

flipped_examples(flipped_clusters < 0) = [];
flipped_clusters(flipped_clusters < 0) = [];

itm_examples = [itm_examples, flipped_examples];
clusters = [clusters, flipped_clusters];
end

function [flipped_clusters] = test_flipped_example(itm_examples, clusters, flipped_examples)

flipped_clusters = -ones(1, length(flipped_examples));

nparts = size(itm_examples(1).objboxes, 2);

for i = 1:length(flipped_examples)
    dists = zeros(1, length(itm_examples));
    for j = 1:length(itm_examples)
        dists(j) = get_itm_example_dist(flipped_examples(i), itm_examples(j));
    end
    
    maxsim = 0.01; % at least 20% of clsuters should be similar
    maxidx = -1;
    
    cidx = unique(clusters);
    for j = 1:length(cidx)
        sim = sum(dists(clusters == cidx(j)) < 1.5 * nparts) / sum(clusters == cidx(j));
        if(maxsim < sim)
            maxsim = sim;
            maxidx = cidx(j);
        end
    end
    
    flipped_clusters(i) = maxidx;
end

end