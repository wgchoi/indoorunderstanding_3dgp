function [camh, objs] = jointInfer3DObjCubes(K, R, objs, poses, models)
%%% get max overlapping hypotehsis
hs = 0.1:0.2:3.0;
for i = 1:length(hs)
    ret(i) = allObjsCost(hs(i), K, R, objs, poses, models);
end
[dummy, idx] = min(ret);
camh = hs(idx);
% fine tuning
[camh, fval] = fminsearch(@(x) allObjsCost(x, K, R, objs, poses, models), camh);
assert(camh > 0);
% cube = get3DObjectCube(loc, model.width(1), model.height(1), model.depth(1), angle);
%%% keyboard
if(nargout >= 2)
    % temp!!!1
    mid = 1;
    cubes = cell(length(objs), 1);
    for i = 1:length(objs)
        if(length(models) < i)
            continue;
        end
        if(models(i).grounded == 0)
            continue;
        end
        for j = 1:length(objs{i})
            obj = objs{i}(j);
            
            pose = poses{i}(j); mid = pose.subid;
            [fval, loc] = optimizeOneObject(camh, K, R, obj, pose, models(i));
			% [fval, loc, mid] = optimizeOneObjectMModel(camh, K, R, obj, models(i));
%             angle = get3DAngle(K, R, obj.pose, loc(2));
            angle = getObjAngleFromCamView(loc, pose);
%             angle = getObjAngleFromCamView(K, R, obj, pose);
            objs{i}(j).cube = get3DObjectCube(loc, models(i).width(mid), models(i).height(mid), models(i).depth(mid), angle);
			objs{i}(j).mid = mid;
        end
    end
end
end

%%% compute 
function ret = allObjsCost(camh, K, R, objs, poses, models)
ret = 0;
for i = 1:length(objs)
    if(length(models) < i)
        continue;
    end
    if(models(i).grounded == 0)
        continue;
    end
    
    for j = 1:length(objs{i})
        obj = objs{i}(j);
%         if(1)
        pose = poses{i}(j); 
        [fval, loc] = optimizeOneObject(camh, K, R, obj, pose, models(i));
		% [fval, loc, minid] = optimizeOneObjectMModel(camh, K, R, obj, models(i));
%         else
%             %%% find the best fitting object hypothesis given a camera height
%             iloc = getInitialGuess(obj, models(i), 1, K, R, camh);
%             %%% avoid unnecessary computation.
%             [pbbox] = loc2bbox(iloc, obj.pose, K, R, models(i), 1);
%             if(boxoverlap(pbbox, obj.bbox) < 0.1)
%                 ret = ret + 1e10;
%                 continue;
%             end
%             xz = iloc([1 3]);
%             %%% optimize over x-z dimension given camera height
%             [dummy, fval] = fminsearch(@(x)objFitnessCost(x, camh, K, R, obj, models(i), 1), xz);
%         end
        ret = ret + fval;
    end
end

end