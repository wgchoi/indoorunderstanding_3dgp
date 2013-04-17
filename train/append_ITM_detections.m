function data = append_ITM_detections(data, ptns, itmcache, modeldir)
viewmaps = cell(length(ptns), 1);
for i = 1:length(ptns)
	try
    	temp = load(fullfile(modeldir, ['itm' num2str(ptns(i).type, '%03d') '_final']));
	catch
    	temp = load(fullfile(modeldir, ['human_itm' num2str(ptns(i).type, '%03d') '_final']));
	end
    for j = 1:length(temp.model.index_pose)
        viewmaps{i}(end+1) = temp.model.index_pose{j}; % (temp.model.index_pose{j} - 1) * pi / 4;
    end
end

for i = 1:length(data)
    disp(['itmappend: processing ' num2str(i)]);
    imfile = data(i).x.imfile;
    [dname, fname] = fileparts(imfile);
    [~, dname] = fileparts(dname);
    itms = load_itm_dets(itmcache, dname, fname, ptns, viewmaps);
    data(i).x.itms = itms;
%     keyboard;
%     assert(strcmp(data(i).x.imfile, itm.imfile));
%     assert(length(itm.itm_type) == length(itm.names));
%     itm.obs_idx(itm.itm_type) = 1:length(itm.itm_type);
%     data(i).x.itms = itm;
end
end

function itms = load_itm_dets(cachedir, dname, fname, ptns, viewmaps)

itms = zeros(0, 8);
dirbase = fullfile(cachedir, dname);
th = -1.0;

for i = 1:length(ptns)
	try
		dirname = fullfile(dirbase, ['itm' num2str(ptns(i).type, '%03d')]);
		dets = load(fullfile(dirname, fname));
	catch
		dirname = fullfile(dirbase, ['human_itm' num2str(ptns(i).type, '%03d')]);
		dets = load(fullfile(dirname, fname));
	end
    
    bbox = dets.bbox{1};
    if isempty(bbox)
        continue;
    end
	bbox(bbox(:, 6) < th, :) = [];
    if isempty(bbox)
        continue;
    end

    bbox(:, 1:4) = bbox(:, 1:4) ./ dets.resizefactor;
    
    pick = nms2(bbox, 0.5);
    
    bbox = bbox(pick, :);
    ndet = size(bbox, 1);
    
    azs = viewmaps{i}(bbox(:, 5));
    
    itm = [ptns(i).type * ones(ndet, 1), ones(ndet, 1), azs(:), bbox(:, 1:4), bbox(:, 6)];
    itms = [itms; itm];
end

end
