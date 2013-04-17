function drawObjects(room, objs, models, fig3d, fig2d)

K = room.K;
R = room.R;

if nargin < 4
    fig3d = -1;
    fig2d = -1;
elseif nargin < 5
    fig2d = -1;
end

% drawObjects
for i = 1:length(objs)
    % each type of objects
    for j = 1:length(objs{i})
		if(~isfield(objs{i}(j), 'cube'))
			continue;
		end
        cube = objs{i}(j).cube;
        if(isempty(cube))
            continue;
        end
        
        if( fig3d >  0)
            draw3Dcube(cube, fig3d);
        end
        
        if( fig2d >  0)
            [poly, rt] = get2DCubeProjection(K, R, cube);
            draw2DCube(poly, rt, fig2d);
            rectangle('position', objs{i}(j).bbs, 'edgecolor', 'b');
            
			mid = objs{i}(j).mid;
			text(rt(1) + 5, rt(2) + 10, [models(i).name ':' models(i).type{mid}], 'backgroundcolor', 'w')
        end
    end
end

end
