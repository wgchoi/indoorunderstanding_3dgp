function [ Polyg ] = adjustGTPolyg( Polyg, y )

if (isempty(Polyg{3}) && ~isempty(Polyg{4})) || (~isempty(Polyg{3}) && isempty(Polyg{4}))
    if y == 0
        warning('yaw = 0!! Potential ambiguity exists!!\n');
    end
    if isempty(Polyg{3})
        if y < 0
            % fprintf('switching occurs!!\n');
            Polyg{3} = Polyg{2};
            Polyg{2} = Polyg{4};
            Polyg{4} = [];
        end
    else
        if y > 0
            % fprintf('switching occurs!!\n');
            Polyg{4} = Polyg{2};
            Polyg{2} = Polyg{3};
            Polyg{3} = [];
        end
    end
end

%[img_row,img_col,~] = size(img);

% if (isempty(Polyg{3}) && ~isempty(Polyg{4})) || (~isempty(Polyg{3}) && isempty(Polyg{4}))
%     if isempty(Polyg{3})
%         [~,~,min_idx] = calcPairDist(Polyg{4},Polyg{1});
%         conpt2D = [img_col/2-Polyg{1}(min_idx(1,2),1) img_row/2-Polyg{1}(min_idx(1,2),2) f]';
%         conpt3D = conpt2D*(-gnd_plane(4)/(gnd_plane(1:3)'*conpt2D));
%         if conpt3D(3) <0
%             error('z coord is negative!!\n');
%         end
%         d11 = -NORMS{4}'*conpt3D;
%         conpt2D = [img_col/2-Polyg{1}(min_idx(2,2),1) img_row/2-Polyg{1}(min_idx(2,2),2) f]';
%         conpt3D = conpt2D*(-gnd_plane(4)/(gnd_plane(1:3)'*conpt2D));
%         if conpt3D(3) <0
%             error('z coord is negative!!\n');
%         end
%         d12 = -NORMS{4}'*conpt3D;
%         %assert(d >= 0);
%         [~,~,min_idx] = calcPairDist(Polyg{2},Polyg{1});
%         conpt2D = [img_col/2-Polyg{1}(min_idx(1,2),1) img_row/2-Polyg{1}(min_idx(1,2),2) f]';
%         conpt3D = conpt2D*(-gnd_plane(4)/(gnd_plane(1:3)'*conpt2D));
%         if conpt3D(3) <0
%             error('z coord is negative!!\n');
%         end
%         d21 = -NORMS{3}'*conpt3D;
%         conpt2D = [img_col/2-Polyg{1}(min_idx(2,2),1) img_row/2-Polyg{1}(min_idx(2,2),2) f]';
%         conpt3D = conpt2D*(-gnd_plane(4)/(gnd_plane(1:3)'*conpt2D));
%         if conpt3D(3) <0
%             error('z coord is negative!!\n');
%         end
%         d22 = -NORMS{3}'*conpt3D;
%         if abs(d11-d12) > abs(d21-d22)
%             fprintf('switching occurs!!\n');
%             Polyg{3} = Polyg{2};
%             Polyg{2} = Polyg{4};
%             Polyg{4} = [];
%         end
%     else
%         [~,~,min_idx] = calcPairDist(Polyg{3},Polyg{1});
%         conpt2D = [img_col/2-Polyg{1}(min_idx(1,2),1) img_row/2-Polyg{1}(min_idx(1,2),2) f]';
%         conpt3D = conpt2D*(-gnd_plane(4)/(gnd_plane(1:3)'*conpt2D));
%         if conpt3D(3) <0
%             error('z coord is negative!!\n');
%         end
%         d11 = -NORMS{3}'*conpt3D;
%         conpt2D = [img_col/2-Polyg{1}(min_idx(2,2),1) img_row/2-Polyg{1}(min_idx(2,2),2) f]';
%         conpt3D = conpt2D*(-gnd_plane(4)/(gnd_plane(1:3)'*conpt2D));
%         if conpt3D(3) <0
%             error('z coord is negative!!\n');
%         end
%         d12 = -NORMS{3}'*conpt3D;
%         %assert(d >= 0);
%         [~,~,min_idx] = calcPairDist(Polyg{2},Polyg{1});
%         conpt2D = [img_col/2-Polyg{1}(min_idx(1,2),1) img_row/2-Polyg{1}(min_idx(1,2),2) f]';
%         conpt3D = conpt2D*(-gnd_plane(4)/(gnd_plane(1:3)'*conpt2D));
%         if conpt3D(3) <0
%             error('z coord is negative!!\n');
%         end
%         d21 = -NORMS{4}'*conpt3D;
%         conpt2D = [img_col/2-Polyg{1}(min_idx(2,2),1) img_row/2-Polyg{1}(min_idx(2,2),2) f]';
%         conpt3D = conpt2D*(-gnd_plane(4)/(gnd_plane(1:3)'*conpt2D));
%         if conpt3D(3) <0
%             error('z coord is negative!!\n');
%         end
%         d22 = -NORMS{4}'*conpt3D;
%         if abs(d11-d12) > abs(d21-d22)
%             fprintf('switching occurs!!\n');
%             Polyg{4} = Polyg{2};
%             Polyg{2} = Polyg{3};
%             Polyg{3} = [];
%         end
%     end
% end

end

