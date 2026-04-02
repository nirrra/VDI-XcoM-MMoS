function [F_active_max, F_passive] = CalculateMuscleForceComponents(muscles, muscle_lengths, muscle_velocities, muscle_names, frame)
%% 分别计算肌肉的主动力最大值和被动力
% 修正：将主动力和被动力分开计算

F_active_max = zeros(length(muscle_names), 1);
F_passive = zeros(length(muscle_names), 1);

for i = 1:length(muscle_names)
    muscle_name = muscle_names{i};

    % 肌肉参数
    l_opt = muscles.(muscle_name).optimal_fiber_length;
    v_max = muscles.(muscle_name).max_contraction_velocity;
    F_max = muscles.(muscle_name).max_isometric_force;

    % 当前肌肉状态
    l = muscle_lengths.(muscle_name)(frame);
    v = muscle_velocities.(muscle_name)(frame);

    % 归一化值
    l_normal = l / l_opt;
    v_normal = v / v_max;

    % 力-长度和力-速度关系
    F_l = CalFl(l_normal);
    F_v = CalFv(v_normal);
    F_pe = CalFpe(l_normal);

    % 主动力最大值（当a=1时）
    F_active_max(i) = F_max * F_l * F_v;
    
    % 被动力（不受激活度控制）
    F_passive(i) = F_max * F_pe;
end
end