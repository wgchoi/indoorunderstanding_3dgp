function dval = discretize_value(value, dstep)
dval = round(value ./ dstep) .* dstep;
end