function [fiber_lengths, tendon_lengths, muscle_lengths] = CalMuscleLengths(muscles,segments_RM,segments_origin,segments_length)
% 考虑肌肉纤维和肌腱的分离计算
% 
% 输入参数:
%   muscles - 肌肉参数结构体
%   segments_RM - 体段旋转矩阵
%   segments_origin - 体段原点
%   segments_length - 体段长度
%
% 输出参数:
%   muscle_lengths - 肌肉-肌腱复合体总长度
%   fiber_lengths - 肌肉纤维长度（用于力计算）
%   tendon_lengths - 肌腱长度

muscle_lengths = struct();
fiber_lengths = struct();
tendon_lengths = struct();

names = fieldnames(muscles);

for idx_name = 1:length(names)
    name = names{idx_name};
    
    % 获取肌肉参数
    tendon_slack_length = muscles.(name).tendon_slack_length;
    optimal_fiber_length = muscles.(name).optimal_fiber_length;
    pennation_angle = muscles.(name).pennation_angle;
    
    % 初始化长度数组
    n_frames = length(segments_origin.HeadNeck);
    mtu_lengths = zeros(n_frames, 1);
    muscle_fiber_lengths = zeros(n_frames, 1);
    muscle_tendon_lengths = zeros(n_frames, 1);
    
    for idxFrame = 1:n_frames
        % 计算肌肉路径点
        muscle_pts = muscles.(name).geometry;
        pts = zeros(length(muscle_pts), 3);
        
        for idx_pt = 1:length(muscle_pts)
            muscle_pt = muscle_pts{idx_pt};
            r = segments_RM.(muscle_pt.frame){idxFrame};
            l = segments_length.(muscle_pt.frame)(idxFrame);
            origin = segments_origin.(muscle_pt.frame)(idxFrame, :);
            aux = l * muscle_pt.location * r' + origin;
            pts(idx_pt, :) = aux(:)';
        end
        
        % 计算肌肉-肌腱复合体的总路径长度
        total_path_length = 0;
        for idx_pt = 2:length(muscle_pts)
            total_path_length = total_path_length + norm(pts(idx_pt-1, :) - pts(idx_pt, :));
        end
        
        % 肌肉-肌腱复合体总长度
        mtu_lengths(idxFrame) = total_path_length;
        
        % 简化假设：肌腱长度为松弛长度（刚体假设）
        muscle_tendon_lengths(idxFrame) = tendon_slack_length;
        
        % 肌肉纤维长度 = 总长度 - 肌腱长度
        fiber_length_along_tendon = total_path_length - tendon_slack_length;
        
        % 考虑羽状角的影响
        % 肌肉纤维长度 = 沿肌腱方向的长度 * cos(羽状角)
        if pennation_angle > 0
            muscle_fiber_lengths(idxFrame) = fiber_length_along_tendon * cos(pennation_angle);
            muscle_fiber_lengths(idxFrame) = fiber_length_along_tendon * 1;
        else
            muscle_fiber_lengths(idxFrame) = fiber_length_along_tendon;
        end
        
        % 确保肌肉纤维长度为正值
        muscle_fiber_lengths(idxFrame) = max(0.1 * optimal_fiber_length, muscle_fiber_lengths(idxFrame));
    end
    
    % 存储结果
    muscle_lengths.(name) = mtu_lengths;           % 总长度（用于运动学）
    fiber_lengths.(name) = muscle_fiber_lengths;   % 纤维长度（用于力计算）
    tendon_lengths.(name) = muscle_tendon_lengths; % 肌腱长度（常数）
    
end

end 