function w = parts2weights(parts)
w = zeros(4 * length(parts), 1);

base = 1;
for i = 1:length(parts)
    w(base) = parts(i).wx;
    base = base + 1;
    w(base) = parts(i).wy;
    base = base + 1;
    w(base) = parts(i).wz;
    base = base + 1;
    w(base) = parts(i).wa;
    base = base + 1;
end

end
