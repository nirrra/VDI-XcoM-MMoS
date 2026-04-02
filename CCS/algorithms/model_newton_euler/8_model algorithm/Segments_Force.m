  function seg_force = Segments_Force(mass,sex,ground_force_Left,ground_force_Right,hip_force_Left,hip_force_Right,segments_com_acceleration)

if sex == 'M'
    Lcs.HeadNeck = 1;
    Lcs.Trunk = 0.4486;
    Lcs.Upperarm = 0.5772;
    Lcs.Forearm = 0.4574;
    Lcs.Hand = 0.79;
    Lcs.Thigh = 0.4095;
    Lcs.Shank = 0.4459;
    Lcs.Foot = 0.4415;
    
    M.HeadNeck = 0.0694;
    M.Trunk = 0.4346;
    M.Upperarm = 0.0271;
    M.Forearm = 0.0162;
    M.Hand = 0.0061;
    M.Thigh = 0.1416;
    M.Shank = 0.0433;
    M.Foot = 0.0137;
elseif sex == 'F'
    Lcs.HeadNeck = 1;
    Lcs.Trunk = 0.4151;
    Lcs.Upperarm = 0.5754;
    Lcs.Forearm = 0.4559;
    Lcs.Hand = 0.7474;
    Lcs.Thigh = 0.3612;
    Lcs.Shank = 0.4416;
    Lcs.Foot = 0.4014;
    
    M.HeadNeck = 0.0669;%为了将体重凑到100%
    M.Trunk = 0.4257;
    M.Upperarm = 0.0255;
    M.Forearm = 0.0138;
    M.Hand = 0.0056;
    M.Thigh = 0.1478;
    M.Shank = 0.0481;
    M.Foot = 0.0129;
end
%% 左下肢
% 地面反作用力
reaction_force_Foot_Left_distal.x = ground_force_Left.x;
reaction_force_Foot_Left_distal.y = ground_force_Left.y;
reaction_force_Foot_Left_distal.z = ground_force_Left.z;
% 左足
reaction_force_Foot_Left_proximal.x = mass*M.Foot* segments_com_acceleration.Foot_Left.x - reaction_force_Foot_Left_distal.x;
reaction_force_Foot_Left_proximal.y = mass*M.Foot* segments_com_acceleration.Foot_Left.y - reaction_force_Foot_Left_distal.y;
reaction_force_Foot_Left_proximal.z = mass*M.Foot* segments_com_acceleration.Foot_Left.z - reaction_force_Foot_Left_distal.z + mass*M.Foot*9.8;
% 作用力与反作用力
reaction_force_Shank_Left_distal.x = -reaction_force_Foot_Left_proximal.x;
reaction_force_Shank_Left_distal.y = -reaction_force_Foot_Left_proximal.y;
reaction_force_Shank_Left_distal.z = -reaction_force_Foot_Left_proximal.z;
% 左小腿
reaction_force_Shank_Left_proximal.x = mass*M.Shank* segments_com_acceleration.Shank_Left.x - reaction_force_Shank_Left_distal.x;
reaction_force_Shank_Left_proximal.y = mass*M.Shank* segments_com_acceleration.Shank_Left.y - reaction_force_Shank_Left_distal.y;
reaction_force_Shank_Left_proximal.z = mass*M.Shank* segments_com_acceleration.Shank_Left.z - reaction_force_Shank_Left_distal.z + mass*M.Shank*9.8;
% 作用力与反作用力
reaction_force_Thigh_Left_distal.x = -reaction_force_Shank_Left_proximal.x;
reaction_force_Thigh_Left_distal.y = -reaction_force_Shank_Left_proximal.y;
reaction_force_Thigh_Left_distal.z = -reaction_force_Shank_Left_proximal.z;

% 臀部垫子作用力
reaction_force_Thigh_Left_hip.x = hip_force_Left.x;
reaction_force_Thigh_Left_hip.y = hip_force_Left.y;
reaction_force_Thigh_Left_hip.z = hip_force_Left.z;


