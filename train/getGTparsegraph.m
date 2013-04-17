function gpg = getGTparsegraph(x, iclusters, anno, model)
gpg = parsegraph();
gpg.scenetype = 1; % not implemented yet

[~, gpg.layoutidx] = min(x.lerr);

ovth = 0.5;
obts = [];

for i = 1:length(anno.obj_annos)
    if(isfield(x, 'hobjs'))
        gtbb = [anno.obj_annos(i).x1 anno.obj_annos(i).y1 anno.obj_annos(i).x2 anno.obj_annos(i).y2];
        
        maxov = 0;
        maxidx = [0, 0];
        
        for j = 1:length(x.hobjs)
            if(x.hobjs(j).oid == anno.obj_annos(i).objtype)
                if(x.hobjs(j).oid == 2 ... % don't care if it is a table
                    || anglediff(x.dets(j, 3), anno.obj_annos(i).azimuth) <= pi / 6)
                    or = boxoverlap(x.dets(j, 4:7), gtbb);
                    
                    if(or > maxov)
                        maxov = or;
                        or = boxoverlap(x.hobjs(j).bbs', gtbb);
                        [~, idx] = max(or);
                        maxidx(1) = j;
                        maxidx(2) = idx;                        
                    end
                end
            end
        end
        
        if(maxov > ovth)
            gpg.childs(end+1) = maxidx(1);
            gpg.subidx(end+1) = maxidx(2);
        end
    else
        % old version
        or = zeros(1, size(x.dets, 1));
        for j = 1:size(x.dets, 1)
            if(x.dets(j, 1) == anno.obj_annos(i).objtype)
                if(x.dets(j, 1) == 2 ... % don't care if it is a table
                        || anglediff(x.dets(j, 3), anno.obj_annos(i).azimuth) <= pi / 6)
                    gtbb = [anno.obj_annos(i).x1 anno.obj_annos(i).y1 anno.obj_annos(i).x2 anno.obj_annos(i).y2];
                    or(j) = boxoverlap(gtbb, x.dets(j, 4:7));
                end
            end
        end

        [dval, midx] = max(or);
        if(dval > ovth)
            gpg.childs(end+1) = midx;
            obts = [obts, min(x.cubes{midx}(2, :))];
        end
    end
end

if(isfield(anno, 'hmn_annos'))
    assert(length(anno.hmns{1}) + length(anno.hmns{2}) == length(anno.hmn_annos));
    
	for i = 1:length(anno.hmn_annos)
        if(i <= length(anno.hmns{1}))
            x1 = anno.hmns{1}(i).head_bbs(1) - anno.hmns{1}(i).head_bbs(3);
            x2 = anno.hmns{1}(i).head_bbs(1) + 2 * anno.hmns{1}(i).head_bbs(3);
        else
            idx = i - length(anno.hmns{1});
            x1 = anno.hmns{2}(idx).head_bbs(1) - anno.hmns{2}(idx).head_bbs(3);
            x2 = anno.hmns{2}(idx).head_bbs(1) + 2 * anno.hmns{2}(idx).head_bbs(3);
        end
        gtbb = [x1 anno.hmn_annos(i).y1 x2 anno.hmn_annos(i).y2];
        % gtbb = [anno.hmn_annos(i).x1 anno.hmn_annos(i).y1 anno.hmn_annos(i).x2 anno.hmn_annos(i).y2];
        
        maxov = 0;
        maxidx = [0, 0];
        
        for j = 1:length(x.hobjs)
            if(x.hobjs(j).oid == 7) % anno.hmn_annos(i).objtype)
				or = boxoverlap(x.dets(j, 4:7), gtbb);
				
				if(or > maxov)
					maxov = or;
					or = boxoverlap(x.hobjs(j).bbs', gtbb);
					[~, idx] = max(or);
					maxidx(1) = j;
					maxidx(2) = idx;                        
				end
            end
        end
        
        if(maxov > ovth)
            gpg.childs(end+1) = maxidx(1);
            gpg.subidx(end+1) = maxidx(2);
        end
	end
end

if(isfield(x, 'hobjs'))
    if(length(unique(gpg.childs)) ~= length(gpg.childs))
        [gpg.childs, idx] = unique(gpg.childs);
        gpg.subidx = gpg.subidx(idx);
    end

    if (isfield(model, 'commonground') && model.commonground)
        gpg = findConsistent3DObjects(gpg, x, iclusters);
    else
        if(isempty(obts))
            gpg.camheight = 1.5;
        else
            gpg.camheight = -mean(obts);
        end
    end
    % or different nethid
%     gpg.camheight = 0;
%     for i = 1:length(gpg.subidx)
%         gpg.camheight = gpg.camheight  + min(x.hobjs(gpg.childs(i)).cubes(2, :, gpg.subidx(i)));
%     end
%     gpg.camheight = -gpg.camheight / length(gpg.subidx);
else
    if(length(unique(gpg.childs)) ~= length(gpg.childs))
        gpg.childs = unique(gpg.childs);
    end
    
    if (isfield(model, 'commonground') && model.commonground)
        gpg = findConsistent3DObjects(gpg, x, iclusters);
    else
        if(isempty(obts))
            gpg.camheight = 1.5;
        else
            gpg.camheight = -mean(obts);
        end
    end
    
    gpg.lkhood = dot(getweights(model), features(gpg, x, iclusters, model));
end

end
