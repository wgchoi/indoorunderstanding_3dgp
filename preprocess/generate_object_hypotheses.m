function [hypotheses, invalid_idx] = generate_object_hypotheses(imfile, K, R, yaw, objmodels, dets, option)

if nargin < 7
	option = 0;
end

cnt = 0;
for o = 1:length(objmodels)
    didx = dets(:, 1) == o;
    h = one_object_hypotheses(imfile, K, R, yaw, objmodels(o), dets(didx, :), option);
    
    hypotheses(cnt+1:cnt+length(h)) = h;
    cnt = cnt + length(h);
end

invalid_idx = [];
for i = 1:length(hypotheses)
    if(hypotheses(i).oid < 0)
        invalid_idx(end+1) = i;
    end
end

end

function h = one_object_hypotheses(imfile, K, R, yaw, objmodel, dets, option)

h = struct( 'oid', cell(size(dets, 1), 1), 'locs', cell(size(dets, 1), 1), ...
            'cubes', cell(size(dets, 1), 1), ...
            'polys', cell(size(dets, 1), 1), ...
            'bbs', cell(size(dets, 1), 1), ...
            'ovs', cell(size(dets, 1), 1), ...
            'diff', cell(size(dets, 1), 1), ...
            'azimuth', cell(size(dets, 1), 1), 'angle', cell(size(dets, 1), 1));

for i = 1:size(dets, 1)
    h(i) = get_hypo_iprojections(imfile, K, R, yaw, objmodel, bbox2rect(dets(i, 4:7)), dets(i, 1:3), option);
end

end
