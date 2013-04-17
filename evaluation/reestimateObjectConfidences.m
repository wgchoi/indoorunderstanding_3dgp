% estimate one object confidence
% baseline detector : return the original confidence
% 3DGP1 : return the logodd ratio - try to add/remove object from the
%  optimal solution. return the difference in energy value.
% 3DGP2 : return the logodd ratio2 - try to add/remove object from the
%  optimal solution. If one object can be added by adding a 3DGP (other
%  constituent objects are already in the graph) and it gives higher energy
%  improvement, then return the difference. 
function [conf] = reestimateObjectConfidences(spg, maxidx, x, iclusters, params)
if(isfield(params, 'quicklearn'))
    quickrun = params.quicklearn;
else
    quickrun = false;
end

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
    
    oidx = getObjIndices(pg, iclusters);
    inset(oidx) = true;
    
    curconf = dot(getweights(params.model), features(pg, x, iclusters, params.model));
    
    for i = 1:size(x.dets, 1)
        pg2 = pg;
        if(inset(i))
            if(sum(pg.childs == i) == 0)
                % 3D-GP
                for j = 1:length(pg.childs)
                    if(any(iclusters(pg.childs(j)).chindices == i))
                        temp = setdiff(iclusters(pg.childs(j)).chindices, i);
                        
                        pg2.childs(pg2.childs == pg.childs(j)) = [];
                        
                        pg2.childs = [pg2.childs, temp];
                        if(params.model.commonground)
                            pg2 = findConsistent3DObjects(pg2, x, iclusters, quickrun);
                        end
                        conf(i) = curconf - dot(getweights(params.model), features(pg2, x, iclusters, params.model));
                        break;
                    end
                end
                assert(conf(i) ~= 0);
            else
                % try to remove it.
                pg2.childs(pg2.childs == i) = [];
                if(params.model.commonground)
                    pg2 = findConsistent3DObjects(pg2, x, iclusters, quickrun);
                end
                conf(i) = curconf - dot(getweights(params.model), features(pg2, x, iclusters, params.model));
            end
        else
            % try to add it.
            pg2.childs(end+1) = i;
            if(params.model.commonground)
                pg2 = findConsistent3DObjects(pg2, x, iclusters, quickrun);
            end
            conf(i) = dot(getweights(params.model), features(pg2, x, iclusters, params.model)) - curconf;
        end
        
        if(~isreal(conf(i)))
            keyboard
        end
    end    
elseif(strcmp(params.objconftype, 'odd2'))
    pg = spg(maxidx);
    
    inset = false(size(x.dets, 1), 1);
    
    oidx = getObjIndices(pg, iclusters);
    inset(oidx) = true;
    
    curconf = dot(getweights(params.model), features(pg, x, iclusters, params.model));
    
    for i = 1:size(x.dets, 1)
        pg2 = pg;
        if(inset(i))
            if(sum(pg.childs == i) == 0)
                % 3D-GP
                for j = 1:length(pg.childs)
                    if(any(iclusters(pg.childs(j)).chindices == i))
                        temp = setdiff(iclusters(pg.childs(j)).chindices, i);
                        
                        pg2.childs(pg2.childs == pg.childs(j)) = [];
                        
                        pg2.childs = [pg2.childs, temp];
                        if(params.model.commonground)
                            pg2 = findConsistent3DObjects(pg2, x, iclusters, quickrun);
                        end
                        conf(i) = curconf - dot(getweights(params.model), features(pg2, x, iclusters, params.model));
                        break;
                    end
                end
                assert(conf(i) ~= 0);
            else
                % try to remove it.
                pg2.childs(pg2.childs == i) = [];
                if(params.model.commonground)
                    pg2 = findConsistent3DObjects(pg2, x, iclusters, quickrun);
                end
                conf(i) = curconf - dot(getweights(params.model), features(pg2, x, iclusters, params.model));
            end
        else
            % try to add it.
            pg2.childs(end+1) = i;
            if(params.model.commonground)
                pg2 = findConsistent3DObjects(pg2, x, iclusters, quickrun);
            end
            conf(i) = dot(getweights(params.model), features(pg2, x, iclusters, params.model)) - curconf;
        end
        
        if(~isreal(conf(i)))
            keyboard
        end
    end
    
    % check if adding one object as a part of 3DGP gives 
    % higher confidence than adding it alone
    for i = size(x.dets, 1)+1:length(iclusters)
        pg2 = pg;
        ic = iclusters(i);
        incluster = [];
        for j = 1:length(pg2.childs)
            if(any(pg2.childs(j) == ic.chindices))
                incluster(end+1) = j;
            end
        end
        
        if(length(incluster) == length(ic.chindices) - 1)
            tidx = setdiff(ic.chindices, pg2.childs(incluster));
            if(inset(tidx))
                continue;
            end
            assert(length(tidx) == 1);
            
            pg2.childs(incluster) = [];
            pg2.childs(end+1) = i;
            
            if(params.model.commonground)
                pg2 = findConsistent3DObjects(pg2, x, iclusters, quickrun);
            end
            tempval = dot(getweights(params.model), features(pg2, x, iclusters, params.model)) - curconf;
            if(conf(tidx) < tempval)
                conf(tidx) = tempval;
            end
        end
    end
elseif(strcmp(params.objconftype, 'orgdet'))
    conf = x.dets(:, end);
end

end