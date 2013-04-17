function [params, info] = trainLITM_ssvm(data, params, expname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('../3rdParty/ssvmqp_uci/');
VERBOSE = 2;
maxiter = 5;

% preprocess
[patterns, labels, annos] = preprocess_train_data(data, params, VERBOSE);
%% ITM mining
% find ITM patterns
try
    temp = load('cache/itmpatterns');
    itmptns = temp.ptns;
    for i = 1:length(itmptns)
        hit1(i) = length(temp.indsets{i});
    end
catch ee
    disp(ee);
    params.minITMmatch = 15;
    [itmptns, hit1] = learn_itm_patterns(patterns, labels, params, VERBOSE);
end
% append the discovered patterns into the model
params = appendITMtoParams(params, itmptns);
params.model.feattype = 'itm_v1';
% make it more generous
for  i = 1:length(params.model.itmptns)
    params.model.itmptns(i).biases(:) = params.model.itmptns(i).numparts * 4;
end

%% LSVM learning
iter = 0;
%%
while(iter < maxiter)
    cachedir = ['cache/' expname '/iter' num2str(iter)];
    
    if ~exist(cachedir, 'dir')
        mkdir(cachedir);
    end
    
    [~, ~, hit, ptnsets] = latent_completion(patterns, labels, params, true, VERBOSE);
    % remove those ITM that is hit less than 5 times
    params = filterITMpatterns(params, hit, ptnsets, 5);
    disp(['There are ' num2str(length(params.model.itmptns)) ' number of patterns']);
    
    % re-run latent completion for SVM train!
    [patterns, labels, hit] = latent_completion(patterns, labels, params, true, VERBOSE);
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
    iter = iter + 1;    
end

end