function [muscle_forces, muscle_forces_ce, muscle_forces_pe, f_ls, f_vs, f_pes] = CalMuscleForces(muscles,fiber_lengths,muscle_velocities,muscle_activations)

%% 计算肌肉力
muscle_forces = struct();
muscle_forces_ce = struct();
muscle_forces_pe = struct();

f_ls = struct();
f_vs = struct();
f_pes = struct();

names = fieldnames(muscles);
for idx_name = 1:length(names)
    name = names{idx_name};

    n_frames = length(fiber_lengths.(name));
    muscle_forces.(name) = zeros(n_frames, 1);
    muscle_forces_ce.(name) = zeros(n_frames, 1);
    muscle_forces_pe.(name) = zeros(n_frames, 1);

    f_ls.(name) = zeros(n_frames, 1);
    f_vs.(name) = zeros(n_frames, 1);
    f_pes.(name) = zeros(n_frames, 1);

    % 肌肉参数
    l_opt = muscles.(name).optimal_fiber_length;
    v_max = muscles.(name).max_contraction_velocity;
    F_max = muscles.(name).max_isometric_force;
    theta = muscles.(name).pennation_angle;

    for idxFrame = 1:n_frames
        a = muscle_activations.(name)(idxFrame);
        l = fiber_lengths.(name)(idxFrame);
        v = muscle_velocities.(name)(idxFrame);
        
        % 归一化
        l_normal = l./l_opt;
        v_normal = v./v_max;

        f_l = CalFl(l_normal);
        f_v = CalFv(v_normal);
        f_pe = CalFpe(l_normal);
        
        % 考虑羽状角的影响
        cos_theta = cos(theta);
        
        % 计算肌肉力分量
        F_ce = F_max * a * f_l * f_v * cos_theta;
        F_pe_total = F_max * f_pe * cos_theta;
        F_total = F_ce + F_pe_total;

        % 确保力值为非负
        muscle_forces_ce.(name)(idxFrame) = max(0, F_ce);
        muscle_forces_pe.(name)(idxFrame) = max(0, F_pe_total);
        muscle_forces.(name)(idxFrame) = max(0, F_total);

        f_ls.(name)(idxFrame) = f_l;
        f_vs.(name)(idxFrame) = f_v;
        f_pes.(name)(idxFrame) = f_pe;
    end

end

f_ls = struct2table(f_ls);
f_vs = struct2table(f_vs);
f_pes = struct2table(f_pes);
