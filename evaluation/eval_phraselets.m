clear

resbase = '~/codes/human_interaction/cache/data.v2';
datasets = dir(resbase);
datasets(1:2) = [];
%%
cnt = 1;
removeidx = [];

for d = 1:length(datasets)
    dataset = datasets(d).name;
    
    resdir = fullfile(resbase, dataset);
    files = dir(fullfile(resdir, 'data*.mat'));
    for i = 1:length(files)
        data(cnt) = load(fullfile(resdir, files(i).name));
        if(isempty(data(cnt).x))
            removeidx(end+1) = cnt;
        end
        cnt = cnt + 1;
    end
end
data(removeidx) = [];
%%
for i = 1:length(data)
    annos{i} = data(i).anno;
    xs{i} = data(i).x;
    confs{i} = data(i).x.dets(:, end);
end
%%
detbase = '~/codes/human_interaction/cache/phraselets/';
detbase = '~/codes/human_interaction/cache/new_detector/';
detbase = '~/codes/human_interaction/cache/detections_pascal';
% detbase ='~/codes/human_interaction/cache/nopascal_mix_cont/';
% detbase ='~/codes/human_interaction/cache/detections_mix_cont/';
% detbase ='~/codes/human_interaction/cache/dpmmine_mix/';
detbase='~/codes/human_interaction/cache/detections_parts_cont/';
detbase='~/codes/human_interaction/cache/human_detections';

obj = 'sofa';
objid = 1;
clear dets;
for i = 1:length(data)
    fprintf('.');
    [dataset, datafile] = fileparts(data(i).x.imfile);
    [~, dataset] = fileparts(dataset);
    try
        dets(i) = load(fullfile(fullfile(fullfile(detbase, dataset), obj), datafile), 'bbox', 'resizefactor', 'top');
    catch
        break;
    end
    % keyboard;
end
fprintf('\n');

for i = 1:length(dets)
    fprintf('.');
    bboxes = dets(i).bbox{1};
    top = dets(i).top{1};
    bboxes = bboxes(top, :);
    % bboxes(:, 2) = bboxes(:, 2) + (bboxes(:, 4) - bboxes(:, 2))/3;
    xs2{i}.dets = [objid * ones(size(bboxes, 1), 1), bboxes(:, 5), zeros(size(bboxes, 1), 1), bboxes(:, 1:4) ./ dets(i).resizefactor, bboxes(:, end)];
    confs2{i} = dets(i).bbox{1}(:, end);
end
fprintf('\n');

subplot(211); [rec, prec, ap]= evalDetection(annos, xs(1:length(xs2)), confs(1:length(xs2)), objid, 1, 0, 1);
subplot(212); [rec, prec, ap]= evalDetection(annos, xs2, confs2, objid, 1, 0, 1);
% title(obj)
return;
%%
subplot(212)
for i = 451:length(data)
    imshow(data(i).x.imfile);
    for j = 1:size(xs2{i}.dets, 1)
        if(xs2{i}.dets(j, :) > -1.0)
            bbox = xs2{i}.dets(j, 4:7);
            % bbox(2) = bbox(2)+(bbox(4)-bbox(2))/3;
            rectangle('position', bbox2rect(bbox), 'edgecolor', 'r', 'linewidth', 2);
        end
    end
    pause
end