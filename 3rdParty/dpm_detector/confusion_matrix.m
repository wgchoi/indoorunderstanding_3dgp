function [cmatrix, ctable] = confusion_matrix(cls, vnum)

switch cls
    case {'car'}
        index_test = 241:480;
    case {'bicycle'}
        index_test = 361:720;
    case {'chair'}
        object = load('../svm_struct_cuda_mpi/data/chair.mat');
        index_test = object.index_test;
    case {'bed'};
        object = load('../svm_struct_cuda_mpi/data/bed.mat');
        index_test = object.index_test;
    case {'sofa'}
        object = load('../svm_struct_cuda_mpi/data/sofa.mat');
        index_test = object.index_test;
    case {'table'}
        object = load('../svm_struct_cuda_mpi/data/table.mat');
        index_test = object.index_test;        
end

cmatrix = zeros(vnum);

N = numel(index_test);
path_anno = sprintf('../Annotations/%s', cls);

% prediction
fpr = fopen(sprintf('data/%s_view%d.pre', cls, vnum), 'r');

for i = 1:N
    % read detections
    num = fscanf(fpr, '%d', 1);
    if num == 0
        fprintf('no detection for test image %d\n', i);
        continue;
    else
        A = zeros(num, 8);
        for j = 1:num
            A(j,:) = fscanf(fpr, '%f', 8);
        end
    end
    
    % read ground truth
    index = index_test(i);
    file_ann = sprintf('%s/%04d.mat', path_anno, index);
    image = load(file_ann);
    object = image.object;
    bbox = object.bbox;
    view = object.view;
    n = size(view, 1);
    
    if n == 1
        azimuth_gt = view(1,1);
        ind_gt = find_interval(azimuth_gt, vnum);
        ind_pr = A(1,3);
        cmatrix(ind_gt, ind_pr) = cmatrix(ind_gt, ind_pr) + 1;
    else
        fprintf('Test image %d contains mulitple instances.\n', i);
        for j = 1:n
            % ground truth viewpoint
            azimuth_gt = view(j,1);
            ind_gt = find_interval(azimuth_gt, vnum);
            % ground truth bounding box
            bbox_gt = [bbox(j,1) bbox(j,2) bbox(j,1)+bbox(j,3) bbox(j,2)+bbox(j,4)];
            flag = 0;
            for k = 1:num
                % get predicted bounding box
                bbox_pr = A(k,end-3:end)';
                o = box_overlap(bbox_gt, bbox_pr);
                if o >= 0.5
                    flag = 1;
                    ind_pr = A(k,3);
                    cmatrix(ind_gt, ind_pr) = cmatrix(ind_gt, ind_pr) + 1;
                    break;
                end
            end
            if flag == 0
                fprintf('No detection with overlap more than 0.5\n');
            end
        end
    end
end

fclose(fpr);

fprintf('Accuracy: %.2f%%\n', sum(diag(cmatrix)) / sum(sum(cmatrix)) * 100);
ctable = cmatrix;

for i = 1:vnum
    if sum(cmatrix(i,:)) ~= 0
        cmatrix(i,:) = cmatrix(i,:) ./ sum(cmatrix(i,:));
    end
end

function ind = find_interval(azimuth, num)

if num == 8
    a = 22.5:45:337.5;
elseif num == 24
    a = 7.5:15:352.5;
end

for i = 1:numel(a)
    if azimuth < a(i)
        break;
    end
end
ind = i;
if azimuth > a(end)
    ind = 1;
end