function [lar, newgraph] = computeAcceptanceRatio(graph, info, cache, x, iclusters, params)

if(isfield(params.model, 'commonground') && params.model.commonground)
    [lar, newgraph] = computeAcceptanceRatioBF(graph, info, cache, x, iclusters, params);
else
    [lar, newgraph] = computeAcceptanceRatioEfficient(graph, info, cache, x, iclusters, params);
end

% if(info.move == 4)
%     lar2 = computeAcceptanceRatioEfficient(graph, info, cache, x, iclusters, params);
%     if(abs(lar - lar2) > 0.0001)
%         keyboard;
%     end
%     assert(abs(lar - lar2) < 0.0001 || lar == -inf);
% elseif(info.move == 5)
%     lar2 = computeAcceptanceRatioEfficient(graph, info, cache, x, iclusters, params);
%     if(abs(lar - lar2) > 0.0001)
%         keyboard;
%     end
%     assert(abs(lar - lar2) < 0.0001 || lar == -inf);
% elseif(info.move == 6)
%     lar2 = computeAcceptanceRatioEfficient(graph, info, cache, x, iclusters, params);
%     if(abs(lar - lar2) > 0.0001)
%         keyboard;
%     end
%     assert(abs(lar - lar2) < 0.0001 || lar == -inf);
% end

end

function [lar, newgraph] = computeAcceptanceRatioEfficient(graph, info, cache, x, iclusters, params)

newgraph = graph;
lkratio = 0.0;
qratio = 0.0;

