function info = MCMCproposal(graph, iclusters, moves, cache, params)
info = mcmcmoveinfo(1);
rval = rand();
cum_pmove = cumsum(params.pmove);
assert(abs(cum_pmove(end) - 1.0) < 0.02);

if(rval < cum_pmove(1)) % scene
    info.move = 1;
elseif(rval < cum_pmove(2)) % layout
    info.move = 2;
    info.idx = sum(cache.clayout < rand()) + 1;
elseif(rval < cum_pmove(3)) % camheight
    assert(0, 'not used')
    % we can change! data driven??
elseif(rval < cum_pmove(4)) % add
    idx = find(cache.inset == false);
    if(isempty(idx))
        info.move = 0;
        return;
    end
    temp = cumsum(cache.padd(idx));
    i = sum(temp < rand() * temp(end)) + 1;
    if(~iclusters(idx(i)).isterminal)
        if(any(cache.inset(iclusters(idx(i)).chindices)))
            info.move = 0;
            return;
        end
    end
    info = moves{4}(idx(i));
    assert(~cache.inset(info.did));
elseif(rval < cum_pmove(5)) % delete
    idx = graph.childs;
    if(isempty(idx))
        info.move = 0;
        return;
    end
    temp = cumsum(1 ./ cache.padd(idx));
    i = sum(temp < rand() * temp(end)) + 1;
    info = moves{5}(idx(i));
    assert(cache.inset(info.sid));
elseif(rval < cum_pmove(6)) % switch
    % among existing
    idx1 = graph.childs;
    if(sum(cache.szswset(idx1)) == 0)
        info.move = 0;
        return;
    end
    temp = cumsum(1 ./ cache.padd(idx1));
    i1 = sum(temp < rand() * temp(end)) + 1;
    
    idx2 = cache.swset{idx1(i1)};
    % among not existing
    idx2 = idx2(~cache.inset(idx2));
    if(isempty(idx2))
        info.move = 0;
        return;
    end
    temp = cumsum(cache.padd(idx2));
    i2 = sum(temp < rand() * temp(end)) + 1;
    
    if(~iclusters(idx2(i2)).isterminal)
        if(any(cache.inset(iclusters(idx2(i2)).chindices)))
            info.move = 0;
            return;
        end
    end
    info.move = 6;
    info.sid = idx1(i1);
    info.did = idx2(i2);
%     temp = cumsum(cache.szswset(idx));
%     rval = randi(temp(end), 1);
%     idx1 = sum(temp < rval) + 1;
%     
%     temp = [0; temp];
%     idx2 = cache.swset{idx(idx1)}(rval - temp(idx1));
%     info = moves{6}(idx2);    
    assert(cache.inset(info.sid));
    assert(~cache.inset(info.did));
elseif(rval < cum_pmove(7)) % combine
    rval = randi(length(moves{7}), 1);
    info = moves{7}(rval);
else                        % break
    rval = randi(length(moves{8}), 1);
    info = moves{8}(rval);
end
    
end