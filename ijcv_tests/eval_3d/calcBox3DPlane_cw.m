function [ Plane ] = calcBox3DPlane_cw( Polyg, NORMS, h, f, imsz )

% [img_row,img_col,~] = size(img);
img_row = imsz(1);
img_col = imsz(2);

Plane = cell(1,1);
if isempty(Polyg{2})
    error('no center wall in Polyg!!\n');
end
refer_idx = [2 2 2 2];
Plane{2} = [NORMS{2};-h];
if ~isempty(Polyg{1})
    idx = refer_idx(1);
    [~,~,min_idx] = calcPairDist(Polyg{1},Polyg{idx});
    % figure; imshow(img); hold on;
    % plot(Polyg{1}(min_idx(1,2),1),Polyg{1}(min_idx(1,2),2),'ro');
    % plot(Polyg{2}(min_idx(1,1),1),Polyg{2}(min_idx(1,1),2),'go');
    conpt2D = [img_col/2-Polyg{idx}(min_idx(1,2),1) img_row/2-Polyg{idx}(min_idx(1,2),2) f]';
    conpt3D = conpt2D*(-Plane{idx}(4)/(Plane{idx}(1:3)'*conpt2D));
    d = -NORMS{1}'*conpt3D;
    Plane{1} = [NORMS{1};d];
    if ~(d >= 0)
        Plane{1} = [];
    end
else
    Plane{1} = [];
end
if ~isempty(Polyg{3})
    idx = refer_idx(2);
    [~,~,min_idx] = calcPairDist(Polyg{3},Polyg{idx});
    conpt2D = [img_col/2-Polyg{idx}(min_idx(1,2),1) img_row/2-Polyg{idx}(min_idx(1,2),2) f]';
    conpt3D = conpt2D*(-Plane{idx}(4)/(Plane{idx}(1:3)'*conpt2D));
    d = -NORMS{3}'*conpt3D;
    Plane{3} = [NORMS{3};d];
    if ~(d >= 0);
        Plane{3} = [];
    end
else
    Plane{3} = [];
end
if ~isempty(Polyg{4})
    idx = refer_idx(3);
    [~,~,min_idx] = calcPairDist(Polyg{4},Polyg{idx});
    conpt2D = [img_col/2-Polyg{idx}(min_idx(1,2),1) img_row/2-Polyg{idx}(min_idx(1,2),2) f]';
    conpt3D = conpt2D*(-Plane{idx}(4)/(Plane{idx}(1:3)'*conpt2D));
    d = -NORMS{4}'*conpt3D;
    Plane{4} = [NORMS{4};d];
    if ~(d <= 0);
        Plane{4} = [];
    end
else
    Plane{4} = [];
end
if ~isempty(Polyg{5})
    idx = refer_idx(4);
    [~,~,min_idx] = calcPairDist(Polyg{5},Polyg{idx});
    conpt2D = [img_col/2-Polyg{idx}(min_idx(1,2),1) img_row/2-Polyg{idx}(min_idx(1,2),2) f]';
    conpt3D = conpt2D*(-Plane{idx}(4)/(Plane{idx}(1:3)'*conpt2D));
    d = -NORMS{5}'*conpt3D;
    Plane{5} = [NORMS{5};d];
    if ~(d <= 0);
        Plane{5} = [];
    end
else
    Plane{5} = [];
end

end

