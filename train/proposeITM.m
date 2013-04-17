function rules = proposeITM(pg, x, isolated, params)
%%% propose all possible ITM rules
%%% found from given example
%%% any combination of objects can be the candidates
%%% validity will be examined by considering the frequency

rules = ITMrule(); rules(:) = [];

% find common grounding
pg = findConsistent3DObjects(pg, x, isolated);

objtypes = []; objlocs = []; objcubes = {}; objpose = []; objsubtypes = [];
for i = 1:length(pg.childs)
    iidx = pg.childs(i);
    
    assert(isolated(iidx).isterminal == 1);
    
    objtypes(end + 1) = isolated(iidx).ittype;
    if(isfield(x, 'hobjs'))
        % locs(j, 1:3) = x.hobjs(iclusters(i1).chindices(j)).locs(1:3, pg.objscale(idx)) * pg.objscale(idx);
        % locs(j, 4) = x.hobjs(iclusters(i1).chindices(j)).angle;
        objlocs(end + 1, :) =  x.hobjs(iidx).locs(:, pg.subidx(i)) .* pg.objscale(i);
        objcubes{end + 1} = x.hobjs(iidx).cubes(:, :, pg.subidx(i)) .* pg.objscale(i);
        objpose(end + 1) = x.hobjs(iidx).angle;
        
        objsubtypes(end + 1) = x.dets(iidx, 2);
    else
        objlocs(end + 1, :) = x.locs(iidx, 1:3) .* pg.objscale(i);
        objcubes{end + 1} = x.cubes{iidx} .* pg.objscale(i);
        objpose(end + 1) = x.locs(iidx, 4) ;
        
        objsubtypes(end + 1) = x.dets(iidx, 2);
    end
end

comb = genAllCombinations(length(pg.childs));
% remove no/single object cases.
comb(sum(comb, 2) == 0, :) = [];
comb(sum(comb, 2) == 1, :) = [];

if(isfield(params.model, 'humancentric') && params.model.humancentric)
    comb(sum(comb, 2) > 3, :) = []; % ignore
    % allow human to others only!!
    removeidx = [];
    for i = 1:size(comb, 1)
        idx = find(comb(i, :) > 0);
        if(sum(objtypes(idx) == 7) >= 2 || sum(objtypes(idx) == 7) == 0)
            removeidx(end+1) = i;
        end
    end
    comb(removeidx, :) = [];
end

for i = 1:size(comb, 1)
    parts = find(comb(i, :));
    numpart = sum(comb(i, :));
    
    rules(i) = ITMrule(numpart);  
    
    % x and z location
    partslocs = objlocs(parts, [1 3]);
    partspose = objpose(parts);
    partstype = objtypes(parts);
    
    cloc = mean(partslocs, 1);
    theta = atan2(partslocs(2, 2) - partslocs(1, 2), partslocs(2, 1) - partslocs(1, 1));
    
    R = rotationMat(theta);
    
    dloc = ( partslocs - repmat(cloc, size(partslocs, 1), 1) ) * R;
    dpose =  partspose - theta;
    
    for j = 1:length(parts)
        rules(i).parts(j).citype = partstype(j);
        if(params.model.objmodel(partstype(j)).submodel_sensitive)
            rules(i).parts(j).subtype = objsubtypes(j);
        else
            rules(i).parts(j).subtype = -1;
        end
        rules(i).parts(j).dx = dloc(j, 1);
        rules(i).parts(j).dy = 0;
        rules(i).parts(j).dz = dloc(j, 2);
        rules(i).parts(j).da = dpose(j);
        
        % initial deformation costs
        rules(i).parts(j).wx = -5;
        rules(i).parts(j).wy = -5;
        rules(i).parts(j).wz = -5;
        rules(i).parts(j).wa = -3;
    end
    
    rules(i).biases(:) = numpart;
end

end

%%% find all possible sets of combinations.
% sets = recFindSets(indices);
function combinations = genAllCombinations(num)

if(num == 0)
    combinations = false(1, 0);
    return;
end

subc = genAllCombinations(num - 1);
combinations = [false(size(subc, 1), 1), subc];
combinations = [combinations ; true(size(subc, 1), 1), subc];

end