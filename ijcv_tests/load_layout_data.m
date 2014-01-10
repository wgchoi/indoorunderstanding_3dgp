function layoutsets = load_layout_data(postfix)

% ddir = ['cache/NewLayoutResults/layout_res/result_object_' postfix '/layout/'];
ddir = ['cache/newlayout/result_object_' postfix '/layout/'];

layoutsets{1} = load(fullfile(ddir, 'bedroom/res_set_jpg.mat'));
layoutsets{2} = load(fullfile(ddir, 'livingroom/res_set_jpg.mat'));
layoutsets{3} = load(fullfile(ddir, 'diningroom/res_set_jpg.mat'));

layoutsets{1}.name = 'bedroom';
layoutsets{2}.name = 'livingroom';
layoutsets{3}.name = 'diningroom';

end
