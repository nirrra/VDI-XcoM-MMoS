% 根据互相关估计两个信号时间的延迟
function [delay_time] = GetDeleyTime(t_a,a,t_b,b,ts)
t_a_start = ts(1); t_b_start = ts(2); t_length = ts(3);
%% 平均分布
t_a = t_a(1):range(t_a)/(length(t_a)-1):t_a(end);
t_b = t_b(1):range(t_b)/(length(t_b)-1):t_b(end);

% figure; hold on;
% plot(t_a,a); plot(t_b,b);
% hold off; legend('a','b');

%% 取大致信号范围
aux = GetIdxTime(t_a,[t_a_start,t_a_start+t_length]);
a = a(aux(1):aux(2)); t_a = t_a(aux(1):aux(2))-t_a(aux(1));
aux = GetIdxTime(t_b,[t_b_start,t_b_start+t_length]);
b = b(aux(1):aux(2)); t_b = t_b(aux(1):aux(2))-t_b(aux(1));

% figure; hold on;
% plot(t_a,a); plot(t_b,b);
% hold off; legend('a','b');
%% 信号插值到同一采样率
t_start = 0; t_end = t_length;

Fs_new = 1000;
dt = 1/Fs_new;
t_new = t_start:dt:t_end;

% 使用样条插值统一采样率
a_new = interp1(t_a, a, t_new, 'spline');
b_new = interp1(t_b, b, t_new, 'spline');

% figure; hold on;
% plot(t_new,a_new); plot(t_new,b_new);
% hold off;

%% 计算归一化互相关
[corr, lags] = xcorr(a_new, b_new, 'coeff');

% 找到最大相关系数及其延迟
[max_corr, idx] = max(abs(corr));
delay_samples = lags(idx);
delay_time = delay_samples * dt;

% 输出结果
fprintf('最大相关系数: %.4f，时间延迟: %.4f秒\n', max_corr, delay_time);

% figure; hold on;
% plot(t_a+delay_time,a); plot(t_b,b);
% hold off; legend('a','b');

delay_time = t_b_start-t_a_start+delay_time;

% figure; hold on;
% plot(times.buttock+delay_time,copButtock.y); plot(times.kinect,posCOMSegments.Trunk.y);
% hold off; legend('a','b');