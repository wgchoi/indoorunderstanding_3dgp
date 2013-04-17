function [fval, loc] = optimizeOneObject3D(K, R, obj, pose, model)

mid = pose.subid;
%%% find the best fitting object hypothesis given a camera height
iloc = getInitialGuess3D(obj, model, pose, K, R, 1.5);
if(iloc(3) > 0)
    iloc = getInitialGuess3D(obj, model, pose, K, R, 1.0);
end
if(iloc(3) > 0)
    iloc = getInitialGuess3D(obj, model, pose, K, R, 2.0);
end
if(iloc(3) > 0)
    iloc = getInitialGuess3D(obj, model, pose, K, R, -1.5);
end
if(iloc(3) > 0)
    iloc = getInitialGuess3D(obj, model, pose, K, R, -1.0);
end
if(iloc(3) > 0)
    iloc = getInitialGuess3D(obj, model, pose, K, R, -2.0);
end
if(iloc(3) > 0)
    % fail!!
    disp('objet back projection failed!!');
    loc = nan(3, 1);
    fval = 1e10;
    return;
end
[pbbox] = loc2bbox(iloc, pose, K, R, model, mid);

if(rectoverlap(pbbox, obj.bbs) < 1e-10)
    loc = nan(3, 1);
    fval = 1e10;
    return;
end

if(rectoverlap(pbbox, obj.bbs) < 0.1)
    [iloc, maxol] = getInitialGuess3D_2(obj, model, pose, K, R);
    if(maxol < 1e-10)
        loc = nan(3, 1);
        fval = 1e10;
        return;
    end
end

%%% optimize over x-z dimension given camera height
[loc, fval] = fminsearch(@(x)objFitnessCost3D(x, K, R, obj, pose, model, mid), iloc);
[pbbox] = loc2bbox(loc, pose, K, R, model, mid);
if(rectoverlap(pbbox, obj.bbs) < 0.2)
    loc = nan(3, 1);
    fval = 1e10;
end

end

function iloc = getInitialGuess3D(obj, model, pose, K, R, ch)

cpt2 = [obj.bbs(1) + obj.bbs(3) / 2; obj.bbs(2) + obj.bbs(4) / 2];
cray3 = (K * R) \ [cpt2; 1];

% ch = 1.0;
iloc = cray3 ./ cray3(2) * -(ch - model.height(pose.subid) / 2);
bbox = loc2bbox(iloc, pose, K, R, model, pose.subid);
scale = bbox(3) / obj.bbs(3);

iloc = cray3 ./ cray3(2) * -(ch - model.height(pose.subid) / 2) * scale;
bbox = loc2bbox(iloc, pose, K, R, model, pose.subid);
cpt2 = 2 .* cpt2 - [bbox(1) + bbox(3) / 2; bbox(2) + bbox(4) / 2];

cray3 = (K * R) \ [cpt2; 1];
iloc = cray3 ./ cray3(2) * -(ch - model.height(pose.subid) / 2) * scale;
% 
% angle = getObjAngleFromCamView(iloc, pose);
% [cube] = get3DObjectCube(iloc, model.width(pose.subid), model.height(pose.subid), model.depth(pose.subid), angle);
% [poly, rt] = get2DCubeProjection(K, R, cube);
% draw2DCube(poly, rt, 1)
%  keyboard;
end


function [iloc, maxol] = getInitialGuess3D_2(obj, model, pose, K, R)

cpt2 = [obj.bbs(1) + obj.bbs(3) / 2; obj.bbs(2) + obj.bbs(4) / 2];
cray3 = (K * R) \ [cpt2; 1];

% ch = 1.0;
maxol = 0;
iloc = [];

for ch = -3:0.1:3
    loc = cray3 ./ cray3(2) * -(ch - model.height(pose.subid) / 2);
    if(loc(3) > 0)
        continue;
    end
    bbox = loc2bbox(loc, pose, K, R, model, pose.subid);
    ol = rectoverlap(bbox, obj.bbs);
    if(ol > maxol)
        maxol = ol;
        iloc = loc;
    end
end

end

function [cost] = objFitnessCost3D(xyz, K, R, obj, pose, model, mid)
assert(length(xyz) == 3);
assert(isfield(pose, 'az'));
%%%%
location = xyz;
%%%%
% angle = get3DAngle(K, R, obj.pose, -camh);
angle = getObjAngleFromCamView(location, pose);
[cube] = get3DObjectCube(location, model.width(mid), model.height(mid), model.depth(mid), angle);
[ppoly, prt] = get2DCubeProjection(K, R, cube);
%%%%
rt = obj.bbs;
%%%%
rt(1:2) = rt(1:2) + rt(3:4) / 2;
prt(1:2) = prt(1:2) + prt(3:4) / 2;
cost = sum( ( rt(1:2) - prt(1:2) ) .^ 2 );
cost = cost + sum( ( rt(3:4) - prt(3:4) ) .^ 2 );
%%%%
cost = 1000 * cost ./ (rt(4) * rt(4));

end
