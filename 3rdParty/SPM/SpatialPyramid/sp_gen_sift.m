function [features] = sp_gen_sift(imageFName,params)
    I = sp_load_image(imageFName);

    [hgt wid] = size(I);
    if min(hgt,wid) > params.maxImageSize
        I = imresize(I, params.maxImageSize/min(hgt,wid), 'bicubic');
        fprintf('Loaded %s: original size %d x %d, resizing to %d x %d\n', ...
            imageFName, wid, hgt, size(I,2), size(I,1));
        [hgt wid] = size(I);
    end

    %% make grid (coordinates of upper left patch corners)
    %{-
    if(params.oldSift)
        remX = mod(wid-params.patchSize,params.gridSpacing);
        offsetX = floor(remX/2)+1;
        remY = mod(hgt-params.patchSize,params.gridSpacing);
        offsetY = floor(remY/2)+1;

        [gridX,gridY] = meshgrid(offsetX:params.gridSpacing:wid-params.patchSize+1, offsetY:params.gridSpacing:hgt-params.patchSize+1);

        siftArr = sp_find_sift_grid(I, gridX, gridY, params.patchSize, 0.8);
        siftArr = sp_normalize_sift(siftArr);
    %}
    %fprintf('Processing %s: wid %d, hgt %d, grid size: %d x %d, %d patches\n', ...
    %         imageFName, wid, hgt, (wid-params.patchSize)/params.gridSpacing, (hgt-params.patchSize)/params.gridSpacing, ((hgt-params.patchSize)*(wid-params.patchSize))/params.gridSpacing);

    %% find SIFT descriptors
    else
        [siftArr gridX gridY] = sp_dense_sift(I, params.gridSpacing, params.patchSize);
        siftArr = reshape(siftArr,[size(siftArr,1)*size(siftArr,2) size(siftArr,3)]);
    end
    features.data = siftArr;
    features.x = gridX(:);% + params.patchSize/2 - 0.5;
    features.y = gridY(:);% + params.patchSize/2 - 0.5;
    features.wid = wid;
    features.hgt = hgt;
end