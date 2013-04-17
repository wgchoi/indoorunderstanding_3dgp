function [moves, cache] = preprocessJumpMoves(x, iclusters, cache, params)
% moves : for each jump type : 
%       add, delete,
%       switch, combine, break
%       layout change : jump among the candidates
%       camera height change : additive gaussian
%       scene label switching
moves = cell(8, 1);
%%% scene, layout, height
for movetype = 1:3
    moves{movetype} = mcmcmoveinfo(0);
end
%%% add moves
movetype = 4;
if(params.pmove(movetype) > 0)
    moves{movetype} = mcmcmoveinfo(length(iclusters));
    for i = 1:length(iclusters)
        moves{movetype}(i).move = movetype;
        moves{movetype}(i).sid = [];
        moves{movetype}(i).did = i;
        % prcompute caches if necessary
    end
end
%%% delete moves
movetype = 5;
if(params.pmove(movetype) > 0)
    moves{movetype} = mcmcmoveinfo(length(iclusters));
    for i = 1:length(iclusters)
        moves{movetype}(i).move = movetype;
        moves{movetype}(i).sid = i;
        moves{movetype}(i).did = [];
        % prcompute caches if necessary
    end
end

%%% switch moves
count = 0;
movetype = 6;
if(params.pmove(movetype) > 0)
    if(~isfield(x, 'cloverlap'))
        x = preprocessClusterOverlap(x, iclusters);
    end
    
    moves{movetype} = mcmcmoveinfo(length(iclusters)*length(iclusters));
    for i = 1:length(iclusters)
        swset = [];
        for j = 1:length(iclusters)
            if(i == j), continue; end
            % if switching is necessary
            % competing elements
            if(iclusters(i).isterminal && iclusters(j).isterminal)
                % conflicting
                if(x.orpolys(i, j) > 0.3 || x.orarea(i, j) > 0.5)
                    count = count + 1;
                    moves{movetype}(count).move = movetype;
                    moves{movetype}(count).sid = i;
                    moves{movetype}(count).did = j;
                    % prcompute caches if necessary
                    % swset(end + 1) = count;
                    swset(end + 1) = j;
                end
            else
                if(x.cloverlap(i, j))
                    count = count + 1;
                    moves{movetype}(count).move = movetype;
                    moves{movetype}(count).sid = i;
                    moves{movetype}(count).did = j;
                    % prcompute caches if necessary
                    % swset(end + 1) = count;
                    swset(end + 1) = j;
                end
            end
        end
        cache.swset{i} = swset;
        cache.szswset(i) = length(swset);
    end
    moves{movetype}((count+1):end) = [];
end

%%% combine moves
count = 0;
movetype = 7;
if(params.pmove(movetype) > 0)
    moves{movetype} = mcmcmoveinfo(10000);
    for i = 1:length(iclusters)
    end
    moves{movetype}((count+1):end) = [];
end

%%% break moves
count = 0;
movetype = 8;
if(params.pmove(movetype) > 0)
    moves{movetype} = mcmcmoveinfo(10000);
    for i = 1:length(iclusters)
    end
    moves{movetype}((count+1):end) = [];
end

end
