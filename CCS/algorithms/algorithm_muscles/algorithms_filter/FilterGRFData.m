function grf_filtered = FilterGRFData(grf_data, fs, cutoff_freq)
% FilterGRFData - 对地面反力数据进行Butterworth低通滤波
%
% 输入:
%   grf_data - 包含地面反力数据的结构体
%   fs - 采样频率 (Hz)
%   cutoff_freq - 截止频率 (Hz)
%
% 输出:
%   grf_filtered - 滤波后的地面反力数据结构体

% 设计4阶Butterworth低通滤波器
[b, a] = butter(4, cutoff_freq/(fs/2), 'low');

% 复制原始结构体
grf_filtered = grf_data;

% 获取所有字段名称
field_names = fieldnames(grf_data);

% 对每个字段的数据进行滤波
for i = 1:length(field_names)
    field_name = field_names{i};
    
    % 检查数据是否为数值向量
    if isnumeric(grf_data.(field_name)) && isvector(grf_data.(field_name))
        % 对地面反力数据进行滤波
        grf_filtered.(field_name) = filtfilt(b, a, grf_data.(field_name));
    end
end

% fprintf('地面反力数据滤波完成 (截止频率: %.1f Hz)\n', cutoff_freq);
end 