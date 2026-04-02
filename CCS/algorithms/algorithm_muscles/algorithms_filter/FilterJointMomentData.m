function jointMomentGlobal_filtered = FilterJointMomentData(jointMomentGlobal, fs, cutoff_freq)
% FilterJointMomentData - 对关节矩数据进行Butterworth低通滤波
%
% 输入:
%   jointMomentGlobal - 包含关节矩数据的结构体
%   fs - 采样频率 (Hz)
%   cutoff_freq - 截止频率 (Hz)
%
% 输出:
%   jointMomentGlobal_filtered - 滤波后的关节矩数据结构体

% 设计4阶Butterworth低通滤波器
[b, a] = butter(4, cutoff_freq/(fs/2), 'low');

% 复制原始结构体
jointMomentGlobal_filtered = jointMomentGlobal;

% 获取所有体段名称
segment_names = fieldnames(jointMomentGlobal);

% 对每个体段的关节矩数据进行滤波
for i = 1:length(segment_names)
    segment_name = segment_names{i};
    
    % 检查是否为结构体
    if isstruct(jointMomentGlobal.(segment_name))
        % 获取该体段的所有字段（如x, y, z）
        moment_fields = fieldnames(jointMomentGlobal.(segment_name));
        
        for j = 1:length(moment_fields)
            field_name = moment_fields{j};
            
            % 检查数据是否为数值向量
            if isnumeric(jointMomentGlobal.(segment_name).(field_name)) && ...
               isvector(jointMomentGlobal.(segment_name).(field_name))
                % 对关节矩数据进行滤波
                jointMomentGlobal_filtered.(segment_name).(field_name) = ...
                    filtfilt(b, a, jointMomentGlobal.(segment_name).(field_name));
            end
        end
    end
end

fprintf('关节矩数据滤波完成 (截止频率: %.1f Hz)\n', cutoff_freq);
end 