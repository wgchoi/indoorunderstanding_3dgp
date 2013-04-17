function [baseline, reestimated, gt] = evalClassification(xs ,annos, res)
baseline = zeros(1, length(xs));
reestimated = zeros(1, length(xs));
gt = zeros(1, length(xs));
for i = 1:length(xs)
    gt(i) = annos{i}.scenetype;
    pg = res{i}.spg(2);
    [~, baseline(i)] = max(xs{i}.sconf);
    reestimated(i) = pg.scenetype;
end
end