function draw_all_plots(summary, humanset)

cols = {'b' 'm' 'g' 'r'};
names = {'ITM' 'DPM[6]'};
hfig=figure(1)
rs{1} = summary.alldet.rec; ps{1} = summary.alldet.prec; aps{1} = summary.alldet.ap;
rs{2} = summary.baseline_alldet.rec; ps{2} = summary.baseline_alldet.prec; aps{2} = summary.baseline_alldet.ap;
draw_pr(rs, ps, aps, cols, names, 'overall');
set(hfig,'Position',[100 400 540 420]);

hfig = figure(2);
if(humanset)
    tnames = {'sofa' 'table' 'chair' 'dtable' 'human'};
    cnt = 0;
    for i = [1:3 5 7]
        cnt = cnt + 1;
        subplot(2,3,cnt);
        rs{1} = summary.objdet(i).rec; ps{1} = summary.objdet(i).prec; aps{1} = summary.objdet(i).ap;
        rs{2} = summary.baseline_objdet(i).rec; ps{2} = summary.baseline_objdet(i).prec; aps{2} = summary.baseline_objdet(i).ap;
        draw_pr(rs, ps, aps, cols, names, tnames{cnt});
    end
else
    tnames = {'sofa' 'table' 'chair' 'bed' 'dtable' 'stable'};
    for i = 1:6
        subplot(2,3,i);
        rs{1} = summary.objdet(i).rec; ps{1} = summary.objdet(i).prec; aps{1} = summary.objdet(i).ap;
        rs{2} = summary.baseline_objdet(i).rec; ps{2} = summary.baseline_objdet(i).prec; aps{2} = summary.baseline_objdet(i).ap;
        draw_pr(rs, ps, aps, cols, names, tnames{i});
    end
end
set(hfig,'Position',[640 400 800 420]);

 
 
end

function draw_pr(rs, ps, aps, cols, names, figname)

hold on
texts = {};

for i = 1:length(rs)
    plot(rs{i}, ps{i}, cols{i}, 'linewidth', 2);
    texts{i} = [names{i} ' AP=' num2str(aps{i}, '%.03f')];
end
hold off;
grid on;

xlabel('recall');
ylabel('precision');
title(figname);
axis([0 1 0 1]);

h=legend(texts,'Location', 'SouthWest');
set(h, 'fontsize', 20);


end