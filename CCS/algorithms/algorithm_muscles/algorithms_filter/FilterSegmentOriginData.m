function segments_origin_filtered = FilterSegmentOriginData(segments_origin, fs, cutoff_freq)
% FilterSegmentOriginData - 对体段原点数据进行Butterworth低通滤波
%
% 输入:
%   segments_origin - 包含体段原点数据的结构体
%   fs - 采样频率 (Hz)
%   cutoff_freq - 截止频率 (Hz)
%
% 输出:
%   segments_origin_filtered - 滤波后的体段原点数据结构体

% 设计4阶Butterworth低通滤波器
[b, a] = butter(4, cutoff_freq/(fs/2), 'low');

% 复制原始结构体
segments_origin_filtered = segments_origin;

% 获取所有体段名称
segment_names = fieldnames(segments_origin);

% 对每个体段的原点数据进行滤波
for i = 1:length(segment_names)
    segment_name = segment_names{i};
    
    % 检查数据是否为矩阵 (3xN)
    if isnumeric(segments_origin.(segment_name)) && ismatrix(segments_origin.(segment_name))
        origin_data = segments_origin.(segment_name);
        [rows, frames] = size(origin_data);
        
        if rows == 3
            % 对x, y, z坐标分别进行滤波
            origin_filtered = zeros(size(origin_data));
            
            for coord = 1:3
                % 提取时间序列并滤波
                time_series = origin_data(coord, :);
                origin_filtered(coord, :) = filtfilt(b, a, time_series);
            end
            
            segments_origin_filtered.(segment_name) = origin_filtered;
        end
    end
end

fprintf('体段原点数据滤波完成 (截止频率: %.1f Hz)\n', cutoff_freq);
end 