clear

resbase = '~/codes/human_interaction/cache/data.v2';
datasets = dir(resbase);
datasets(1:2) = [];
detbase = '~/codes/human_interaction/cache/detections_v5';
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
load ./cvpr13data/human/fulltrainfiles.mat
for i = 1:length(patterns)
    data(i).x = patterns(i).x;
end
clear patterns labels annos
%%
for i = 1:length(data)
    annos{i} = data(i).anno;
    xs{i} = data(i).x;
    confs{i} = data(i).x.dets(:, end);
end
%%
clear dets;

obj = 'diningtable';
objid = 5;
for i = 1:length(data)
    [dataset, datafile] = fileparts(data(i).x.imfile);
    [~, dataset] = fileparts(dataset);
    
    dets(i) = load(fullfile(fullfile(fullfile(detbase, dataset), obj), datafile));
end

for i = 1:length(dets)
    xs2{i}.dets = [objid * ones(size(dets(i).ds, 1), 1) ones(size(dets(i).ds, 1), 1) zeros(size(dets(i).ds, 1), 1) dets(i).ds];
    confs2{i} = dets(i).ds(:, end);
end
subplot(211); [rec, prec, ap]= evalDetection(annos, xs(1:length(xs2)), confs(1:length(xs2)), objid, 1, 0, 1);
subplot(212); [rec, prec, ap]= evalDetection(annos, xs2, confs2, objid, 1, 0, 1);