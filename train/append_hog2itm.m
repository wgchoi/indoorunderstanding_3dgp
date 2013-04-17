function params = append_hog2itm(params, prefix)

ptns = params.model.itmptns;
for i = 1:length(ptns)
    try
        temp = load([prefix num2str(ptns(i).type, '%03d') '_root']);
    catch
        assert(0);
        ptns(i).hogmodel = [];
        ptns(i).hogview = {};
        continue;
    end
    
    ptns(i).hogmodel = temp.models;
    ptns(i).hogview = temp.index_pose;
end
params.model.itmptns = ptns;

end