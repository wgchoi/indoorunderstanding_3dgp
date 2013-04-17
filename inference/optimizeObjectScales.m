function [ camh, alpha ] = optimizeObjectScales( bottoms )
if length(bottoms) > 8
    ret = [mean(bottoms) ./ bottoms, mean(bottoms)];
else
    options = optimset('Display', 'off', 'TolX', 0.1);
    [ret, ~, flag] = fminsearch(@(x) objfunc(x, bottoms), [mean(bottoms) ./ bottoms, mean(bottoms)], options);
end
camh = ret(end);
alpha = ret(1:end-1);
end

function fval = objfunc(x, d)

k = x(1:end-1) .* d;
fval = 10 * sum( ( k - x(end) ) .^ 2);
fval = fval + sum( log( x(1:end-1) ) .^ 2);

end