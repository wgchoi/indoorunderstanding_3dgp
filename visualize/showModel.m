function showModel(params)

close all;

w = getweights(params.model);
% w(:)'
plot(w, 'b.-', 'linewidth', 2, 'markersize', 20);
set(gca, 'XTick', 1:length(w));

if(~isfield(params.model, 'feattype') || strcmp(params.model.feattype, 'type1'))
    set(gca, 'XTickLabel', {'scene' '3D o' '2D o' 'Floor-O' 'Center-O' 'Left-O' 'Right-O' 'Ceil-O' ...
                            '3D-Wall1' '3D-Wall2' '2D-Wall1' '2D-Wall1' 'Floor dist 1' 'Floor dist 2' ...
                            'Score 1' 'Bias 1' 'Score 2' 'Bias 2'});
elseif(strcmp(params.model.feattype, 'type2'))
    set(gca, 'XTickLabel', {'scene' '3D o' '2D o' ...
                            'Floor-0' 'Floor-0.3' 'Floor-1.0' 'Floor-2.O' 'Floor-Inf' ...
                            'Ceil-0' 'Ceil-0.3' 'Ceil-1.0' 'Ceil-2.O' 'Ceil-Inf' ...
                            'Wall-0' 'Wall-0.3' 'Wall-1.0' 'Wall-2.O' 'Wall-Inf' ...
                            '3D-Wall1' '3D-Wall2' '2D-Wall1' '2D-Wall1' 'Floor dist 1' 'Floor dist 2' ...
                            'Score 1' 'Bias 1' 'Score 2' 'Bias 2'});
end

rotateXLabels(gca, 45);

title('model weights');
grid on;

end
