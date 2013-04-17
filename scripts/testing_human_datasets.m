%%
clear
datadir = 'cvpr13data/human/temptrain_all';
datadir = 'cvpr13data/human/finalsets/train/';
datadir = 'cvpr13data/human/finalsets/test/';
%%
files = dir(fullfile(datadir, 'data*.mat'));
cnt = 1;
for i = 1:length(files)
    data(cnt) = load(fullfile(datadir, files(i).name));
    cnt=cnt+1;
end
% for i = 1:20:820 % length(files)
%     data(i) = load(fullfile(datadir, files(i).name));
% end

% addPaths
% addVarshaPaths
% addpath ../3rdParty/ssvmqp_uci/
% addpath experimental/
% 
% resbase = '~/codes/human_interaction/cache/additional/data.v2';
% datasets = dir(resbase);
% datasets(1:2) = [];
% 
% cnt = length(data)+1; 
% for d = 1:length(datasets)
%     resdir = fullfile(resbase, datasets(d).name);
%     files = dir(fullfile(resdir, '*.mat'));
%     for i = 1:length(files)
%         data(cnt) = load(fullfile(resdir, files(i).name));
%         if(isempty(data(cnt).x))
%             i
%         else
%             cnt = cnt + 1;
%         end
%     end
% end

%%
for i = 1:length(data)
    dname = fileparts(data(i).x.imfile);
    [~, dname] = fileparts(dname);
    if strcmp(dname, 'dancing')
        keep(i) = true;
        data(i).gpg.scenetype = 1;
        data(i).anno.scenetype = 1;
    elseif strcmp(dname, 'having_dinner')
        keep(i) = true;
        data(i).gpg.scenetype = 2;
        data(i).anno.scenetype = 2;
    elseif strcmp(dname, 'talking')
        keep(i) = true;
        data(i).gpg.scenetype = 3;
        data(i).anno.scenetype = 3;
    elseif strcmp(dname, 'washing_dishes')
        keep(i) = true;
        data(i).gpg.scenetype = 4;
        data(i).anno.scenetype = 4;
    elseif strcmp(dname, 'watching_tv')
        keep(i) = true;
        data(i).gpg.scenetype = 5;
        data(i).anno.scenetype = 5;
    else
        keep(i) = false;
    end
end
data = data(keep);
%%
params = initparam(5, 7);
params.ignorescene = true;
params.model.feattype = 'itm_v2';
params.model.w_ior = zeros(8, 1);

poseletbase = '~/codes/human_interaction/cache/poselet/converted/';
for i = 1:length(data)
    disp(i);
    hidx = find(data(i).x.dets(:, 1) == 7);
    data(i).x.dets(hidx, :) = [];
    temp = [data(i).x.hobjs(:).oid];
    hidx = find(temp == 7);
    data(i).x.hobjs(hidx) = [];
    
    [datadir, datafile] = fileparts(data(i).x.imfile);
    [~, datadir] = fileparts(datadir);
    poselet = load(fullfile(fullfile(poseletbase, datadir), datafile));
    
    hdets = get_human_iprojections_2(poselet);
    [hhmns, invalid_idx] = generate_object_hypotheses(data(i).x.imfile, data(i).x.K, data(i).x.R, data(i).x.yaw, objmodels(), hdets, 1);
    hdets(invalid_idx, :) = [];
    hhmns(invalid_idx) = [];
    
    data(i).x.hobjs(end+1:end+length(hhmns)) = hhmns;
    data(i).x.dets = [data(i).x.dets; hdets];
    
    data(i).x = precomputeOverlapArea(data(i).x);

    data(i).iclusters = clusterInteractionTemplates(data(i).x, params.model);
    data(i).gpg = get_GT_human_parsegraph(data(i).x, data(i).iclusters, data(i).anno, params.model);
    
    data(i).gpg.scenetype = data(i).anno.scenetype;
