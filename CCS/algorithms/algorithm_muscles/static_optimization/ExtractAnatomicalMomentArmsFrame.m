function R = ExtractAnatomicalMomentArmsFrame(moment_arms, muscle_names, joints_to_optimize, frame)
%% 提取特定帧的力臂矩阵R（基于解剖学映射）
% R(i,j) = 肌肉j相对于关节i的力臂
% 只有解剖学上有意义的肌肉-关节组合才有非零力臂

n_joints = length(joints_to_optimize);
n_muscles = length(muscle_names);
R = zeros(n_joints, n_muscles);

for i = 1:n_joints
    joint = joints_to_optimize{i};
    for j = 1:n_muscles
        muscle = muscle_names{j};
        field_name = [muscle '_' joint];
        
        % 只有当该肌肉-关节组合在解剖学映射中存在时，才设置力臂值
        if isfield(moment_arms, field_name)
            R(i, j) = moment_arms.(field_name)(frame);
        else
            R(i, j) = 0; % 解剖学上无关联的肌肉-关节组合力臂为0
        end
    end
end
end