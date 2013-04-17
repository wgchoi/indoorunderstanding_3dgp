% %% experimnet code for appearance model.
% clc
% %%
% [patterns, labels, annos] = preprocess_train_data(data, iparams, 2);
% %% get itmsets from testsets
% [sets] = generate_itm_trainsets(patterns, labels, iparams, ptns);
%%
% cachedir = 'cache/dpm';
% prefix = 'room_';
%cachedir = 'cache/dpm2';
%prefix = '';
function mr = itm_hog_testing(sets, cachedir, prefix)

parfor i = 1:length(sets)
    temp=load(fullfile(cachedir, [prefix 'itm' num2str(i, '%03d') '_root']));
    
    vr = struct('rpos', {}, 'rneg', {});
    for m = 1:length(temp.index_pose)
        testidx = [];
        
        if(iscell(temp.index_pose))
            poses = temp.index_pose{m};
        else
            poses = temp.index_pose(m);
        end
        
        for j = 1:length(poses)
            testidx = [testidx, find(sets(i).pos.clusters == poses(j))];
        end
        
        if isempty(testidx)
            continue;
        end
        
        [~, ~, vr(m).rpos] = featwarp(temp.models{m}, sets(i).pos.itm_examples(testidx));
        [~, ~, vr(m).rneg] = featwarp(temp.models{m}, sets(i).neg.itm_examples);
    end
    
    mr(i).vr = vr;
end

for i = 1:length(sets)
    vr = mr(i).vr;
    for m = 1:length(vr)
        if isempty(vr(m).rpos)
            continue;
        end
        
        minval = min([vr(m).rpos, vr(m).rneg]);
        maxval = max([vr(m).rpos, vr(m).rneg]);
        
        dval = (maxval-minval) / 50;
        subplot(211); 
        hist(vr(m).rpos, minval:dval:maxval);
        grid on;
        title(['histogram of positive responses for itm ' num2str(i) ' view ' num2str(m)])
        subplot(212); 
        hist(vr(m).rneg, minval:dval:maxval);
        grid on;
        title(['histogram of negative  responses for itm ' num2str(i) ' view ' num2str(m)])
        drawnow;
        
        print('-djpeg', fullfile(cachedir, ['hist_itm_train_' num2str(i, '%03d') '_v' num2str(m, '%03d') '.jpg']));
        % print('-djpeg', fullfile(cachedir, ['hist_itm_' num2str(i, '%03d') '_v' num2str(m, '%03d') '.jpg']));
    end
end

save(fullfile(cachedir, 'train_summary'), 'mr')