end
%% converting scores... simulated scores...
for i = 1:length(data)
%     data(i).x = data(i).x;
    % sofa
    data(i).x = simulate_better_detector(data(i).x, data(i).anno, 1, 1.7, 0.4, -1.25);
    % table
    data(i).x = simulate_better_detector(data(i).x, data(i).anno, 2, 1.7, 0.4, -1.25);
    % chair
    data(i).x = simulate_better_detector(data(i).x, data(i).anno, 3, 1.2, 0.1, -1.25);
    % dtable 
    data(i).x = simulate_better_detector(data(i).x, data(i).anno, 5, 1.2, 0.1, -1.25);
end
%%
clear xs confs annos
for i = 1:length(data)
    annos{i} = data(i).anno;
    xs{i} = data(i).x;
    confs{i} = data(i).x.dets(:, end);
    % confs2{i} = data(i).x2.dets(:, end);
end
%%
objid = 5;
subplot(211); [rec, prec, ap]= evalDetection(annos, xs, confs, objid, 1, 0, 1); drawnow();
subplot(212); [rec, prec, ap]= evalDetection(annos, xs, confs2, objid, 1, 0, 1); drawnow();
%%
clear patterns labels annos data;
load('/home/wgchoi/codes/eccv_indoor/IndoorLayoutUnderstanding/cvpr13data/human/fulltrainfiles.mat')
for i = 1:length(annos)
    if(annos(i).scenetype == 1 || annos(i).scenetype == 5)
        keep(i) = true;
    else
        keep(i) = false;
    end
end
%% remove other objects for experiment
patterns = patterns(keep);
annos= annos(keep);
labels= labels(keep);
for i = 1:length(patterns)
    objidx = find(patterns(i).x.dets(:, 1) < 7);
    patterns(i).x.dets(objidx, :) = [];
    patterns(i).x.hobjs(objidx) = [];
    patterns(i).x.orarea(objidx, :) = []; patterns(i).x.orarea(:, objidx) = [];
    patterns(i).x.orpolys(objidx, :) = []; patterns(i).x.orpolys(:, objidx) = [];
    annos(i).oloss(objidx, :) = [];
    labels(i).pg.childs = find(annos(i).oloss(:, 2));
    labels(i).pg = findConsistent3DObjects(labels(i).pg, patterns(i).x, patterns(i).isolated);
end

%%
[patterns, labels, annos] = preprocess_train_data(data, params, 2);
%%
params = initparam(5, 7);
params.ignorescene = true;
%params.model.feattype = 'itm_v2';
params.model.feattype = 'itm_v3';
params.model.w_iso = zeros(5*(7+1), 1);
params.model.w_ior = zeros(8, 1);
if(1)
    itms = load('cache/human_itm_fixed.mat');
    params = appendITMtoParams(params, itms.ps);
    params.ignorefarobj = true;
    params.model.humancentric = true;
end
%%
paramfile = 'cache/simulitm_v3_handpick/iter5/params.mat';
[params, info] = trainLITM_ssvm_iter(patterns, labels, annos, params, 5, 'simulitm_v3_handpick', false);
%%
clear patterns labels annos data;
datadir = 'cvpr13data/human/temptrain';

cnt = 1;
files = dir(fullfile(datadir, 'data*.mat'));
for i = 1:length(files)
    temp = load(fullfile(datadir, files(i).name));
    if(isempty(temp.x))
        continue;
    end
    dname = fileparts(temp.x.imfile);
    [~, dname] = fileparts(dname);
    
    if(strcmp(dname, 'dancing') || strcmp(dname, 'washing_dishes'))
        data(cnt) = temp;
        cnt = cnt + 1;
    end
end
%%
for i = 1:length(data)
    objidx = find(data(i).x.dets(:, 1) < 7);
    data(i).x.dets(objidx, :) = [];
    data(i).x.hobjs(objidx) = [];
    data(i).x.orarea(objidx, :) = []; data(i).x.orarea(:, objidx) = [];
    data(i).x.orpolys(objidx, :) = []; data(i).x.orpolys(:, objidx) = [];
    data(i).iclusters = clusterInteractionTemplates(data(i).x, params.model);

    data(i).gpg = getGTparsegraph(data(i).x, data(i).iclusters, data(i).anno, params.model);
end

