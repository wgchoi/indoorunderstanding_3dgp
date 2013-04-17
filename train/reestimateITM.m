function rule = reestimateITM(rule, composites, onlycenter)
if nargin < 3
    onlycenter = false;
end
% conservative..
N = 4;

if(isfield(rule, 'refpart') && rule.refpart > 0)
    N = 2;
    for i = 1:rule.numparts
        if(rule.refpart == i)
            %
            rule.parts(i).dx = 0;
            rule.parts(i).dz = 0;
            rule.parts(i).da = 0;
            if(onlycenter), continue; end
            rule.parts(i).wx = 0;
            rule.parts(i).wz = 0;
            rule.parts(i).wa = 0;
%         elseif(rule.parts(i).citype == 7)
%             %
%             rule.parts(i).dx = 0;
%             rule.parts(i).dz = 0;
%             rule.parts(i).da = 0;
%             
%             temp = zeros(0, 3);
%             for j = 1:length(composites)
%                 % references
%                 cloc = composites(j).dloc(rule.refpart, :);
%                 theta = composites(j).dpose(rule.refpart) + composites(j).angle;
%                 R = rotationMat(-theta);
%                 
%                 dloc = (composites(j).dloc(i, :) - cloc) * R;
%                 dpose =  composites(j).dpose(i) + composites(j).angle - theta;
%                 
%                 temp(end+1, :) = [dloc, dpose];
%             end
%             
%             rule.parts(i).wx = - 1 / var(temp(:, 1)) / N ;
%             rule.parts(i).wz = - 1 / var(temp(:, 2)) / N ;
%             da = [];
%             for j = 1:size(temp, 1)
%                 da(j) = anglediff(rule.parts(i).da, temp(j, 3));
%             end
%             rule.parts(i).wa = -1 / mean(da.^2) / N ;
        else
            temp = zeros(0, 3);
            for j = 1:length(composites)
                % references
                cloc = composites(j).dloc(rule.refpart, :);
%                 theta = composites(j).dpose(rule.refpart) + composites(j).angle;
%                 R = rotationMat(-composites(j).angle);

                dloc = (composites(j).dloc(i, :) - cloc) * rotationMat(composites(j).dpose(rule.refpart));
                dpose =  composites(j).dpose(i) - composites(j).dpose(rule.refpart);
                
                temp(end+1, :) = [dloc, dpose];
            end
            
            if(rule.parts(i).citype == 7)
                rule.parts(i).dx = mean(temp(:, 1));
                rule.parts(i).dz = mean(temp(:, 2));
                rule.parts(i).da = anglemean(temp(:, 3));
                if(sqrt(rule.parts(i).dx^2 + rule.parts(i).dz^2) < 1)
                    rule.parts(i).dx = 0;
                    rule.parts(i).dz = 0;
                end
            else
                rule.parts(i).dx = mean(temp(:, 1));
                rule.parts(i).dz = mean(temp(:, 2));
                rule.parts(i).da = anglemean(temp(:, 3));
            end
            if(onlycenter), continue; end

            rule.parts(i).wx = - 1 / var(temp(:, 1)) / N ;
            rule.parts(i).wz = - 1 / var(temp(:, 2)) / N ;
            da = [];
            for j = 1:size(temp, 1)
                da(j) = anglediff(rule.parts(i).da, temp(j, 3));
            end
            rule.parts(i).wa = -1 / mean(da.^2) / N ;
        end
    end
else
    for i = 1:rule.numparts
        temp = [rule.parts(i).dx, rule.parts(i).dz, rule.parts(i).da];
        for j = 1:length(composites)
            temp(end+1, :) = [ composites(j).dloc(i, :), composites(j).dpose(i)];
        end

        rule.parts(i).dx = mean(temp(:, 1));
        rule.parts(i).dz = mean(temp(:, 2));
        rule.parts(i).da = anglemean(temp(:, 3));
        if(onlycenter), continue; end

        rule.parts(i).wx = - 1 / var(temp(:, 1)) / N ;
        rule.parts(i).wz = - 1 / var(temp(:, 2)) / N ;
        da = [];
        for j = 1:size(temp, 1)
            da(j) = anglediff(rule.parts(i).da, temp(j, 3));
        end
        rule.parts(i).wa = -1 / mean(da.^2) / N ;
    end
end
end