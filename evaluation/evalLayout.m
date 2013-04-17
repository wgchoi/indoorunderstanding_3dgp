function [baseline, reestimated] = evalLayout(xs, res)
baseline = zeros(1, length(xs));
reestimated = zeros(1, length(xs));
for i = 1:length(xs)
    pg = res{i}.spg(2);
    baseline(i) =  xs{i}.lerr(1);
    reestimated(i) =  xs{i}.lerr(pg.layoutidx);
end
return
% idx = find(reestimated < baseline);
% for i = 1:length(idx)
% reest = res{idx(i)}.spg(2).layoutidx;
% figure(1);
% ShowGTPolyg2(imread(data(idx(i)).x.imfile), data(idx(i)).x.lpolys(1, :), 1);
% ShowGTPolyg2(imread(data(idx(i)).x.imfile), data(idx(i)).x.lpolys(reest, :), 2);
% pause;
% end
end