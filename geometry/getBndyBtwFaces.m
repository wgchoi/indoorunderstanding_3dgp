function [bct, bline] = getBndyBtwFaces(poly1, poly2)

dists = (poly1(:,1) * ones(1, size(poly2, 1)) - ones(size(poly1, 1), 1) * poly2(:,1)') .^ 2 + ...
            (poly1(:,2) * ones(1, size(poly2, 1)) - ones(size(poly1, 1), 1) * poly2(:,2)') .^ 2;

% find nearby points 
[i1, i2] = find(dists < 100);
if isempty(i1)
    bline = [];
    bct = [];
    
    return;
end

p = [poly1(unique(i1), :); poly2(unique(i2), :)];
bct = mean(p, 1);
if nargout >= 2
    bline =  polyfit(p(:, 1), p(:, 2), 1);
end

end