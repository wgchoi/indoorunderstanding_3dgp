function [params, info] = train_feat_test(data, model, C, VERBOSE)

params.model = model;
params.evaltrain = 1;
params.C = C;
%%%%%%%%%%%% dimension
temp = feat_test(data(1).gpg, data(1).x, data(1).iclusters, model);
ndim = length(temp);
params.w = zeros(ndim, 1);
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
cost = 0;
MAX_CON = 10000;

trigger = 1;
low_bound = -inf;

chunksize = 16;
% initial evaluation
ls = 0; le = 0;
if(params.evaltrain)
    [ls, le] = evaluateModel(data, params);
end

info.loss = sum(ls);
info.err = mean(le(~isnan(le)));
info.cost = cost;
info.params = params;
info.history.w = params.w(:);
info.history.n = n;
disp(['initial : all cost ' num2str(cost) ', inference error : ' num2str(sum(ls)) ', ' num2str(mean(le(~isnan(le)))) ]);
disp(['w : ' num2str(params.w')]);

while (iter <= max_iter && trigger)
    disp(['ssvm training iter = ' num2str(iter)])
    tic;
    trigger=0;
    % per image
    for id = 1:chunksize:length(data)
        any_addition = 0;
        numdata = min(chunksize, length(data) - id + 1);
        
        % save the memory
        buff = data(id:id+numdata-1);
        
        parfor did = 1:numdata
%         for did = 1:numdata
            [~, dphi(:, did), margin(did)] = find_MVC2(buff(did).x, buff(did).gpg, buff(did).iclusters, params);
        end
        
        for did = 1:numdata
            %if this constraint is the MVC for this image
            isMVC = 1;
            check_labels = find(IDS(1, 1:n) == (id + did - 1));
            score = margin(did) - dot(params.w, dphi(:, did));

            for ii = 1:numel(check_labels)
                label_ii = check_labels(ii);
                if (Margins(label_ii) - params.w' * Constraints(:, label_ii) >= score - abs(score) * 1e-4)
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
                        [slacks I_ids] = sort((Margins(:,n)  - params.w' * Constraints(:, 1:n)), 'descend');
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
            % Prune working set
            if 0 % don't use this!!
                I = find(cache.sv > 0);
                n = length(I);
                Constraints(:,1:n) = Constraints(:,I);
                Margins(:,1:n) = Margins(:,I);
                IDS(:,1:n) = IDS(:,I);
                ITER(:, 1:n) = ITER(:, I);
            end
            
            cost = cache.ub;
            low_bound = cache.lb;
            trigger = 1;

			info.history.w(:, end+1) = w(:);
			info.history.n(end+1) = n;
            params.w = w;
            
            % disp(['w : ' num2str(w')]);
        end
    end
    fprintf('done. '); toc;
    
    iter = iter + 1;
    ls = 0;
    if(params.evaltrain)
        [ls, le] = evaluateModel(data, params);
    end
    
    disp(['all cost ' num2str(cost) ' LB : ' num2str(low_bound) ', inference error : ' num2str(sum(ls)) ', ' num2str(mean(le(~isnan(le))))]);
    disp(['w : ' num2str(w')]);
    info.cost(end + 1) = cost;
    info.loss(end + 1) = sum(ls);
    info.err(end + 1) = mean(le(~isnan(le)));
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

function [ls, le] = evaluateModel(data, params)

ls = zeros(1, length(data));
le = zeros(1, length(data));

model =  params.model;
parfor i = 1:length(data)
    pg = data(i).gpg;
    maxval = -inf;
    
    for j = 1:min(length(data(i).x.lloss), 50)
        pg.layoutidx = j;
        phi = feat_test(pg, data(i).x, data(i).iclusters, model);
        
        if(dot(phi, params.w) > maxval)
            maxval = dot(phi, params.w);
            ls(i) = data(i).x.lloss(j);
            le(i) = data(i).x.lerr(j);
        end
    end
end

end

function [yhat dphi margin] = find_MVC2(x, gpg, iclusters, params)
% finds the most violated constraint on image id i_id under the current
% model in params.
% 1st output: 0/1 labeling on all the detection windows 
% 2nd output: The constraint corresponding to that labeling (Groud
% Truth Feature - Worst Offending feature)
% 3rd output: the margin you want to enforce for this constraint.
pg = gpg;

yphi = feat_test(pg, x, iclusters, params.model);
yloss = x.lloss(pg.layoutidx);

maxval = dot(yphi, params.w) + yloss;
maxfeat = yphi;
maxloss = yloss;

for i = 1:min(length(x.lloss), 50)
    pg.layoutidx = i;
    phi = feat_test(pg, x, iclusters, params.model);
    if(dot(phi, params.w) + x.lloss(i) > maxval)
        maxval = dot(phi, params.w) + x.lloss(i);
        maxfeat = phi;
        maxloss = x.lloss(i);
    end
end

yhat.feat = maxfeat;
yhat.loss = maxloss;
if nargout >= 2
    dphi = yphi  - yhat.feat;
    if nargout >= 3
        margin = yhat.loss - yloss;
    end
end

end