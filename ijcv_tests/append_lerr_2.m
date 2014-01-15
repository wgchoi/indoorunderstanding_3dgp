function [ data ] = append_lerr_2( data )

data.x.base_ywc3d = zeros(1, length(data.x.lconf));

for i = 1:length(data.x.lconf)
    data.x.lerr_ywc2d(i) = ywcGetPixErr(data.anno.gtPolyg, data.x.lpolys(i, :));
    if isempty(data.x.lpolys{i, 1}) && isempty(data.x.lpolys{i, 2})
        data.x.lerr_ywc3d(i) = NaN;
        data.x.base_ywc3d(i) = NaN;
    else
        [data.x.lerr_ywc3d(i) data.x.base_ywc3d(i)] = get_3d_space_iu_2( ...
            data.anno, data.x.lpolys(i, :), data.x.imsz, data.x.vp, data.x.K, data.x.R);
    end
end

end

