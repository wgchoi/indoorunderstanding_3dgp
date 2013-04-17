clear
%% preprocessing all data.. 
addPaths
addVarshaPaths

imbase = '~/codes/eccv_indoor/Data_Collection/';
resbase = '~/codes/eccv_indoor/Data_Collection/cache/';
annobase = '~/codes/eccv_indoor/Annotation/';

datasets = {'bedroom' 'livingroom' 'diningroom'};
for i = 1:length(datasets)
    preprocess_data(imbase, resbase, annobase, datasets{i}, 0);
end
% resdir = 'cvpr13data/data.v2';
%% read all data - obsolete
addPaths
addVarshaPaths
addpath ../3rdParty/ssvmqp_uci/
addpath experimental/

resdir = 'cvpr13data/data.v2.bk';

expinfo = load(fullfile('cvpr13data/', 'info'));

cnt = 1; 
files = dir(fullfile(resdir, '*.mat'));

trainfiles = [];
testfiles = [];

for i = expinfo.trainfiles % 1:length(files)
    data(cnt) = load(fullfile(resdir, files(i).name));
    if(isempty(data(cnt).x))
        i
    else
        cnt = cnt + 1;
    end
end
%% regenerate training data
resdir = 'cvpr13data/train';
try
    matlabpool open 8
end

params = initparam(3, 7);
csize = 16;
for idx = 1:csize:length(data)
    setsize = min(length(data) - idx + 1, csize);
    
    for i = 1:setsize
        tdata(i) = data(idx+i-1);
    end    
    
    parfor i = 1:setsize
        disp([num2str(i) ' proc'])
        [hobjs, inv_list] = generate_object_hypotheses(tdata(i).x.imfile, tdata(i).x.K, tdata(i).x.R, tdata(i).x.yaw, objmodels(), tdata(i).x.dets, 0);
        assert(isempty(inv_list));
        tdata(i).x.hobjs = hobjs;

        [gtx] = get_ground_truth_observations(tdata(i).x, tdata(i).anno);

        nobjs = length(gtx.hobjs);
        if(nobjs > 0)
            disp([num2str(i) ' add ' num2str(nobjs) ' objs'])
            
            tdata(i).x.hobjs(end+1:end+nobjs) = gtx.hobjs;
            tdata(i).x.dets(end+1:end+nobjs, :) = gtx.dets;
            tdata(i).x = precomputeOverlapArea(tdata(i).x);
        end
        tdata(i).iclusters = clusterInteractionTemplates(tdata(i).x, params.model);
        tdata(i).gpg = getGTparsegraph(tdata(i).x, tdata(i).iclusters, tdata(i).anno, params.model);
        
        % scene classification
        tdata(i).x = sceneClassify(tdata(i).x);
        [~, dataset] = fileparts(fileparts(tdata(i).x.imfile));
        if(strcmp(dataset, 'bedroom'))
            tdata(i).anno.scenetype = 1;
            tdata(i).gpg.scenetype = 1;
        elseif(strcmp(dataset, 'livingroom'))
            tdata(i).anno.scenetype = 2;
            tdata(i).gpg.scenetype = 2;
        elseif(strcmp(dataset, 'diningroom'))
            tdata(i).anno.scenetype = 3;
            tdata(i).gpg.scenetype = 3;
        else
            disp(dataset);
            assert(0);
        end
        disp([num2str(i) ' done'])
    end
    
    for i = 1:setsize
        temp = tdata(i);
        save(fullfile(resdir, ['data' num2str(idx+i-1, '%03d')]), '-struct', 'temp');
    end
end
matlabpool close
%% load train data
clear data

resdir = 'cvpr13data/train';
cnt = 1; 
files = dir(fullfile(resdir, '*.mat'));

trainfiles = [];
for i = 1:length(files)
    data(cnt) = load(fullfile(resdir, files(i).name));
    if(isempty(data(cnt).x))
        i
    else
        cnt = cnt + 1;
    end
end
%% use real gt (only for ITM generation)
params = initparam(3, 7);
for i = 1:length(data)
    data(i).x.hobjs(:) = [];
    data(i).x.dets(:) = [];
    [gtx] = get_ground_truth_observations(data(i).x, data(i).anno);
    data(i).x.hobjs = gtx.hobjs;
    data(i).x.dets = gtx.dets;
    data(i).x = precomputeOverlapArea(data(i).x);
    
    data(i).iclusters = clusterInteractionTemplates(data(i).x, params.model);
    data(i).gpg = get_GT_human_parsegraph(data(i).x, data(i).iclusters, data(i).anno, params.model);
end
%%
params = initparam(3, 7);
params.model.feattype = 'itm_v1';
params.model.feattype = 'itm_v2';
params.model.w_ior = zeros(7+1, 1);
params.minITMmatch = 15;
%% preprocessing training data
[patterns, labels, annos] = preprocess_train_data(data, params, 2);
% for i = 1:length(labels)
%     labels(i).pg.childs = 1:length(patterns(i).x.hobjs);
%     labels(i).pg.subidx = 14 * ones(1, length(patterns(i).x.hobjs));
% end
%% learn ITM patterns
[ptns, comps, indsets] = learn_itm_patterns(patterns, labels, params, 2, 'room_itm_fixed');
% if human use itm-filtering 
%% train DPM for ITMs
for i = 1:length(data)
    imlist{i} = fullfile(pwd(), data(i).x.imfile);
end
matlabpool open 4
for i = 1:length(ptns)
    [itm_examples] = get_itm_examples(data, indsets{i}, comps{i});
    train_dpm_for_itms(itm_examples, ['room_itm' num2str(i, '%03d')], imlist);
end
matlabpool close
%% process images with trained DPM detector
[data, ptns] = process_ITM_detector(data, dpm_prefix, ptns, 'cache/itm/room/');
%% append ITM detections
data = append_ITM_detections(data, ptns, 'cache/itm/room/', expinfo.trainfiles);
%% add scene classification
parfor i = 1:length(data)
    data(i).x = sceneClassify(data(i).x);
    [~, dataset] = fileparts(fileparts(data(i).x.imfile));
    if(strcmp(dataset, 'bedroom'))
        data(i).anno.scenetype = 1;
        data(i).gpg.scenetype = 1;
    elseif(strcmp(dataset, 'livingroom'))
        data(i).anno.scenetype = 2;
        data(i).gpg.scenetype = 2;
    elseif(strcmp(dataset, 'diningroom'))
        data(i).anno.scenetype = 3;
        data(i).gpg.scenetype = 3;
    else
        disp(dataset);
        assert(0);
    end
    disp(['done ' num2str(i)]);
end
%% start model paramter learning
params = initparam(3, 7);
load('/home/wgchoi/codes/eccv_indoor/IndoorLayoutUnderstanding/cache/room_itm_fixed.mat');
params = appendITMtoParams(params, ptns);
params.model.feattype = 'itm_v1';
% make it more generous
for  i = 1:length(params.model.itmptns)
    params.model.itmptns(i).biases(:) = params.model.itmptns(i).numparts * 4;
end
%% preprocessing training data
[patterns, labels, annos] = preprocess_train_data(data, params, 2);
clear data;
