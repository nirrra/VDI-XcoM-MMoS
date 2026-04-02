function muscle_joint_map = GetMuscleJointMap(include_lumbar, include_lumbar_muscle)
%% 定义肌肉-关节解剖学关系
% 基于解剖学知识定义每块肌肉作用的关节
% 新增：根据include_lumbar参数决定是否包含腰椎关节

muscle_joint_map = struct();

% 基于解剖学知识定义每块肌肉作用的关节
muscle_joint_map.hamstrings_l = {'hip_l', 'knee_l'};
muscle_joint_map.hamstrings_r = {'hip_r', 'knee_r'};
muscle_joint_map.bifemsh_l = {'knee_l'};
muscle_joint_map.bifemsh_r = {'knee_r'};
muscle_joint_map.glut_max_l = {'hip_l'};
muscle_joint_map.glut_max_r = {'hip_r'};
muscle_joint_map.rect_fem_l = {'hip_l', 'knee_l'};
muscle_joint_map.rect_fem_r = {'hip_r', 'knee_r'};
muscle_joint_map.vasti_l = {'knee_l'};
muscle_joint_map.vasti_r = {'knee_r'};
muscle_joint_map.gastroc_l = {'knee_l', 'ankle_l'};
muscle_joint_map.gastroc_r = {'knee_r', 'ankle_r'};
muscle_joint_map.soleus_l = {'ankle_l'};
muscle_joint_map.soleus_r = {'ankle_r'};
muscle_joint_map.tib_ant_l = {'ankle_l'};
muscle_joint_map.tib_ant_r = {'ankle_r'};

if include_lumbar_muscle
    if include_lumbar
        muscle_joint_map.ercspn_l = {'lumbar', 'hip_l'};
        muscle_joint_map.ercspn_r = {'lumbar', 'hip_r'};
        muscle_joint_map.extobl_l = {'lumbar', 'hip_l'};
        muscle_joint_map.extobl_r = {'lumbar', 'hip_r'};
        muscle_joint_map.intobl_l = {'lumbar', 'hip_l'};
        muscle_joint_map.intobl_r = {'lumbar', 'hip_r'};
    else
        muscle_joint_map.ercspn_l = {'hip_l'};
        muscle_joint_map.ercspn_r = {'hip_r'};
        muscle_joint_map.extobl_l = {'hip_l'};
        muscle_joint_map.extobl_r = {'hip_r'};
        muscle_joint_map.intobl_l = {'hip_l'};
        muscle_joint_map.intobl_r = {'hip_r'};
    end
end

% 根据include_lumbar参数决定是否包含腰椎关节
if include_lumbar
    muscle_joint_map.iliopsoas_l = {'hip_l', 'lumbar'};
    muscle_joint_map.iliopsoas_r = {'hip_r', 'lumbar'};
else
    % 不包含腰椎关节时，这些肌肉只作用于髋关节
    muscle_joint_map.iliopsoas_l = {'hip_l'};
    muscle_joint_map.iliopsoas_r = {'hip_r'};
end
end