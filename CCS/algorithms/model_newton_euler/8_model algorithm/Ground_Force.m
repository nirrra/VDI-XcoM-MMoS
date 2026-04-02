%% 求解地面反作用力
function [ground_force_Left,ground_force_Right] = Ground_Force(mass,hip_force_Left,hip_force_Right,segments_com_acceleration)

% 地面总的反作用力
x =  segments_com_acceleration.human.x*mass - hip_force_Left.x - hip_force_Right.x;
y =  segments_com_acceleration.human.y*mass - hip_force_Left.y - hip_force_Right.y;
z =  segments_com_acceleration.human.z*mass+mass*9.8 - hip_force_Left.z - hip_force_Right.z;

ground_force_Left.x = x*0.5;
ground_force_Left.y = y*0.5;
ground_force_Left.z = z*0.5;

ground_force_Right.x = x*0.5;
ground_force_Right.y = y*0.5;
ground_force_Right.z = z*0.5;
%% 双支撑相


end
