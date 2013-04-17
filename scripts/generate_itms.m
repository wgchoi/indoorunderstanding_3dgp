
load('/home/wgchoi/codes/eccv_indoor/IndoorLayoutUnderstanding/cache/itmobs/iter3/params.mat')
load ./cvpr13data/fulltrainset.mat

ptns = iparams.model.itmptns;
for i = 1:length(ptns)
    ptns(i).obs = zeros(8, 1);
end
params = appendITMtoParams(iparams, ptns);
%%
[sets] = generate_itm_trainsets(patterns, labels, params, ptns);

for i = 1:length(patterns)
	allimlists{i} = fullfile(pwd(), patterns(i).x.imfile);
end

save ./cvpr13data/room/itmtrainsets sets params ptns allimlists
