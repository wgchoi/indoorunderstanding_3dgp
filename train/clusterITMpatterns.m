function [res, newptns, newcomps, newdids] = clusterITMpatterns(data, ptns, comps, dids, params)

smat = inf(length(ptns), length(ptns));
sset = zeros(length(ptns), length(ptns));

maxsim = 0.5; % at least 50% sharing of training data required.
maxc = [];
res = false;

for i = 1:length(ptns)
    for j = i+1:length(ptns)
        % smat(i, j) = compareITM(ptns(i), ptns(j));
        % smat(j, i) = smat(i, j);
        % if(smat(i,j) < 25)
            [a, b, imatch] = findCommonITMset(dids{i}, comps{i}, dids{j}, comps{j});
            sset(i, j) = length(a) / b;
            sset(j, i) = sset(i, j);
            
            if( (length(a) / b) > maxsim )
                temp = struct('i', i, 'j', j, 'itmdist', smat(i, j), 'setsim', sset(i, j), 'iidx', a, 'imatch', imatch);
                maxc = temp;
                maxsim = length(a) / b;
            end
        % end
    end
end

newptns = ptns;
newcomps = comps;
newdids = dids;

if(~isempty(maxc))
    res = true;
    
    imatch = mode(maxc.imatch, 2);
    if(length(unique(imatch)) ~= size(maxc.imatch, 1))
        disp('!!!!!!');
        
        maxc.imatch(:, end) = [];
        imatch = mode(maxc.imatch, 2);
        
        if(length(unique(imatch)) ~= size(maxc.imatch, 1))
            % error?
            newptns(maxc.i) = [];
            newcomps(maxc.i) = [];
            newdids(maxc.i) = [];
            return;
        end
    end
    
    N = length(dids{maxc.i});
    idx = setdiff(1:N, maxc.iidx);
    
    setid = dids{maxc.j};
    setcomps = comps{maxc.j};
    
    ptn = ptns(maxc.j);
    cidx = zeros(1, length(imatch));
    
    for i = 1:length(idx)
        setid(end + 1) = dids{maxc.i}(idx(i));
        for j = 1:length(imatch)
            cidx(imatch(j)) = comps{maxc.i}(idx(i)).chindices(j);
        end
        
        assert(length(cidx) == ptn.numparts);
        
        if(iscell(data))
            setcomps(end + 1) = createITMnode(ptn, data{setid(end)}.x, cidx, params);
        elseif(isstruct(data))
            setcomps(end + 1) = createITMnode(ptn, data(setid(end)).x, cidx, params);
        else
            assert(0);
        end
    end
    
    newptns(maxc.j) = reestimateITM(ptn, setcomps);
    newcomps{maxc.j} = setcomps;
    newdids{maxc.j} = setid;
    
    newptns(maxc.i) = [];
    newcomps(maxc.i) = [];
    newdids(maxc.i) = [];
else
    res = false;
end

end


function itmnode = createITMnode(ptn, x, idx, params)

itmnode = graphnodes(1);

itmnode.isterminal = 0;
itmnode.ittype = ptn.type;

% temp
sidx = 14 * ones(1, length(idx));

[ifeat, cloc, theta, azimuth, dloc, dpose] = computeITMfeature(x, ptn, idx, sidx, params, true);
assert(~isempty(dloc));

itmnode.chindices = idx;
itmnode.angle = theta;
itmnode.azimuth = azimuth;
itmnode.loc = cloc; 
itmnode.feats = ifeat;
itmnode.dloc = dloc;
itmnode.dpose = dpose;
    
end