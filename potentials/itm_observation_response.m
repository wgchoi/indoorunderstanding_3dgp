function patterns = itm_observation_response(patterns, model)
assert(model.itmhogs);

for i = 1:length(patterns)
    pattern = patterns(i);
    
    n = length(pattern.composite);
    itm_examples = get_itm_examples(pattern, [], ones(1, n), pattern.composite);
    responses = zeros(1, n);
    itmidx = zeros(1, n);

    ptns = model.itmptns;
    parfor j = 1:length(itm_examples)
        itmidx(j) = model.itm_map(pattern.composite(j).ittype);
        assert(itmidx(j) > 0);

        ptn = ptns(itmidx(j));
        [~, mid]=itm_view_idx(ptn, pattern.composite(j).azimuth);
        if(mid < 0)
            responses(j) = 0;
            itmidx(j) = 0;
        else
            [~, ~, r] = featwarp(ptn.hogmodel{mid}, itm_examples(j));
            % scale it properly
            responses(j) = 10 * r;
            if(isnan(responses(j)) || isinf(responses(j)))
                responses(j) = -3;
                fprintf('error in response\n');
            end
        end
    end
    
    for j = 1:length(itm_examples)
        patterns(i).composite(j).robs = responses(j);
    end
end

for i = 1:length(patterns)
	patterns(i).iclusters = [patterns(i).isolated; patterns(i).composite];
end
% 
% for m = 1:length(temp.index_pose)
%     testidx = [];
% 
%     if(iscell(temp.index_pose))
%         poses = temp.index_pose{m};
%     else
%         poses = temp.index_pose(m);
%     end
% 
%     for j = 1:length(poses)
%         testidx = [testidx, find(sets(i).pos.clusters == poses(j))];
%     end
% 
%     if isempty(testidx)
%         continue;
%     end
% 
%     [~, ~, vr(m).rpos] = featwarp(temp.models{m}, sets(i).pos.itm_examples(testidx));
%     [~, ~, vr(m).rneg] = featwarp(temp.models{m}, sets(i).neg.itm_examples);
% end
end
