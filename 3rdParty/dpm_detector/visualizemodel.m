function visualizemodel(model, components, layers)

% visualizemodel(model)
% Visualize a model.

clf;
if nargin < 2
  components = 1:length(model.rules{model.start});
end

if nargin < 3
  layers = 1;
end

k = 1;
for i = components
  for layer = layers
    visualizecomponent(model, i, length(layers)*length(components), k, layer);
    k = k+1;
  end
end

