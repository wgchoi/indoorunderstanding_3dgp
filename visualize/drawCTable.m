function CTableProb = drawCTable(CTable, classNames, outputfile, extraTitle)
if nargin < 4
    extraTitle = '';
end

saveFile = 1;
if nargin < 3
    saveFile = 0;
end


for i = 1:size(CTable, 1)
    CTableProb(i, :) = 100 * CTable(i, :) / sum(CTable(i, :));
end

imagesc(100 - CTableProb, [-20 100]); colormap('gray');
title({extraTitle;['Average Accuracy: ', num2str(sum(sum(diag(CTable))) / sum(sum(CTable)) * 100, '%.1f'),'%']});
set(gca, 'FontWeight', 'bold')

h = xlabel('Classified activity');
set(h, 'fontsize', 12);
set(h, 'FontWeight', 'bold')
h = ylabel('Actual activity');
set(h, 'fontsize', 12);
set(h, 'FontWeight', 'bold')

set(gca, 'YTick', 1:size(CTable, 1))
set(gca, 'XTick', 1:size(CTable, 2))
set(gca, 'YTickLabel', classNames)
set(gca, 'XTickLabel', classNames)
set(gca, 'FontWeight', 'bold')
set(gca, 'fontsize', 12);

for i=1:size(CTable, 1)
    for j=1:size(CTable, 2)
        dispStr=[num2str(CTableProb(i, j),'%.1f'),'%'];
        text(j, i, dispStr, 'HorizontalAlignment','center','color','w', 'FontSize', 15, 'FontWeight', 'bold')
    end
end

if saveFile
    try
%         saveas(gcf,[outputfile '.fig'])
%         saveas(gcf,[outputfile '.jpg'])
        saveas(gcf,[outputfile '.png'])
    catch ME
        ME
    end
end

end