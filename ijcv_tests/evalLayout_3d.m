function [baseline, reestimated] = evalLayout_3d(xs, res)
baseline = zeros(1, length(xs));
reestimated = zeros(1, length(xs));
for i = 1:length(xs)
    pg = res{i}.spg(2);
    baseline(i) =  xs{i}.lerr_ywc3d(1);
    reestimated(i) =  xs{i}.lerr_ywc3d(pg.layoutidx);
end
end