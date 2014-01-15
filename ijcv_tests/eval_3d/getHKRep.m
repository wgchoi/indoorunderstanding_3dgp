function [ H, K ] = getHKRep( Plane, CamPlane )

H = zeros(0,3);
K = zeros(0,1);
sign = [-1 1 -1 1 1];
for iter_pln = 1:5
    if ~isempty(Plane{iter_pln})
        H = [H; sign(iter_pln)*Plane{iter_pln}(1:3)'];
        K = [K;-sign(iter_pln)*Plane{iter_pln}(4)'  ];
    end
end
H = [H; CamPlane{1}(1:3)']; K = [K;0'];
H = [H;-CamPlane{2}(1:3)']; K = [K;0'];
H = [H;-CamPlane{3}(1:3)']; K = [K;0'];
H = [H; CamPlane{4}(1:3)']; K = [K;0'];

end
