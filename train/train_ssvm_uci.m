function [params, info] = train_ssvm_uci(data, params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('../3rdParty/ssvmqp_uci/');
VERBOSE = 0;  

%%%%% assume all is preprocessed
patterns = cell(length(data), 1);   % idx, x, iclusters 
labels = cell(length(data), 1);     % idx, pg
annos = cell(length(data), 1);
for i=1:length(data)
    %%% start from gt labels..
    %%% it would help making over-generated violating consts
    %%% also make it iterate less as it goes through iterations.
    % disp(['prepare data ' num2str(i)])
    patterns{i}.idx = i;
    patterns{i}.x = data(i).x;
    patterns{i}.iclusters = data(i).iclusters;
    
    labels{i}.idx = i;
    labels{i}.pg = data(i).gpg;
    if(strcmp(params.losstype, 'exclusive'))
        if(isfield(params.model, 'commonground') && params.model.commonground)
            labels{i}.pg = findConsistent3DObjects(labels{i}.pg, data(i).x);
        else
            mh = getAverageObjectsBottom(labels{i}.pg, data(i).x);
            if(~isnan(mh))
                labels{i}.pg.camheight = -mh;
            else
                labels{i}.pg.camheight = 1.5;
            end
            assert(~isnan(labels{i}.pg.camheight));
            assert(~isinf(labels{i}.pg.camheight));
        end
        
        labels{i}.feat = features(labels{i}.pg, patterns{i}.x, patterns{i}.iclusters, params.model);
        labels{i}.loss = lossall(data(i).anno, patterns{i}.x, labels{i}.pg, params);
        annos{i} = data(i).anno;
    elseif(strcmp(params.losstype, 'isolation'))
        GT = [];
        Det = data(i).x.dets(:, [4:7 1]);
        for j = 1:length(data(i).anno.obj_annos)
            anno = data(i).anno.obj_annos(j);
            GT(j, :) = [anno.x1 anno.y1 anno.x2 anno.y2 anno.objtype];
        end
        % GT(GT(:, end) > 2, :) = [];
        annos{i}.oloss = computeloss(Det, GT);
        annos{i}.scenetype = data(i).anno.scenetype;
        
        numtp(i) = sum(annos{i}.oloss(:, 2));
        nump(i) = size(GT, 1);
        
        ambids = find((annos{i}.oloss(:, 1) == 0) & (annos{i}.oloss(:, 2) == 0));
        %% remove too many flase positives
        filterids = falsepositiveNMSFilter(patterns{i}.x, find((annos{i}.oloss(:, 1) == 1)), 30);
        ambids = unique(union(ambids, filterids));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        annos{i}.oloss(ambids, :) = [];
        
        patterns{i}.iclusters(ambids) = [];
        
        patterns{i}.x.dets(ambids, :) = [];
        patterns{i}.x.locs(ambids, :) = [];
        patterns{i}.x.cubes(ambids) = [];
        patterns{i}.x.projs(ambids) = [];
        
        patterns{i}.x.orpolys(ambids, :) = [];
        patterns{i}.x.orpolys(:, ambids) = [];
        patterns{i}.x.orarea(ambids, :) = [];
        patterns{i}.x.orarea(:, ambids) = [];
		for j = 1:length(patterns(i).isolated)
			patterns{i}.isolated(j).chindices = j;
		end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%% find the ground truth solution
        labels{i}.pg = data(i).gpg;
        labels{i}.pg.childs = find(annos{i}.oloss(:, 2));
        if(isfield(params.model, 'commonground') && params.model.commonground)
            labels{i}.pg = findConsistent3DObjects(labels{i}.pg, patterns{i}.x, patterns{i}.iclusters);
        else
            mh = getAverageObjectsBottom(labels{i}.pg, patterns{i}.x);
            if(~isnan(mh))
                labels{i}.pg.camheight = -mh;
            else
                labels{i}.pg.camheight = 1.5;
            end
            assert(~isnan(labels{i}.pg.camheight));
            assert(~isinf(labels{i}.pg.camheight));
        end
        
        labels{i}.feat = features(labels{i}.pg, patterns{i}.x, patterns{i}.iclusters, params.model);
        labels{i}.loss = lossall(annos{i}, patterns{i}.x, labels{i}.pg, params);
        
        gtfeats(:, i) = labels{i}.feat;
    else
        assert(0, 'not defined loss type');
    end
end
clear data;
%%%%%%%%%%%% dimension
params.model.w = getweights(params.model);
ndim = length(params.model.w);
%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% uci ssvm codes
Constraints = zeros(ndim, 10000, 'single');
Margins = zeros(1, 10000, 'single');
IDS = zeros(1, 10000, 'single');
ITER = zeros(1, 10000, 'single');

max_iter = 8;
iter = 1;

C = params.C;
n = 0;
MAX_CON = 10000;

%%%% initial empty constraints
for id = 1:length(patterns)
    [yhat dphi margin] = getEmpty(patterns{id}, labels{id}, annos{id}, params);
 
    n = n + 1;
    Constraints(:, n) = dphi;
    Margins(n) = margin;
    IDS(n) = id;
    ITER(n) = 0;
end
% %%%% initial all selected constraints
% % parfor id = 1:length(patterns)
% %     [yhat dphi margin] = getFull(patterns{id}, labels{id}, annos{id}, params);
% %    
% %     Constraints(:, n + id) = dphi;
% %     Margins(n + id) = margin;
% %     IDS(n + id) = id;
% % end
% % n = n + length(patterns);
[w, cache]= lsvmopt(Constraints(:,1:n),Margins(1:n), IDS(1:n) ,C, 0.01,[]);
% Update parameters
params.model = getmodelparam(params.model, w);
%reset the running estimate on upper bund
cost =cache.ub;
low_bound = cache.lb;
trigger = 1;

chunksize = 16;
% initial evaluation
ls = 0;
if(params.evaltrain)
    ls = evaluateModel(patterns, labels, annos, params);
end
info.err = sum(ls);
info.cost = cost;
info.params = params;
info.history.w = w(:);
info.history.n = n;
disp(['initial : all cost ' num2str(cost) ', inference error : ' num2str(sum(ls))]);
disp(['w : ' num2str(w')]);

while (iter < max_iter && trigger)
    disp(['ssvm training iter = ' num2str(iter)])
    tic;
    trigger=0;
    % per image
    for id = 1:chunksize:length(patterns)
        any_addition = 0;
        params.model.w = getweights(params.model);
        
        numdata = min(chunksize, length(patterns) - id + 1);
        
        % save the memory
        buffx = patterns(id:id+numdata-1);
        buffy = labels(id:id+numdata-1);
        buffa = annos(id:id+numdata-1);
        parfor did = 1:numdata
            [~, dphi(:, did), margin(did)] = find_MVC(buffx{did}, buffy{did}, buffa{did}, params);
            % [yhat(did) dphi(:, did) margin(did)] = find_MVC(patterns{id + did - 1}, labels{id + did - 1}, annos{id + did - 1}, params);
        end
        
        for did = 1:numdata
            %if this constraint is the MVC for this image
            isMVC = 1;
            check_labels = find(IDS(1, 1:n) == (id + did - 1));
            score = margin(did) - dot(params.model.w, dphi(:, did));

            for ii = 1:numel(check_labels)
                label_ii = check_labels(ii);
                if (margin(did) - params.model.w' * Constraints(:, label_ii) > score)
                    isMVC = 0;
                    break;
                end
            end

            if isMVC ==1
                cost = cost + C * max(0, score);
                %add only if this is a hard constraint
                if score >= -0.001
                    n = n + 1;
                    Constraints(:, n) = dphi(:, did);
                    Margins(n) = margin(:, did);
                    IDS(n) = (id + did - 1);
                    ITER(n) = iter;

                    any_addition = 1;

                    if n > MAX_CON
                        disp('Max constraints reached, reduce the set to make it feasible');
                        [slacks I_ids] = sort((Margins(:,n)  - params.model.w' * Constraints(:, 1:n)), 'descend');
                        J = I_ids(1:MAX_CON);
                        n = length(J);
                        Constraints(:, 1:n) = Constraints(:, J);
                        Margins(:, 1:n) = Margins(:, J);
                        IDS(:, 1:n) = IDS(:, J);
                        ITER(:, 1:n) = ITER(:, J);
                    end
                end

                if(VERBOSE > 0)
                    disp(['new constraint ' num2str(id) 'th added : score ' num2str(score) ' all cost ' num2str(cost) ' LB : ' num2str(low_bound)]);
                else
                    fprintf('+');
                    if(mod(id + did - 1, 100) == 0)
                        fprintf('\n');
                    end
                end
            else
                fprintf('.');
                if(mod(id + did - 1, 100) == 0)
                    fprintf('\n');
                end
            end
        end
        assert(cost + 1e-3 >= low_bound);
        
        if ((1 - low_bound / cost > .01) && (any_addition == 1))
            % Call QP
            %if mod(iter, 10) == 1
            % [cost low_bound]
            %end
            [w, cache]= lsvmopt(Constraints(:,1:n),Margins(1:n), IDS(1:n) ,C, 0.0001,[]);
%             [w, cache]= lsvmopt(Constraints(:,1:n),Margins(1:n), 1:n ,C, 0.01,[]);
            % Prune working set
            if 0
                I = find(cache.sv > 0);
                n = length(I);
                Constraints(:,1:n) = Constraints(:,I);
                Margins(:,1:n) = Margins(:,I);
                IDS(:,1:n) = IDS(:,I);
                ITER(:, 1:n) = ITER(:, I);
            end
            % Update parameters
            params.model = getmodelparam(params.model, w);
            %reset the running estimate on upper bund
%             cost = w'*w*0.5;
%             cost = cost + C * sum(max(zeros(1, n), Margins(1:n) - w'*Constraints(:, 1:n)));
%             if(abs(cost - cache.ub) > 1e-3)
%                 keyboard;
%             end
%             if(dot(w, w) < 1e-5)
%                 keyboard;
%             end
            cost = cache.ub;
            low_bound = cache.lb;
            trigger = 1;

			info.history.w(:, end+1) = w(:);
			info.history.n(end+1) = n;
%             showModel(params);
%             drawnow;
        end
    end
    fprintf('done. '); toc;
    
    iter = iter + 1;
    ls = 0;
    if(params.evaltrain)
        ls = evaluateModel(patterns, labels, annos, params);
    end
    
    disp(['all cost ' num2str(cost) ' LB : ' num2str(low_bound) ', inference error : ' num2str(sum(ls))]);
    disp(['w : ' num2str(w')]);
    info.cost(end + 1) = cost;
    info.err(end + 1) = sum(ls);
    info.params(end + 1) = params;
    
%     if(info.cost(end) - info.cost(end - 1) < 1)
%         break;
%     end
end
% matlabpool close;

info.Constraints = Constraints(:,1:n); 
info.Margins = Margins(1:n); 
info.IDS =  IDS(1:n);
info.ITER =  ITER(1:n);

end

function ls = evaluateModel(patterns, labels, annos, params)

ls = zeros(length(patterns), 1);
tic;
parfor id = 1:length(patterns)
    [spg, maxidx] = infer_top(patterns{id}.x, patterns{id}.iclusters, params, labels{id}.pg);
    ls(id) = lossall(annos{id}, patterns{id}.x, spg(maxidx), params);
end
toc;
end

function drawPlot(w, Constraints, Margins)
figure(1);
clf

svs = find(Margins - w'*Constraints > 0);
% scatter(Constraints(end-3, :) ./ Margins, Constraints(end-2, :) ./ Margins, '.');
scatter(Constraints(end-3, :), Constraints(end-2, :), '.');
hold on;
% scatter(Constraints(end-3, svs) ./ Margins(svs), Constraints(end-2, svs) ./ Margins(svs), 'rx');
scatter(Constraints(end-3, svs), Constraints(end-2, svs), 'rx');

x = min(Constraints(end-3, :)):max(Constraints(end-3, :));
plot(x, -w(end-3) * x / w(end-2), 'r');
hold off;

axis([ min(Constraints(end-3, :)) max(Constraints(end-3, :)) min(Constraints(end-2, :)) max(Constraints(end-2, :))] )
xlabel('c(y) - c(h), conf diff');
ylabel('b(y) - b(h), bias diff');
grid on;

pause(0.2);

end

function [yhat dphi margin] = find_MVC(x, y, anno, params)
% finds the most violated constraint on image id i_id under the current
% model in params.
% 1st output: 0/1 labeling on all the detection windows 
% 2nd output: The constraint corresponding to that labeling (Groud
% Truth Feature - Worst Offending feature)
% 3rd output: the margin you want to enforce for this constraint.

maxpg = y.pg;
for i = 1:params.model.nscene
    pg = y.pg;
    pg.scenetype = i;
    
    if(strcmp(params.inference, 'mcmc'))
        init.pg = pg;
        [spg, maxidx] = DDMCMCinference(x.x, x.iclusters, params, init, anno);
    elseif(strcmp(params.inference, 'greedy'))
        initpg = pg;
        [spg] = GreedyInference(x.x, x.iclusters, params, initpg, anno);
        maxidx = 1;
    elseif(strcmp(params.inference, 'combined'))
        init.pg = pg;
        [init.pg] = GreedyInference(x.x, x.iclusters, params, init.pg, anno);
        [spg, maxidx, ~, h] = DDMCMCinference(x.x, x.iclusters, params, init, anno);
    else
        assert(0);
    end
    
    pg = spg(maxidx);
    if(maxpg.lkhood + maxpg.loss < pg.lkhood + pg.loss)
        maxpg = pg;
    end
end

yhat = y;
yhat.pg = maxpg;
yhat.feat = features(yhat.pg, x.x, x.iclusters, params.model);
yhat.loss = lossall(anno, x.x, yhat.pg, params);

if nargout >= 2
    dphi = y.feat  - yhat.feat;
    if nargout >= 3
        margin = yhat.loss - y.loss;
    end
end

end

function [yhat dphi margin] = getFull(x, y, anno, params)
% finds the most violated constraint on image id i_id under the current
% model in params.
% 1st output: 0/1 labeling on all the detection windows 
% 2nd output: The constraint corresponding to that labeling (Groud
% Truth Feature - Worst Offending feature)
% 3rd output: the margin you want to enforce for this constraint.
yhat = y;
yhat.pg.childs = 1:size(x.x.dets, 1);
if(isfield(params.model, 'commonground') && params.model.commonground)
    yhat.pg = findConsistent3DObjects(yhat.pg, x.x);
else
    mh = getAverageObjectsBottom(yhat.pg, x.x);
    if(~isnan(mh))
        yhat.pg.camheight = -mh;
    else
        yhat.pg.camheight = 1.5;
    end
end
yhat.feat = features(yhat.pg, x.x, x.iclusters, params.model);
yhat.loss = lossall(anno, x.x, yhat.pg, params);

if nargout >= 2
    dphi = y.feat  - yhat.feat;
    if nargout >= 3
        margin = yhat.loss - y.loss;
    end
end

end

function [yhat dphi margin] = getEmpty(x, y, anno, params)
% finds the most violated constraint on image id i_id under the current
% model in params.
% 1st output: 0/1 labeling on all the detection windows 
% 2nd output: The constraint corresponding to that labeling (Groud
% Truth Feature - Worst Offending feature)
% 3rd output: the margin you want to enforce for this constraint.
yhat = y;
yhat.pg.childs = [];
yhat.feat = features(yhat.pg, x.x, x.iclusters, params.model);
yhat.loss = lossall(anno, x.x, yhat.pg, params);

if nargout >= 2
    dphi = y.feat  - yhat.feat;
    if nargout >= 3
        margin = yhat.loss - y.loss;
    end
end

end
