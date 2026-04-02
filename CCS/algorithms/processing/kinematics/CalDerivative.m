%% 函数：计算加速度
function acc = CalDerivative(vel,fs)
    acc = vel;    
    for i = 3:length(vel)-2
        acc(i) = (-vel(i+2)+8*vel(i+1)-8*vel(i-1)+vel(i-2))*fs/12;
    end
    acc(1) = (vel(2)-vel(1))*fs;
    acc(2) = (vel(2)-vel(1))*fs;
    acc(end) = (vel(end)-vel(end-1))*fs;
    acc(end-1) = (vel(end)-vel(end-1))*fs;
end