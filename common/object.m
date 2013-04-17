function obj = object(num)
if nargin < 1
    num = 1;
end
obj = struct('id', cell(num, 1), 'pose', cell(num, 1), 'poly', cell(num, 1), ...
                'bbs', cell(num, 1), 'cube', cell(num, 1), 'mid', cell(num, 1), 'feat', cell(num, 1));
end