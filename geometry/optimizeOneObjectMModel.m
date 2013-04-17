function [minf, minloc, minid] = optimizeOneObjectMModel(camh, K, R, obj, model)
n = length(model.type);

minf = 1e100;
minid = -1;
minloc = [];

for mid = 1:n
    assert(0);
	[fval, loc] = optimizeOneObject(camh, K, R, obj, model, mid);
	if(minf > fval)
		minf = fval;
		minid = mid;
		minloc = loc;
	end
end

end
