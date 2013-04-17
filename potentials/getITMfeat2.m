function [ifeat, cloc, theta, azimuth, dloc, dpose] = getITMfeat2(ptn, itmobs, bbox, locs, model)
%% [ifeat, cloc, theta, azimuth, dloc, dpose] = getITMfeat(ptn, itmobs, bbox, locs, model)
% ptn : itm pattern
% itmobs, bbox : observation response
% locs : n by 2 matrix containing [x, z] location of each childs
% model : params.model
assert(nargin == 5);

% (dx^2, dz^2, da^2) * n + view dependent biases & observation terms.
ifeat = zeros(ptn.numparts * 3 + 8 + 1, 1);
% assert(nargout == 6);

partslocs = locs(:, [1 3]);
partspose = locs(:, 4);

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
else
	idx = getposeidx(azimuth, 8);
	ifeat(ibase + idx) = 1;
end
ibase = ibase + 8;

if(isempty(itmobs))
    ifeat(ibase + 1) = -1.0;
	return;
end
%% we need to add observation feature here!!!
dets = find_matched_itm_detection(ptn.type, itmobs, bbox, azimuth);
if(isempty(dets))
    ifeat(ibase + 1) = -1.0;
else
    ifeat(ibase + 1) = dets(end);
end

end