switch(info.move)
    case 1 % scene
        newgraph.scenetype = info.idx;
		assert(false, 'not implemented yet');
		lkratio = 0.0;
		newgraph.lkhood = graph.lkhood + lkratio;
    case 2 % layout index
        newgraph.layoutidx = info.idx;
        %%% observation confidence
		lkratio = (x.lconf(info.idx) - x.lconf(graph.layoutidx)) * params.model.w_or;
		%%% object-wall interaction
		assert(false, 'not implemented yet');
        newgraph.lkhood = graph.lkhood + lkratio;
        % proposal
        qratio = log(cache.playout(graph.layoutidx)) - log(cache.playout(info.idx));
    case 3 % camera height
        newgraph.camheight = info.dval;
        % compute the features
        phi = features(newgraph, x, iclusters, params.model);
        newgraph.lkhood = dot(phi, params.model.w);
        lkratio = newgraph.lkhood - graph.lkhood;
        % balanced already, no proposal adjust required
        % lar = lar + 0.0;
    case 4 % add
        idx = find(graph.childs == info.did, 1);
        if(isempty(idx)) 
            newgraph.childs(end + 1) = info.did;
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			otype = iclusters(info.did).ittype;
			i1 = info.did;
            lkratio = 0; 
			%%% object-object interaction
			for j = 1:length(graph.childs)
				% not supporting grouping yet!
				i2 = graph.childs(j);
				assert(i1 ~= i2);
				assert(iclusters(i2).isterminal);
				
				lkratio = lkratio + x.intvol(i1, i2) * params.model.w_ioo(1);
				lkratio = lkratio + x.orarea(i1, i2) * params.model.w_ioo(2);
			end
			%%% object-room interaction
			% room intersection
			volume = cuboidRoomIntersection(x.faces{graph.layoutidx}, graph.camheight, x.cubes{i1});
            if(~isfield(params.model, 'feattype') || strcmp(params.model.feattype, 'type1'))
                lkratio = lkratio + dot(params.model.w_ior, volume);
            elseif(strcmp(params.model.feattype, 'type2'))
                n = length(params.model.ow_edge) - 1;
                
                temp = histc(volume(1), params.model.ow_edge);
                lkratio = lkratio + dot(params.model.w_ior(1:n), temp(1:n));
                temp = histc(volume(5), params.model.ow_edge);
                lkratio = lkratio + dot(params.model.w_ior(n+1:2*n), temp(1:n));
                temp = histc(volume(2:4), params.model.ow_edge);
                lkratio = lkratio + dot(params.model.w_ior(2*n+1:3*n), temp(1:n));
            else
                assert(0);
            end
			% min wall distance
			[d1, d2] = obj2wallFloorDist(x.faces{graph.layoutidx}, x.cubes{i1}, graph.camheight);
			lkratio = lkratio + params.model.w_iow3(otype) * min(abs(d1) + abs(d2));
			[d1, d2] = obj2wallImageDist(x.corners{graph.layoutidx}, x.projs(i1).poly);
			lkratio = lkratio + params.model.w_iow2(otype) * min(abs(d1) + abs(d2));
			% floor support
			bottom = x.cubes{i1}(2, 1); % bottom y position.
			lkratio = lkratio + params.model.w_iof(otype) * (graph.camheight + bottom) .^ 2;
			%%% object observation confidence
			oconf = x.dets(i1, 8);
			lkratio = lkratio + dot(params.model.w_oo((otype*2-1):(otype*2)), [oconf; 1]);

			newgraph.lkhood = graph.lkhood + lkratio;
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            p1 = cache.padd(info.did) / sum(cache.padd(~cache.inset));
            p2 = 1 / cache.padd(info.did) / ( sum(1 ./ cache.padd(cache.inset)) + 1 / cache.padd(info.did) );
            qratio = (log(params.pmove(5) * p2)) - (log(params.pmove(4) * p1));
        else % cannot add already existing cluster
            assert(0);
        end
    case 5 % delete
        idx = find(graph.childs == info.sid, 1);
        if(isempty(idx)) % cannot delete not existing cluster
            assert(0);
        else
            newgraph.childs(idx) = [];
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			otype = iclusters(info.sid).ittype;
			i1 = info.sid;
            lkratio = 0; 
			%%% object-object interaction
			for j = 1:length(graph.childs)
				% not supporting grouping yet!
				i2 = graph.childs(j);
				if(i1 == i2)
					continue;
				end
				assert(iclusters(i2).isterminal);
				
				lkratio = lkratio - x.intvol(i1, i2) * params.model.w_ioo(1);
				lkratio = lkratio - x.orarea(i1, i2) * params.model.w_ioo(2);
			end
			%%% object-room interaction
			% room intersection
			volume = cuboidRoomIntersection(x.faces{graph.layoutidx}, graph.camheight, x.cubes{i1});
            if(~isfield(params.model, 'feattype') || strcmp(params.model.feattype, 'type1'))
                lkratio = lkratio - dot(params.model.w_ior, volume);
            elseif(strcmp(params.model.feattype, 'type2'))
                n = length(params.model.ow_edge) - 1;
                
                temp = histc(volume(1), params.model.ow_edge);
                lkratio = lkratio - dot(params.model.w_ior(1:n), temp(1:n));
                temp = histc(volume(5), params.model.ow_edge);
                lkratio = lkratio - dot(params.model.w_ior(n+1:2*n), temp(1:n));
                temp = histc(volume(2:4), params.model.ow_edge);
                lkratio = lkratio - dot(params.model.w_ior(2*n+1:3*n), temp(1:n));
            else
                assert(0);
            end			
			% min wall distance
			[d1, d2] = obj2wallFloorDist(x.faces{graph.layoutidx}, x.cubes{i1}, graph.camheight);
			lkratio = lkratio - params.model.w_iow3(otype) * min(abs(d1) + abs(d2));
			[d1, d2] = obj2wallImageDist(x.corners{graph.layoutidx}, x.projs(i1).poly);
			lkratio = lkratio - params.model.w_iow2(otype) * min(abs(d1) + abs(d2));
			% floor support
			bottom = x.cubes{i1}(2, 1); % bottom y position.
			lkratio = lkratio - params.model.w_iof(otype) * (graph.camheight + bottom) .^ 2;
			%%% object observation confidence
			oconf = x.dets(i1, 8);
			lkratio = lkratio - dot(params.model.w_oo((otype*2-1):(otype*2)), [oconf; 1]);

			newgraph.lkhood = graph.lkhood + lkratio;
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            p1 = 1 / cache.padd(info.sid) / sum(1 ./ cache.padd(cache.inset));
            p2 = cache.padd(info.sid) / (sum(cache.padd(~cache.inset)) + cache.padd(info.sid));
            qratio = log(params.pmove(4) * p2) - log(params.pmove(5) * p1);
        end
    case 6 % switch
        idx = find(graph.childs == info.sid, 1);
        if(isempty(idx)) % cannot switch not existing cluster
            assert(0);
        else
            newgraph.childs(idx) = info.did;
            lkratio = 0; 
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			otype = iclusters(info.did).ittype;
			i1 = info.did;
			%%% object-object interaction
			for j = 1:length(graph.childs)
				% not supporting grouping yet!
				i2 = graph.childs(j);
				if(i2 == info.sid)
					continue;
				end
				assert(iclusters(i2).isterminal);
				
				lkratio = lkratio + x.intvol(i1, i2) * params.model.w_ioo(1);
				lkratio = lkratio + x.orarea(i1, i2) * params.model.w_ioo(2);
			end
			%%% object-room interaction
			% room intersection
			volume = cuboidRoomIntersection(x.faces{graph.layoutidx}, graph.camheight, x.cubes{i1});
			if(~isfield(params.model, 'feattype') || strcmp(params.model.feattype, 'type1'))
                lkratio = lkratio + dot(params.model.w_ior, volume);
            elseif(strcmp(params.model.feattype, 'type2'))
                n = length(params.model.ow_edge) - 1;
                
                temp = histc(volume(1), params.model.ow_edge);
                lkratio = lkratio + dot(params.model.w_ior(1:n), temp(1:n));
                temp = histc(volume(5), params.model.ow_edge);
                lkratio = lkratio + dot(params.model.w_ior(n+1:2*n), temp(1:n));
                temp = histc(volume(2:4), params.model.ow_edge);
                lkratio = lkratio + dot(params.model.w_ior(2*n+1:3*n), temp(1:n));
            else
                assert(0);
            end
			% min wall distance
			[d1, d2] = obj2wallFloorDist(x.faces{graph.layoutidx}, x.cubes{i1}, graph.camheight);
			lkratio = lkratio + params.model.w_iow3(otype) * min(abs(d1) + abs(d2));
			[d1, d2] = obj2wallImageDist(x.corners{graph.layoutidx}, x.projs(i1).poly);
			lkratio = lkratio + params.model.w_iow2(otype) * min(abs(d1) + abs(d2));
			% floor support
			bottom = x.cubes{i1}(2, 1); % bottom y position.
			lkratio = lkratio + params.model.w_iof(otype) * (graph.camheight + bottom) .^ 2;
			%%% object observation confidence
			oconf = x.dets(i1, 8);
			lkratio = lkratio + dot(params.model.w_oo((otype*2-1):(otype*2)), [oconf; 1]);
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			otype = iclusters(info.sid).ittype;
			i1 = info.sid;
			%%% object-object interaction
			for j = 1:length(graph.childs)
				% not supporting grouping yet!
				i2 = graph.childs(j);
				if(i1 == i2)
					continue;
				end
				assert(iclusters(i2).isterminal);
				
				lkratio = lkratio - x.intvol(i1, i2) * params.model.w_ioo(1);
				lkratio = lkratio - x.orarea(i1, i2) * params.model.w_ioo(2);
			end
			%%% object-room interaction
			% room intersection
			volume = cuboidRoomIntersection(x.faces{graph.layoutidx}, graph.camheight, x.cubes{i1});
            if(~isfield(params.model, 'feattype') || strcmp(params.model.feattype, 'type1'))
                lkratio = lkratio - dot(params.model.w_ior, volume);
            elseif(strcmp(params.model.feattype, 'type2'))
                n = length(params.model.ow_edge) - 1;
                
                temp = histc(volume(1), params.model.ow_edge);
                lkratio = lkratio - dot(params.model.w_ior(1:n), temp(1:n));
                temp = histc(volume(5), params.model.ow_edge);
                lkratio = lkratio - dot(params.model.w_ior(n+1:2*n), temp(1:n));
                temp = histc(volume(2:4), params.model.ow_edge);
                lkratio = lkratio - dot(params.model.w_ior(2*n+1:3*n), temp(1:n));
            else
                assert(0);
            end
			% min wall distance
			[d1, d2] = obj2wallFloorDist(x.faces{graph.layoutidx}, x.cubes{i1}, graph.camheight);
			lkratio = lkratio - params.model.w_iow3(otype) * min(abs(d1) + abs(d2));
			[d1, d2] = obj2wallImageDist(x.corners{graph.layoutidx}, x.projs(i1).poly);
			lkratio = lkratio - params.model.w_iow2(otype) * min(abs(d1) + abs(d2));
			% floor support
			bottom = x.cubes{i1}(2, 1); % bottom y position.
			lkratio = lkratio - params.model.w_iof(otype) * (graph.camheight + bottom) .^ 2;
			%%% object observation confidence
			oconf = x.dets(i1, 8);
			lkratio = lkratio - dot(params.model.w_oo((otype*2-1):(otype*2)), [oconf; 1]);
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			newgraph.lkhood = graph.lkhood + lkratio;
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % phi = features(newgraph, x, iclusters, params.model);
            % newgraph.lkhood = dot(phi, params.model.w);
            % lkratio = newgraph.lkhood - graph.lkhood;
            
            p11 = 1 / cache.padd(info.sid) / sum(1 ./ cache.padd(cache.inset));
            id2 = cache.swset{info.sid};
            id2 = id2(~cache.inset(id2)); % consider non-existing only
            p12 = cache.padd(info.did) / sum(cache.padd(id2));
            
            tinset = cache.inset;
            tinset(info.sid) = false;
            tinset(info.did) = true;
            p21 = 1 / cache.padd(info.did) / sum(1 ./ cache.padd(tinset));
            id2 = cache.swset{info.did};
            id2 = id2(~tinset(id2)); % consider non-existing only
            p22 = cache.padd(info.sid) / sum(cache.padd(id2));
            qratio = log((p21*p22) / (p11*p12));
        end
    case 7 % combine
    case 8 % break
    otherwise
        assert(0, ['not defined mcmc move = ' num2str(info.move)]);
