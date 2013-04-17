function ShowGTPolyg2(img,gtPolyg,fignum)
pfc={'r','g','b','k','w'};
%  pfc={'r','r','r','r','r'};
names = {'floor', 'center', 'right', 'left', 'ceiling'};
if nargin == 3
    figure(fignum);
end

img = displayout(gtPolyg, size(img, 2), size(img, 1), img);

imshow(uint8(img),[]);
hold on;
% imagesc(img);hold on;
for f=1: numel(gtPolyg)
    if numel(gtPolyg{f})>0
      plot([gtPolyg{f}(:,1);gtPolyg{f}(1,1)],[gtPolyg{f}(:,2);gtPolyg{f}(1,2)],'-', 'LineWidth',4,...
            'Color',pfc{f});
      % text(mean(gtPolyg{f}(:,1)), mean(gtPolyg{f}(:,2)), names{f}, 'backgroundcolor', 'w');
    end
end
hold off;
