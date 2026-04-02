function moment_arms = CalculateAnatomicalMomentArms(muscles, segments_RM, segments_origin, segments_length, streamInter, include_lumbar, include_lumbar_muscle)
%% 基于解剖学知识计算力臂
% 只计算解剖学上有意义的肌肉-关节组合
% 新增：根据include_lumbar参数决定是否计算腰椎相关的力臂
% 修改：添加肌肉方向性，确保力臂符号正确反映肌肉功能（伸肌为负，屈肌为正）

muscle_names = fieldnames(muscles);
n_frames = length(streamInter.wtime);

moment_arms = struct();

% 定义肌肉-关节解剖学关系
muscle_joint_map = GetMuscleJointMap(include_lumbar, include_lumbar_muscle);

% 定义关节中心和轴向
joint_info = struct();
if include_lumbar
    joint_info.lumbar.center_field = {'SPINE_NAVAL'};
    joint_info.lumbar.axis = [1, 0, 0]; % 绕X轴的屈伸运动（矢状面）
end
joint_info.hip_l.center_field = {'HIP_LEFT'};
joint_info.hip_l.axis = [1, 0, 0]; % 绕X轴的屈伸运动
joint_info.hip_r.center_field = {'HIP_RIGHT'};
joint_info.hip_r.axis = [1, 0, 0];
joint_info.knee_l.center_field = {'KNEE_LEFT'};
joint_info.knee_l.axis = [1, 0, 0];
joint_info.knee_r.center_field = {'KNEE_RIGHT'};
joint_info.knee_r.axis = [1, 0, 0];
joint_info.ankle_l.center_field = {'ANKLE_LEFT'};
joint_info.ankle_l.axis = [1, 0, 0];
joint_info.ankle_r.center_field = {'ANKLE_RIGHT'};
joint_info.ankle_r.axis = [1, 0, 0];

% 只计算解剖学上有意义的肌肉-关节组合
for muscle_idx = 1:length(muscle_names)
    muscle_name = muscle_names{muscle_idx};
    
    % 检查该肌肉是否在映射表中
    if ~isfield(muscle_joint_map, muscle_name)
        continue;
    end
    
    % 获取该肌肉作用的关节列表
    relevant_joints = muscle_joint_map.(muscle_name);
    
    for joint_idx = 1:length(relevant_joints)
        joint_name = relevant_joints{joint_idx};
        
        % 检查关节是否在关节信息中
        if ~isfield(joint_info, joint_name)
            continue;
        end
        
        field_name = [muscle_name '_' joint_name];
        moment_arms.(field_name) = zeros(n_frames, 1);

        for frame = 1:n_frames
            % 获取肌肉路径点
            muscle_pts = muscles.(muscle_name).geometry;
            pts = zeros(length(muscle_pts), 3);

            for pt_idx = 1:length(muscle_pts)
                muscle_pt = muscle_pts{pt_idx};
                r = segments_RM.(muscle_pt.frame){frame};
                l = segments_length.(muscle_pt.frame)(frame);
                origin = segments_origin.(muscle_pt.frame)(frame, :);
                aux = l * muscle_pt.location * r' + origin;
                pts(pt_idx, :) = aux(:)';
            end

            % 计算力臂
            if size(pts, 1) >= 2
                % 获取关节中心
                joint_center_field = joint_info.(joint_name).center_field{1};
                joint_center = [streamInter.(joint_center_field).x(frame), ...
                    streamInter.(joint_center_field).y(frame), ...
                    streamInter.(joint_center_field).z(frame)];

                % 计算有效力臂
                moment_arm = CalculateEffectiveMomentArm(pts, joint_center, joint_info.(joint_name).axis);
                
                % 添加肌肉特定的力臂权重调整
                moment_arm_weight = GetMomentArmWeight(muscle_name, joint_name);
                moment_arm = moment_arm * moment_arm_weight;
                
                % 应用肌肉方向性修正（确保伸肌为负，屈肌为正）
                moment_arm = ApplyMuscleDirectionality(muscle_name, joint_name, moment_arm);
                
%                 % 限制力臂范围并检查合理性
%                 moment_arm = max(-0.2, min(0.2, moment_arm));
%                 if isnan(moment_arm) || isinf(moment_arm)
%                     moment_arm = 0;
%                 end
                
                moment_arms.(field_name)(frame) = moment_arm;
            end
        end
    end
end
end

