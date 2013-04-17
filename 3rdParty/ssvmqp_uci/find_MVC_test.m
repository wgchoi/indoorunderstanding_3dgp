function [E_mex H_wo] = find_MVC_test(W_s, W_a, numClasses)
global ids d_ij_size Detections Scores;

Detections = double(Detections);
nDet = size(Detections, 1);

ptr = nDet;
while length(find(Detections(ptr, :)>0)) == 0
    ptr = ptr-1;
end
nDet = ptr;

Detections = Detections(1:nDet,:);
Scores = Scores(1:nDet);


E = zeros(nDet,1);
for clsID = 1:numClasses-1
    cls_dets = find(Detections(:, 5) == clsID);
    E(cls_dets) = W_a(2*clsID - 1).*Scores(cls_dets) + W_a(2*clsID);
end

Pos = E ;


[E_mex H_wo] = maximize(double(Detections),Pos,W_s,zeros(nDet, 2));


end

