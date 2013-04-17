function draw_itm_dets(dset, idx)
imbase = '~/codes/eccv_indoor/Data_Collection/';
dtbase = 'cache/itmdets';
dtbase = fullfile(dtbase, dset);
itmname = ['itm' num2str(idx, '%03d')];
dtbase = fullfile(dtbase, itmname);

files = dir(fullfile(dtbase, '*.mat'));
th = -1.0;

for i = 1:length(files)
    det = load(fullfile(dtbase, files(i).name));
    bbox = det.bbox{1}; % (det.top{1}, :);
    bbox(:, 1:4)  = bbox(:, 1:4) ./ det.resizefactor;
    if(bbox(1, end) > th)
        [~, imname] = fileparts(files(i).name);
        imname = [imname '.jpg'];
        imshow(fullfile(fullfile(imbase, dset), imname));
        
        for j = 1:size(bbox, 1)
            if(bbox(j, end) > th)
                thickness = (bbox(j, end) - th) * 4;
                rectangle('position', bbox2rect(bbox(j, 1:4)), 'edgecolor', 'r', 'linewidth', thickness);
                text(bbox(j, 1)+10, bbox(j, 2)+10, num2str(bbox(j, 5)), 'backgroundcolor', 'w');
            end
        end
        pause;
    end
end

end