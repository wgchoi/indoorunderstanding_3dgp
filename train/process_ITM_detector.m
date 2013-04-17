function [data, ptns] = process_ITM_detector(data, dpm_prefix, ptns, itmcache)

addpath ../Detector/DPM
addpath ../Detector/dpm_detector/

% itmcache = 'cache/itm/room';
mkdir(itmcache);

models = {};
names = {};
itm_type = [];

dpm_idx = {};

cnt = 1;
num_itm = length(ptns);
for i = 1:num_itm
    try
        load([dpm_prefix num2str(i, '%03d') '_mix']);
        
        models{cnt} = model;
        
        names{cnt} = ['itm_' num2str(ptns(i).type, '%03d')];
        itm_type(cnt) = ptns(i).type;
        
        dpm_idx{cnt} = index_pose;
        cnt = cnt + 1;
    catch
    end
end

csize = 16;
for idx = 1:csize:length(data)
    disp(['process ' num2str(idx)]); tic();
    if(exist(fullfile(itmcache, ['data' num2str(idx, '%03d') '.mat']), 'file'))
        continue;
    end
    
    setsize = min(length(data) - idx + 1, csize);
    
    for i = 1:setsize
        imfiles{i} = data(idx+i-1).x.imfile;
    end
    
    parfor i = 1:setsize 
        try
            [bbox, top, ~, ~, resizefactor] = detect_objs(imfiles{i}, models, names, -1.0, 800, []);
            top2 = cell(length(bbox), 1);

            for j = 1:length(bbox)
                if(isempty(bbox{j}))
                    continue;
                end
                bbox{j}(:, 1:4) = bbox{j}(:, 1:4) ./ resizefactor;
                
                erridx = bbox{j}(:, 1) >= bbox{j}(:, 3);
                bbox{j}(erridx, :) = [];
                erridx = bbox{j}(:, 2) >= bbox{j}(:, 4);
                bbox{j}(erridx, :) = [];

                top2{j} = [];
                subtypes = unique(bbox{j}(:, 5));
                for k = 1:length(subtypes)
                    tidx = find(bbox{j}(:, 5) == subtypes(k));
                    tops = nms2(bbox{j}(tidx, :), 0.5);
                    top2{j} = [top2{j}; tidx(tops(:))];

                    % convert into actual pose azimuth
                    bbox{j}(tidx, 5) = dpm_idx{j}(subtypes(k));
                end
            end

            itmobs(i).itm_type = itm_type;
            itmobs(i).imfile = imfiles{i};
            itmobs(i).names = names;
            itmobs(i).top = top;
            itmobs(i).top2 = top2';
            itmobs(i).bbox = bbox;
        catch em
            disp(['error in ' num2str(idx+i-1)]);
        end
        disp(['done ' num2str(idx+i-1)]);
    end
    
    for i = 1:setsize 
        temp = itmobs(i);
        save(fullfile(itmcache, ['data' num2str(idx+i-1, '%03d')]), '-struct', 'temp');
    end
    toc();
end

rmpath ../Detector/DPM
rmpath ../Detector/dpm_detector

end