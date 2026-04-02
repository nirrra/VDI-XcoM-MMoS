function AnalyzeJointMomentMuscleContribution(jointMomentGlobal, muscle_forces, moment_arms, muscle_names, times, options, varargin)
%% 分析每个关节的关节矩与关联肌肉提供关节矩的大小关系
%
% 输入参数:
%   jointMomentGlobal - 关节力矩结构体
%   muscle_forces - 肌肉力结构体
%   moment_arms - 肌肉力臂结构体
%   muscle_names - 肌肉名称列表
%   times - 时间向量
%   varargin - 可选参数
%     'side' - 'left' 或 'right'，默认 'left'
%     'include_lumbar' - 是否包含腰椎关节，默认 true
%
% 输出:
%   生成3个子图显示髋关节、膝关节、踝关节的力矩平衡分析

% 解析可选参数
p = inputParser;
addParameter(p, 'side', 'left', @(x) ismember(x, {'left', 'right'}));
addParameter(p, 'include_lumbar', true, @islogical);
addParameter(p, 'include_lumbar_muscle', true, @islogical);
parse(p, varargin{:});

side = p.Results.side;
include_lumbar = options.include_lumbar;
include_lumbar_muscle = options.include_lumbar_muscle;

% 定义肌肉-关节映射关系
muscle_joint_map = GetMuscleJointMap(include_lumbar, include_lumbar_muscle);

% 定义要分析的关节
if strcmp(side, 'left')
    joints_to_analyze = {'hip_l', 'knee_l', 'ankle_l'};
    joint_moment_fields = {'Thigh_Left_proximal', 'Shank_Left_proximal', 'Foot_Left_proximal'};
    joint_titles = {'左髋关节', '左膝关节', '左踝关节'};
else
    joints_to_analyze = {'hip_r', 'knee_r', 'ankle_r'};
    joint_moment_fields = {'Thigh_Right_proximal', 'Shank_Right_proximal', 'Foot_Right_proximal'};
    joint_titles = {'右髋关节', '右膝关节', '右踝关节'};
end

% 创建图形
figure('Position', [100, 100, 1200, 900]);

% 分析每个关节
for joint_idx = 1:length(joints_to_analyze)
    subplot(3, 1, joint_idx);
    
    joint_name = joints_to_analyze{joint_idx};
    joint_field = joint_moment_fields{joint_idx};
    joint_title = joint_titles{joint_idx};
    
    % 提取关节力矩（目标）
    target_moment = jointMomentGlobal.(joint_field).x;
    
    % 计算该关节相关肌肉的力矩贡献
    [muscle_moments, muscle_contributions, total_muscle_moment] = ...
        CalculateJointMuscleContributions(joint_name, muscle_forces, moment_arms, muscle_names, muscle_joint_map);
    
    % 绘制结果
    PlotJointMomentComparison(times, target_moment, muscle_contributions, total_muscle_moment, joint_title, muscle_moments);
    
    % 计算并显示统计信息
    DisplayJointStatistics(target_moment, total_muscle_moment, joint_title, muscle_contributions);
end

% 添加总标题
sgtitle('关节力矩与肌肉贡献分析');

end

function [muscle_moments, muscle_contributions, total_muscle_moment] = ...
    CalculateJointMuscleContributions(joint_name, muscle_forces, moment_arms, muscle_names, muscle_joint_map)
%% 计算特定关节的肌肉力矩贡献

n_frames = length(muscle_forces.(muscle_names{1}));
muscle_moments = struct();
muscle_contributions = [];
muscle_labels = {};
total_muscle_moment = zeros(n_frames, 1);

% 遍历所有肌肉，找到作用于该关节的肌肉
for muscle_idx = 1:length(muscle_names)
    muscle_name = muscle_names{muscle_idx};
    
    % 检查该肌肉是否作用于目标关节
    if isfield(muscle_joint_map, muscle_name) && ...
       ismember(joint_name, muscle_joint_map.(muscle_name))
        
        % 构建力臂字段名
        moment_arm_field = [muscle_name '_' joint_name];
        
        % 检查力臂数据是否存在
        if isfield(moment_arms, moment_arm_field)
            % 计算该肌肉对该关节的力矩贡献
            muscle_moment = muscle_forces.(muscle_name) .* moment_arms.(moment_arm_field);
            muscle_moments.(muscle_name) = muscle_moment;
            
            % 存储用于绘图
            muscle_contributions = [muscle_contributions, muscle_moment];
            muscle_labels{end+1} = strrep(muscle_name, '_', '\_'); % 转义下划线用于显示
            
            % 累加到总力矩
            total_muscle_moment = total_muscle_moment + muscle_moment;
        end
    end
