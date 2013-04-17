function h = get_hypo_iprojections(imfile, K, R, yaw, objmodel, rect, attr, option)
if(nargin < 8)
	option = 0;
end

mid = attr(2);
dstep = 0.1; 

obj.bbs = rect;
cpt2 = [obj.bbs(1) + obj.bbs(3) / 2; obj.bbs(2) + obj.bbs(4) / 2];
cray3 = (K * R) \ [cpt2; 1];

aaa = atan2(-cray3(1), -cray3(3));

dp = -2*pi:pi/4:2*pi;
% angle = get_closest(dp, attr(3) - yaw);
angle = get_closest(dp, attr(3) - aaa);

if(angle < 0)
    angle = angle + 2 * pi;
end

best_depth = 0;
mindiff = 1.0;
cnt = 0;

dlist = [0.01:0.1:1, logspace(0, 3, 100)];
% for depth = 0.1:0.1:50
for depth = dlist
    loc = -sign(cray3(3)) * cray3 .* (depth / norm(cray3));
    [cube] = get3DObjectCube(loc, objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
    [~, pbbox] = get2DCubeProjection(K, R, cube);
    
    dheight = abs(rect(4) - pbbox(4)) / rect(4);
    
    cnt  = cnt  + 1;
    if(any(cube(3, :) > 0))
        continue;
    end
    
    if(dheight < 0.5)
       if(mindiff > dheight)
           mindiff = dheight;
           best_depth = depth;
       elseif(mindiff * 2 < dheight)
           break;
       end
    end
end

h = struct( 'oid', -1, 'locs', zeros(3, 27), ...
            'cubes', zeros(3, 8, 27), ...
            'polys', zeros(2, 8, 27), ...
            'bbs', zeros(4, 27), ...
            'ovs', zeros(1, 27), ...
            'diff', zeros(1, 27), ...
            'azimuth', attr(3), ... % notice that this angle is azimuth defined in image plane!!!
            'angle', angle ); 
        
% invalid detection will be filtered out!
if(mindiff > 0.5)
    return;
end

% valid!
h.oid = attr(1);

% cnt
% if(mindiff > 0.5)
%     keyboard;
% end
assert(mindiff < 0.5);

if(option == 0)
	loc = -sign(cray3(3)) * cray3 .* (best_depth / norm(cray3));
	[cube] = get3DObjectCube(loc, objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
	[ppoly, pbbox] = get2DCubeProjection(K, R, cube);
	maxov = boxoverlap(rect2bbox(pbbox), rect2bbox(rect));
	% subplot(121);
	% imshow(imfile);
	% hold on;
	% rectangle('position', rect, 'edgecolor', 'k', 'LineStyle', '--', 'linewidth', 3);
	% rectangle('position', pbbox, 'edgecolor', 'r', 'LineStyle', '-.', 'linewidth', 4);
	% idx= [1 2 4 3 1 5 6 8 7 5];
	% plot(ppoly(1, idx), ppoly(2, idx), 'w-', 'linewidth', 2);
	% hold off;
	% pause
	iter = 0;
	while(iter < 50)
        iter = iter + 1;
		% dv = zeros(3, 27);
		cnt = 1;
		for dx = [-1 0 1]
			for dy = [-1 0 1]
				for dz = [-1 0 1]
					h.locs(:, cnt) = loc + [dx; dy; dz] .* dstep;
					h.cubes(:, :, cnt) = get3DObjectCube(h.locs(:, cnt), objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
					[h.polys(:, :, cnt), h.bbs(:, cnt)] = get2DCubeProjection(K, R, h.cubes(:, :, cnt));
					% dv(:, cnt) = [dx; dy; dz];
					cnt = cnt + 1;
				end
			end
		end
		h.bbs(3:4, :) = h.bbs(3:4, :) + h.bbs(1:2, :) - 1;
		h.ovs = boxoverlap(h.bbs', rect2bbox(rect));
		
		[val, idx] = max(h.ovs);
		if(maxov < val)
			loc = h.locs(:, idx);
			maxov = val;
		else
			break;
		end
	end
elseif(option == 1)
	loc = -sign(cray3(3)) * cray3 .* (best_depth / norm(cray3));
	[cube] = get3DObjectCube(loc, objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
	[ppoly, pbbox] = get2DCubeProjection(K, R, cube);
	mindiff = sum((rect2btm(pbbox(:)) - rect2btm(rect(:))) .^ 2 );

    iter = 0;
	while(iter < 50)
        iter = iter + 1;
		% dv = zeros(3, 27);
		cnt = 1;
		for dx = [-1 0 1]
			for dy = [-1 0 1]
				for dz = [-1 0 1]
					h.locs(:, cnt) = loc + [dx; dy; dz] .* dstep;
					h.cubes(:, :, cnt) = get3DObjectCube(h.locs(:, cnt), objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
					[h.polys(:, :, cnt), h.bbs(:, cnt)] = get2DCubeProjection(K, R, h.cubes(:, :, cnt));
					cnt = cnt + 1;
				end
			end
		end
		
		h.diff = sum((rect2btm(h.bbs) - repmat(rect2btm(rect(:)), 1, 27)) .^ 2, 1);
		h.bbs(3:4, :) = h.bbs(3:4, :) + h.bbs(1:2, :) - 1;

		[val, idx] = min(h.diff);
		if(mindiff > val)
			loc = h.locs(:, idx);
			mindiff = val;
		else
			break;
		end
	end

end
end
