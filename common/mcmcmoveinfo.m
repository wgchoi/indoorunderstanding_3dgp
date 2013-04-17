% 'move' :  1. scene, 2. layout selection, 3. cam height diffusion
%           4. add, 5. delete, 6. switch, 7. combine, 8. break, 

% 'idx' : selection among indices - scene, layout
% 'dval' : diffusion value - camheight
% 'sid' : set of source cluster ids
% 'did' : set of dest cluster ids
% 'lkcache' : can be useful
function info = mcmcmoveinfo(num)
info = struct('move', cell(num, 1), 'idx', cell(num, 1), 'dval', cell(num, 1), 'sid', cell(num, 1), 'did', cell(num, 1), 'lkcache', cell(num, 1));
end