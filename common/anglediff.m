function d = anglediff(a1, a2)

a1 = mod(a1, 2 * pi);
a2 = mod(a2, 2 * pi);

d = abs(a1 - a2);
if(d > pi)
    d = 2 * pi - d;
end

end