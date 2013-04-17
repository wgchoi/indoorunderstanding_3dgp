function [conf] = reestimateObjectConfidences(spg, maxidx, x, iclusters, params)

conf = zeros(size(x.dets, 1), 1);
if(strcmp(params.objconftype, 'samplesum'))
    temp = zeros(size(x.dets, 1), length(spg));
    for i = 1:length(spg)
        temp(spg(i).childs, i) = 1;
    end
    conf = sum(temp, 2);
elseif(strcmp(params.objconftype, 'odd'))
    pg = spg(maxidx);
    
    inset = false(size(x.dets, 1), 1);
    inset(pg.childs) = true;
    
    curconf = dot(getweights(params.model), features(pg, x, iclusters, params.model));
    
    for i = 1:size(x.dets, 1)
        pg2 = pg;
        if(inset(i))
            % try to remove it.
            pg2.childs(pg2.childs == i) = [];
            if(params.model.commonground)
                pg2 = findConsistent3DObjects(pg2, x, iclusters);
            end
            conf(i) = curconf - dot(getweights(params.model), features(pg2, x, iclusters, params.model));
        else
            % try to add it.
            pg2.childs(end+1) = i;
            if(params.model.commonground)
                pg2 = findConsistent3DObjects(pg2, x, iclusters);
            end
            conf(i) = dot(getweights(params.model), features(pg2, x, iclusters, params.model)) - curconf;
        end
        
        if(~isreal(conf(i)))
            keyboard
        end
    end
elseif(strcmp(params.objconftype, 'orgdet'))
    conf = x.dets(:, end);
end

end