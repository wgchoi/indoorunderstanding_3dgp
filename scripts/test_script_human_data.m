%%
clear
addPaths
datadir = 'cvpr13data/human/finalsets/train/';
%%
files = dir(fullfile(datadir, 'data*.mat'));
cnt = 1;
for i = 1:length(files)
    data(cnt) = load(fullfile(datadir, files(i).name));
    cnt=cnt+1;
end
%% converting scores for training ... simulated scores... not reliable detection scores
for i = 1:length(data)
%     data(i).x = data(i).x;
    % sofa
    % test 1
    data(i).x = simulate_better_detector(data(i).x, data(i).anno, 1, 1.7, 0.4, -1.25);
%     data(i).x = simulate_better_detector(data(i).x, data(i).anno, 1, 1.2, 0.1, -1.25); % test 2
    % table
    % test 1
    data(i).x = simulate_better_detector(data(i).x, data(i).anno, 2, 1.7, 0.4, -1.25);
%     data(i).x = simulate_better_detector(data(i).x, data(i).anno, 2, 1.2, 0.1, -1.25); % test 2
    % chair
    data(i).x = simulate_better_detector(data(i).x, data(i).anno, 3, 1.2, 0.1, -1.25);
    % dtable 
    data(i).x = simulate_better_detector(data(i).x, data(i).anno, 5, 1.2, 0.1, -1.25);
end
%% append scene classification!

%%
params = initparam(5, 7);
params.ignorescene = true;
%params.model.feattype = 'itm_v2';
params.model.feattype = 'itm_v3';
params.model.w_iso = zeros(5*(7+1), 1);
params.model.w_ior = zeros(8, 1);
if(1)
    itms = load('cache/human_itm_fixed.mat');
    if(1)
        for i = 1:length(itms.ps)
            ptn(i) = set_reference_object(itms.ps(i));
            ptn(i) = reestimateITM(ptn(i), itms.cs{i});
        end
        % [ptn] = clusterITMpatterns2(ptn);
        params = appendITMtoParams(params, ptn([6 22]));
    else
        params = appendITMtoParams(params, itms.ps);
    end
    params.ignorefarobj = true;
    params.model.humancentric = true;
    params.model.itmoneviewpoint = true;
	params.use_itm_det = false;
end
%%
[patterns, labels, annos] = preprocess_train_data(data, params, 2);
clear data

if(isfield(params, 'use_itm_det') && params.use_itm_det)
	patterns = append_ITM_detections(patterns, params.model.itmptns, 'cache/itmdets_human', 'cache/dpm_parts_human');
end
expname = 'human_itm_oneview_refobj_picked6_22';
iter = 1;
%%
try
	matlabpool open 8
end
[params, info] = trainLITM_ssvm_iter(patterns, labels, annos, params, 1, expname, false);
paramfile = ['cache/' expname '/iter' num2str(iter) '/params.mat'];
%%
clear patterns annos labels
datadir = 'cvpr13data/human/finalsets/test/';

files = dir(fullfile(datadir, 'data*.mat'));
cnt = 1;
for i = 1:length(files)
    data(cnt) = load(fullfile(datadir, files(i).name));
    cnt=cnt+1;
end

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
<<<<<<< HEAD

if(isfield(params, 'use_itm_det') && params.use_itm_det)
	data = append_ITM_detections(data, params.model.itmptns, 'cache/itmdets_human', 'cache/dpm_parts_human');
end
%%
for kkk = iter
    paramfile = ['cache/' expname '/iter' num2str(kkk) '/params.mat'];

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

    paramsout.model

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
        %par
        for i = 1:setsize
            try
                params=paramsout;
                pg = findConsistent3DObjects(tdata(i).gpg, tdata(i).x, tdata(i).iclusters, true);
                pg.layoutidx = 1; % initialization


                [tdata(i).iclusters] = clusterInteractionTemplates(tdata(i).x, params.model);
                [tempres{i}.spg, tempres{i}.maxidx, tempres{i}.h, tempres{i}.clusters] = infer_top(tdata(i).x, tdata(i).iclusters, params, pg);
                if(any(tempres{i}.spg(2).childs > length(tdata(i).iclusters)))
                    disp('itm found!');
                end

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
=======
%%
paramfile = ['cache/human_itm_allview_refobj_picked6_22/iter' num2str(2) '/params.mat'];
load(paramfile);
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

paramsout.model

tdata = data(1);
%par
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
            if(any(tempres{i}.spg(2).childs > length(tdata(i).iclusters)))
                disp('itm found!');
            end

            params.objconftype = 'odd';
            [tconf1{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);
            params.objconftype = 'orgdet';
            [tconf2{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);

            fprintf('+');
        catch
            fprintf('-');
            terroridx(i) = true;
>>>>>>> d1fde5ba1ab20a10370c2bf92a2a7282d9ee5e9a
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

keyboard;

<<<<<<< HEAD
    resdir = fileparts(paramfile);
    save(fullfile(resdir, 'testres'), 'summary', 'res', 'conf1', 'conf2');
end
=======
resdir = fileparts(paramfile);
save(fullfile(resdir, 'testres'), 'summary', 'res', 'conf1', 'conf2');
%% hand defined ptns....testing..
for i = 1:length(itms.ps)
ptn(i) = set_reference_object(itms.ps(i));
ptn(i) = reestimateITM(ptn(i), itms.cs{i});
end
paramsout = appendITMtoParams(paramsout, ptn([6 22]));
paramsout.model.itmptns(1)
paramsout.model.itmptns(2)
paramsout.model.itmptns(1).parts
paramsout.model.itmptns(1).biases
paramsout.model.itmptns(1).biases(:) = 1;
paramsout.model.itmptns(2).biases(:) = 1;
paramsout.model.itmptns(1).parts(1)
paramsout.model.itmptns(1).parts(2)
paramsout.model.itmptns(1).parts(2).wa = 0;
paramsout.model.itmptns(1).parts(2)
paramsout.model.itmptns(2).parts(2).wa = 0;
paramsout.model.itmptns(2).parts(2)
paramsout.model.itmptns(1).parts(1)
paramsout.model.itmptns(1).parts(2)
paramsout.model.itmptns(1).parts(2).wx = -1;
paramsout.model.itmptns(1).parts(2).wz = -1;
paramsout.model.itmptns(2).parts(2).wx
paramsout.model.itmptns(2).parts(2).wx = -0.5;
paramsout.model.itmptns(2).parts(2).wz
paramsout.model.itmptns(2).parts(2).wz = -1;
>>>>>>> d1fde5ba1ab20a10370c2bf92a2a7282d9ee5e9a
