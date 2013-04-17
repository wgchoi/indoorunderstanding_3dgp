function [inner, outer] = get_inner_outer_polys(poly)
ct = mean(poly, 2);
vt = poly - repmat(ct, 1, 5);
inner = repmat(ct, 1, 5) + vt ./ 2;
outer = repmat(ct, 1, 5) + vt .* 1.5;
end