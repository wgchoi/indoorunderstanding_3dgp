function m = anglemean(angles)
n = length(angles);
m = atan2(sum(sin(angles)) / n, sum(cos(angles)) / n);
end