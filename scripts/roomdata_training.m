%% load cached data
clear
addPaths;
addVarshaPaths;

files = dir('./cache/itmobs/iter3/traindata*.mat');  
datadir = './cache/itmobs/iter3';              

load('./cache/itmobs/iter3/params.mat');
params = iparams;

option = 3;
iter = 5;
if(option == 1)
	params.C = 1
	expname = 'itmobs_test1_v1_C1'
	params.model.feattype = 'itm_v1';
	params.model.itmhogs = true;
elseif(option == 2)
	params.C = 10
	expname = 'itmobs_test1_v1_C10'
	params.model.feattype = 'itm_v1';
	params.model.itmhogs = true;
elseif(option == 3)
	params.C = 100
	expname = 'itmobs_test1_v1_C100'
	params.model.feattype = 'itm_v1';
	params.model.itmhogs = true;
elseif(option == 4)
	params = initparam(3, 7);
	params.model.feattype = 'itm_v1';
	params.C = 10
	expname = 'noitm_test_v1_C10'
	params.model.itmhogs = false;
elseif(option == 5)
	params = initparam(3, 7);
	params.model.feattype = 'itm_v1';
	params.C = 100
	expname = 'noitm_test_v1_C100'
	params.model.itmhogs = false;
elseif(option == 6)
	params = initparam(3, 7);
	params.model.feattype = 'itm_v2';
	params.C = 10
	expname = 'noitm_test_v2_C10'
	params.model.itmhogs = false;
elseif(option == 7)
	params = initparam(3, 7);
	params.model.feattype = 'itm_v2';
	params.C = 100
	expname = 'noitm_test_v2_C100'
	params.model.itmhogs = false;
end

if(strcmp(params.model.feattype, 'itm_v2'))
	params.model.w_ior = zeros(7+1, 1);
end
cachedir = ['cache/' expname '/iter' num2str(iter)];
if ~exist(cachedir, 'dir')
	mkdir(cachedir);
end

%% loading data
for i = 1:length(files)                      
    temp = load(fullfile(datadir, files(i).name));
    patterns(i) = temp.pattern;
	for j = 1:length(patterns(i).isolated)
		patterns(i).isolated(j).robs = 0;
	end
    labels(i) = temp.label;
	if(isempty(params.model.itmptns))
		labels(i).lcpg = labels(i).pg;
		patterns(i).composite = [];
		patterns(i).iclusters = patterns(i).isolated;
	end
    annos(i) = temp.anno;
end
%% training
try 
    matlabpool open
end
if(params.model.itmhogs)
	% learn itm hog model ... 
	params = append_hog2itm(params, 'cache/dpm2/itm');
	% append observation confidence.
	fprintf('appending itm hog observarions ... '); tic();
	patterns = itm_observation_response(patterns, params.model);
	fprintf('done'); toc();
end

save(fullfile(cachedir, 'params'), 'iparams');

%%% DDMCMC not ready yet! rely on Greedy + MCMC for layout only
params.pmove = [0 1.0 0 0 0 0 0 0];
params.numsamples = 100;
params.quicklearn = true;
params.max_ssvm_iter = 6 + iter;

[paramsout, info] = train_ssvm_uci2(patterns, labels, annos, params, 0);
save(fullfile(cachedir, 'params'), '-append', 'paramsout', 'info');
%% testing
niter = iter;
clear patterns labels annos;

paramfile = ['cache/' expname '/iter' num2str(niter) '/params'];
loadfile = true;
%%
assert(exist('paramfile', 'var') > 0);
assert(exist('loadfile', 'var') > 0);

disp(['run testing experiment for ' paramfile]);
try
    matlabpool open
end

if(loadfile)
    % clear
    addPaths
    addVarshaPaths
    addpath ../3rdParty/ssvmqp_uci/
    addpath experimental/

    resdir = 'cvpr13data/room/test';
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
end
%% testing
load(paramfile); % './cache/itm_noobs_test/iter3/params.mat')
%%
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
            params = paramsout;
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

resdir = fileparts(paramfile);
save(fullfile(resdir, 'testres'), '-v7.3', 'res', 'conf1', 'conf2', 'summary'); 
