

function drawVoxels(Xc_dummy,Yc_dummy,Zc_dummy,new_inds,fignum)

figure(fignum);hold on; grid_res=1;
for i=1:length(new_inds)
    voxel([Xc_dummy(new_inds(i)) Yc_dummy(new_inds(i)) Zc_dummy(new_inds(i))],...
        [1 1 1],'b',1);
end
