function [normal_fiber_lengths,normal_fiber_velocities] = CalNormalFiberLengths(muscles,fiber_lengths,muscle_velocities)

names = fieldnames(muscles);
n_frames = length(fiber_lengths.(names{1}));

normal_fiber_lengths = zeros(n_frames,length(names));
normal_fiber_velocities = zeros(n_frames,length(names));

for idx_name = 1:length(names)
    name = names{idx_name};

    % 肌肉参数
    l_opt = muscles.(name).optimal_fiber_length;
    v_max = muscles.(name).max_contraction_velocity;
    F_max = muscles.(name).max_isometric_force;
    theta = muscles.(name).pennation_angle;

    for idxFrame = 1:n_frames
        l = fiber_lengths.(name)(idxFrame);
        v = muscle_velocities.(name)(idxFrame);
        
        % 归一化
        l_normal = l./l_opt;
        v_normal = v./v_max;

        normal_fiber_lengths(idxFrame,idx_name) = l_normal;
        normal_fiber_velocities(idxFrame,idx_name) = v_normal;
    end

end

normal_fiber_lengths = array2table(normal_fiber_lengths,"VariableNames",names);
normal_fiber_velocities = array2table(normal_fiber_velocities,"VariableNames",names);