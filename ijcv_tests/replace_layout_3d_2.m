function [data] = replace_layout_3d_2(data, models, layoutsets)

parfor i = 1:length(data)
    data(i) = replace_layout1(data(i), models, layoutsets);
end

end

function data = replace_layout1(data, models, layoutsets)

[imdir, filename, ext] = fileparts(data.x.imfile);
[~, roomtype] = fileparts(imdir);

[id1, id2] = find_layout_idx(layoutsets, roomtype, filename);

data = assign_layout(data, layoutsets{id1}.vpdata{id2}, layoutsets{id1}.boxlayout{id2});

% re-estimate 3D information of each detection.
[hobjs, invalid_idx] = generate_object_hypotheses(data.x.imfile, data.x.K, data.x.R, data.x.yaw, objmodels(), data.x.dets);
hobjs(invalid_idx) = [];
data.x.hobjs = hobjs;
data.x.dets(invalid_idx, :) = [];

data.x = precomputeOverlapArea(data.x);

data.iclusters = clusterInteractionTemplates(data.x, models);
data.gpg = getGTparsegraph(data.x, data.iclusters, data.anno, models);
data.gpg.scenetype = id1;

end

function data = assign_layout(data, vpdata, boxlayout)

[imfile] = get_im_file(data);
data.x.imfile = imfile;

img = imread(data.x.imfile);
data.x.imsz(1) = size(img, 1);
data.x.imsz(2) = size(img, 2);

rfactor = size(img, 1) ./ vpdata.dim(1);

data.x.vp = vpdata.vp .* rfactor;
[ data.x.K, data.x.R ]=calibrate_cam(data.x.vp, size(img, 1), size(img, 2));

% new estimate yaw and pitch from the central ray
cray3 = (data.x.K * data.x.R) \ [size(img, 1)/2; size(img, 2)/2; 1];
data.x.yaw = atan2(-cray3(1), -cray3(3));
data.x.pitch = atan2(-cray3(2), -cray3(3));

%%%% images were rescaled for faster computation
data.x.lpolys = boxlayout.polyg(boxlayout.reestimated(:, 2), :);
data.x.faces = {};
data.x.corners = {};
data.x.lfpts = {};

errpoly = false(size(data.x.lpolys, 1), 1);
for i = 1:size(data.x.lpolys, 1)
    for j = 1:size(data.x.lpolys, 2)
        data.x.lpolys{i, j} = data.x.lpolys{i, j} * rfactor;
    end
    try
        [data.x.faces{i}, data.x.corners{i}] = getRoomFaces(data.x.lpolys(i, :), size(img, 1), size(img, 2), data.x.K, data.x.R);
    catch em
        errpoly(i) = true;
    end
    data.x.lfpts{i} = lpoly2fourpoints(data.x.lpolys(i, :), data.x.imsz);
end
data.x.lconf = boxlayout.reestimated(:, 1);

data.x.lpolys(errpoly, :) = [];
data.x.faces(errpoly) = [];
data.x.corners(errpoly) = [];
data.x.lfpts(errpoly) = [];
data.x.lconf(errpoly) = [];

data.x.lloss = zeros(1, length(data.x.lconf));
data.x.lerr = zeros(1, length(data.x.lconf));
data.x.lerr_ywc3d = zeros(1, length(data.x.lconf));
data.x.base_ywc3d = zeros(1, length(data.x.lconf));
for i = 1:length(data.x.lconf)
    data.x.lloss(i) = layout_loss(data.anno.gtPolyg, data.x.lpolys(i, :));
    data.x.lerr(i) = getPixerr(data.anno.gtPolyg, data.x.lpolys(i, :));
    if isempty(data.x.lpolys{i, 1}) && isempty(data.x.lpolys{i, 2})
        data.x.lerr_ywc3d(i) = NaN;
        data.x.base_ywc3d(i) = NaN;
    else
        [data.x.lerr_ywc3d(i) data.x.base_ywc3d(i)] = get_3d_space_iu_2( ...
            data.anno, data.x.lpolys(i, :), data.x.imsz, data.x.vp, data.x.K, data.x.R);
    end
end

end

function [id1, id2] = find_layout_idx(layoutsets, roomtype, filename)

if(strcmp(roomtype, layoutsets{1}.name))
    id1 = 1;
elseif(strcmp(roomtype, layoutsets{2}.name))
    id1 = 2;
elseif(strcmp(roomtype, layoutsets{3}.name))
    id1 = 3;
end

id2 = -1;
for i = 1:length(layoutsets{id1}.fnames)
    [~, fname] = fileparts(layoutsets{id1}.fnames{i});
    if(strcmp(filename, fname))
        id2 = i;
    end
end

assert(id2 > 0);

end