% 左大腿
reaction_force_Thigh_Left_proximal.x = mass*M.Thigh* segments_com_acceleration.Thigh_Left.x - reaction_force_Thigh_Left_distal.x - reaction_force_Thigh_Left_hip.x;
reaction_force_Thigh_Left_proximal.y = mass*M.Thigh* segments_com_acceleration.Thigh_Left.y - reaction_force_Thigh_Left_distal.y - reaction_force_Thigh_Left_hip.y;
reaction_force_Thigh_Left_proximal.z = mass*M.Thigh* segments_com_acceleration.Thigh_Left.z - reaction_force_Thigh_Left_distal.z...
    - reaction_force_Thigh_Left_hip.z+ mass*M.Thigh*9.8;


% 左大腿与躯干作用力与反作用力
reaction_force_Trunk_Lower_Left_proximal.x = -reaction_force_Thigh_Left_proximal.x;
reaction_force_Trunk_Lower_Left_proximal.y = -reaction_force_Thigh_Left_proximal.y;
reaction_force_Trunk_Lower_Left_proximal.z = -reaction_force_Thigh_Left_proximal.z;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 右下肢
% 地面反作用力
reaction_force_Foot_Right_distal.x = ground_force_Right.x;
reaction_force_Foot_Right_distal.y = ground_force_Right.y;
reaction_force_Foot_Right_distal.z = ground_force_Right.z;
% 右足
reaction_force_Foot_Right_proximal.x = mass*M.Foot* segments_com_acceleration.Foot_Right.x - reaction_force_Foot_Right_distal.x;
reaction_force_Foot_Right_proximal.y = mass*M.Foot* segments_com_acceleration.Foot_Right.y - reaction_force_Foot_Right_distal.y;
reaction_force_Foot_Right_proximal.z = mass*M.Foot* segments_com_acceleration.Foot_Right.z - reaction_force_Foot_Right_distal.z + mass*M.Foot*9.8;
% 作用力与反作用力
reaction_force_Shank_Right_distal.x = -reaction_force_Foot_Right_proximal.x;
reaction_force_Shank_Right_distal.y = -reaction_force_Foot_Right_proximal.y;
reaction_force_Shank_Right_distal.z = -reaction_force_Foot_Right_proximal.z;
% 右小腿
reaction_force_Shank_Right_proximal.x = mass*M.Shank* segments_com_acceleration.Shank_Right.x - reaction_force_Shank_Right_distal.x;
reaction_force_Shank_Right_proximal.y = mass*M.Shank* segments_com_acceleration.Shank_Right.y - reaction_force_Shank_Right_distal.y;
reaction_force_Shank_Right_proximal.z = mass*M.Shank* segments_com_acceleration.Shank_Right.z - reaction_force_Shank_Right_distal.z + mass*M.Shank*9.8;
% 作用力与反作用力
reaction_force_Thigh_Right_distal.x = -reaction_force_Shank_Right_proximal.x;
reaction_force_Thigh_Right_distal.y = -reaction_force_Shank_Right_proximal.y;
reaction_force_Thigh_Right_distal.z = -reaction_force_Shank_Right_proximal.z;

% 臀部垫子作用力
reaction_force_Thigh_Right_hip.x = hip_force_Right.x;
reaction_force_Thigh_Right_hip.y = hip_force_Right.y;
reaction_force_Thigh_Right_hip.z = hip_force_Right.z;

% 右大腿
reaction_force_Thigh_Right_proximal.x = mass*M.Thigh* segments_com_acceleration.Thigh_Right.x  - reaction_force_Thigh_Right_distal.x - reaction_force_Thigh_Right_hip.x;
reaction_force_Thigh_Right_proximal.y = mass*M.Thigh* segments_com_acceleration.Thigh_Right.y  - reaction_force_Thigh_Right_distal.y - reaction_force_Thigh_Right_hip.y;
reaction_force_Thigh_Right_proximal.z = mass*M.Thigh* segments_com_acceleration.Thigh_Right.z  - reaction_force_Thigh_Right_distal.z ...
    - reaction_force_Thigh_Right_hip.z + mass*M.Thigh*9.8;


