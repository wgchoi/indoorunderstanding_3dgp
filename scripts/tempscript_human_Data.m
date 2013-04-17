% % clear
% % 
% % imbase='~/codes/human_interaction/DataCollection/MainDataset/';
% % resbase='~/codes/human_interaction/cache/';
% % annobase='~/codes/human_interaction/DataAnnotation/MainDataset/';
% % dataset='dancing';
% % %%
% % addPaths
% % addVarshaPaths
% % addpath ../3rdParty/ssvmqp_uci/
% % addpath experimental/
% % 
% % resbase = '~/codes/human_interaction/cache/data.v2';
% % datasets = dir(resbase);
% % datasets(1:2) = [];
% % 
% % cnt = 1; 
% % for d = 1:length(datasets)
% %     resdir = fullfile(resbase, datasets(d).name);
% %     files = dir(fullfile(resdir, '*.mat'));
% %     for i = 1:length(files)
% %         data(cnt) = load(fullfile(resdir, files(i).name));
% %         if(isempty(data(cnt).x))
% %             i
% %         else
% %             cnt = cnt + 1;
% %         end
% %     end
% % end
% % %%
% % params = initparam(3, 7);
% % for i = 1:length(data)
% %     [data(i).iclusters] = clusterInteractionTemplates(data(i).x, params.model);
% % end
% % %%
% % poseletbase = '~/codes/human_interaction/cache/poselet/converted/';
% % erridx = [];
% % posletmodel = load('./model/poselet_model');
% % 
% % addpath ../3rdParty/libsvm-3.12/
% % 
% % for i = 1:10:length(data)
% %     [datadir, datafile] = fileparts(data(i).x.imfile);
% %     [~, datadir] = fileparts(datadir);
% %     
% %     poselet = load(fullfile(fullfile(poseletbase, datadir), datafile));
% %     % poselet.bodies.scores(6:end) = [];
% %     % data(i).gpg.camheight = 0.01;
% %     % get camera height voting...
% %     % show2DGraph(data(i).gpg, data(i).x, data(i).iclusters);
% %     
% %     features = get_poselet_feature(poselet);
% %     [labels, p] = classify_poselet(posletmodel.model, posletmodel.DATAtrain, features);
% %     poselet.pose_prob = p;
% %     try
% %         [locs, reporjs, heights, maxh] = get_human_iprojections(data(i).x.K, data(i).x.R, poselet);
% %         poselet.pose_prob(:) = 0;
% %         [locs2, reporjs2, heights2, maxh2] = get_human_iprojections(data(i).x.K, data(i).x.R, poselet);
% %     catch ee
% %         erridx(end+1) = i;
% %         keyboard;
% %         continue;
% %     end
% % 
% %     ShowGTPolyg2(imread(data(i).x.imfile), data(i).x.lpolys(data(i).gpg.layoutidx, :), 1);
% %     for j = 1:5 % length(poselet.bodies.scores)
% %         if(poselet.bodies.scores(j) > 1)
% %             rectangle('position', poselet.torsos.rts(:, j), 'edgecolor', 'r', 'linewidth', 2);
% %             rectangle('position', poselet.bodies.rts(:, j), 'edgecolor', 'g', 'linewidth', 4);
% %             rectangle('position', reporjs(:, j), 'edgecolor', 'w', 'linewidth', 3, 'linestyle', '--');
% %             rectangle('position', reporjs2(:, j), 'edgecolor', 'm', 'linewidth', 2, 'linestyle', '--');
% %             
% %             text(reporjs(1, j), reporjs(2, j), num2str(heights(j), '%.02f'), 'backgroundcolor', 'w');
% %             text(reporjs2(1, j), reporjs2(2, j)+20, num2str(heights2(j), '%.02f'), 'backgroundcolor', 'w');
% %             
% %             if(p(j, 1) > 0.5)
% %                 text(reporjs2(1, j), reporjs2(2, j)+40, 'stand', 'backgroundcolor', 'w');
% %             else
% %                 text(reporjs2(1, j), reporjs2(2, j)+40, 'sit', 'backgroundcolor', 'w');
% %             end
% %         end
% %     end
% %     % pause;
% % end
% %% 
% for i = 1:length(data)
%     hdetidx = find(data(i).x.dets(:, 1) == 7);
%     data(i).x.dets(hdetidx, :) = [];
%     data(i).x.hobjs(hdetidx) = [];
%     assert(length(data(i).x.hobjs) == size( data(i).x.dets, 1));
%     data(i).x.sconf = zeros(1, 5);
% end
% 
% csize = 32;
% 
% tdata = data(1);
% for idx = 1:csize:length(data)
%     setsize = min(length(data) - idx + 1, csize);
%     fprintf(['processing ' num2str(idx) ' - ' num2str(idx + setsize)]);
%     
%     tdata(:) = [];
%     for i = 1:setsize
%         tdata(i) = data(idx+i-1);
%     end    
%     
%     parfor i = 1:setsize
%         fprintf('%d processing\n', i + idx - 1);
%    
%         [imdir, imname] = fileparts(tdata(i).x.imfile);
%         [~, dataset] = fileparts(imdir);
% 
%         hmnfile = [imname '.mat'];
% 
%         hmndir = fullfile(['~/codes/human_interaction/cache/' '/poselet/converted/'], dataset);
% 
%         tdata(i).x = readHuamnObservationData(tdata(i).x.imfile, fullfile(hmndir, hmnfile), tdata(i).x);
%         tdata(i).x = precomputeOverlapArea(tdata(i).x);
% 
%         [tdata(i).iclusters] = clusterInteractionTemplates(tdata(i).x, params.model);
%         tdata(i).gpg = get_GT_human_parsegraph(tdata(i).x, tdata(i).iclusters, tdata(i).anno, params.model);
% 
%         fprintf('%d done\n', idx+i-1);
%     end
%     
%     for i = 1:setsize
%         data(idx+i-1) = tdata(i);
%     end 
% end
% 
% %% 
% datadir = 'cvpr13data/human/data.v2';
% 
% files = dir(fullfile(datadir, 'data*.mat'));
% for i = 1:length(files)
%     data(i) = load(fullfile(datadir, files(i).name));
% end
%% regenerate training data
% resdir = 'cvpr13data/human/newtrain';
try
    matlabpool open 8
