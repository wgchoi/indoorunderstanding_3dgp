function [potential, feat] = computeCompositePotential(node, childs, rule)
% N = 5;
feat = zeros(5 * rule.numparts, 1);
assert(isfield(rule, 'w'));

ibase = 1;
iR = [cos(node.angle), sin(node.angle); -sin(node.angle), cos(node.angle)];

for i = 1:rule.numparts
    dloc = childs(i).loc - node.loc;
    dloc([1 3]) = iR * dloc([1 3])';
    
    feat(ibase) = (dloc(1) - rule.parts(i).dx) ^ 2;
    feat(ibase + 1) = (dloc(2) - rule.parts(i).dy) ^ 2;
    feat(ibase + 2) = (dloc(3) - rule.parts(i).dz) ^ 2;
    feat(ibase + 3) = 1 - cos(childs(i).angle - (node.angle + rule.parts(i).da));
    feat(ibase + 4) = 1;
    
    ibase = ibase + 5;
end

potential = dot(rule.w, feat);
end