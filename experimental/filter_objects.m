function x = filter_objects(x, filteridx)

x.dets(filteridx, :) = [];
x.hobjs(filteridx) = [];
x.orarea(filteridx, :) = [];
x.orarea(:, filteridx) = [];
x.orpolys(filteridx, :) = [];
x.orpolys(:, filteridx) = [];

end