end

%mkdir(resdir);

params = initparam(5, 7);
csize = 32;

totalobjs = zeros(1, 7);
missingobjs = zeros(1, 7);

for idx = 1:csize:length(data)
    setsize = min(length(data) - idx + 1, csize);
    
    for i = 1:setsize
        data(idx+i-1).x.dets(:, :) = [];
        data(idx+i-1).x.hobjs(:) = [];
        tdata(i) = data(idx+i-1);
    end    
    
    objs = zeros(setsize, 7);
    mobjs = zeros(setsize, 7);
    
    parfor i = 1:setsize
        disp([num2str(i) ' proc'])
        
        [gtx, objs(i, :), mobjs(i, :)] = get_ground_truth_observations(tdata(i).x, tdata(i).anno);
        
        nobjs = length(gtx.hobjs);
        if(nobjs > 0)
            disp([num2str(i) ' add ' num2str(nobjs) ' objs'])
            
            tdata(i).x.hobjs(end+1:end+nobjs) = gtx.hobjs;
            tdata(i).x.dets(end+1:end+nobjs, :) = gtx.dets;
            tdata(i).x = precomputeOverlapArea(tdata(i).x);
        end
        tdata(i).iclusters = clusterInteractionTemplates(tdata(i).x, params.model);
        tdata(i).gpg = getGTparsegraph(tdata(i).x, tdata(i).iclusters, tdata(i).anno, params.model);
        
        disp([num2str(i) ' done'])
    end
    
    totalobjs = totalobjs + sum(objs, 1);
    missingobjs = missingobjs + sum(mobjs, 1);
    
    for i = 1:setsize
        data(idx+i-1) = tdata(i);
        % save(fullfile(resdir, ['data' num2str(idx+i-1, '%03d')]), '-struct', 'temp');
    end
end
matlabpool close

%%
clear
datadir = 'cvpr13data/human/newtrain';
files = dir(fullfile(datadir, 'data*.mat'));
for i = 1:length(files)
    data(i) = load(fullfile(datadir, files(i).name));
end

return
%% reestimate detections and gt
params = initparam(3, 7);
for i = 1:length(data)
    hidx = find(data(i).x.dets(:, 1) == 7);
    data(i).x.dets(hidx, 2) = 1;
    [a, b] = generate_object_hypotheses(data(i).x.imfile, data(i).x.K, data(i).x.R, data(i).x.yaw, objmodels(), data(i).x.dets(hidx, :), 1);
    data(i).x.hobjs(hidx) = a;
    
    data(i).iclusters = clusterInteractionTemplates(data(i).x, params.model);
	data(i).gpg = get_GT_human_parsegraph(data(i).x, data(i).iclusters, data(i).anno, params.model);
