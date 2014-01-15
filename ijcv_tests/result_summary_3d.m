allap = zeros(4, length(om) - 1);
om = objmodels();
for i = 1:length(om)-1
	[~, ~, allap(1, i)] = evalDetection(annos, xs, conf0, i, 0, 0, 1);
	[~, ~, allap(2, i)] = evalDetection(annos, xs, conf1, i, 0, 0, 1);
	[~, ~, allap(3, i)] = evalDetection(annos, xs, conf2, i, 0, 0, 1);
	[~, ~, allap(4, i)] = evalDetection(annos, xs, conf3, i, 0, 0, 1);
end

% 3d object detection
allap_3d = zeros(4, length(om) - 1);
for i = 1:length(om)-1
    [~, ~, allap_3d(1, i)] = evalDetection_3d(annos, xs, res, conf0, i, ovthres, nmsthres, 0, 0, 1);
	[~, ~, allap_3d(2, i)] = evalDetection_3d(annos, xs, res, conf1, i, ovthres, nmsthres, 0, 0, 1);
	[~, ~, allap_3d(3, i)] = evalDetection_3d(annos, xs, res, conf2, i, ovthres, nmsthres, 0, 0, 1);
	[~, ~, allap_3d(4, i)] = evalDetection_3d(annos, xs, res, conf3, i, ovthres, nmsthres, 0, 0, 1);
end

[baseline, reestimated] = evalLayout(xs, res);
mean(baseline)
mean(reestimated)

[baseline, reestimated] = evalLayout_3d(xs, res);
mean(baseline)
mean(reestimated)

allap

allap_3d
