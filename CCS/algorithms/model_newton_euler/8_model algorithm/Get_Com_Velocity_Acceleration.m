%% 计算速度 加速度
% flag == 1 中心有限差分法精度更高，但是有延迟 ；flag == 0，普通方法，没有延迟
function [com_velocity,com_acceleration] = Get_Com_Velocity_Acceleration(position,freq,flag)
if nargin<3
    flag = 1;
end
if flag==1
    com_velocity = [0;0;( - position(5:end) + 8 * position(4:end-1) - 8 * position(2:end-3) + position(1:end-4))*freq/12;0;0];
    com_acceleration = [0;0;( - position(5:end) + 16 * position(4:end-1) - 30 * position(3:end-2) +  16 * position(2:end-3) - position(1:end-4))*freq*freq/12;0;0];
    
    com_velocity(1) = (position(2) - position(1)) * freq;
    com_velocity(2) = (position(3) - position(2)) * freq;
    com_velocity(end-1) = (position(end) - position(end - 1)) * freq;
    com_velocity(end) = (position(end) - position(end-1)) * freq;
    
    com_acceleration(1) = (com_velocity(2) - com_velocity(1)) * freq;
    com_acceleration(2) = (com_velocity(3) - com_velocity(2)) * freq;
    com_acceleration(end-1) = (com_velocity(end) - com_velocity(end - 1)) * freq;
    com_acceleration(end) = (com_velocity(end) - com_velocity(end-1)) * freq;

elseif flag==0
    
    com_velocity = [0;(position(2:end) - position(1:end-1))*freq];
    com_velocity(1) = (position(2) - position(1)) * freq;
    
    com_acceleration = [0;com_velocity(2:end) - com_velocity(1:end-1)];

end