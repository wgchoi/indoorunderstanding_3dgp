%%
i = 4;
[itm_examples] = get_itm_examples(data, indsets{i}, comps{i});
[itms, clusters, distmap] = cluster_itm_examples(itm_examples);
unique(clusters)
%%
for i = 1:length(unique(clusters))
    clf(); 
    i
    show_itm_examples([], itms(clusters == i))
    pause
end