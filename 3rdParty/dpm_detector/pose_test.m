% cls: class name
% n: view number
function pose_test(cls, n, thresh)

switch cls
    case {'car'}
        %index_test = 241:480;
        index_test = 1:150;
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

model_name = sprintf('data/%s_view%d.mat', cls, n);
object = load(model_name);
model = object.model;
index_pose = model.index_pose;

path_image = sprintf('../Images/%s', cls);
file_name = sprintf('data/%s_view%d.pre', cls, n);
fp = fopen(file_name, 'w');

for i = 1:numel(index_test)
    disp(i);
    index = index_test(i);
    file_img = sprintf('%s/%04d.jpg', path_image, index);
    I = imread(file_img);
    det = process(I, model, thresh);
    num = size(det, 1);
    fprintf('%d objects are detected\n', num);
    
    % write detection to file
    fprintf(fp, '%d\n', num);
    for j = 1:num
        fprintf(fp, '1 0 %d %f ', index_pose(det(j,5)), det(j,6));
        fprintf(fp, '%f ', det(j, 1:4));
        fprintf(fp, '\n');
    end
end

fclose(fp);