end

end

function PlotJointMomentComparison(times, target_moment, muscle_contributions, total_muscle_moment, joint_title, muscle_moments)
%% 绘制关节力矩比较图

% 计算时间范围：开始10秒到结束前10秒
time_start = min(times) + 10;  % 开始后10秒
time_end = max(times) - 10;    % 结束前10秒

% 找到对应的索引范围
start_idx = find(times >= time_start, 1, 'first');
end_idx = find(times <= time_end, 1, 'last');

% 如果时间范围不足20秒，则显示全部数据
if isempty(start_idx) || isempty(end_idx) || start_idx >= end_idx
    warning('时间数据不足20秒，显示全部数据');
    start_idx = 1;
    end_idx = length(times);
end

% 截取时间和数据
times_plot = times(start_idx:end_idx);
target_moment_plot = target_moment(start_idx:end_idx);
total_muscle_moment_plot = total_muscle_moment(start_idx:end_idx);

hold on;

% 绘制目标关节力矩（黑色粗线）
plot(times_plot, target_moment_plot, 'k-', 'LineWidth', 3, 'DisplayName', '目标关节力矩');

% 绘制总肌肉力矩（红色虚线）
plot(times_plot, total_muscle_moment_plot, 'r--', 'LineWidth', 2, 'DisplayName', '肌肉总贡献');

% 绘制各个肌肉的贡献（不同颜色）
if ~isempty(muscle_contributions)
    muscle_names_display = fieldnames(muscle_moments);
    colors = lines(length(muscle_names_display));
    
    for i = 1:length(muscle_names_display)
        muscle_name = muscle_names_display{i};
        muscle_moment = muscle_moments.(muscle_name);
        muscle_moment_plot = muscle_moment(start_idx:end_idx);
        
        % 只显示贡献较大的肌肉（避免图形过于复杂）
        if max(abs(muscle_moment_plot)) > 0.01 * max(abs(target_moment_plot))
            plot(times_plot, muscle_moment_plot, '-', 'Color', colors(i,:), 'LineWidth', 1.5, ...
                'DisplayName', strrep(muscle_name, '_', '\_'));
        end
    end
end

% 绘制零线
plot(times_plot, zeros(size(times_plot)), 'k:', 'LineWidth', 0.5, 'HandleVisibility', 'off');

% 设置图形属性
xlabel('时间 (s)');
ylabel('力矩 (N·m)');
title(sprintf('%s力矩平衡分析 (显示时间: %.1f-%.1fs)', joint_title, time_start, time_end));
legend('Location', 'best', 'FontSize', 8);
grid on;
xlim([min(times_plot), max(times_plot)]);

hold off;

end

function DisplayJointStatistics(target_moment, total_muscle_moment, joint_title, muscle_contributions)
%% 显示关节力矩统计信息

% 计算残差
residual = target_moment - total_muscle_moment;
rms_residual = sqrt(mean(residual.^2));
max_target = max(abs(target_moment));
relative_error = rms_residual / max_target * 100;

% 计算肌肉贡献的分布
if ~isempty(muscle_contributions)
    muscle_rms = sqrt(mean(muscle_contributions.^2));
    [~, dominant_idx] = max(muscle_rms);
    
    fprintf('\n=== %s统计信息 ===\n', joint_title);
    fprintf('最大关节力矩: %.2f N·m\n', max_target);
    fprintf('RMS残差: %.4f N·m\n', rms_residual);
    fprintf('相对误差: %.2f%%\n', relative_error);
    fprintf('主要贡献肌肉: 第%d个肌肉\n', dominant_idx);
    fprintf('肌肉数量: %d\n', size(muscle_contributions, 2));
end

end
