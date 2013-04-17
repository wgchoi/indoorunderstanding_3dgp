function ptn = setITMweights2(ptn, w)
assert(length(w) == (ptn.numparts * 3 + 8 + 1));
ibase = 0;
for i = 1:length(ptn.parts)
    ptn.parts(i).wx = w(ibase + 1);
    ptn.parts(i).wz = w(ibase + 2);
    ptn.parts(i).wa = w(ibase + 3);
    ibase = ibase + 3;
end
ptn.biases = w(ibase+1:ibase+8);
ibase = ibase + 8;
ptn.obs = w(ibase+1);

end