end

lar = params.accconst * lkratio + qratio;
if isnan(lar)
    lar = -inf;
end

end

function [lar, newgraph ] = computeAcceptanceRatioBF(graph, info, cache, x, iclusters, params)
newgraph = graph;
lkratio = 0.0;
qratio = 0.0;

if(isfield(params, 'quicklearn'))
    quickrun = params.quicklearn;
else
    quickrun = false;
end

switch(info.move)
    case 1 % scene
        newgraph.scenetype = info.idx;
        % balanced already, no proposal adjust required
        % lar = lar + 0.0;
    case 2 % layout index
        newgraph.layoutidx = info.idx;
        % proposal
        qratio = log(cache.playout(graph.layoutidx)) - log(cache.playout(info.idx));
    case 3 % camera height
        assert(0);
        newgraph.camheight = info.dval;
        % balanced already, no proposal adjust required
        % lar = lar + 0.0;
    case 4 % add
        idx = find(graph.childs == info.did, 1);
        if(isempty(idx)) 
            newgraph.childs(end + 1) = info.did;
            
            p1 = cache.padd(info.did) / sum(cache.padd(~cache.inset));
            p2 = 1 / cache.padd(info.did) / ( sum(1 ./ cache.padd(newgraph.childs)) );
            
            qratio = (log(params.pmove(5) * p2)) - (log(params.pmove(4) * p1));
        else % cannot add already existing cluster
            assert(0);
        end
        newgraph = findConsistent3DObjects(newgraph, x, iclusters, quickrun);
    case 5 % delete
        idx = find(graph.childs == info.sid, 1);
        if(isempty(idx)) % cannot delete not existing cluster
            assert(0);
        else
            newgraph.childs(idx) = [];
            
            p1 = 1 / cache.padd(info.sid) / sum(1 ./ cache.padd(graph.childs));
            p2 = cache.padd(info.sid) / (sum(cache.padd(~cache.inset)) + cache.padd(info.sid));
            qratio = log(params.pmove(4) * p2) - log(params.pmove(5) * p1);
        end
        newgraph = findConsistent3DObjects(newgraph, x, iclusters, quickrun);
    case 6 % switch
        idx = find(graph.childs == info.sid, 1);
        if(isempty(idx)) % cannot switch not existing cluster
            assert(0);
        else
            newgraph.childs(idx) = info.did;
            
            p11 = 1 / cache.padd(info.sid) / sum(1 ./ cache.padd(graph.childs));
            id2 = cache.swset{info.sid};
            id2 = id2(~cache.inset(id2)); % consider non-existing only
            p12 = cache.padd(info.did) / sum(cache.padd(id2));
            
            tinset = cache.inset;
            tinset(info.sid) = false;
            tinset(info.did) = true;
            p21 = 1 / cache.padd(info.did) / sum(1 ./ cache.padd(newgraph.childs));
            id2 = cache.swset{info.did};
            id2 = id2(~tinset(id2)); % consider non-existing only
            p22 = cache.padd(info.sid) / sum(cache.padd(id2));
            qratio = log((p21*p22) / (p11*p12));
        end
        newgraph = findConsistent3DObjects(newgraph, x, iclusters, quickrun);
    case 7 % combine
    case 8 % break
    otherwise
        assert(0, ['not defined mcmc move = ' num2str(info.move)]);
end

% compute the features
phi = features(newgraph, x, iclusters, params.model);
newgraph.lkhood = dot(phi, params.model.w);
lkratio = newgraph.lkhood - graph.lkhood;

lar = params.accconst * lkratio + qratio;
if isnan(lar)
    lar = -inf;
end

end
