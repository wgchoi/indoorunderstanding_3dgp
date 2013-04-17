function newdets = appendGTforTrain(imfile, dets, anno)
% search for all object candidates
% if there are no suitable candidate, run detector and append the
% confidence
ovth = 0.6;

or = zeros(length(anno.obj_annos), size(dets, 1));
for i = 1:length(anno.obj_annos)
    for j = 1:size(dets, 1)
        if(dets(j, 1) == anno.obj_annos(i).objtype)
            if(anglediff(dets(j, 3), anno.obj_annos(i).azimuth) <= pi / 6)
                gtbb = [anno.obj_annos(i).x1 anno.obj_annos(i).y1 anno.obj_annos(i).x2 anno.obj_annos(i).y2];
                or(i, j) = boxoverlap(gtbb, dets(j, 4:7));
            end
        end
    end
end
midx = find(sum((or > ovth), 2) == 0);

addpath detector;
newdets = zeros(0, 7);

iinfo = imfinfo(imfile);

for i = 1:length(midx)
    [model, views, bbox] = getDetectionInfo(anno.obj_annos(midx(i)));
    assert(strcmp(imfile(find(imfile == '/', 1, 'last')+1:end), anno.obj_annos(midx(i)).im));
    if(isempty(model))
        continue;
    end
    [~, ar] = boxinimage([iinfo.Height iinfo.Width], bbox);
    if(ar < 0.5)
        det = [repmat(bbox, length(views), 1), views', repmat(-4, length(views), 1)];
    else
        det = detect_positive(imfile, bbox, model, ovth, views);
    end
    newdets(end+1:end+size(det, 1), :) = [anno.obj_annos(midx(i)).objtype * ones(size(det, 1), 1), det];
end
rmpath detector;

% search for all layout candidate
% if there are no suitable candidate, run detector and append the
% confidence
end

function [model, view, bbox] = getDetectionInfo(objanno)
bbox = [objanno.x1, objanno.y1, objanno.x2, objanno.y2];
if(objanno.objtype == 1)
    % sofa
    temp = load('detector/data/2007/sofa_final');
    model = temp.model;    view = 1:length(model.index_pose);
elseif(objanno.objtype == 2)
    % table
    temp = load('detector/data/2007/table_final');
    model = temp.model;    view = 1:length(model.index_pose);
else
    model = [];
    view = [];
end

end