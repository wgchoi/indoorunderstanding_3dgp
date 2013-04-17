function phi = feat_test(pg, x, iclusters, model)

if(strcmp(model.feattype, 'new4') || strcmp(model.feattype, 'new5') || strcmp(model.feattype, 'new6'))
    phi = feat_test2(pg, x, iclusters, model);
    return;
end

featlen =   1 + ... % layout confidence : no bias required, selection problem    
            model.nobjs + ... % overlap ratio between object and wall
            model.nobjs * ( length(model.ow_edge) - 1 ) + ... % object-wall inclusion 
            1;      % smaller floor area

phi = zeros(featlen, 1);
ibase = 1;
objidx = getObjIndices(pg, iclusters);

assert(isfield(pg, 'objscale'));
%% scene layout confidence
phi(ibase) = x.lconf(pg.layoutidx);
ibase = ibase + 1;

if strcmp(model.feattype, 'new') || strcmp(model.feattype, 'new3') || strcmp(model.feattype, 'hybrid')
    btm_idx = [1 2 6 5 1];
    if(isempty(x.lpolys{pg.layoutidx, 1}))
        xfloor = [0];
        yfloor = [0];
    else
        [xfloor, yfloor] = poly2cw(x.lpolys{pg.layoutidx, 1}(:, 1), x.lpolys{pg.layoutidx, 1}(:, 2));
    end

    for i = 1:length(objidx)
        if(isfield(x, 'hobjs'))
            rt1 = x.hobjs(objidx(i)).polys(:, btm_idx, pg.subidx(i));
        else
            rt1 = x.projs(objidx(i)).poly(:, btm_idx);
        end
        [xobj, yobj] = poly2cw(rt1(1, :), rt1(2, :));
        [xi, yi] = polybool('intersection', xobj, yobj, xfloor, yfloor);

        a1 = polyarea(xobj, yobj);
        a2 = polyarea(xi, yi);
        %if(~isfield(model, 'areanorm') || model.areanorm == 1)
        if strcmp(model.feattype, 'new3')
            phi(ibase + iclusters(objidx(i)).ittype - 1) = phi(ibase + iclusters(objidx(i)).ittype - 1) + (a1 - a2) / a1;
        else
            phi(ibase) = phi(ibase) + (a1 - a2) / a1;
        end
        %elseif(model.areanorm == 2)
        %    phi(ibase) = phi(ibase) + (a1 - a2) / prod(x.imsz);
        %    assert(0); % didn't work...
        %end
    end
end
ibase = ibase + model.nobjs;

% if (~isfield(model, 'noareaprior') || model.noareaprior == 0) ...
%     && (strcmp(model.feattype, 'new') || strcmp(model.feattype, 'hybrid'))
if strcmp(model.feattype, 'org') || (strcmp(model.feattype, 'new') || strcmp(model.feattype, 'new3') || strcmp(model.feattype, 'hybrid'))
     if(isempty(x.lpolys{pg.layoutidx, 1}))
        xfloor = [0];
        yfloor = [0];
    else
        [xfloor, yfloor] = poly2cw(x.lpolys{pg.layoutidx, 1}(:, 1), x.lpolys{pg.layoutidx, 1}(:, 2));
    end
    
    phi(ibase) = polyarea(xfloor, yfloor) / prod(x.imsz);
end
ibase = ibase + 1;

%% origianl feature
nbin = (length(model.ow_edge) - 1);
if strcmp(model.feattype, 'org') || strcmp(model.feattype, 'hybrid')
    cubes = cell(1, length(objidx));
    for i = 1:length(objidx)
        idx = objidx(i);
        if(isfield(x, 'hobjs'))
            cubes{i} = x.hobjs(idx).cubes(:,:,pg.subidx(i)) .* pg.objscale(i);
        else
            cubes{i} = x.cubes{idx} .* pg.objscale(i);
        end
    end
    % object-wall interaction - no inclusion
    for i = 1:length(cubes)
        %%%%%% need to make it robust!!!
        volume = cuboidRoomIntersection(x.faces{pg.layoutidx}, pg.camheight, cubes{i});
        temp = histc(volume(2:4), model.ow_edge);
        i1 = objidx(i);
        if(iclusters(i1).isterminal)
            idx = ibase + nbin * (iclusters(i1).ittype - 1);
            phi(idx:idx+nbin-1) = phi(idx:idx+nbin-1) + temp(1:end-1);
        else
            assert(false, 'not right');
        end
    end
end
ibase = ibase + model.nobjs * nbin;

assert(featlen == ibase - 1);
assert(~(any(isnan(phi)) || any(isinf(phi))));

end