%% train
clear

addPaths
addVarshaPaths
addpath ../3rdParty/ssvmqp_uci/
addpath experimental/
matlabpool open 8

%%
load ./filtereddata/validfiles
resbase='../Data_Collection/cache';
% datadir = 'data';
datadir = 'data.v2';

datasets = {'bedroom' 'livingroom' 'diningroom'};
cnt = 1;
for i = 1:length(datasets)
    files = dir(fullfile(fullfile(fullfile(resbase, datadir), datasets{i}), '*.mat'));
    for j = 1:length(files)
        temp = load(fullfile(fullfile(fullfile(resbase, datadir), datasets{i}), files(j).name));
        if ~isempty(temp.x) && inlist(validfiles, temp.x.imfile)
            data(cnt) = temp;
            cnt = cnt + 1;
        end
    end
end
%%
params = initparam(3, 7);
params.quicklearn = true;
%%
parfor i = 1:length(data)
    try
        [data(i).x.hobjs, invalid_idx] = generate_object_hypotheses(data(i).x.imfile, data(i).x.K, data(i).x.R, data(i).x.yaw, objmodels(), data(i).x.dets);
        if(~isempty(invalid_idx))
            disp([num2str(i) ': remove ' num2str(length(invalid_idx)) ' detections']);
            disp(data(i).x.dets(invalid_idx, :));
        end
        data(i).x = filter_objects(data(i).x, invalid_idx);
    catch
        disp(['error in ' num2str(i)]);
        assert(0);
    end
    data(i).iclusters = clusterInteractionTemplates(data(i).x, params.model);
    data(i).gpg = getGTparsegraph(data(i).x, data(i).iclusters, data(i).anno, params.model);
end
%% use real gt
for i = 1:length(data)
    [data(i).x, data(i).iclusters] = get_ground_truth_observations(data(i).x, data(i).anno, params.model);
    data(i).gpg = get_GT_human_parsegraph(data(i).x, data(i).iclusters, data(i).anno, params.model);
end
%%
% params.model.feattype = 'org';
for i = 1:length(data)
    leo(i) = data(i).x.lerr(1);
end
%% 
params.model.feattype = 'org';
C = [1 10];
summary0 = 1:length(C);
for i = 1:length(C)
    [p0(i), iout0(i)] = train_feat_test(data(1:3:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data, p0(i));
    disp([params.model.feattype 'C' num2str(C(i))]);
    [gain, oracle_gain] = stat_testlayout(data, outputs);
    summary0(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
    
%     show_testlayout(data, outputs, le, 0, ['experimental/org_C' num2str(C(i))]);
%     show_testlayout(data, outputs, le, 1, ['experimental/org_C' num2str(C(i))]);
end
%% 
params.model.feattype = 'new';
C = [1 10];
summary1 = 1:length(C);
for i = 1:length(C)
    [p1(i), iout1(i)] = train_feat_test(data(1:3:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data, p1(i));
    disp([params.model.feattype 'C' num2str(C(i))]);
    [gain, oracle_gain] = stat_testlayout(data, outputs);
    summary1(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
    
    % show_testlayout(data, outputs, le, 0, ['experimental/new_C' num2str(C(i))]);
    % show_testlayout(data, outputs, le, 1, ['experimental/new_C' num2str(C(i))]);
end
% %% 
% params.model.feattype = 'new3';
% C = [1 10];
% summary2 = 1:length(C);
% for i = 1:length(C)
%     [p2(i), iout2(i)] = train_feat_test(data(1:3:end), params.model, C(i), 0);
%     
%     [outputs, ls, le] = evaluate_testlayout(data, p2(i));
%     disp([params.model.feattype 'C' num2str(C(i))]);
%     [gain, oracle_gain] = stat_testlayout(data, outputs);
%     summary2(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
% %     show_testlayout(data, outputs, le, 0, ['experimental/new3_C' num2str(C(i))]);
% %     show_testlayout(data, outputs, le, 1, ['experimental/new3_C' num2str(C(i))]);
% end
% summary2
% %% 
% params.model.feattype = 'new4';
% C = [1 10];
% summary3 = 1:length(C);
% for i = 1:length(C)
%     [p3(i), iout3(i)] = train_feat_test(data(1:3:end), params.model, C(i), 0);
%     
%     [outputs, ls, le] = evaluate_testlayout(data, p3(i));
%     disp([params.model.feattype 'C' num2str(C(i))]);
%     [gain, oracle_gain] = stat_testlayout(data, outputs);
%     summary3(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
% %     show_testlayout(data, outputs, le, 0, ['experimental/new4_C' num2str(C(i))]);
% %     show_testlayout(data, outputs, le, 1, ['experimental/new4_C' num2str(C(i))]);
% end
% summary3
% %% 
params.model.feattype = 'new5';
C = [1 10];
summary4 = 1:length(C);
for i = 1:length(C)
    [p4(i), iout4(i)] = train_feat_test(data(1:3:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data, p4(i));
    disp([params.model.feattype 'C' num2str(C(i))]);
    [gain, oracle_gain] = stat_testlayout(data, outputs);
    summary4(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
    
%     show_testlayout(data, outputs, le, 0, ['experimental/new5_C' num2str(C(i))]);
%     show_testlayout(data, outputs, le, 1, ['experimental/new5_C' num2str(C(i))]);
end

%% 
params.model.feattype = 'new6';
C = [1 10];
summary5 = 1:length(C);
for i = 1:length(C)
    [p5(i), iout5(i)] = train_feat_test(data(1:3:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data, p5(i));
    disp([params.model.feattype 'C' num2str(C(i))]);
    [gain, oracle_gain] = stat_testlayout(data, outputs);
    summary5(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
%     show_testlayout(data, outputs, le, 0, ['experimental/new4_C' num2str(C(i))]);
%     show_testlayout(data, outputs, le, 1, ['experimental/new4_C' num2str(C(i))]);
end
summary5