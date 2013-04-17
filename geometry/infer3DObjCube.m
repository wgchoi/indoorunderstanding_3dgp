function cube = infer3DObjCube(K, R, obj, model, cam_height, figid)
%%% get intial guess!
cpt2 = [obj.rect(1) + obj.rect(3) / 2; obj.rect(2) + obj.rect(4) / 2];
cray3 = (K * R) \ [cpt2; 1];
angle = get3DAngle(K, R, obj.pose, -cam_height);
iloc = cray3 ./ cray3(2) * -(cam_height - model.height(1) / 2);
%%% get max overlapping hypotehsis
loc = fminsearch(@(x) costfunction(x, K, R, model, obj.rect, obj.poly, angle), iloc);
cube = get3DObjectCube(loc, model.width(1), model.height(1), model.depth(1), angle);
%%% keyboard
end


function [cost] = costfunction(location, K, R, model, rt, poly, angle)
%%%
[cube] = get3DObjectCube(location, model.width(1), model.height(1), model.depth(1), angle);
[ppoly, prt] = get2DCubeProjection(K, R, cube);
% cost = -log(boxoverlap(pbbox, bbox));
%%%
rt(1:2) = rt(1:2) + rt(3:4) / 2;
prt(1:2) = prt(1:2) + prt(3:4) / 2;
cost = sum( ( rt - prt ) .^ 2 );

end