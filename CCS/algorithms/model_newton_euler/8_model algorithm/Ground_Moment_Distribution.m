%% 分配地面反作用力矩

function [ground_moment_Left,ground_moment_Right] = Ground_Moment_Distribution(ground_couple_moment_global)

len_m = length(ground_couple_moment_global);


ground_moment_Left.x = zeros(len_m,1);
ground_moment_Left.y = zeros(len_m,1);
ground_moment_Left.z = zeros(len_m,1);

ground_moment_Right.x = zeros(len_m,1);
ground_moment_Right.y = zeros(len_m,1);
ground_moment_Right.z = zeros(len_m,1);

for i =1:len_m
    ground_moment_Left.x(i) = ground_couple_moment_global{i}(1) * 0.5 ;
    ground_moment_Left.y(i) = ground_couple_moment_global{i}(2) * 0.5;
    ground_moment_Left.z(i) = ground_couple_moment_global{i}(3) * 0.5;

    ground_moment_Right.x(i) = ground_couple_moment_global{i}(1) * 0.5;
    ground_moment_Right.y(i) = ground_couple_moment_global{i}(2) * 0.5;
    ground_moment_Right.z(i) = ground_couple_moment_global{i}(3) * 0.5;
end

end