end
%% use real gt
params = initparam(3, 7);
for i = 1:length(data)
    [data(i).x, data(i).iclusters] = get_ground_truth_observations(data(i).x, data(i).anno, params.model);
    data(i).gpg = get_GT_human_parsegraph(data(i).x, data(i).iclusters, data(i).anno, params.model);
end
%%
params.model.feattype = 'itm_v1';
params.model.humancentric = 1;
params.minITMmatch = 15;

%% 
[patterns, labels, annos] = preprocess_train_data(data, params, 2);
for i = 1:length(labels)
    labels(i).pg.childs = 1:length(patterns(i).x.hobjs);
    labels(i).pg.subidx = 14 * ones(1, length(patterns(i).x.hobjs));
end

%%
[ptns, comps, indsets] = learn_itm_patterns(patterns, labels, params, 2, 'human_itm_fixed');
%%
[ps, is, cs] = filter_itms(ptns, indsets, comps, params);
save('cache/human_itm_fixed', '-append', 'ps', 'is', 'cs');
%%
try
    matlabpool open 8
catch
end

for i = 1:length(ptns)
    [itm_examples] = get_itm_examples(data, is{i}, cs{i});
    train_dpm_for_itms(itm_examples, ['human_filtered_itm' num2str(i, '%03d')]);
end

return;
%%
% for i = 1:length(data)
%     show2DGraph(data(i).gpg, data(i).x, data(i).iclusters);
%     show3DGraph(data(i).gpg, data(i).x, data(i).iclusters);
%     pause
% end
%%
params = initparam(3, 7);
params.quicklearn = true;

for i = 1:length(data)
    leo(i) = data(i).x.lerr(1);
end
leo = leo(2:2:end);
%%
params.model.feattype = 'org';
C = [1 10];
summary0 = 1:length(C);
for i = 1:length(C)
    [p0(i), iout0(i)] = train_feat_test(data(1:2:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data(2:2:end), p0(i));
    
    disp([params.model.feattype 'C' num2str(C(i))]);
    [gain, oracle_gain] = stat_testlayout(data(2:2:end), outputs);
    summary0(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
end
 
params.model.feattype = 'new';
C = [1 10];
summary1 = 1:length(C);
for i = 1:length(C)
    [p1(i), iout1(i)] = train_feat_test(data(1:2:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data(2:2:end), p1(i));
    disp([params.model.feattype 'C' num2str(C(i))]);
    [gain, oracle_gain] = stat_testlayout(data(2:2:end), outputs);
    summary1(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
end
% 
% params.model.feattype = 'new3';
% C = [1 10];
% summary2 = 1:length(C);
% for i = 1:length(C)
%     [p2(i), iout2(i)] = train_feat_test(data(1:2:end), params.model, C(i), 0);
%     
%     [outputs, ls, le] = evaluate_testlayout(data(2:2:end), p2(i));
%     disp([params.model.feattype 'C' num2str(C(i))]);
%     [gain, oracle_gain] = stat_testlayout(data(2:2:end), outputs);
%     summary2(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
% end
% summary2
% 
% params.model.feattype = 'new4';
% C = [1 10];
% summary3 = 1:length(C);
% for i = 1:length(C)
%     [p3(i), iout3(i)] = train_feat_test(data(1:2:end), params.model, C(i), 0);
%     
%     [outputs, ls, le] = evaluate_testlayout(data(2:2:end), p3(i));
%     disp([params.model.feattype 'C' num2str(C(i))]);
%     [gain, oracle_gain] = stat_testlayout(data(2:2:end), outputs);
%     summary3(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
% end
% summary3

params.model.feattype = 'new5';
C = [1 10];
summary4 = 1:length(C);
for i = 1:length(C)
    [p4(i), iout4(i)] = train_feat_test(data(1:2:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data(2:2:end), p4(i));
    disp([params.model.feattype 'C' num2str(C(i))]);
    [gain, oracle_gain] = stat_testlayout(data(2:2:end), outputs);
    summary4(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
end
% params.model.feattype = 'new6';
% C = [1 10];
% summary5 = 1:length(C);
% for i = 1:length(C)
%     [p5(i), iout5(i)] = train_feat_test(data(1:2:end), params.model, C(i), 0);
%     
%     [outputs, ls, le] = evaluate_testlayout(data(2:2:end), p5(i));
%     disp([params.model.feattype 'C' num2str(C(i))]);
%     [gain, oracle_gain] = stat_testlayout(data(2:2:end), outputs);
%     summary5(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
% end
% summary5
