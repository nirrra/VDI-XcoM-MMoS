function [segments_W_G,segments_W_L,segments_W_G_xyz,segments_W_L_xyz]=Segments_Rotation_Angular_velocity(r_all_segments,freq)

names = fieldnames(r_all_segments);
for i = 1:length(names)
    name = names{i};
    
    segments_W_G.(name) = Get_Derivatives_Multiply_Inv(freq,r_all_segments.(name));
    segments_W_L.(name) = Get_Inv_Multiply_Derivatives(freq,r_all_segments.(name));

    for j = 1:length(segments_W_L.(name))
        segments_W_G_xyz.(name).x(j,1) = segments_W_G.(name){j}(3,2);
        segments_W_G_xyz.(name).y(j,1) = segments_W_G.(name){j}(1,3);
        segments_W_G_xyz.(name).z(j,1) = segments_W_G.(name){j}(2,1);

        segments_W_L_xyz.(name).x(j,1) = segments_W_L.(name){j}(3,2);
        segments_W_L_xyz.(name).y(j,1) = segments_W_L.(name){j}(1,3);
        segments_W_L_xyz.(name).z(j,1) = segments_W_L.(name){j}(2,1);
    end
end