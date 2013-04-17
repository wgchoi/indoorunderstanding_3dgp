function phi = feat_test2(pg, x, iclusters, model)

featlen =   1 + ...                 % layout confidence : no bias required, selection problem    
            model.nobjs * 3 + ...   % overlap ratio between object and wall
            1;                      % smaller floor area

phi = zeros(featlen, 1);
ibase = 1;
objidx = getObjIndices(pg, iclusters);

assert(isfield(pg, 'objscale'));
%% scene layout confidence
phi(ibase) = x.lconf(pg.layoutidx);
ibase = ibase + 1;
% 
% imshow(x.imfile);
% btm_idx = [1 2 6 5 1];
% hold on;
% for i = 1:length(objidx)
%     rt1 = x.projs(objidx(i)).poly(:, btm_idx);
%     plot(rt1(1, :), rt1(2, :), 'b-');
%     
%     ct = mean(rt1, 2);
%     vt = rt1 - repmat(ct, 1, 5);
%     
%     rt2 = repmat(ct, 1, 5) + vt ./ 2;
%     rt3 = repmat(ct, 1, 5) + vt .* 1.5;
%     
%     plot(rt2(1, :), rt2(2, :), 'r-');
%     plot(rt3(1, :), rt3(2, :), 'y-');
% end
% hold off;
% return;
btm_idx = [1 2 6 5 1];

if(isempty(x.lpolys{pg.layoutidx, 1}))
    xfloor = [0];
    yfloor = [0];
else
    [xfloor, yfloor] = poly2cw(x.lpolys{pg.layoutidx, 1}(:, 1), x.lpolys{pg.layoutidx, 1}(:, 2));
end

for i = 1:length(objidx)
    if(isfield(x, 'hobjs'))
        poly = x.hobjs(objidx(i)).polys(:, btm_idx, pg.subidx(i));
    else
        poly = x.projs(objidx(i)).poly(:, btm_idx);
    end
    [poly(1, :), poly(2, :)] = poly2cw(poly(1, :), poly(2, :));
    [ipoly, opoly] = get_inner_outer_polys(poly);

    objbase = 3 * (iclusters(objidx(i)).ittype - 1);

    [xi, yi] = polybool('intersection', ipoly(1, :), ipoly(2, :), xfloor, yfloor);
    a1i = polyarea(ipoly(1, :), ipoly(2, :));
    a2i = polyarea(xi, yi);
    
    if(strcmp(model.feattype, 'new4'))
        phi(ibase + objbase) = phi(ibase + objbase) + (a1i - a2i) / a1i;
    elseif(strcmp(model.feattype, 'new5'))
        phi(ibase) = phi(ibase) + (a1i - a2i) / a1i;
    elseif(strcmp(model.feattype, 'new6'))
        phi(ibase + objbase) = phi(ibase + objbase) + 4 * (a1i - a2i) / a1i;
    end
    

    [xi, yi] = polybool('intersection', poly(1, :), poly(2, :), xfloor, yfloor);
    a1 = polyarea(poly(1, :), poly(2, :)) - a1i;
    a2 = polyarea(xi, yi) - a2i;
    
    if(strcmp(model.feattype, 'new4'))
        phi(ibase + objbase + 1) = phi(ibase + objbase + 1) + (a1 - a2) / a1;
    elseif(strcmp(model.feattype, 'new5'))
        phi(ibase + 1) = phi(ibase + 1) + (a1 - a2) / a1;
    elseif(strcmp(model.feattype, 'new6'))
        phi(ibase + objbase) = phi(ibase + objbase) + 2 * (a1 - a2) / a1;
    end    

    [xi, yi] = polybool('intersection', opoly(1, :), opoly(2, :), xfloor, yfloor);
    a1o = polyarea(opoly(1, :), opoly(2, :)) - a1 - a1i;
    a2o = polyarea(xi, yi) - a2 - a2i;
    
    if(strcmp(model.feattype, 'new4'))
        phi(ibase + objbase + 2) = phi(ibase + objbase + 2) + (a1o - a2o) / a1o;
    elseif(strcmp(model.feattype, 'new5'))
        phi(ibase + 2) = phi(ibase + 2) + (a1o - a2o) / a1o;
    elseif(strcmp(model.feattype, 'new6'))
        phi(ibase + objbase) = phi(ibase + objbase) + (a1o - a2o) / a1o;
    end
end
ibase = ibase + model.nobjs * 3;

phi(ibase) = polyarea(xfloor, yfloor) / prod(x.imsz);
ibase = ibase + 1;

assert(featlen == ibase - 1);
% if(any(isnan(phi)))
%     x.imfile
%     find(isnan(phi))
%     phi(isnan(phi)) = 0;
% end
% 
% if(any(isinf(phi)))
%     x.imfile
%     find(isinf(phi))
%     phi(isinf(phi)) = 0;
% end
assert(~(any(isnan(phi)) || any(isinf(phi))));

end
