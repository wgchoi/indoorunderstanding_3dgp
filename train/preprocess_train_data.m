function [patterns, labels, annos] = preprocess_train_data(data, params, VERBOSE)

patterns = struct(  'idx', cell(length(data), 1), ...
                    'x', cell(length(data), 1), ...
                    'isolated', cell(length(data), 1), ...
                    'composite', cell(length(data), 1), ...
                    'iclusters', cell(length(data), 1));   % idx, x, iclusters 

labels = struct(  'idx', cell(length(data), 1), ...
                    'pg', cell(length(data), 1), ...
                    'lcpg', cell(length(data), 1));   % idx, pg, lcpg
                
annos = struct('oloss', cell(length(data), 1));

removecnt = 0;
totalfp = 0;

for i = 1:length(data)
    %%% start from gt labels..
    %%% it would help making over-generated violating consts
    %%% also make it iterate less as it goes through iterations.
    if(VERBOSE > 2)
        disp(['prepare data ' num2str(i)])
    end
    patterns(i).idx = i;
    patterns(i).x = data(i).x;
    patterns(i).isolated = data(i).iclusters;
    
    labels(i).idx = i;
    labels(i).pg = data(i).gpg;
    if(strcmp(params.losstype, 'exclusive'))
        if(isfield(params.model, 'commonground') && params.model.commonground)
            labels(i).pg = findConsistent3DObjects(labels(i).pg, data(i).x);
        else
            mh = getAverageObjectsBottom(labels(i).pg, data(i).x);
            if(~isnan(mh))
                labels(i).pg.camheight = -mh;
            else
                labels(i).pg.camheight = 1.5;
            end
            assert(~isnan(labels(i).pg.camheight));
            assert(~isinf(labels(i).pg.camheight));
        end
        
        labels(i).feat = features(labels(i).pg, patterns(i).x, patterns(i).isolated, params.model);
        labels(i).loss = lossall(data(i).anno, patterns(i).x, labels(i).pg, params);
        annos(i) = data(i).anno;
    elseif(strcmp(params.losstype, 'isolation'))
        GT = [];
        Det = data(i).x.dets(:, [4:7 1]);
        for j = 1:length(data(i).anno.obj_annos)
            anno = data(i).anno.obj_annos(j);
            GT(j, :) = [anno.x1 anno.y1 anno.x2 anno.y2 anno.objtype];
        end
        if(isfield(data(i).anno, 'hmn_annos'))
            for j = 1:length(data(i).anno.hmn_annos)
                anno = data(i).anno.hmn_annos(j);
                GT(length(data(i).anno.obj_annos)+j, :) = [anno.x1 anno.y1 anno.x2 anno.y2 7];
            end
        end
        % GT(GT(:, end) > 2, :) = [];
        try
        annos(i).oloss = computeloss(Det, GT);
        catch
            annos(i).oloss = zeros(0, 2);
        end
        
        numtp(i) = sum(annos(i).oloss(:, 2));
        nump(i) = size(GT, 1);
        if(numtp(i) < nump(i))
            disp([num2str(nump(i) - numtp(i)) ' missing object in ' num2str(i)])
        end
        ambids = find((annos(i).oloss(:, 1) == 0) & (annos(i).oloss(:, 2) == 0));
        %% remove too many flase positives
        filterids = falsepositiveNMSFilter(patterns(i).x, find((annos(i).oloss(:, 1) == 1)), 35);
        ambids = unique(union(ambids, filterids));
        
        removecnt = removecnt + length(filterids);
        totalfp = totalfp + sum(annos(i).oloss(:, 1) == 1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        annos(i).oloss(ambids, :) = [];
        
        patterns(i).isolated(ambids) = [];
        
        patterns(i).x.dets(ambids, :) = [];
        if(isfield(patterns(i).x, 'hobjs'))
            patterns(i).x.hobjs(ambids) = [];
        else
            patterns(i).x.locs(ambids, :) = [];
            patterns(i).x.cubes(ambids) = [];
            patterns(i).x.projs(ambids) = [];
        end
        
        patterns(i).x.orpolys(ambids, :) = [];
        patterns(i).x.orpolys(:, ambids) = [];
        patterns(i).x.orarea(ambids, :) = [];
        patterns(i).x.orarea(:, ambids) = [];
        
        for j = 1:length(patterns(i).isolated)
            patterns(i).isolated(j).chindices = j;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%% find the ground truth solution
        labels(i).pg = data(i).gpg;
        labels(i).pg.childs = find(annos(i).oloss(:, 2));
        labels(i).pg.subidx = 14 .* ones(1, length(labels(i).pg.childs));
        
        if(isfield(params.model, 'commonground') && params.model.commonground)
            labels(i).pg = findConsistent3DObjects(labels(i).pg, patterns(i).x, patterns(i).isolated);
        else
            mh = getAverageObjectsBottom(labels(i).pg, patterns(i).x);
            if(~isnan(mh))
                labels(i).pg.camheight = -mh;
            else
                labels(i).pg.camheight = 1.5;
            end
            assert(~isnan(labels(i).pg.camheight));
            assert(~isinf(labels(i).pg.camheight));
        end
        
        labels(i).feat = features(labels(i).pg, patterns(i).x, patterns(i).isolated, params.model);
        labels(i).loss = lossall(annos(i), patterns(i).x, labels(i).pg, params);
        
        gtfeats(:, i) = labels(i).feat;
    else
        assert(0, 'not defined loss type');
    end
end
if(VERBOSE > 0)
    disp(['prepare data done, removed ' num2str(removecnt) '/' num2str(totalfp) ' for faster training'])
end
end