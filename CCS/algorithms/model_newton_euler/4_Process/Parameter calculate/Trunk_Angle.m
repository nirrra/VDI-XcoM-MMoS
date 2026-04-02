function trunk_angle = Trunk_Angle(kinect_cell_arrays_model)

%%
len = length(kinect_cell_arrays_model);

spineshoulder = zeros(len,3);
spinebase = zeros(len,3);

trunk_angle = zeros(len,1);
%
for i = 1:len
    joints_position_model = kinect_cell_arrays_model{i}.joints;
    
    spineshoulder(i,:) = joints_position_model(19,:);
    
    spinebase(i,:) = joints_position_model(1,:);
    
end


for i = 1:len
    
    trunk =  spinebase(i,:) - spineshoulder(i,:);
    A = [0 0 -1];
    B = [0 trunk(2) trunk(3)];
    trunk_angle(i) =  rad2deg(acos(dot(A, B) / (norm(A) * norm(B))));
    direction = cross(A,B);
    if(direction(1)<0)
        trunk_angle(i) = -trunk_angle(i);
    end   
end

end