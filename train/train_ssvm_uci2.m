function [params, info] = train_ssvm_uci2(patterns, labels, annos, params, VERBOSE)

for i = 1:length(labels)
    labels(i).feat = features(labels(i).lcpg, patterns(i).x, patterns(i).iclusters, params.model);
    labels(i).loss = lossall2(annos(i), patterns(i).x, patterns(i).iclusters, labels(i).lcpg, params);
	% temp(:, i) = labels(i).feat;
end
%save('cache/gtfeats', 'temp');

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

if(isfield(params, 'max_ssvm_iter'))
    max_iter = params.max_ssvm_iter;
else
    max_iter = 10;
end
iter = 1;

C = params.C;
n = 0;
MAX_CON = 10000;

%%%% initial empty constraints
for id = 1:length(patterns)
    [yhat dphi margin] = getEmpty(patterns(id), labels(id), annos(id), params);
 
    n = n + 1;
    Constraints(:, n) = dphi;
    Margins(n) = margin;
    IDS(n) = id;
    ITER(n) = 0;
end

[w, cache]= lsvmopt(Constraints(:,1:n),Margins(1:n), IDS(1:n) ,C, 0.01,[]);

% Update parameters
params.model = getmodelparam(params.model, w);

%reset the running estimate on upper bund
cost = cache.ub;
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

while (iter <= max_iter && trigger)
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
%         for did = 1:numdata
            [~, dphi(:, did), margin(did)] = find_MVC2(buffx(did), buffy(did), buffa(did), params);
        end
        
        for did = 1:numdata
            %if this constraint is the MVC for this image
            isMVC = 1;
            check_labels = find(IDS(1, 1:n) == (id + did - 1));
            score = margin(did) - dot(params.model.w, dphi(:, did));

            for ii = 1:numel(check_labels)
                label_ii = check_labels(ii);
				if (Margins(label_ii) - params.model.w' * Constraints(:, label_ii) >= score - abs(score) * 1e-4)
                % if (margin(did) - params.model.w' * Constraints(:, label_ii) > score)
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
                    disp(['new constraint ' num2str(id + did - 1) 'th added : score ' num2str(score) ' all cost ' num2str(cost) ' LB : ' num2str(low_bound)]);
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
            % [w, cache]= lsvmopt(Constraints(:,1:n),Margins(1:n), IDS(1:n) ,C, 0.01,[]);
            % Prune working set
            if 0 % don't use this!!
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
        end
    end
    fprintf('done. '); toc;
    disp(['w_ior : ' num2str(params.model.w_ior')]);
    
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
    [spg, maxidx] = infer_top(patterns(id).x, patterns(id).iclusters, params, labels(id).pg);
    ls(id) = lossall2(annos(id), patterns(id).x, patterns(id).iclusters, spg(maxidx), params);
end
toc;

end

function [yhat dphi margin] = find_MVC2(x, y, anno, params)
% finds the most violated constraint on image id i_id under the current
% model in params.
% 1st output: 0/1 labeling on all the detection windows 
% 2nd output: The constraint corresponding to that labeling (Groud
% Truth Feature - Worst Offending feature)
% 3rd output: the margin you want to enforce for this constraint.

maxpg = y.pg;

if(isfield(params, 'ignorescene') && params.ignorescene) 
	sidx = maxpg.scenetype;
else
	sidx = 1:params.model.nscene;
end

for i = sidx % 1:params.model.nscene
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
yhat.loss = lossall2(anno, x.x, x.iclusters, yhat.pg, params);

if nargout >= 2
    dphi = y.feat  - yhat.feat;
    if nargout >= 3
        margin = yhat.loss - y.loss;
    end
end

end

function [yhat dphi margin] = find_MVC(x, y, anno, params)
% finds the most violated constraint on image id i_id under the current
% model in params.
% 1st output: 0/1 labeling on all the detection windows 
% 2nd output: The constraint corresponding to that labeling (Groud
% Truth Feature - Worst Offending feature)
% 3rd output: the margin you want to enforce for this constraint.

y = scene_MVC(x, y, anno, params);

if(strcmp(params.inference, 'mcmc'))
    init.pg = y.pg;
    [spg, maxidx] = DDMCMCinference(x.x, x.iclusters, params, init, anno);
elseif(strcmp(params.inference, 'greedy'))
    initpg = y.pg;
    [spg] = GreedyInference(x.x, x.iclusters, params, initpg, anno);
    maxidx = 1;
elseif(strcmp(params.inference, 'combined'))
    init.pg = y.pg;
    
    [init.pg] = GreedyInference(x.x, x.iclusters, params, init.pg, anno);
    init = scene_MVC(x, init, anno, params);
    [spg, maxidx, ~, h] = DDMCMCinference(x.x, x.iclusters, params, init, anno);
    
else
    assert(0);
end

y.pg = spg(maxidx);
yhat = scene_MVC(x, y, anno, params);
yhat.feat = features(yhat.pg, x.x, x.iclusters, params.model);
yhat.loss = lossall2(anno, x.x, x.iclusters, yhat.pg, params);

if nargout >= 2
    dphi = y.feat  - yhat.feat;
    if nargout >= 3
        margin = yhat.loss - y.loss;
    end
end

end

function y = scene_MVC(x, y, anno, params)

pg = y.pg;
maxval = -inf;
for i = 1:params.model.nscene
    pg.scenetype = i;
    val = lossall2(anno, x.x, x.iclusters, pg, params);
    val = val + dot(getweights(params.model), features(pg, x.x, x.iclusters, params.model));
    if(maxval < val)
        maxval = val;
        y.pg = pg;
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
