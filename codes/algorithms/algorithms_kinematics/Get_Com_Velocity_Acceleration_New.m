%% 基于滤波后质心位置，计算速度与加速度
function [vel_filter,acc_filter,vel_raw,acc_raw] = Get_Com_Velocity_Acceleration_New(position,freq,fs_filter)
if nargin < 3
    fs_filter = 3;
end
fs = freq;

win = max(3, 2*floor(0.15*fs)+1); % 约0.3s窗口，保证奇数

pos = position(:);

fc_vel = min(fs_filter, 0.45*fs);
fc_acc = min(fs_filter, 0.45*fs);
[b_vel, a_vel] = butter(4, fc_vel/(fs/2));
[b_acc, a_acc] = butter(4, fc_acc/(fs/2));

vel_raw = gradient(pos, 1/fs);
vel_clean = hampel(vel_raw, win);
vel_filter = filtfilt(b_vel, a_vel, vel_clean);

acc_raw = gradient(vel_filter, 1/fs);
acc_clean = hampel(acc_raw, win);
acc_filter = filtfilt(b_acc, a_acc, acc_clean);