function weight = GetMomentArmWeight(muscle_name, joint_name)
    %% 获取肌肉-关节力臂权重，用于调整某些肌肉的过度影响
    
    weight = 1.0; % 默认权重
    
    % 针对特定肌肉-关节组合调整权重
    switch [muscle_name '_' joint_name]
        case {'ercspn_l_hip_l', 'ercspn_r_hip_r'}
            weight = 0.3; % 减少竖脊肌对髋关节的影响
        case {'vasti_l_knee_l', 'vasti_r_knee_r'}
            weight = 0.7; % 适度减少股四头肌的主导作用
        case {'tib_ant_l_ankle_l', 'tib_ant_r_ankle_r'}
            weight = 0.6; % 减少胫前肌的过度影响
        case {'vasti_l_hip_l', 'vasti_r_hip_r'}
            weight = 0.1; % 股四头肌对髋关节的作用很小
    end
end

function corrected_moment_arm = ApplyMuscleDirectionality(muscle_name, joint_name, moment_arm)
    %% 根据肌肉的解剖功能调整力臂符号
    % 根据关节力矩方向约定：
    % - 髋关节力矩为正 → 髋关节屈曲倾向
    % - 膝关节力矩为正 → 膝关节伸展倾向
    % - 踝关节力矩为正 → 踝关节屈曲（背屈）倾向
    
    corrected_moment_arm = moment_arm;
    
    % 根据肌肉-关节组合调整符号
    switch [muscle_name '_' joint_name]
        % 髋关节 (正值=屈曲倾向)
        case {'hamstrings_l_hip_l', 'hamstrings_r_hip_r'}
            % 腘绳肌是髋关节伸肌 → 负力臂
            corrected_moment_arm = -abs(moment_arm);
        case {'glut_max_l_hip_l', 'glut_max_r_hip_r'}
            % 臀大肌是髋关节伸肌 → 负力臂
            corrected_moment_arm = -abs(moment_arm);
        case {'iliopsoas_l_hip_l', 'iliopsoas_r_hip_r'}
            % 髂腰肌是髋关节屈肌 → 正力臂
            corrected_moment_arm = abs(moment_arm);
        case {'rect_fem_l_hip_l', 'rect_fem_r_hip_r'}
            % 股直肌是髋关节屈肌 → 正力臂
            corrected_moment_arm = abs(moment_arm);
        case {'ercspn_l_hip_l', 'ercspn_r_hip_r'}
            % 竖脊肌是髋关节伸肌 → 负力臂
            corrected_moment_arm = -abs(moment_arm);
            
        % 膝关节 (正值=伸展倾向)
        case {'hamstrings_l_knee_l', 'hamstrings_r_knee_r'}
            % 腘绳肌是膝关节屈肌 → 负力臂
            corrected_moment_arm = -abs(moment_arm);
        case {'bifemsh_l_knee_l', 'bifemsh_r_knee_r'}
            % 股二头肌是膝关节屈肌 → 负力臂
            corrected_moment_arm = -abs(moment_arm);
        case {'rect_fem_l_knee_l', 'rect_fem_r_knee_r'}
            % 股直肌是膝关节伸肌 → 正力臂
            corrected_moment_arm = abs(moment_arm);
        case {'vasti_l_knee_l', 'vasti_r_knee_r'}
            % 股四头肌是膝关节伸肌 → 正力臂
            corrected_moment_arm = abs(moment_arm);
        case {'gastroc_l_knee_l', 'gastroc_r_knee_r'}
            % 腓肠肌是膝关节屈肌 → 负力臂
            corrected_moment_arm = -abs(moment_arm);
            
        % 踝关节 (正值=背屈倾向)
        case {'gastroc_l_ankle_l', 'gastroc_r_ankle_r'}
            % 腓肠肌是踝关节跖屈肌 → 负力臂
            corrected_moment_arm = -abs(moment_arm);
        case {'soleus_l_ankle_l', 'soleus_r_ankle_r'}
            % 比目鱼肌是踝关节跖屈肌 → 负力臂
            corrected_moment_arm = -abs(moment_arm);
        case {'tib_ant_l_ankle_l', 'tib_ant_r_ankle_r'}
            % 胫前肌是踝关节背屈肌 → 正力臂
            corrected_moment_arm = abs(moment_arm);
            
        % 腰椎关节 (正值=伸展倾向)
        case {'ercspn_l_lumbar', 'ercspn_r_lumbar'}
            % 竖脊肌是腰椎伸肌 → 正力臂
            corrected_moment_arm = abs(moment_arm);
        case {'extobl_l_lumbar', 'extobl_r_lumbar'}
            % 腹外斜肌是腰椎屈肌 → 负力臂
            corrected_moment_arm = -abs(moment_arm);
        case {'intobl_l_lumbar', 'intobl_r_lumbar'}
            % 腹内斜肌是腰椎屈肌 → 负力臂
            corrected_moment_arm = -abs(moment_arm);
        case {'iliopsoas_l_lumbar', 'iliopsoas_r_lumbar'}
            % 髂腰肌是腰椎屈肌 → 负力臂
            corrected_moment_arm = -abs(moment_arm);
    end
end