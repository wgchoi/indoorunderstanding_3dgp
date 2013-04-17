function ovp = order_vp(vp)
assert(size(vp, 1) == 3);
% 1 : vertical
% 2 : horizontal
% 3 : middle
v = abs(vp(:, 1) ./ vp(:, 2));
[a, b] = sort(v);
ovp = vp([b(1), b(3), b(2)], :);

end