paramsout=params;
%%
load(paramfile);
% res = struct('spg', cell(length(data), 1), 'maxidx', [], 'h', []);
paramsout.numsamples = 1000;
paramsout.pmove = [0 0.4 0 0.3 0.3 0 0 0];
paramsout.accconst = 3;

res = cell(1, length(data));
annos = cell(1, length(data));
xs = cell(1, length(data));
conf1 = cell(1, length(data));
conf2 = cell(1, length(data));

erroridx = false(1, length(data));
csize = 32;

tdata = data(1);
for idx = 1:csize:length(data)
    setsize = min(length(data) - idx + 1, csize);
    fprintf(['processing ' num2str(idx) ' - ' num2str(idx + setsize)]);
    
    tdata(:) = [];
    for i = 1:setsize
        tdata(i) = data(idx+i-1);
    end    
    tempres = cell(1, setsize);
    tconf1 = cell(1, setsize);
    tconf2 = cell(1, setsize);
    
    terroridx = false(1, setsize);
    parfor i = 1:setsize
        try
            params=paramsout;
            pg = findConsistent3DObjects(tdata(i).gpg, tdata(i).x, tdata(i).iclusters, true);
            pg.layoutidx = 1; % initialization
            
            
            [tdata(i).iclusters] = clusterInteractionTemplates(tdata(i).x, params.model);
            [tempres{i}.spg, tempres{i}.maxidx, tempres{i}.h, tempres{i}.clusters] = infer_top(tdata(i).x, tdata(i).iclusters, params, pg);

            params.objconftype = 'odd';
            [tconf1{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);
            params.objconftype = 'orgdet';
            [tconf2{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);

            fprintf('+');
        catch
            fprintf('-');
            terroridx(i) = true;
        end
    end
    erroridx(idx:idx+setsize-1) = terroridx;
    
    for i = 1:setsize
        res{idx+i-1} = tempres{i};
        annos{idx+i-1} = tdata(i).anno;
        xs{idx+i-1} = tdata(i).x;
        conf1{idx+i-1} = tconf1{i};
        conf2{idx+i-1} = tconf2{i};
    end
    fprintf(' => done\n')
end
summary = evalAllResults(xs, annos, conf2, conf1, res);
%%
resdir = fileparts(paramfile);
save(fullfile(resdir, 'testres'), '-v7.3', 'res', 'conf1', 'conf2', 'summary'); 
%% train/test splits...
for i = 1:length(data)
    sceneidx(i) = data(i).anno.scenetype;
end
%% split testing
% trainset = [];
% testset = [];
% for i = 1:5
%     dataidx = find(sceneidx == i);
%     rnums=randperm(length(dataidx));
%     trainset = [trainset; dataidx(rnums(1:100))'];
% end
% testset = setdiff(1:length(data), trainset);
% mean(summary.layout.reest(testset))
% mean(summary.layout.baseline(testset))
% mean(summary.layout.baseline(testset)) - mean(summary.layout.reest(testset))
%% testfile
% for i = 1:length(tdata)
%     idx = find(tdata(i).x.dets(:, 1) < 7);
%     gtadded = find(tdata(i).x.dets(idx, end) == -1.25);
%     tdata(i).x.dets(idx(gtadded), :) = [];
%     tdata(i).x.hobjs(idx(gtadded)) = [];
%     
%     idx = find(tdata(i).x.dets(:, 1) == 7);
%     gtadded = find(tdata(i).x.dets(idx, end) == -1.5);
%     disp([num2str(i) ':' num2str(length(gtadded))]);
%     tdata(i).x.dets(idx(gtadded), :) = [];
%     tdata(i).x.hobjs(idx(gtadded)) = [];
%     
%     assert(length(tdata(i).x.hobjs) == size(tdata(i).x.dets, 1));
% end
% %%
% parfor i = 1:length(tdata)
%     disp(i);
%     tdata(i).x = precomputeOverlapArea(tdata(i).x);
%     tdata(i).iclusters = clusterInteractionTemplates(tdata(i).x, params.model);
%     tdata(i).gpg = get_GT_human_parsegraph(tdata(i).x, tdata(i).iclusters, tdata(i).anno, params.model);
% end