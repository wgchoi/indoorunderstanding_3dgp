function [ PairDist, min_val, min_sub ] = calcPairDist( ptset1, ptset2 )

size1 = size(ptset1,1);
size2 = size(ptset2,1);

P1 = repmat(permute(ptset1,[1 3 2]),[1 size2 1]);
P2 = repmat(permute(ptset2,[3 1 2]),[size1 1 1]);
PairDist = sqrt(sum((P1 - P2).^2,3));

assert(size(PairDist,1) == size1);
assert(size(PairDist,2) == size2);

% [min_val, min_idx] = sort(PairDist(:));
% % [min_val, min_idx] = min(PairDist(:));
% [i,j] = ind2sub([size1 size2], min_idx(1:2));
% min_sub = [i,j];

[min_val, min_idx] = sort(PairDist(:));
% [min_val, min_idx] = min(PairDist(:));
[i,j] = ind2sub([size1 size2], min_idx(1));
min_sub(1,:) = [i,j];

for t = 2:length(PairDist(:))
    [k,l] = ind2sub([size1 size2], min_idx(t));
    if k ~= i && l ~= j
        min_sub(2,:) = [k,l];
        break;
    end
end

end