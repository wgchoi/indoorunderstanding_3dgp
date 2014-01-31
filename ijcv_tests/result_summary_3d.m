if ~exist('layout_option','var')
    layout_option = 'sp10_hedau';
end

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
    if i ~=4 && i ~= 6
        continue
    end
    [rec0, prec0, allap_3d(1, i)] = evalDetection_3d(annos, xs, res, conf0, i, 0, 0, 1, option);
	[rec1, prec1, allap_3d(2, i)] = evalDetection_3d(annos, xs, res, conf1, i, 0, 0, 1, option);
	[rec2, prec2, allap_3d(3, i)] = evalDetection_3d(annos, xs, res, conf2, i, 0, 0, 1, option);
	[rec3, prec3, allap_3d(4, i)] = evalDetection_3d(annos, xs, res, conf3, i, 0, 0, 1, option);
    % % plot pr-curve
    % figure;
    % plot(rec0, prec0, 'r-'); hold on
    % plot(rec1, prec1, 'g-');
    % plot(rec2, prec2, 'k-');
    % plot(rec3, prec3, 'b-');
    % grid;
    % xlabel 'recall'
    % ylabel 'precision'
    % title(sprintf('class: %d, AP = %.3f / %.3f / %.3f / %.3f ', ...
    %     i,allap_3d(1,i),allap_3d(2,i),allap_3d(3,i),allap_3d(4,i)));
    % savename = ['d' num2str(option.dist_metric,'%1d') 'i' num2str(i,'%1d') 'n' num2str(option.nmsthres,'%3.1f') 'o' num2str(option.ovthres,'%3.1f') '_' layout_option lbl];
    % axis([0 1 0 1]);
    % cache_dir = 'ijcv_tests/cache_eval/';
    % if ~exist(cache_dir,'file')
    %     mkdir(cache_dir);
    % end
    % print(gcf,'-djpeg',[cache_dir savename '.jpg']);
    % % close;
end

[baseline, reestimated] = evalLayout(xs, res);
mean(baseline)
mean(reestimated)

[baseline, reestimated] = evalLayout_3d(xs, res);
mean(baseline)
mean(reestimated)

allap

allap_3d
