function segments_RM_filtered = FilterRotationMatrixData(segments_RM, fs, cutoff_freq)
% FilterRotationMatrixData - 对旋转矩阵数据进行Butterworth低通滤波
%
% 输入:
%   segments_RM - 包含旋转矩阵数据的结构体
%   fs - 采样频率 (Hz)
%   cutoff_freq - 截止频率 (Hz)
%
% 输出:
%   segments_RM_filtered - 滤波后的旋转矩阵数据结构体

% 设计4阶Butterworth低通滤波器
[b, a] = butter(4, cutoff_freq/(fs/2), 'low');

% 复制原始结构体
segments_RM_filtered = segments_RM;

% 获取所有体段名称
segment_names = fieldnames(segments_RM);

% 对每个体段的旋转矩阵数据进行滤波
for i = 1:length(segment_names)
    segment_name = segment_names{i};
    
    % 检查数据是否为3D矩阵 (3x3xN)
    if isnumeric(segments_RM.(segment_name)) && ndims(segments_RM.(segment_name)) == 3
        RM_data = segments_RM.(segment_name);
        [rows, cols, frames] = size(RM_data);
        
        if rows == 3 && cols == 3
            % 对旋转矩阵的每个元素进行滤波
            RM_filtered = zeros(size(RM_data));
            
            for row = 1:3
                for col = 1:3
                    % 提取时间序列并滤波
                    time_series = squeeze(RM_data(row, col, :));
                    RM_filtered(row, col, :) = filtfilt(b, a, time_series);
                end
            end
            
            % 确保滤波后的矩阵仍然是正交矩阵
            for frame = 1:frames
                [U, ~, V] = svd(RM_filtered(:, :, frame));
                RM_filtered(:, :, frame) = U * V';
            end
            
            segments_RM_filtered.(segment_name) = RM_filtered;
        end
    end
end

fprintf('旋转矩阵数据滤波完成 (截止频率: %.1f Hz)\n', cutoff_freq);
end 