function [itm_examples] = get_itm_examples(patterns, labels, didx, composites)

itm_examples = struct(  'imfile', cell(1, length(didx)), ...
                        'flip', false, ...
                        'bbox', [], 'angle', [], 'azimuth', [], ...
                        'objtypes', [], 'objboxes', [], 'objangs', [], 'objazs', []);

for i = 1:length(didx)
    x = patterns(didx(i)).x;
    
    if(x.imfile(1) == '/' || x.imfile(1) == '~')
        itm_examples(i).imfile = x.imfile; 
    else
        itm_examples(i).imfile = fullfile(pwd(), x.imfile); 
    end
    itm_examples(i).angle = composites(i).angle;
    
    if(isfield(x, 'hobjs'))
        oidx = composites(i).chindices;
        
        allx = [];
        ally = [];
        
        for j = 1:length(oidx)
            itm_examples(i).objtypes(j) = x.hobjs(oidx(j)).oid;
            itm_examples(i).objboxes(:, j) = x.hobjs(oidx(j)).bbs(:, 14);
            itm_examples(i).objangs(j) = x.hobjs(oidx(j)).angle;
            itm_examples(i).objazs(j) = x.hobjs(oidx(j)).azimuth;
            
            allx = [allx, x.hobjs(oidx(j)).bbs([1 3], 14)'];
            ally = [ally, x.hobjs(oidx(j)).bbs([2 4], 14)'];
        end
    else
        % not implemented
        assert(0);
    end
    itm_examples(i).bbox = [min(allx); min(ally); max(allx); max(ally)];
    itm_examples(i).azimuth = composites(i).azimuth;
    
    %
    pg = parsegraph(1); % labels(didx(i)).pg;
    pg.childs= oidx;
    pg.subidx(:) = 14;
    pg = findConsistent3DObjects(pg, patterns(didx(i)).x, patterns(didx(i)).isolated);
    
    loc1 = x.hobjs(oidx(1)).locs(:, 14) * pg.objscale(1);
    loc2 = x.hobjs(oidx(2)).locs(:, 14) * pg.objscale(2);

    camangle = atan2(-composites(i).loc(2), -composites(i).loc(1)); 
    azimuth1 = camangle - composites(i).angle;
    
    camangle = atan2(-loc1(3), -loc1(1)); 
    azimuth2 = camangle - composites(i).angle;
    
    itm_examples(i).azimuth = azimuth2;
    
    continue;
    
    
    show2DGraph(pg, patterns(didx(i)).x, patterns(didx(i)).isolated);
    show3DGraph(pg, patterns(didx(i)).x, patterns(didx(i)).isolated);
    hold on;
    plot3(loc1(1), loc1(2), loc1(3), 'co', 'markersize', 30);
    plot3([loc1(1) loc2(1)], [loc1(2) loc2(2)], [loc1(3) loc2(3)], ...
        'r--', 'linewidth', 3);
    plot3([0 composites(i).loc(1)] , [0 0], [0 composites(i).loc(2)], ...
        'k--', 'linewidth', 3);
    plot3([0 loc1(1)] , [0 0], [0 loc1(3)], ...
        'b--', 'linewidth', 3);
    view([0 180])
    hold off;
    
    disp(num2str(itm_examples(i).azimuth /pi * 180, '%.02f'))
    disp(num2str(azimuth1 /pi * 180, '%.02f'))
    disp(num2str(azimuth2 /pi * 180, '%.02f'))
    
    pause;
end

end