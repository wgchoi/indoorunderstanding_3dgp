function idx = find_detidx(dets, filename)
idx = -1;
for i = 1:length(dets)
    if(compare_file_name(dets{i}.name, filename))
        idx = i;
        return;
    end
end
end