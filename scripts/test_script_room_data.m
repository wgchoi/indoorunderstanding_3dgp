clear
addPaths
addVarshaPaths

try
    matlabpool open
end
load('./cvpr13data/room/fulltrainset.mat');

%for i = 1:length(patterns)
%	patterns(i).x.lloss = 5 .* patterns(i).x.lloss;
%end

expname = 'noitm_itmv2_nogeo';
niter = 5;
params = initparam(3, 7);
params.model.feattype = 'itm_v2';
params.model.w_ior = zeros(7+1, 1);
params.model.ignore_geometry = 1;
% load ./cache/itmobs_iter2_params.mat

%expname = 'itmobs_itmv2';
%niter = 15;
%params = appendITMtoParams(paramsout, paramsout.model.itmptns);
%params.model.feattype = 'itm_v2';
%params.model.w_ior = zeros(7+1, 1);

disp(['train: '  expname ]);
[params, info] = trainLITM_ssvm_iter(patterns, labels, annos, params, niter, expname, true);

%% testing
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
%%
if(loadfile)
    % clear
    addPaths
    addVarshaPaths
    addpath ../3rdParty/ssvmqp_uci/
    addpath experimental/

    resdir = 'cvpr13data/test';
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
conf3 = cell(1, length(data));

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
    tconf3 = cell(1, setsize);
    
    terroridx = false(1, setsize);
    parfor i = 1:setsize
        try
            params = paramsout;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            params.quicklearn = 100; % tempcode!!!!!
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            pg = findConsistent3DObjects(tdata(i).gpg, tdata(i).x, tdata(i).iclusters, true);
            pg.layoutidx = 1; % initialization
            
            
            [tdata(i).iclusters] = clusterInteractionTemplates(tdata(i).x, params.model);
            [tempres{i}.spg, tempres{i}.maxidx, tempres{i}.h, tempres{i}.clusters] = infer_top(tdata(i).x, tdata(i).iclusters, params, pg);

            params.objconftype = 'odd';
            [tconf1{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);
            params.objconftype = 'orgdet';
            [tconf2{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            params.objconftype = 'odd2';
            [tconf3{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);
            tempres{i}.clusters = [];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
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
        conf3{idx+i-1} = tconf3{i};
    end
    fprintf(' => done\n')
end
summary = evalAllResults(xs, annos, conf2, conf1, res);

keyboard;

resdir = fileparts(paramfile);
save(fullfile(resdir, 'testres'), '-v7.3', 'res', 'conf1', 'conf2', 'summary'); 