% 右大腿与躯干作用力与反作用力
reaction_force_Trunk_Lower_Right_proximal.x = -reaction_force_Thigh_Right_proximal.x;
reaction_force_Trunk_Lower_Right_proximal.y = -reaction_force_Thigh_Right_proximal.y;
reaction_force_Trunk_Lower_Right_proximal.z = -reaction_force_Thigh_Right_proximal.z;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 左上肢
% 左手掌
reaction_force_Hand_Left_distal.x = 0.0*ground_force_Left.x;
reaction_force_Hand_Left_distal.y = 0.0*ground_force_Left.x;
reaction_force_Hand_Left_distal.z = 0.0*ground_force_Left.x;

reaction_force_Hand_Left_proximal.x = mass*M.Hand* segments_com_acceleration.Hand_Left.x  - reaction_force_Hand_Left_distal.x;
reaction_force_Hand_Left_proximal.y = mass*M.Hand* segments_com_acceleration.Hand_Left.y  - reaction_force_Hand_Left_distal.y;
reaction_force_Hand_Left_proximal.z = mass*M.Hand* segments_com_acceleration.Hand_Left.z  - reaction_force_Hand_Left_distal.z + mass*M.Hand*9.8;

% 作用力与反作用力
reaction_force_Forearm_Left_distal.x = -reaction_force_Hand_Left_proximal.x;
reaction_force_Forearm_Left_distal.y = -reaction_force_Hand_Left_proximal.y;
reaction_force_Forearm_Left_distal.z = -reaction_force_Hand_Left_proximal.z;
% 左前臂
reaction_force_Forearm_Left_proximal.x = mass*M.Forearm* segments_com_acceleration.Forearm_Left.x  - reaction_force_Forearm_Left_distal.x;
reaction_force_Forearm_Left_proximal.y = mass*M.Forearm* segments_com_acceleration.Forearm_Left.y  - reaction_force_Forearm_Left_distal.y;
reaction_force_Forearm_Left_proximal.z = mass*M.Forearm* segments_com_acceleration.Forearm_Left.z  - reaction_force_Forearm_Left_distal.z + mass*M.Forearm*9.8;
% 作用力与反作用力
reaction_force_Upperarm_Left_distal.x = -reaction_force_Forearm_Left_proximal.x;
reaction_force_Upperarm_Left_distal.y = -reaction_force_Forearm_Left_proximal.y;
reaction_force_Upperarm_Left_distal.z = -reaction_force_Forearm_Left_proximal.z;
% 左上臂
reaction_force_Upperarm_Left_proximal.x = mass*M.Upperarm* segments_com_acceleration.Upperarm_Left.x  - reaction_force_Upperarm_Left_distal.x;
reaction_force_Upperarm_Left_proximal.y = mass*M.Upperarm* segments_com_acceleration.Upperarm_Left.y  - reaction_force_Upperarm_Left_distal.y;
reaction_force_Upperarm_Left_proximal.z = mass*M.Upperarm* segments_com_acceleration.Upperarm_Left.z  - reaction_force_Upperarm_Left_distal.z + mass*M.Upperarm*9.8;
% 左上臂与躯干上作用力与反作用力
reaction_force_Trunk_Upper_Left_distal.x = -reaction_force_Upperarm_Left_proximal.x;
reaction_force_Trunk_Upper_Left_distal.y = -reaction_force_Upperarm_Left_proximal.y;
reaction_force_Trunk_Upper_Left_distal.z = -reaction_force_Upperarm_Left_proximal.z;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 右上肢
% 右手掌
reaction_force_Hand_Right_distal.x = 0.0*ground_force_Left.x;
reaction_force_Hand_Right_distal.y = 0.0*ground_force_Left.x;
reaction_force_Hand_Right_distal.z = 0.0*ground_force_Left.x;

reaction_force_Hand_Right_proximal.x = mass*M.Hand* segments_com_acceleration.Hand_Right.x  - reaction_force_Hand_Right_distal.x;
reaction_force_Hand_Right_proximal.y = mass*M.Hand* segments_com_acceleration.Hand_Right.y  - reaction_force_Hand_Right_distal.y;
reaction_force_Hand_Right_proximal.z = mass*M.Hand* segments_com_acceleration.Hand_Right.z  - reaction_force_Hand_Right_distal.z + mass*M.Hand*9.8;

