function idx = getposeidx(theta, npose)
idx = floor((theta + pi / npose) / (2 * pi / npose));
if(idx < 0)
    idx = idx + npose;
elseif idx >= npose
    idx = idx - npose;
end
idx = idx + 1;

end