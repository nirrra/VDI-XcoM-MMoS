function [segments_Alpha_G,segments_Alpha_L,segments_Alpha_G_xyz,segments_Alpha_L_xyz]=Segments_Rotation_Angular_Acceleration(segments_W_G,segments_W_L,freq)

names = fieldnames(segments_W_G);
for i = 1:length(names)
    name = names{i};

    segments_Alpha_G.(name) = Get_Angular_Acceleration(freq,segments_W_G.(name));
    segments_Alpha_L.(name) = Get_Angular_Acceleration(freq,segments_W_L.(name));

    for j = 1:length(segments_Alpha_L.(name))
        segments_Alpha_G_xyz.(name).x(j,1) = segments_Alpha_G.(name){j}(3,2);
        segments_Alpha_G_xyz.(name).y(j,1) = segments_Alpha_G.(name){j}(1,3);
        segments_Alpha_G_xyz.(name).z(j,1) = segments_Alpha_G.(name){j}(2,1);

        segments_Alpha_L_xyz.(name).x(j,1) = segments_Alpha_L.(name){j}(3,2);
        segments_Alpha_L_xyz.(name).y(j,1) = segments_Alpha_L.(name){j}(1,3);
        segments_Alpha_L_xyz.(name).z(j,1) = segments_Alpha_L.(name){j}(2,1);
    end
end