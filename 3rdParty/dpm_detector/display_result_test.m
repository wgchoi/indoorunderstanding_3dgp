function display_result_test(cls, vnum)

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

% open prediction file
pre_file = sprintf('data/%s_view%d.pre', cls, vnum);
ftest = fopen(pre_file, 'r');

N = numel(index_test);
path_anno = sprintf('../Annotations/%s', cls);
path_image = sprintf('../Images/%s', cls);

figure;
for i = 1:N
    index = index_test(i);
    if i ~= 1 && mod(i-1, 16) == 0
        pause;
    end
    ind = mod(i-1,16)+1;
    subplot(4, 4, ind);
    file_img = sprintf('%s/%04d.jpg', path_image, index);
    I = imread(file_img);    
    imshow(I);
    hold on;
    
    % read ground truth
    file_ann = sprintf('%s/%04d.mat', path_anno, index);
    image = load(file_ann);
    object = image.object;
    bbox = object.bbox;
    bbox = [bbox(:,1) bbox(:,2) bbox(:,1)+bbox(:,3) bbox(:,2)+bbox(:,4)];
    view = object.view;
    azimuth_gt = view(1,1);
    ind_gt = find_interval(azimuth_gt, vnum);
    
    num = fscanf(ftest, '%d', 1);
    for k = 1:num
        A = fscanf(ftest, '%f', 8);
        if k > 1
            continue;
        end
        A(4+1) = max(A(4+1), 1);
        A(4+2) = max(A(4+2), 1);
        A(4+3) = min(A(4+3), size(I, 2));
        A(4+4) = min(A(4+4), size(I, 1));        
     
        til = sprintf('gt: %d, prediction: %d', ind_gt, A(3));
        title(til);
        % draw bounding box
        bbox_pr = [A(5), A(6), A(7)-A(5), A(8)-A(6)];
        if box_overlap(bbox(1,:), A(5:8)) >= 0.5
            rectangle('Position', bbox_pr, 'EdgeColor', 'g', 'LineWidth',2);
        else
            rectangle('Position', bbox_pr, 'EdgeColor', 'r', 'LineWidth',2);
        end
    end
    
    subplot(4, 4, ind);
    hold off;
end
fclose(ftest);

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