function [dist] = get_itm_example_dist(e1, e2)

dist = 0;

diag1 = sqrt( (e1.bbox(3) - e1.bbox(1) + 1).^2 + (e1.bbox(4) - e1.bbox(2) + 1).^2);
diag2 = sqrt( (e2.bbox(3) - e2.bbox(1) + 1).^2 + (e2.bbox(4) - e2.bbox(2) + 1).^2);

distmap = zeros(size(e1.objboxes, 2), size(e2.objboxes, 2));
for i = 1:size(e1.objboxes, 2)
    bbox1 = e1.objboxes(:, i);
    bbox1(1) = (bbox1(1) - e1.bbox(1)) / diag1;
    bbox1(3) = (bbox1(3) - e1.bbox(1)) / diag1;
    bbox1(2) = (bbox1(2) - e1.bbox(2)) / diag1;
    bbox1(4) = (bbox1(4) - e1.bbox(2)) / diag1;
    
    for j = 1:size(e2.objboxes, 2)
        if(e1.objtypes(i) ~= e2.objtypes(j))
            distmap(i, j) = inf;
            continue;
        end
        
        bbox2 = e2.objboxes(:, j);
        bbox2(1) = (bbox2(1) - e2.bbox(1)) / diag2;
        bbox2(3) = (bbox2(3) - e2.bbox(1)) / diag2;
        bbox2(2) = (bbox2(2) - e2.bbox(2)) / diag2;
        bbox2(4) = (bbox2(4) - e2.bbox(2)) / diag2;
        
        diffa = anglediff(e1.objazs(i),  e2.objazs(j));
        if(diffa > pi / 4)
            distmap(i, j) = inf;
            continue;
        end
        distmap(i, j) = diffa / (pi / 6);
        
        ov = boxoverlap(bbox1' .* 100, bbox2'  .* 100);
%         if(ov < 0.5)
%             distmap(i, j) = inf;
%             continue;
%         end
        distmap(i, j) = distmap(i, j) +  log(ov) / log(0.5);
        % normalized distance
    end
end
[m,dist] = Hungarian(distmap);
if(sum(sum(m)) ~= size(e1.objboxes, 2))
    dist = inf;
end

return;

% need to find the best matching
for i = 1:size(e1.objboxes, 2)
    bbox1 = e1.objboxes(:, i);
    bbox2 = e2.objboxes(:, i);
    
    bbox1(1) = (bbox1(1) - e1.bbox(1)) / diag1;
    bbox1(3) = (bbox1(3) - e1.bbox(1)) / diag1;
    bbox1(2) = (bbox1(2) - e1.bbox(2)) / diag1;
    bbox1(4) = (bbox1(4) - e1.bbox(2)) / diag1;
    
    
    bbox2(1) = (bbox2(1) - e2.bbox(1)) / diag2;
    bbox2(3) = (bbox2(3) - e2.bbox(1)) / diag2;
    bbox2(2) = (bbox2(2) - e2.bbox(2)) / diag2;
    bbox2(4) = (bbox2(4) - e2.bbox(2)) / diag2;
    
%     if(boxoverlap(bbox1' .* 100, bbox2'  .* 100) < 0.3)
%         dist = inf;
%     end
    dist = dist + log(boxoverlap(bbox1' .* 100, bbox2'  .* 100)) / log(0.5); % normalized distance
    if(anglediff(e1.objazs(i),  e2.objazs(i)) > pi / 4)
        dist = inf;
    end
    continue;
    dist = dist + anglediff(e1.objazs(i),  e2.objazs(i)) / (pi/18);
end

% if(dist < 0.7 * size(e1.objboxes, 2))
%     cols = {'r' 'g' 'b' 'k' 'm'};
%     subplot(121);
%     imshow(e1.imfile);
%     for i = 1:size(e1.objboxes, 2)
%         rectangle('position', bbox2rect(e1.objboxes(:, i)), 'linewidth', 2, 'edgecolor', cols{i});
%     end
%     subplot(122);
%     imshow(e2.imfile);
%     for i = 1:size(e2.objboxes, 2)
%         rectangle('position', bbox2rect(e2.objboxes(:, i)), 'linewidth', 2, 'edgecolor', cols{i});
%     end
% end

end