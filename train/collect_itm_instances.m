function [didx, composite] = collect_itm_instances(patterns, labels, params, ptn)
composite = graphnodes(0);
didx = [];
%%% match examples
for i = 1:length(patterns)
    if(isempty(labels))
        temp = findITMCandidates(patterns(i).x, patterns(i).isolated, params, ptn);
    else
        temp = findITMCandidates(patterns(i).x, patterns(i).isolated, params, ptn, labels(i).pg.childs, labels(i).pg.subidx, 0);
    end
    composite(end+1:end+length(temp)) = temp;
    didx(end+1:end+length(temp)) = i .* ones(1, length(temp));
end

end