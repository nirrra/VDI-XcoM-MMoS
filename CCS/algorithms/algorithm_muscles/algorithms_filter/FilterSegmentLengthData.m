function segments_length_filtered = FilterSegmentLengthData(segments_length, fs, cutoff_freq)
% FilterSegmentLengthData - 对体段长度数据进行Butterworth低通滤波
%
% 输入:
%   segments_length - 包含体段长度数据的结构体
%   fs - 采样频率 (Hz)
%   cutoff_freq - 截止频率 (Hz)
%
% 输出:
%   segments_length_filtered - 滤波后的体段长度数据结构体

% 设计4阶Butterworth低通滤波器
[b, a] = butter(4, cutoff_freq/(fs/2), 'low');

% 复制原始结构体
segments_length_filtered = segments_length;

% 获取所有体段名称
segment_names = fieldnames(segments_length);

% 对每个体段的长度数据进行滤波
for i = 1:length(segment_names)
    segment_name = segment_names{i};
    
    % 检查数据是否为数值向量
    if isnumeric(segments_length.(segment_name)) && isvector(segments_length.(segment_name))
        % 对体段长度数据进行滤波
        segments_length_filtered.(segment_name) = filtfilt(b, a, segments_length.(segment_name));
    end
end

fprintf('体段长度数据滤波完成 (截止频率: %.1f Hz)\n', cutoff_freq);
end 