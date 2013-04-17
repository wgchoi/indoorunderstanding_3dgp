function x=readHuamnObservationData(imfile, detfile, x)

poselet = load(detfile);
hdets = get_human_iprojections_2(poselet);
[hhmns, invalid_idx] = generate_object_hypotheses(x.imfile, x.K, x.R, x.yaw, objmodels(), hdets, 1);
hdets(invalid_idx, :) = [];
hhmns(invalid_idx) = [];

if(0)
    data = load(detfile);
    hdets = parseDets(data);
    [hhmns, invalid_idx] = generate_object_hypotheses(x.imfile, x.K, x.R, x.yaw, objmodels(), hdets, 1);
    hhmns(invalid_idx) = [];  hdets(invalid_idx, :) = [];
end

x.hobjs(end+1:end+length(hhmns)) = hhmns;
x.dets = [x.dets; hdets];

% keyboard;
end

function dets = parseDets(data)
% do 
dets = zeros(length(data.bodies.scores), 8);
if(1)
    posletmodel = load('./model/poselet_model');
    
    dets(:, end) = log(data.bodies.scores) / 3; % arbitrary normalization -_-;;
    w = data.torsos.rts(3, :)';
    cx = data.torsos.rts(1, :)' + data.torsos.rts(3, :)' ./ 2;
    dets(:, 4) = cx - w;
    dets(:, 6) = cx + w;
    dets(:, 5) = data.bodies.rts(2, :)';
    dets(:, 7) = data.bodies.rts(2, :)' + data.bodies.rts(4, :)';
    
    features = get_poselet_feature(data);
    [labels, p] = classify_poselet(posletmodel.model, posletmodel.DATAtrain, features);
    dets(:, 2) = labels;
else
    dets(:, end) = data.bodies.scores;
    dets(:, 4:7) = data.bodies.rts';
    dets(:, 6:7) = dets(:, 4:5) + dets(:, 6:7) - 1;
    dets(:, 2) = 1; % standing humans
end
dets(:, 1) = 7;

end

function show_hobj(imfile, hobj, det)
imagesc(imread(imfile))
rectangle('position', bbox2rect(det(1, 4:7)), 'linewidth', 4, 'edgecolor', 'k');

for i = 1:27
	rectangle('position', hobj.bbs(:, i), 'linewidth', 2, 'edgecolor', 'g');
end
[~, idx] = min(hobj.diff);
rectangle('position', hobj.bbs(:, idx), 'linewidth', 3', 'edgecolor', 'r');
end
