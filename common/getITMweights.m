function w = getITMweights(ptn)
% (dx^2, dz^2, da^2) * n + view dependent biases & observation terms.
w = zeros(ptn.numparts * 3 + 8 * 2, 1);
ibase = 0;
for i = 1:length(ptn.parts)
    w(ibase + 1) = ptn.parts(i).wx;
    w(ibase + 2) = ptn.parts(i).wz;
    w(ibase + 3) = ptn.parts(i).wa;
    ibase = ibase + 3;
end
w(ibase+1:ibase+8) = ptn.biases;
ibase = ibase + 8;
w(ibase+1:ibase+8) = ptn.obs;

end