% 作用力与反作用力
reaction_force_Forearm_Right_distal.x = -reaction_force_Hand_Right_proximal.x;
reaction_force_Forearm_Right_distal.y = -reaction_force_Hand_Right_proximal.y;
reaction_force_Forearm_Right_distal.z = -reaction_force_Hand_Right_proximal.z;
% 右前臂
reaction_force_Forearm_Right_proximal.x = mass*M.Forearm* segments_com_acceleration.Forearm_Right.x  - reaction_force_Forearm_Right_distal.x;
reaction_force_Forearm_Right_proximal.y = mass*M.Forearm* segments_com_acceleration.Forearm_Right.y  - reaction_force_Forearm_Right_distal.y;
reaction_force_Forearm_Right_proximal.z = mass*M.Forearm* segments_com_acceleration.Forearm_Right.z  - reaction_force_Forearm_Right_distal.z + mass*M.Forearm*9.8;
% 作用力与反作用力
reaction_force_Upperarm_Right_distal.x = -reaction_force_Forearm_Right_proximal.x;
reaction_force_Upperarm_Right_distal.y = -reaction_force_Forearm_Right_proximal.y;
reaction_force_Upperarm_Right_distal.z = -reaction_force_Forearm_Right_proximal.z;
% 右上臂
reaction_force_Upperarm_Right_proximal.x = mass*M.Upperarm* segments_com_acceleration.Upperarm_Right.x  - reaction_force_Upperarm_Right_distal.x;
reaction_force_Upperarm_Right_proximal.y = mass*M.Upperarm* segments_com_acceleration.Upperarm_Right.y  - reaction_force_Upperarm_Right_distal.y;
reaction_force_Upperarm_Right_proximal.z = mass*M.Upperarm* segments_com_acceleration.Upperarm_Right.z  - reaction_force_Upperarm_Right_distal.z + mass*M.Upperarm*9.8;
% 右上臂与躯干上作用力与反作用力
reaction_force_Trunk_Upper_Right_distal.x = -reaction_force_Upperarm_Right_proximal.x;
reaction_force_Trunk_Upper_Right_distal.y = -reaction_force_Upperarm_Right_proximal.y;
reaction_force_Trunk_Upper_Right_distal.z = -reaction_force_Upperarm_Right_proximal.z;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 头颈

reaction_force_HeadNeck_distal.x = 0.0*ground_force_Left.x;
reaction_force_HeadNeck_distal.y = 0.0*ground_force_Left.x;
reaction_force_HeadNeck_distal.z = 0.0*ground_force_Left.x;

reaction_force_HeadNeck_proximal.x = mass*M.HeadNeck* segments_com_acceleration.HeadNeck.x  - reaction_force_HeadNeck_distal.x;
reaction_force_HeadNeck_proximal.y = mass*M.HeadNeck* segments_com_acceleration.HeadNeck.y  - reaction_force_HeadNeck_distal.y;
reaction_force_HeadNeck_proximal.z = mass*M.HeadNeck* segments_com_acceleration.HeadNeck.z  - reaction_force_HeadNeck_distal.z + mass*M.HeadNeck*9.8;
% 头颈与躯干上作用力与反作用力
reaction_force_Trunk_Upper_Middle_distal.x = -reaction_force_HeadNeck_proximal.x;
reaction_force_Trunk_Upper_Middle_distal.y = -reaction_force_HeadNeck_proximal.y;
reaction_force_Trunk_Upper_Middle_distal.z = -reaction_force_HeadNeck_proximal.z;

%% 验证
force_zero_x = reaction_force_Trunk_Lower_Left_proximal.x + reaction_force_Trunk_Lower_Right_proximal.x + ...
    reaction_force_Trunk_Upper_Left_distal.x + reaction_force_Trunk_Upper_Right_distal.x + ...
    reaction_force_Trunk_Upper_Middle_distal.x - segments_com_acceleration.Trunk.x * mass * M.Trunk;
force_zero_y = reaction_force_Trunk_Lower_Left_proximal.y + reaction_force_Trunk_Lower_Right_proximal.y + ...
    reaction_force_Trunk_Upper_Left_distal.y + reaction_force_Trunk_Upper_Right_distal.y + ...
    reaction_force_Trunk_Upper_Middle_distal.y - segments_com_acceleration.Trunk.y*mass*M.Trunk;
