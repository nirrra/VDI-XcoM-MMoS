%% 求角速度
function angle_W = Angle_W(angle,freq)


angle_W = [0,0,( - angle(5:end) + 8 * angle(4:end-1) - 8 * angle(2:end-3) + angle(1:end-4))*freq/12,0,0];

angle_W(1) = (angle(2) - angle(1)) * freq;
angle_W(2) = (angle(3) - angle(2)) * freq;
angle_W(end-1) = (angle(end) - angle(end - 1)) * freq;
angle_W(end) = (angle(end) - angle(end-1)) * freq;
end