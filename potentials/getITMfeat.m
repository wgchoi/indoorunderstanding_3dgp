function [ifeat, cloc, theta, azimuth, dloc, dpose] = getITMfeat(ptn, robs, locs, model)
%% [ifeat, cloc, theta, azimuth, dloc, dpose] = getITMfeat(ptn, robs, locs, model)
% ptn : itm pattern
% robs : observation response
% locs : n by 2 matrix containing [x, z] location of each childs
% model : params.model
assert(nargin == 4);

% (dx^2, dz^2, da^2) * n + view dependent biases & observation terms.
ifeat = zeros(ptn.numparts * 3 + 8 * 2, 1);
% assert(nargout == 6);

partslocs = locs(:, [1 3]);
partspose = locs(:, 4);

%%% we can modify here to reference on a certain object
if(isfield(ptn, 'refpart') && ptn.refpart > 0)
    cloc = partslocs(ptn.refpart , :);
    theta = partspose(ptn.refpart);
else
    cloc = mean(partslocs, 1);
    theta = atan2(partslocs(2, 2) - partslocs(1, 2), partslocs(2, 1) - partslocs(1, 1));
end
R = rotationMat(theta);

dloc = ( partslocs - repmat(cloc, size(partslocs, 1), 1) ) * R;
dpose =  partspose - theta;

ibase = 0;
for i = 1:length(ptn.parts)
    ifeat(ibase + 1) = (dloc(i, 1) - ptn.parts(i).dx) ^ 2;
    ifeat(ibase + 2) = (dloc(i, 2) - ptn.parts(i).dz) ^ 2;
    
    if(model.objmodel(ptn.parts(i).citype).ori_sensitive)
        ifeat(ibase + 3) = anglediff(dpose(i), ptn.parts(i).da) ^ 2;
    else
        % ignore orientation feature.. 
        % e.g. table, dining table - no consistent pose definition
        ifeat(ibase + 3) = 0;
    end
    ibase = ibase + 3;
end

camangle = atan2(-locs(1, 3), -locs(1, 1)); 
azimuth = camangle - theta;

if(isfield(model, 'itmoneviewpoint') && model.itmoneviewpoint)
    % not-viewdependent bias
    ifeat(ibase + 1) = 1;
    return;
end
%% we need to add observation feature here!!!
if(isfield(model, 'itmhogs') && model.itmhogs)
    % need implementation!
    % idx = getposeidx(azimuth, 8);
    [viewidx] = itm_view_idx(ptn, azimuth);
    ifeat(ibase + viewidx) = 1;
    ibase = ibase + 8;
	if(isnan(robs) || isinf(robs)) % why?
		robs = -10;
	end
    ifeat(ibase + viewidx) = robs;
    ibase = ibase + 8;
else
    % view dependent bias
    idx = getposeidx(azimuth, 8);
    ifeat(ibase + idx) = 1;
    ibase = ibase + 8;
end
% [dets, overlap] = find_matched_itm_detection(ptn.type, itmobs, bbox, azimuth);
% if(isempty(dets))
%     ifeat(ibase + 1) = -1.2;
% else
%     ifeat(ibase + 1) = dets(end);
%     ifeat(ibase + 2) = log(overlap);
% end

end
