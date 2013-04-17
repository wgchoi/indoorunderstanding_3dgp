function val = get_closest(list, v)
[~, idx] = min(abs(list-v));
val = list(idx);
end
