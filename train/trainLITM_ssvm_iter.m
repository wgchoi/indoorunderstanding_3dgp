function [params, info] = trainLITM_ssvm_iter(patterns, labels, annos, params, iter, expname, learn_itmhog_model)
if nargin < 7
    learn_itmhog_model = false;
end
addpath('../3rdParty/ssvmqp_uci/');
VERBOSE = 2;

% temporary... frequently changed format of clusters....
for i = 1:length(patterns)
    [patterns(i).isolated] = clusterInteractionTemplates(patterns(i).x, params.model);
end
%
initrand();

cachedir = ['cache/' expname '/iter' num2str(iter)];
if ~exist(cachedir, 'dir')
    mkdir(cachedir);
end

[~, ~, hit, ptnsets] = latent_completion(patterns, labels, params, true, VERBOSE);
% remove those ITM that is hit less than 5 times
%params = filterITMpatterns(params, hit, ptnsets, 10);
params = filterITMpatterns(params, hit, ptnsets, 5);

[newptns] = clusterITMpatterns2(params.model.itmptns);
params = appendITMtoParams(params, newptns);

disp(['There are ' num2str(length(params.model.itmptns)) ' number of patterns']);
% re-run latent completion for SVM train!
[patterns, labels, hit] = latent_completion(patterns, labels, params, true, VERBOSE);
if(learn_itmhog_model)
    params.model.itmhogs = true;
    % learn itm hog model ... 
    params = append_hog2itm(params, 'cache/dpm2/itm');
    % append observation confidence.
    fprintf('appending itm hog observarions ... '); tic();
    patterns = itm_observation_response(patterns, params.model);
    fprintf('done'); toc();
end
for i = 1:length(patterns)
    temp.pattern = patterns(i);
    temp.label = labels(i);
    temp.anno = annos(i);
    save(fullfile(cachedir, ['traindata' num2str(i, '%03d')]), '-struct', 'temp');
end
iparams = params;
save(fullfile(cachedir, 'params'), 'iparams', 'hit');

%%% DDMCMC not ready yet! rely on Greedy + MCMC for layout only
params.pmove = [0 1.0 0 0 0 0 0 0];
params.numsamples = 100;
params.quicklearn = true;
params.max_ssvm_iter = 6 + iter;

[paramsout, info] = train_ssvm_uci2(patterns, labels, annos, params, 0);
save(fullfile(cachedir, 'params'), '-append', 'paramsout', 'info');

params = paramsout;

end