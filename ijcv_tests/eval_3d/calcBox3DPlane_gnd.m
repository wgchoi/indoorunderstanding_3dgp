function [ Plane ] = calcBox3DPlane_gnd( Polyg, NORMS, h, f, imsz )

% [img_row,img_col,~] = size(img);
img_row = imsz(1);
img_col = imsz(2);

h_manual = 10;
% h_limit = 20;

Plane = cell(1,1);
if isempty(Polyg{1})
    error('no ground plane in Polyg!!\n');
end
refer_idx = [1 1 1 2];
Plane{1} = [NORMS{1};h];
if ~isempty(Polyg{2})
    idx = refer_idx(1);
    [~,~,min_idx] = calcPairDist(Polyg{2},Polyg{idx});
    % figure; imshow(img); hold on;
    % plot(Polyg{idx}(min_idx(1,2),1),Polyg{idx}(min_idx(1,2),2),'ro');
    % plot(Polyg{2}(min_idx(1,1),1),Polyg{2}(min_idx(1,1),2),'go');
    conpt2D = [img_col/2-Polyg{idx}(min_idx(1,2),1) img_row/2-Polyg{idx}(min_idx(1,2),2) f]';
    conpt3D = conpt2D*(-Plane{idx}(4)/(Plane{idx}(1:3)'*conpt2D));
    if conpt3D(3) <0
        % fprintf('z coord is negative 2: use manual h = %d\n',h_manual);
        Plane{2} = [NORMS{2};-h_manual];
        refer_idx = [1 2 2 2];
    else
        d = -NORMS{2}'*conpt3D;
        % if d < -h_limit
        %     fprintf('limit h is used!!\n');
        %     d = -h_limit;
        %     refer_idx = [1 2 2 2];
        % end
        Plane{2} = [NORMS{2};d];
        if ~(d <= 0)
            Plane{2} = [];
            
        end
    end
else
    Plane{2} = [];
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
    % idx = refer_idx(4);
    if ~isempty(Polyg{2})
        idx = 2;
    elseif ~isempty(Polyg{3}) && isempty(Polyg{4})
        idx = 3;
    elseif ~isempty(Polyg{4}) && isempty(Polyg{3})
        idx = 4;
    else
        error('wtf?\n');
    end
    if isempty(Plane{idx})
        Plane{5} = [];  % if the base plane is empty
        return;
    end
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

