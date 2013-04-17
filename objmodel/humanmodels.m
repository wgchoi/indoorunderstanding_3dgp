function model = humanmodels()

model = struct('name', cell(1, 0), 'type', cell(1, 0), ...
                'width', cell(1, 0), 'height', cell(1, 0), 'depth', cell(1, 0), ...
                'grounded', cell(1, 0), 'ori_sensitive', cell(1, 0));

idx = 1;
model(idx).name = 'Human';
model(idx).type = {'Standing' 'Sitting'};
model(idx).width = [0.5 0.5];
model(idx).height = [1.7 1.2];
model(idx).depth = [0.3 0.3];
model(idx).grounded = 1;
model(idx).ori_sensitive = 1;

end
