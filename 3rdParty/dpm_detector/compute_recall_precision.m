% compute recall and precision
function [recall, precision] = compute_recall_precision(cls, vnum, threshold)

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

M = numel(index_test);
path_anno = sprintf('../Annotations/%s', cls);

% open prediction file
pre_file = sprintf('data/%s_view%d.pre', cls, vnum);
fpr = fopen(pre_file, 'r');

energy = [];
correct = [];
overlap = [];
count = zeros(M,1);
num = zeros(M,1);
num_pr = 0;
for i = 1:M
    % read ground truth bounding box
    index = index_test(i);
    file_ann = sprintf('%s/%04d.mat', path_anno, index);
    image = load(file_ann);
    object = image.object;
    bbox = object.bbox;
    bbox = [bbox(:,1) bbox(:,2) bbox(:,1)+bbox(:,3) bbox(:,2)+bbox(:,4)];
    count(i) = size(bbox, 1);
    
    num(i) = fscanf(fpr, '%d', 1);
    % for each predicted bounding box
    for j = 1:num(i)
        num_pr = num_pr + 1;
        A = fscanf(fpr, '%f', 8);
        energy(num_pr) = A(4);
        % get predicted bounding box
        bbox_pr = A(end-3:end)';
        
        % compute box overlap
        if isempty(bbox) == 0
            o = box_overlap(bbox, bbox_pr);
            index = find(o >= 0.5);
            overlap{end+1} = index;
            if numel(index) >= 1
                correct(num_pr) = 1;
            else
                correct(num_pr) = 0;               
            end
        else
            overlap{num_pr} = [];
            correct(num_pr) = 0;
        end
    end
end
fclose(fpr);
overlap = overlap';

n = numel(threshold);
recall = zeros(n,1);
precision = zeros(n,1);
for i = 1:n
    % compute precision
    num_positive = numel(find(energy >= threshold(i)));
    num_correct = sum(correct(energy >= threshold(i)));
    if num_positive ~= 0
        precision(i) = num_correct / num_positive;
    else
        precision(i) = 0;
    end
    
    % compute recall
    correct_recall = correct;
    correct_recall(energy < threshold(i)) = 0;
    num_correct = 0;
    start = 1;
    for j = 1:M
        for k = 1:count(j)
            for s = start:start+num(j)-1
                if correct_recall(s) == 1 && numel(find(overlap{s} == k)) ~= 0
                    num_correct = num_correct + 1;
                    break;
                end
            end
        end
        start = start + num(j);
    end
    recall(i) = num_correct / sum(count);
end

ap = VOCap(recall(end:-1:1), precision(end:-1:1));

% draw recall-precision curve
figure;
plot(recall, precision, 'r', 'LineWidth',3);
xlabel('Recall');
ylabel('Precision');
tit = sprintf('Average Precision = %.1f', 100*ap);
title(tit);