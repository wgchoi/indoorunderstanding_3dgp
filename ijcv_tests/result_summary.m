allap = zeros(4, length(om) - 1);
om = objmodels();
for i = 1:length(om)-1
	[~, ~, allap(1, i)] = evalDetection(annos, xs, conf0, i, 0, 0, 1);
	[~, ~, allap(2, i)] = evalDetection(annos, xs, conf1, i, 0, 0, 1);
	[~, ~, allap(3, i)] = evalDetection(annos, xs, conf2, i, 0, 0, 1);
	[~, ~, allap(4, i)] = evalDetection(annos, xs, conf3, i, 0, 0, 1);
end

[baseline, reestimated] = evalLayout(xs, res);
mean(baseline)
mean(reestimated)

allap
