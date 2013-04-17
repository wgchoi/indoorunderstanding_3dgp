function [ex, remove_idx, distmap] = remove_duplicate_itm_examples(ex, distmap)
if nargin < 2
    distmap = [];
end
remove_idx = [];
nparts = size(ex(1).objboxes, 2);
for i = 1:length(ex)
    if(any(remove_idx == i))
        continue;
    end
    for j = i+1:length(ex)
        if(strcmp(ex(i).imfile, ex(j).imfile) && ex(i).flip == ex(j).flip)
            if(~isempty(distmap))
                dist = distmap(i, j);
            else
                dist = get_itm_example_dist(ex(i), ex(j));
            end
            
            if(dist == 0)
                remove_idx(end+1) = j;
            end
        end
    end
end
ex(remove_idx) = [];
if(~isempty(distmap))
    distmap(:, remove_idx) = [];
    distmap(remove_idx, :) = [];
end
end