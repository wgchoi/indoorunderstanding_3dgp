function rule = clusterrule(numparts)
if nargin == 0, numparts = 1; end
rule = struct('type', 0, 'numparts', numparts, 'parts', partrules(numparts), 'threshold', 0, 'w', zeros(numparts * 4, 1));
end

function rules = partrules(numparts)
%
citypes = cell(numparts, 1);
citypes(:) = {0};
rules = struct('citype', citypes, ...
                'dx', 0, 'dy', 0, 'dz', 0, 'da', 0, ...
                'wx', 0, 'wy', 0, 'wz', 0,  'wa', 0, ...
                'bias', 0);

end
