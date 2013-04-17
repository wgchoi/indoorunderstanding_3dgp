function params = train_ssvm(data, params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('../3rdParty/svm-struct-matlab-1.0/');

%%%%% assume all is preprocessed
patterns = cell(length(data), 1);   % idx, x, iclusters 
labels = cell(length(data), 1);     % idx, pg
annos = cell(length(data), 1);
for i=1:length(data)
    %%% start from gt labels..
    %%% it would help making over-generated violating consts
    %%% also make it iterate less as it goes through iterations.
    disp(['prepare data ' num2str(i)])
    
    patterns{i}.idx = i;
    patterns{i}.x = data(i).x;
    patterns{i}.iclusters = data(i).iclusters;
    
    labels{i}.idx = i;
    labels{i}.pg = data(i).gpg;
%     annos{i} = data(i).anno;
    if(strcmp(params.losstype, 'exclusive'))
        labels{i}.loss = lossall(data(i).anno, patterns{i}.x, labels{i}.pg, params);
        annos{i} = data(i).anno;
    elseif(strcmp(params.losstype, 'isolation'))
        Det = data(i).x.dets(:, [4:7 1]);
        for j = 1:length(data(i).anno.obj_annos)
            anno = data(i).anno.obj_annos(j);
            GT(j, :) = [anno.x1 anno.y1 anno.x2 anno.y2 anno.objtype];
        end
        annos{i}.oloss = computeloss(Det, GT);
        labels{i}.loss = lossall(annos{i}, patterns{i}.x, labels{i}.pg, params);
    end
end
clear data;
%%%%%%%%%%%% dimension
params.model.w = getweights(params.model);
ndim = length(params.model.w);
%%%%%%%%%%%%
global g_iter
g_iter = 0;

parm.patterns = patterns ;
parm.labels = labels ;
parm.annos = annos ;
clear patterns labels annos;

parm.lossFn = @lossCB ;
parm.constraintFn  = @constraintCB;
parm.featureFn = @featureCB;
parm.dimension = ndim ;

parm.finalizeIterationFn = @finalizeIterationCB;
if isfield(params, 'filename')
    parm.resmodel = params.filename;
else
	parm.resmodel = ['./model/model_C' num2str(params.C) '.mat'];
end

if(exist(parm.resmodel, 'file'))
    delete(parm.resmodel);
end
    
% if(isfield(params, 'train_data'))
%     parm.train_data = params.train_data;
%     if(exist(params.train_data, 'file'))
%         delete(params.train_data);
%     end
% end

parm.verbose = 0;
parm.params = params ;

parm.last_ceps = 1e10;

tic;
model = svm_struct_learn([' -c ' num2str(params.C) ' -o 2 -v 1 -w ' num2str(params.joint_op) ' -e .01 '], parm) ;

params.model = getmodelparam(parm.params.model, model.w);

end

function [ret]=finalizeIterationCB(param, model, ceps)
global g_iter
n_iter = g_iter;
toc;

disp(['ssvm : ceps ' num2str(ceps)]);

ret = 0.0;
if(abs(param.last_ceps - ceps) < 1e-5)
	ret = 1.0;
	return;
end
param.last_ceps = ceps;

params = param.params;
params.model = getmodelparam(params.model, model.w);

%% evaluate loss for all examples
allloss = 0;
% for i = 1:length(param.patterns)
%     x = param.patterns{i};
%     init.pg = param.labels{i}.pg;
%     [spg, maxidx] = DDMCMCinference(x.x, x.iclusters, params, init);
%     allloss = allloss + lossall(param.annos{i}, x.x, spg(maxidx));
% end
model.w'
%% save info
if(isfield(param, 'resmodel'))
	if(exist(param.resmodel, 'file'))
		data = load(param.resmodel, 'params', 'ceps', 'n_iter', 'allloss');
		data.params(end+1) = params;
        data.ceps(end+1) = ceps;
        data.n_iter(end+1) = n_iter;
        data.allloss(end+1) = allloss;
		save(param.resmodel, '-struct', 'data');
	else
		save(param.resmodel, 'params', 'ceps', 'n_iter', 'allloss');
	end
	pause(0.5);
end
g_iter = g_iter + 1;
tic;

end

function delta = lossCB(param, y, ybar)
delta = lossall(param.annos{y.idx}, param.patterns{y.idx}.x, ybar.pg, param.params) ...
        - lossall(param.annos{y.idx}, param.patterns{y.idx}.x, y.pg, param.params);
% delta = loss_class(y.label, ybar.label, param.params);
% disp([num2str(length(y.label.inodes)) ' => ' num2str(delta)])
end

function psi = featureCB(param, x, y)
% psi should be an N dimensional column vector
psi = sparse(features(y.pg, x.x, x.iclusters, param.params.model));
% psi
end

function yhat = constraintCB(param, model, x, y)

params = param.params;
params.model = getmodelparam(params.model, model.w);

% init.pg = y.pg;
% [spg, maxidx] = DDMCMCinference(x.x, x.iclusters, params, init, param.annos{y.idx});
if(strcmp(params.inference, 'mcmc'))
    init.pg = y.pg;
    [spg, maxidx] = DDMCMCinference(x.x, x.iclusters, params, init, param.annos{y.idx});
elseif(strcmp(params.inference, 'greedy'))
    initpg = y.pg;
    [spg] = GreedyInference(x.x, x.iclusters, params, initpg, param.annos{y.idx});
    maxidx = 1;
elseif(strcmp(params.inference, 'combined'))
    init.pg = y.pg;
    [init.pg] = GreedyInference(x.x, x.iclusters, params, init.pg, param.annos{y.idx});
    [spg, maxidx] = DDMCMCinference(x.x, x.iclusters, params, init, param.annos{y.idx});
else
    assert(0);
end

yhat = y;
yhat.pg = spg(maxidx);
% 
% param.params = get_model_param(model.w, param.params);
% 
% x.label = y.label;
% x = bp_inference(x, param.params, true, false);
% yhat.label = get_labels(x);
% yhat.feats = get_cifeats(x);

end
