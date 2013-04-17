function [reprojs] = get_human_iprojections_2(poselet)

nobjs = length(poselet.bodies.scores);

% 7 1/2 az x1 x2 y1 y2 score
reprojs = zeros(2*nobjs, 8);

for i = 1:nobjs
    rt = poselet.bodies.rts(:, i);
    th = poselet.torsos.rts(4, i);
    ibase = 2 * (i-1);
    
    % standing
    fh = th * 1.7 / 0.45;
    rt(4) = fh;
    
    reprojs(ibase+1, 1) = 7;
    reprojs(ibase+1, 2) = 1;
    reprojs(ibase+1, 3) = 0;
    reprojs(ibase+1, 4:7) = rect2bbox(rt);
    reprojs(ibase+1, 8) = log(poselet.bodies.scores(i));
    
    % sitting
    fh = th * 1.25 / 0.45;
    rt(4) = fh;
    
    reprojs(ibase+2, 1) = 7;
    reprojs(ibase+2, 2) = 2;
    reprojs(ibase+2, 3) = 0;
    reprojs(ibase+2, 4:7) = rect2bbox(rt);
    reprojs(ibase+2, 8) = log(poselet.bodies.scores(i));
end

end
