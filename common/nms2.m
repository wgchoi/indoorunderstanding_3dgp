function pick = nms2(boxes, overlap)

% pick = nms(boxes, overlap) 
% Non-maximum suppression.
% Greedily select high-scoring detections and skip detections
% that are significantly covered by a previously selected detection.

if isempty(boxes)
  pick = [];
else
  s = boxes(:,end);
  [vals, I] = sort(s);
  
  pick = [];
  while ~isempty(I)
    last = length(I);
    i = I(last);
    pick = [pick; i];
    o = boxoverlap(boxes(I, :), boxes(i, :));
    I(o >= overlap) = [];
  end  
end
