function streamInter_filtered = FilterStreamInter(streamInter, fs, cutoff_freq)
% FilterStreamInter - 对streamInter结构体中的运动学数据进行Butterworth低通滤波
%
% 输入:
%   streamInter - 包含运动学数据的结构体
%   fs - 采样频率 (Hz)
%   cutoff_freq - 截止频率 (Hz)
%
% 输出:
%   streamInter_filtered - 滤波后的运动学数据结构体

% 设计4阶Butterworth低通滤波器
[b, a] = butter(4, cutoff_freq/(fs/2), 'low');

% 复制原始结构体
streamInter_filtered = streamInter;

% 获取所有关节点名称
joint_names = fieldnames(streamInter);

% 对每个关节点的x, y, z坐标进行滤波
for i = 1:length(joint_names)
    joint_name = joint_names{i};
    
    % 跳过非关节点字段
    if ~isstruct(streamInter.(joint_name)) || strcmp(joint_name, 'wtime')
        continue;
    end
    
    % 检查是否有x, y, z字段
    if isfield(streamInter.(joint_name), 'x') && ...
       isfield(streamInter.(joint_name), 'y') && ...
       isfield(streamInter.(joint_name), 'z')
        
        % 对x, y, z坐标进行滤波
        streamInter_filtered.(joint_name).x = filtfilt(b, a, streamInter.(joint_name).x);
        streamInter_filtered.(joint_name).y = filtfilt(b, a, streamInter.(joint_name).y);
        streamInter_filtered.(joint_name).z = filtfilt(b, a, streamInter.(joint_name).z);
    end
end

fprintf('运动学数据滤波完成 (截止频率: %.1f Hz)\n', cutoff_freq);
end