function muscle_data_filtered = FilterMuscleData(muscle_data, fs, cutoff_freq)
% FilterMuscleData - 对肌肉长度或速度数据进行Butterworth低通滤波
%
% 输入:
%   muscle_data - 包含肌肉数据的结构体
%   fs - 采样频率 (Hz)
%   cutoff_freq - 截止频率 (Hz)
%
% 输出:
%   muscle_data_filtered - 滤波后的肌肉数据结构体

% 设计4阶Butterworth低通滤波器
[b, a] = butter(4, cutoff_freq/(fs/2), 'low');

% 复制原始结构体
muscle_data_filtered = muscle_data;

% 获取所有肌肉名称
muscle_names = fieldnames(muscle_data);

% 对每个肌肉的数据进行滤波
for i = 1:length(muscle_names)
    muscle_name = muscle_names{i};
    
    % 检查数据是否为数值向量
    if isnumeric(muscle_data.(muscle_name)) && isvector(muscle_data.(muscle_name))
        % 对肌肉数据进行滤波
        muscle_data_filtered.(muscle_name) = filtfilt(b, a, muscle_data.(muscle_name));
    end
end

fprintf('肌肉数据滤波完成 (截止频率: %.1f Hz)\n', cutoff_freq);
end 