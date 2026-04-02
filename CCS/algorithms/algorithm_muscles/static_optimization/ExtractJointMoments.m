function target_moments = ExtractJointMoments(jointMomentGlobal, joints_to_optimize, frame)
%% 提取用于优化的目标关节力矩（修正为X轴分量）
% 修改：根据joints_to_optimize动态提取关节力矩

target_moments = zeros(length(joints_to_optimize), 1);

for i = 1:length(joints_to_optimize)
    joint = joints_to_optimize{i};

    switch joint
        case 'lumbar'
            % 腰椎关节力矩：正值表示伸展
            if isfield(jointMomentGlobal, 'Trunk_Lower_proximal') && isfield(jointMomentGlobal.Trunk_Lower_proximal, 'x')
                target_moments(i) = jointMomentGlobal.Trunk_Lower_proximal.x(frame);
            else
                target_moments(i) = 0; % 如果没有腰椎力矩数据，设为0
            end
        case 'hip_l'
            % 髋关节力矩：正值表示屈曲
            target_moments(i) = jointMomentGlobal.Thigh_Left_proximal.x(frame);
        case 'hip_r'
            target_moments(i) = jointMomentGlobal.Thigh_Right_proximal.x(frame);
        case 'knee_l'
            % 膝关节力矩：正值表示伸展
            target_moments(i) = jointMomentGlobal.Shank_Left_proximal.x(frame);
        case 'knee_r'
            target_moments(i) = jointMomentGlobal.Shank_Right_proximal.x(frame);
        case 'ankle_l'
            % 踝关节力矩：正值表示屈曲
            target_moments(i) = jointMomentGlobal.Foot_Left_proximal.x(frame);
        case 'ankle_r'
            target_moments(i) = jointMomentGlobal.Foot_Right_proximal.x(frame);
    end
end
end