force_zero_z = reaction_force_Trunk_Lower_Left_proximal.z + reaction_force_Trunk_Lower_Right_proximal.z + ...
    reaction_force_Trunk_Upper_Left_distal.z + reaction_force_Trunk_Upper_Right_distal.z + ...
    reaction_force_Trunk_Upper_Middle_distal.z - segments_com_acceleration.Trunk.z * mass * M.Trunk - mass*M.Trunk*9.8;
%% 整合输出结果
% 左下肢
seg_force.reaction_force_Foot_Left_distal = reaction_force_Foot_Left_distal;
seg_force.reaction_force_Foot_Left_proximal = reaction_force_Foot_Left_proximal;
seg_force.reaction_force_Shank_Left_distal = reaction_force_Shank_Left_distal;
seg_force.reaction_force_Shank_Left_proximal = reaction_force_Shank_Left_proximal;
seg_force.reaction_force_Thigh_Left_distal = reaction_force_Thigh_Left_distal;
seg_force.reaction_force_Thigh_Left_proximal = reaction_force_Thigh_Left_proximal;
seg_force.reaction_force_Trunk_Lower_Left_proximal = reaction_force_Trunk_Lower_Left_proximal;

seg_force.reaction_force_Thigh_Left_hip = reaction_force_Thigh_Left_hip;
% 右下肢
seg_force.reaction_force_Foot_Right_distal = reaction_force_Foot_Right_distal;
seg_force.reaction_force_Foot_Right_proximal= reaction_force_Foot_Right_proximal;
seg_force.reaction_force_Shank_Right_distal = reaction_force_Shank_Right_distal;
seg_force.reaction_force_Shank_Right_proximal = reaction_force_Shank_Right_proximal;
seg_force.reaction_force_Thigh_Right_distal = reaction_force_Thigh_Right_distal;
seg_force.reaction_force_Thigh_Right_proximal = reaction_force_Thigh_Right_proximal;
seg_force.reaction_force_Trunk_Lower_Right_proximal = reaction_force_Trunk_Lower_Right_proximal;

seg_force.reaction_force_Thigh_Right_hip = reaction_force_Thigh_Right_hip;
% 左上肢
seg_force.reaction_force_Hand_Left_distal = reaction_force_Hand_Left_distal;
seg_force.reaction_force_Hand_Left_proximal = reaction_force_Hand_Left_proximal;
seg_force.reaction_force_Forearm_Left_distal = reaction_force_Forearm_Left_distal;
seg_force.reaction_force_Forearm_Left_proximal = reaction_force_Forearm_Left_proximal;
seg_force.reaction_force_Upperarm_Left_distal = reaction_force_Upperarm_Left_distal;
seg_force.reaction_force_Upperarm_Left_proximal = reaction_force_Upperarm_Left_proximal;
seg_force.reaction_force_Trunk_Upper_Left_distal = reaction_force_Trunk_Upper_Left_distal;
% 右上肢
seg_force.reaction_force_Hand_Right_distal = reaction_force_Hand_Right_distal;
seg_force.reaction_force_Hand_Right_proximal = reaction_force_Hand_Right_proximal;
seg_force.reaction_force_Forearm_Right_distal = reaction_force_Forearm_Right_distal;
seg_force.reaction_force_Forearm_Right_proximal = reaction_force_Forearm_Right_proximal;
seg_force.reaction_force_Upperarm_Right_distal = reaction_force_Upperarm_Right_distal;
seg_force.reaction_force_Upperarm_Right_proximal = reaction_force_Upperarm_Right_proximal;
seg_force.reaction_force_Trunk_Upper_Right_distal = reaction_force_Trunk_Upper_Right_distal;
% 头颈
seg_force.reaction_force_HeadNeck_distal = reaction_force_HeadNeck_distal;
seg_force.reaction_force_HeadNeck_proximal = reaction_force_HeadNeck_proximal;
seg_force.reaction_force_Trunk_Upper_Middle_distal = reaction_force_Trunk_Upper_Middle_distal;