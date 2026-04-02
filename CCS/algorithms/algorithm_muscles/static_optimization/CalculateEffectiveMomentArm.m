function moment_arm = CalculateEffectiveMomentArm(muscle_pts, joint_center, joint_axis)
%% 计算有效力臂，考虑多段肌肉路径
% 使用分段计算方法，更准确地反映肌肉的实际作用线

if size(muscle_pts, 1) < 2
    moment_arm = 0;
    return;
end

total_moment_arm = 0;
total_length = 0;

% 对每个肌肉段计算力臂并加权平均
for i = 1:size(muscle_pts, 1)-1
    seg_start = muscle_pts(i, :);
    seg_end = muscle_pts(i+1, :);
    seg_vector = seg_end - seg_start;
    seg_length = norm(seg_vector);
    
    if seg_length > 1e-6  % 避免除零
        seg_unit_vector = seg_vector / seg_length;
        
        % 计算段中点到关节中心的向量
        seg_midpoint = (seg_start + seg_end) / 2;
        r_vec = seg_midpoint - joint_center;
        
        % 计算力臂向量
        moment_arm_vector = cross(r_vec, seg_unit_vector);
        
        % 投影到关节轴上
        segment_moment_arm = dot(moment_arm_vector, joint_axis);
        
        % 按长度加权
        total_moment_arm = total_moment_arm + segment_moment_arm * seg_length;
        total_length = total_length + seg_length;
    end
end

if total_length > 1e-6
    moment_arm = total_moment_arm / total_length;
else
    moment_arm = 0;
end
end