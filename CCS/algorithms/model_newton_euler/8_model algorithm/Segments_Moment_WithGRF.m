function [moment_reaction_couple_global_new,moment_reaction_couple_local_new,Segments_Length,moment_couple_global_new,moment_from_reaction_force_new] = Segments_Moment_WithGRF(weight,gender,kinectstream,...
    segments_com_position,segments_force,segments_RM,segments_W_L,segments_Alpha_L,...
    moment_grf2foot_Left,moment_grf2foot_Right,moment_grf2hip_Left,moment_grf2hip_Right)
%% 各体段测量参数
if gender == 'M'
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
elseif gender == 'F'
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
SegmentNames = {'HeadNeck','Trunk','Upperarm','Forearm','Hand','Thigh','Shank','Foot'};
SegmentLRNames = {'HeadNeck','Trunk','Upperarm_Left','Forearm_Left','Hand_Left','Thigh_Left','Shank_Left','Foot_Left',...
    'Upperarm_Right','Forearm_Right','Hand_Right','Thigh_Right','Shank_Right','Foot_Right'};
lengthStream = length(kinectstream.wtime);
%% 计算各体段长度
% 转动惯量，分为3个方向，绕着Sagittal，Transverse，Longitudinal（长轴方向），一般分别指绕着Y，X，Z，
% 脚（Foot）除外，脚的Sagittal，Transverse，Longitudinal 指， Z，X，Y
for i = 1:length(SegmentNames)
    Moment_of_Inertia.(SegmentNames{i}) = zeros(3,3);
end

Segments_Length = Get_Segments_Length_Struct(kinectstream);
if gender == 'M'
    % 绕x轴
    Moment_of_Inertia.HeadNeck(1,1) = (Segments_Length.HeadNeck)^2 * 0.376*0.376;
    Moment_of_Inertia.Trunk(1,1) = (Segments_Length.Trunk)^2 * 0.347*0.347;
    Moment_of_Inertia.Upperarm(1,1) = (Segments_Length.Upperarm)^2 * 0.269*0.269;
    Moment_of_Inertia.Forearm(1,1) = (Segments_Length.Forearm)^2 * 0.265*0.265;
    Moment_of_Inertia.Hand(1,1) = (Segments_Length.Hand)^2 * 0.513*0.513;
    Moment_of_Inertia.Thigh(1,1) = (Segments_Length.Thigh)^2 * 0.329*0.329;
    Moment_of_Inertia.Shank(1,1) = (Segments_Length.Shank)^2 * 0.249*0.249;
    Moment_of_Inertia.Foot(1,1) = (Segments_Length.Foot)^2 * 0.245*0.245;  %Transverse
    %绕y轴
    Moment_of_Inertia.HeadNeck(2,2) = (Segments_Length.HeadNeck)^2 * 0.362*0.362;
    Moment_of_Inertia.Trunk(2,2) = (Segments_Length.Trunk)^2 * 0.372*0.372;
    Moment_of_Inertia.Upperarm(2,2) = (Segments_Length.Upperarm)^2 * 0.285*0.285;
    Moment_of_Inertia.Forearm(2,2) = (Segments_Length.Forearm)^2 * 0.276*0.276;
    Moment_of_Inertia.Hand(2,2) = (Segments_Length.Hand)^2 * 0.628*0.628;
    Moment_of_Inertia.Thigh(2,2) = (Segments_Length.Thigh)^2 * 0.329*0.329;
    Moment_of_Inertia.Shank(2,2) = (Segments_Length.Shank)^2 * 0.255*0.255;
    %Moment_of_Inertia.Foot(2,2) = (Segments_Length.Foot)^2 * 0.124*0.124;  %Longitudinal
    %绕z轴
    %     Moment_of_Inertia.HeadNeck(3,3) = (Segments_Length.HeadNeck)^2 * 0.312*0.312;
         Moment_of_Inertia.Trunk(3,3) = (Segments_Length.Trunk)^2 * 0.191*0.191;
    %     Moment_of_Inertia.Upperarm(3,3) = (Segments_Length.Upperarm)^2 * 0.158*0.158;
    %     Moment_of_Inertia.Forearm(3,3) = (Segments_Length.Forearm)^2 * 0.121*0.121;
    %     Moment_of_Inertia.Hand(3,3) = (Segments_Length.Hand)^2 * 0.401*0.401;
    %     Moment_of_Inertia.Thigh(3,3) = (Segments_Length.Thigh)^2 * 0.149*0.149;
    %     Moment_of_Inertia.Shank(3,3) = (Segments_Length.Shank)^2 * 0.103*0.103;
    Moment_of_Inertia.Foot(3,3) = (Segments_Length.Foot)^2 * 0.257*0.257;  %Sagittal
else
    % 绕x轴
    Moment_of_Inertia.HeadNeck(1,1) = (Segments_Length.HeadNeck)^2 * 0.359*0.359;
    Moment_of_Inertia.Trunk(1,1) = (Segments_Length.Trunk)^2 * 0.339*0.339;
    Moment_of_Inertia.Upperarm(1,1) = (Segments_Length.Upperarm)^2 * 0.260*0.260;
    Moment_of_Inertia.Forearm(1,1) = (Segments_Length.Forearm)^2 * 0.257*0.257;
    Moment_of_Inertia.Hand(1,1) = (Segments_Length.Hand)^2 * 0.454*0.454;
    Moment_of_Inertia.Thigh(1,1) = (Segments_Length.Thigh)^2 * 0.364*0.364;
    Moment_of_Inertia.Shank(1,1) = (Segments_Length.Shank)^2 * 0.267*0.267;
    Moment_of_Inertia.Foot(1,1) = (Segments_Length.Foot)^2 * 0.279*0.279;  %Transverse
    %绕y轴
    Moment_of_Inertia.HeadNeck(2,2) = (Segments_Length.HeadNeck)^2 * 0.330*0.330;
    Moment_of_Inertia.Trunk(2,2) = (Segments_Length.Trunk)^2 * 0.357*0.357;
    Moment_of_Inertia.Upperarm(2,2) = (Segments_Length.Upperarm)^2 * 0.278*0.278;
    Moment_of_Inertia.Forearm(2,2) = (Segments_Length.Forearm)^2 * 0.261*0.261;
    Moment_of_Inertia.Hand(2,2) = (Segments_Length.Hand)^2 * 0.531*0.531;
    Moment_of_Inertia.Thigh(2,2) = (Segments_Length.Thigh)^2 * 0.369*0.369;
    Moment_of_Inertia.Shank(2,2) = (Segments_Length.Shank)^2 * 0.271*0.271;
    %Moment_of_Inertia.Foot(2,2) = (Segments_Length.Foot)^2 * 0.139*0.139;  %Longitudinal
    %绕z轴
    %     Moment_of_Inertia.HeadNeck(3,3) = (Segments_Length.HeadNeck)^2 * 0.318*0.318;
         Moment_of_Inertia.Trunk(3,3) = (Segments_Length.Trunk)^2 * 0.171*0.171;
    %     Moment_of_Inertia.Upperarm(3,3) = (Segments_Length.Upperarm)^2 * 0.148*0.148;
    %     Moment_of_Inertia.Forearm(3,3) = (Segments_Length.Forearm)^2 * 0.094*0.094;
    %     Moment_of_Inertia.Hand(3,3) = (Segments_Length.Hand)^2 * 0.335*0.335;
    %     Moment_of_Inertia.Thigh(3,3) = (Segments_Length.Thigh)^2 * 0.162*0.162;
    %     Moment_of_Inertia.Shank(3,3) = (Segments_Length.Shank)^2 * 0.093*0.093;
    Moment_of_Inertia.Foot(3,3) = (Segments_Length.Foot)^2 * 0.299*0.299;   %Sagittal
end

%% 各体段绕质心旋转所需的力偶矩，格式3*1
for i=1:lengthStream
    for j = 1:length(SegmentLRNames)
        nameLR = SegmentLRNames{j};
        if contains(nameLR,'_')
            name = nameLR(1:strfind(nameLR,'_')-1);
        else
            name = nameLR;
        end
        % 局部坐标系
        moment_couple_local.(nameLR){i} = (weight * M.(name) * Moment_of_Inertia.(name)) * ...
            [segments_Alpha_L.(nameLR){i}(3,2);segments_Alpha_L.(nameLR){i}(1,3);segments_Alpha_L.(nameLR){i}(2,1)]...
            + segments_W_L.(nameLR){i} * (weight * M.(name) * Moment_of_Inertia.(name)) * ...
            [segments_W_L.(nameLR){i}(3,2);segments_W_L.(nameLR){i}(1,3);segments_W_L.(nameLR){i}(2,1)];
        % 全局坐标系
        moment_couple_global.(nameLR){i} = segments_RM.(nameLR){i} * moment_couple_local.(nameLR){i};
    end
end


%% 全局各体段两端力偶矩 求解
for i=1:lengthStream
    %% 左下肢
    % 足部
    % 两端的力对足质心的力矩
    moment_from_reaction_force.Foot_Left{i} = cross(([kinectstream.ANKLE_LEFT.x(i),kinectstream.ANKLE_LEFT.y(i),kinectstream.ANKLE_LEFT.z(i)] -...
            [segments_com_position.Foot_Left.x(i),segments_com_position.Foot_Left.y(i),segments_com_position.Foot_Left.z(i)]),...
            [segments_force.reaction_force_Foot_Left_proximal.x(i),segments_force.reaction_force_Foot_Left_proximal.y(i),segments_force.reaction_force_Foot_Left_proximal.z(i)])';
    % 足远端力偶矩，地面对足作用力偶矩
    moment_reaction_couple_global.Foot_Left_distal{i} = [moment_grf2foot_Left.x(i);moment_grf2foot_Left.y(i);moment_grf2foot_Left.z(i)];
    % 足近端力偶矩
    moment_reaction_couple_global.Foot_Left_proximal{i} = moment_couple_global.Foot_Left{i} - moment_reaction_couple_global.Foot_Left_distal{i} - moment_from_reaction_force.Foot_Left{i};
    
    
    % 小腿
    % 两端的力对小腿质心的力矩
    moment_from_reaction_force.Shank_Left{i} = cross(([kinectstream.ANKLE_LEFT.x(i),kinectstream.ANKLE_LEFT.y(i),kinectstream.ANKLE_LEFT.z(i)] -...
        [segments_com_position.Shank_Left.x(i),segments_com_position.Shank_Left.y(i),segments_com_position.Shank_Left.z(i)]),...
        [segments_force.reaction_force_Shank_Left_distal.x(i),segments_force.reaction_force_Shank_Left_distal.y(i),segments_force.reaction_force_Shank_Left_distal.z(i)])'...
        + cross(([kinectstream.KNEE_LEFT.x(i),kinectstream.KNEE_LEFT.y(i),kinectstream.KNEE_LEFT.z(i)] -...
        [segments_com_position.Shank_Left.x(i),segments_com_position.Shank_Left.y(i),segments_com_position.Shank_Left.z(i)]),...
        [segments_force.reaction_force_Shank_Left_proximal.x(i),segments_force.reaction_force_Shank_Left_proximal.y(i),segments_force.reaction_force_Shank_Left_proximal.z(i)])';
    % 小腿远端力偶矩
    moment_reaction_couple_global.Shank_Left_distal{i} = -moment_reaction_couple_global.Foot_Left_proximal{i};
    % 小腿近端力偶矩
    moment_reaction_couple_global.Shank_Left_proximal{i} = moment_couple_global.Shank_Left{i} - moment_reaction_couple_global.Shank_Left_distal{i} - moment_from_reaction_force.Shank_Left{i};
    
    % 大腿
    % 两端的力对大腿质心的力矩
    moment_from_reaction_force.Thigh_Left{i} = cross(([kinectstream.KNEE_LEFT.x(i),kinectstream.KNEE_LEFT.y(i),kinectstream.KNEE_LEFT.z(i)] -...
        [segments_com_position.Thigh_Left.x(i),segments_com_position.Thigh_Left.y(i),segments_com_position.Thigh_Left.z(i)]),...
        [segments_force.reaction_force_Thigh_Left_distal.x(i),segments_force.reaction_force_Thigh_Left_distal.y(i),segments_force.reaction_force_Thigh_Left_distal.z(i)])'...
        + cross(([kinectstream.HIP_LEFT.x(i),kinectstream.HIP_LEFT.y(i),kinectstream.HIP_LEFT.z(i)] -...
        [segments_com_position.Thigh_Left.x(i),segments_com_position.Thigh_Left.y(i),segments_com_position.Thigh_Left.z(i)]),...
        [segments_force.reaction_force_Thigh_Left_proximal.x(i),segments_force.reaction_force_Thigh_Left_proximal.y(i),segments_force.reaction_force_Thigh_Left_proximal.z(i)])'...
        +[moment_grf2hip_Left.x(i);moment_grf2hip_Left.y(i);moment_grf2hip_Left.z(i)];
    % 大腿远端力偶矩
    moment_reaction_couple_global.Thigh_Left_distal{i} = -moment_reaction_couple_global.Shank_Left_proximal{i};
    % 大腿近端力偶矩
    moment_reaction_couple_global.Thigh_Left_proximal{i} = moment_couple_global.Thigh_Left{i} - moment_reaction_couple_global.Thigh_Left_distal{i} - moment_from_reaction_force.Thigh_Left{i};
    
    %% 右下肢
    % 足部
    % 两端的力对足质心的力矩
    moment_from_reaction_force.Foot_Right{i} = cross(([kinectstream.ANKLE_RIGHT.x(i),kinectstream.ANKLE_RIGHT.y(i),kinectstream.ANKLE_RIGHT.z(i)] -...
            [segments_com_position.Foot_Right.x(i),segments_com_position.Foot_Right.y(i),segments_com_position.Foot_Right.z(i)]),...
            [segments_force.reaction_force_Foot_Right_proximal.x(i),segments_force.reaction_force_Foot_Right_proximal.y(i),segments_force.reaction_force_Foot_Right_proximal.z(i)])';
    % 足远端力偶矩，地面对足作用力偶矩
    moment_reaction_couple_global.Foot_Right_distal{i} = [moment_grf2foot_Right.x(i);moment_grf2foot_Right.y(i);moment_grf2foot_Right.z(i)];
    % 足近端力偶矩
    moment_reaction_couple_global.Foot_Right_proximal{i} = moment_couple_global.Foot_Right{i} - moment_reaction_couple_global.Foot_Right_distal{i} - moment_from_reaction_force.Foot_Right{i};
    
    
    % 小腿
    % 两端的力对小腿质心的力矩
    moment_from_reaction_force.Shank_Right{i} = cross(([kinectstream.ANKLE_RIGHT.x(i),kinectstream.ANKLE_RIGHT.y(i),kinectstream.ANKLE_RIGHT.z(i)] -...
        [segments_com_position.Shank_Right.x(i),segments_com_position.Shank_Right.y(i),segments_com_position.Shank_Right.z(i)]),...
        [segments_force.reaction_force_Shank_Right_distal.x(i),segments_force.reaction_force_Shank_Right_distal.y(i),segments_force.reaction_force_Shank_Right_distal.z(i)])'...
        + cross(([kinectstream.KNEE_RIGHT.x(i),kinectstream.KNEE_RIGHT.y(i),kinectstream.KNEE_RIGHT.z(i)] -...
        [segments_com_position.Shank_Right.x(i),segments_com_position.Shank_Right.y(i),segments_com_position.Shank_Right.z(i)]),...
        [segments_force.reaction_force_Shank_Right_proximal.x(i),segments_force.reaction_force_Shank_Right_proximal.y(i),segments_force.reaction_force_Shank_Right_proximal.z(i)])';
    % 小腿远端力偶矩
    moment_reaction_couple_global.Shank_Right_distal{i} = -moment_reaction_couple_global.Foot_Right_proximal{i};
    % 小腿近端力偶矩
    moment_reaction_couple_global.Shank_Right_proximal{i} = moment_couple_global.Shank_Right{i} - moment_reaction_couple_global.Shank_Right_distal{i} - moment_from_reaction_force.Shank_Right{i};
    
    % 大腿
    % 两端的力对大腿质心的力矩
    moment_from_reaction_force.Thigh_Right{i} = cross(([kinectstream.KNEE_RIGHT.x(i),kinectstream.KNEE_RIGHT.y(i),kinectstream.KNEE_RIGHT.z(i)] -...
        [segments_com_position.Thigh_Right.x(i),segments_com_position.Thigh_Right.y(i),segments_com_position.Thigh_Right.z(i)]),...
        [segments_force.reaction_force_Thigh_Right_distal.x(i),segments_force.reaction_force_Thigh_Right_distal.y(i),segments_force.reaction_force_Thigh_Right_distal.z(i)])'...
        + cross(([kinectstream.HIP_RIGHT.x(i),kinectstream.HIP_RIGHT.y(i),kinectstream.HIP_RIGHT.z(i)] -...
        [segments_com_position.Thigh_Right.x(i),segments_com_position.Thigh_Right.y(i),segments_com_position.Thigh_Right.z(i)]),...
        [segments_force.reaction_force_Thigh_Right_proximal.x(i),segments_force.reaction_force_Thigh_Right_proximal.y(i),segments_force.reaction_force_Thigh_Right_proximal.z(i)])'...
        +[moment_grf2hip_Right.x(i);moment_grf2hip_Right.y(i);moment_grf2hip_Right.z(i)];
    % 大腿远端力偶矩
    moment_reaction_couple_global.Thigh_Right_distal{i} = -moment_reaction_couple_global.Shank_Right_proximal{i};
    % 大腿近端力偶矩
    moment_reaction_couple_global.Thigh_Right_proximal{i} = moment_couple_global.Thigh_Right{i} - moment_reaction_couple_global.Thigh_Right_distal{i} - moment_from_reaction_force.Thigh_Right{i};
    
    %% 左上肢
    % 手掌
    % 两端的力对手掌的力矩
    moment_from_reaction_force.Hand_Left{i} = cross(([kinectstream.HAND_LEFT.x(i),kinectstream.HAND_LEFT.y(i),kinectstream.HAND_LEFT.z(i)] -...
        [segments_com_position.Hand_Left.x(i),segments_com_position.Hand_Left.y(i),segments_com_position.Hand_Left.z(i)]),...
        [segments_force.reaction_force_Hand_Left_distal.x(i),segments_force.reaction_force_Hand_Left_distal.y(i),segments_force.reaction_force_Hand_Left_distal.z(i)])'...
        + cross(([kinectstream.WRIST_LEFT.x(i),kinectstream.WRIST_LEFT.y(i),kinectstream.WRIST_LEFT.z(i)] -...
        [segments_com_position.Hand_Left.x(i),segments_com_position.Hand_Left.y(i),segments_com_position.Hand_Left.z(i)]),...
        [segments_force.reaction_force_Hand_Left_proximal.x(i),segments_force.reaction_force_Hand_Left_proximal.y(i),segments_force.reaction_force_Hand_Left_proximal.z(i)])';
    % 手掌远端力偶矩
    moment_reaction_couple_global.Hand_Left_distal{i} = [0;0;0];
    % 手掌近端力偶矩
    moment_reaction_couple_global.Hand_Left_proximal{i} = moment_couple_global.Hand_Left{i} - moment_reaction_couple_global.Hand_Left_distal{i} - moment_from_reaction_force.Hand_Left{i};
    
    % 前臂
    % 两端的力对前臂质心的力矩
    moment_from_reaction_force.Forearm_Left{i} = cross(([kinectstream.WRIST_LEFT.x(i),kinectstream.WRIST_LEFT.y(i),kinectstream.WRIST_LEFT.z(i)] -...
        [segments_com_position.Forearm_Left.x(i),segments_com_position.Forearm_Left.y(i),segments_com_position.Forearm_Left.z(i)]),...
        [segments_force.reaction_force_Forearm_Left_distal.x(i),segments_force.reaction_force_Forearm_Left_distal.y(i),segments_force.reaction_force_Forearm_Left_distal.z(i)])'...
        + cross(([kinectstream.ELBOW_LEFT.x(i),kinectstream.ELBOW_LEFT.y(i),kinectstream.ELBOW_LEFT.z(i)] -...
        [segments_com_position.Forearm_Left.x(i),segments_com_position.Forearm_Left.y(i),segments_com_position.Forearm_Left.z(i)]),...
        [segments_force.reaction_force_Forearm_Left_proximal.x(i),segments_force.reaction_force_Forearm_Left_proximal.y(i),segments_force.reaction_force_Forearm_Left_proximal.z(i)])';
    % 前臂远端力偶矩
    moment_reaction_couple_global.Forearm_Left_distal{i} = -moment_reaction_couple_global.Hand_Left_proximal{i};
    % 前臂近端力偶矩
    moment_reaction_couple_global.Forearm_Left_proximal{i} = moment_couple_global.Forearm_Left{i} - moment_reaction_couple_global.Forearm_Left_distal{i} - moment_from_reaction_force.Forearm_Left{i};
    
    % 上臂
    % 两端的力对上臂质心的力矩
    moment_from_reaction_force.Upperarm_Left{i} = cross(([kinectstream.ELBOW_LEFT.x(i),kinectstream.ELBOW_LEFT.y(i),kinectstream.ELBOW_LEFT.z(i)] -...
        [segments_com_position.Upperarm_Left.x(i),segments_com_position.Upperarm_Left.y(i),segments_com_position.Upperarm_Left.z(i)]),...
        [segments_force.reaction_force_Upperarm_Left_distal.x(i),segments_force.reaction_force_Upperarm_Left_distal.y(i),segments_force.reaction_force_Upperarm_Left_distal.z(i)])'...
        + cross(([kinectstream.SHOULDER_LEFT.x(i),kinectstream.SHOULDER_LEFT.y(i),kinectstream.SHOULDER_LEFT.z(i)] -...
        [segments_com_position.Upperarm_Left.x(i),segments_com_position.Upperarm_Left.y(i),segments_com_position.Upperarm_Left.z(i)]),...
        [segments_force.reaction_force_Upperarm_Left_proximal.x(i),segments_force.reaction_force_Upperarm_Left_proximal.y(i),segments_force.reaction_force_Upperarm_Left_proximal.z(i)])';
    % 上臂远端力偶矩
    moment_reaction_couple_global.Upperarm_Left_distal{i} = -moment_reaction_couple_global.Forearm_Left_proximal{i};
    % 上臂近端力偶矩
    moment_reaction_couple_global.Upperarm_Left_proximal{i} = moment_couple_global.Upperarm_Left{i} - moment_reaction_couple_global.Upperarm_Left_distal{i} - moment_from_reaction_force.Upperarm_Left{i};
    
    %% 右上肢
    % 手掌
    % 两端的力对手掌的力矩
    moment_from_reaction_force.Hand_Right{i} = cross(([kinectstream.HAND_RIGHT.x(i),kinectstream.HAND_RIGHT.y(i),kinectstream.HAND_RIGHT.z(i)] -...
        [segments_com_position.Hand_Right.x(i),segments_com_position.Hand_Right.y(i),segments_com_position.Hand_Right.z(i)]),...
        [segments_force.reaction_force_Hand_Right_distal.x(i),segments_force.reaction_force_Hand_Right_distal.y(i),segments_force.reaction_force_Hand_Right_distal.z(i)])'...
        + cross(([kinectstream.WRIST_RIGHT.x(i),kinectstream.WRIST_RIGHT.y(i),kinectstream.WRIST_RIGHT.z(i)] -...
        [segments_com_position.Hand_Right.x(i),segments_com_position.Hand_Right.y(i),segments_com_position.Hand_Right.z(i)]),...
        [segments_force.reaction_force_Hand_Right_proximal.x(i),segments_force.reaction_force_Hand_Right_proximal.y(i),segments_force.reaction_force_Hand_Right_proximal.z(i)])';
    % 手掌远端力偶矩
    moment_reaction_couple_global.Hand_Right_distal{i} = [0;0;0];
    % 手掌近端力偶矩
    moment_reaction_couple_global.Hand_Right_proximal{i} = moment_couple_global.Hand_Right{i} - moment_reaction_couple_global.Hand_Right_distal{i} - moment_from_reaction_force.Hand_Right{i};
    
    % 前臂
    % 两端的力对前臂质心的力矩
    moment_from_reaction_force.Forearm_Right{i} = cross(([kinectstream.WRIST_RIGHT.x(i),kinectstream.WRIST_RIGHT.y(i),kinectstream.WRIST_RIGHT.z(i)] -...
        [segments_com_position.Forearm_Right.x(i),segments_com_position.Forearm_Right.y(i),segments_com_position.Forearm_Right.z(i)]),...
        [segments_force.reaction_force_Forearm_Right_distal.x(i),segments_force.reaction_force_Forearm_Right_distal.y(i),segments_force.reaction_force_Forearm_Right_distal.z(i)])'...
        + cross(([kinectstream.ELBOW_RIGHT.x(i),kinectstream.ELBOW_RIGHT.y(i),kinectstream.ELBOW_RIGHT.z(i)] -...
        [segments_com_position.Forearm_Right.x(i),segments_com_position.Forearm_Right.y(i),segments_com_position.Forearm_Right.z(i)]),...
        [segments_force.reaction_force_Forearm_Right_proximal.x(i),segments_force.reaction_force_Forearm_Right_proximal.y(i),segments_force.reaction_force_Forearm_Right_proximal.z(i)])';
    % 前臂远端力偶矩
    moment_reaction_couple_global.Forearm_Right_distal{i} = -moment_reaction_couple_global.Hand_Right_proximal{i};
    % 前臂近端力偶矩
    moment_reaction_couple_global.Forearm_Right_proximal{i} = moment_couple_global.Forearm_Right{i} - moment_reaction_couple_global.Forearm_Right_distal{i} - moment_from_reaction_force.Forearm_Right{i};
    
    % 上臂
    % 两端的力对上臂质心的力矩
    moment_from_reaction_force.Upperarm_Right{i} = cross(([kinectstream.ELBOW_RIGHT.x(i),kinectstream.ELBOW_RIGHT.y(i),kinectstream.ELBOW_RIGHT.z(i)] -...
        [segments_com_position.Upperarm_Right.x(i),segments_com_position.Upperarm_Right.y(i),segments_com_position.Upperarm_Right.z(i)]),...
        [segments_force.reaction_force_Upperarm_Right_distal.x(i),segments_force.reaction_force_Upperarm_Right_distal.y(i),segments_force.reaction_force_Upperarm_Right_distal.z(i)])'...
        + cross(([kinectstream.SHOULDER_RIGHT.x(i),kinectstream.SHOULDER_RIGHT.y(i),kinectstream.SHOULDER_RIGHT.z(i)] -...
        [segments_com_position.Upperarm_Right.x(i),segments_com_position.Upperarm_Right.y(i),segments_com_position.Upperarm_Right.z(i)]),...
        [segments_force.reaction_force_Upperarm_Right_proximal.x(i),segments_force.reaction_force_Upperarm_Right_proximal.y(i),segments_force.reaction_force_Upperarm_Right_proximal.z(i)])';
    % 上臂远端力偶矩
    moment_reaction_couple_global.Upperarm_Right_distal{i} = -moment_reaction_couple_global.Forearm_Right_proximal{i};
    % 上臂近端力偶矩
    moment_reaction_couple_global.Upperarm_Right_proximal{i} = moment_couple_global.Upperarm_Right{i} - moment_reaction_couple_global.Upperarm_Right_distal{i} - moment_from_reaction_force.Upperarm_Right{i};
    
    %% 头颈
    % 头颈
    % 两端的力对头颈的力矩
    moment_from_reaction_force.HeadNeck{i} = cross(([kinectstream.HEAD.x(i),kinectstream.HEAD.y(i),kinectstream.HEAD.z(i)] -...
        [segments_com_position.HeadNeck.x(i),segments_com_position.HeadNeck.y(i),segments_com_position.HeadNeck.z(i)]),...
        [segments_force.reaction_force_HeadNeck_distal.x(i),segments_force.reaction_force_HeadNeck_distal.y(i),segments_force.reaction_force_HeadNeck_distal.z(i)])'...
        + cross(([kinectstream.NECK.x(i),kinectstream.NECK.y(i),kinectstream.NECK.z(i)] -...
        [segments_com_position.HeadNeck.x(i),segments_com_position.HeadNeck.y(i),segments_com_position.HeadNeck.z(i)]),...
        [segments_force.reaction_force_HeadNeck_proximal.x(i),segments_force.reaction_force_HeadNeck_proximal.y(i),segments_force.reaction_force_HeadNeck_proximal.z(i)])';
    % 头颈远端力偶矩
    moment_reaction_couple_global.HeadNeck_distal{i} = [0;0;0];
    % 头颈近端力偶矩
    moment_reaction_couple_global.HeadNeck_proximal{i} = moment_couple_global.HeadNeck{i} - moment_reaction_couple_global.HeadNeck_distal{i} - moment_from_reaction_force.HeadNeck{i};
    
    %% 躯干
    % 各段力偶矩
    moment_reaction_couple_global.Trunk_Lower_Left_proximal{i} = - moment_reaction_couple_global.Thigh_Left_proximal{i};
    moment_reaction_couple_global.Trunk_Lower_Right_proximal{i} = - moment_reaction_couple_global.Thigh_Right_proximal{i};
    moment_reaction_couple_global.Trunk_Upper_Left_diatal{i} = - moment_reaction_couple_global.Upperarm_Left_proximal{i};
    moment_reaction_couple_global.Trunk_Upper_Right_diatal{i} = - moment_reaction_couple_global.Upperarm_Right_proximal{i};
    moment_reaction_couple_global.Trunk_Upper_Middle_distal{i} = - moment_reaction_couple_global.HeadNeck_proximal{i};
    % 各端对躯干的力矩
    moment_from_reaction_force.Trunk{i} = cross(([kinectstream.HIP_LEFT.x(i),kinectstream.HIP_LEFT.y(i),kinectstream.HIP_LEFT.z(i)] -...
        [segments_com_position.Trunk.x(i),segments_com_position.Trunk.y(i),segments_com_position.Trunk.z(i)]),...
        [segments_force.reaction_force_Trunk_Lower_Left_proximal.x(i),segments_force.reaction_force_Trunk_Lower_Left_proximal.y(i),segments_force.reaction_force_Trunk_Lower_Left_proximal.z(i)])'...
        + cross(([kinectstream.HIP_RIGHT.x(i),kinectstream.HIP_RIGHT.y(i),kinectstream.HIP_RIGHT.z(i)] -...
        [segments_com_position.Trunk.x(i),segments_com_position.Trunk.y(i),segments_com_position.Trunk.z(i)]),...
        [segments_force.reaction_force_Trunk_Lower_Right_proximal.x(i),segments_force.reaction_force_Trunk_Lower_Right_proximal.y(i),segments_force.reaction_force_Trunk_Lower_Right_proximal.z(i)])'...
        + cross(([kinectstream.SHOULDER_LEFT.x(i),kinectstream.SHOULDER_LEFT.y(i),kinectstream.SHOULDER_LEFT.z(i)] -...
        [segments_com_position.Trunk.x(i),segments_com_position.Trunk.y(i),segments_com_position.Trunk.z(i)]),...
        [segments_force.reaction_force_Trunk_Upper_Left_distal.x(i),segments_force.reaction_force_Trunk_Upper_Left_distal.y(i),segments_force.reaction_force_Trunk_Upper_Left_distal.z(i)])'...
        + cross(([kinectstream.SHOULDER_RIGHT.x(i),kinectstream.SHOULDER_RIGHT.y(i),kinectstream.SHOULDER_RIGHT.z(i)] -...
        [segments_com_position.Trunk.x(i),segments_com_position.Trunk.y(i),segments_com_position.Trunk.z(i)]),...
        [segments_force.reaction_force_Trunk_Upper_Right_distal.x(i),segments_force.reaction_force_Trunk_Upper_Right_distal.y(i),segments_force.reaction_force_Trunk_Upper_Right_distal.z(i)])'...
        + cross(([kinectstream.NECK.x(i),kinectstream.NECK.y(i),kinectstream.NECK.z(i)] -...
        [segments_com_position.Trunk.x(i),segments_com_position.Trunk.y(i),segments_com_position.Trunk.z(i)]),...
        [segments_force.reaction_force_Trunk_Upper_Middle_distal.x(i),segments_force.reaction_force_Trunk_Upper_Middle_distal.y(i),segments_force.reaction_force_Trunk_Upper_Middle_distal.z(i)])';
    %% 验证
    moment_zero{i} = moment_reaction_couple_global.Trunk_Lower_Left_proximal{i} +...
        moment_reaction_couple_global.Trunk_Lower_Right_proximal{i} +...
        moment_reaction_couple_global.Trunk_Upper_Left_diatal{i} +...
        moment_reaction_couple_global.Trunk_Upper_Right_diatal{i} +...
        moment_reaction_couple_global.Trunk_Upper_Middle_distal{i} +...
        moment_from_reaction_force.Trunk{i} - moment_couple_global.Trunk{i};
    
    
end
%% 局部各体段两端力偶矩 求解
for i=1:lengthStream
    
    %% 左下肢
    % 足
    % 足远端力偶矩，地面对足作用力偶矩
    moment_reaction_couple_local.Foot_Left_distal{i} = (segments_RM.Foot_Left{i})' * moment_reaction_couple_global.Foot_Left_distal{i};
    % 足近端力偶矩
    moment_reaction_couple_local.Foot_Left_proximal{i} = (segments_RM.Foot_Left{i})' * moment_reaction_couple_global.Foot_Left_proximal{i};
    
    
    % 小腿
    % 小腿远端力偶矩
    moment_reaction_couple_local.Shank_Left_distal{i} = (segments_RM.Shank_Left{i})' * moment_reaction_couple_global.Shank_Left_distal{i};
    % 小腿近端力偶矩
    moment_reaction_couple_local.Shank_Left_proximal{i} = (segments_RM.Shank_Left{i})' * moment_reaction_couple_global.Shank_Left_proximal{i};
    
    % 大腿
    % 大腿远端力偶矩
    moment_reaction_couple_local.Thigh_Left_distal{i} = (segments_RM.Thigh_Left{i})' * moment_reaction_couple_global.Thigh_Left_distal{i};
    % 大腿近端力偶矩
    moment_reaction_couple_local.Thigh_Left_proximal{i} = (segments_RM.Thigh_Left{i})' * moment_reaction_couple_global.Thigh_Left_proximal{i};
    
    %% 右下肢
    % 足
    % 足远端力偶矩，地面对足作用力偶矩
    moment_reaction_couple_local.Foot_Right_distal{i} = (segments_RM.Foot_Right{i})' * moment_reaction_couple_global.Foot_Right_distal{i};
    % 足近端力偶矩
    moment_reaction_couple_local.Foot_Right_proximal{i} = (segments_RM.Foot_Right{i})' * moment_reaction_couple_global.Foot_Right_proximal{i};
    
    
    % 小腿
    % 小腿远端力偶矩
    moment_reaction_couple_local.Shank_Right_distal{i} = (segments_RM.Shank_Right{i})' * moment_reaction_couple_global.Shank_Right_distal{i};
    % 小腿近端力偶矩
    moment_reaction_couple_local.Shank_Right_proximal{i} = (segments_RM.Shank_Right{i})' * moment_reaction_couple_global.Shank_Right_proximal{i};
    
    % 大腿
    % 大腿远端力偶矩
    moment_reaction_couple_local.Thigh_Right_distal{i} = (segments_RM.Thigh_Right{i})' * moment_reaction_couple_global.Thigh_Right_distal{i};
    % 大腿近端力偶矩
    moment_reaction_couple_local.Thigh_Right_proximal{i} = (segments_RM.Thigh_Right{i})' * moment_reaction_couple_global.Thigh_Right_proximal{i};
    
    %% 左上肢
    % 手掌
    
    % 手掌远端力偶矩
    moment_reaction_couple_local.Hand_Left_distal{i} = [0;0;0];
    % 手掌近端力偶矩
    moment_reaction_couple_local.Hand_Left_proximal{i} = (segments_RM.Hand_Left{i})' * moment_reaction_couple_global.Hand_Left_proximal{i};
    
    % 前臂
    % 前臂远端力偶矩
    moment_reaction_couple_local.Forearm_Left_distal{i} = (segments_RM.Forearm_Left{i})' * moment_reaction_couple_global.Forearm_Left_distal{i};
    % 前臂近端力偶矩
    moment_reaction_couple_local.Forearm_Left_proximal{i} = (segments_RM.Forearm_Left{i})' * moment_reaction_couple_global.Forearm_Left_proximal{i};
    
    % 上臂 
    % 上臂远端力偶矩
    moment_reaction_couple_local.Upperarm_Left_distal{i} = (segments_RM.Upperarm_Left{i})' * moment_reaction_couple_global.Upperarm_Left_distal{i};
    % 上臂近端力偶矩
    moment_reaction_couple_local.Upperarm_Left_proximal{i} = (segments_RM.Upperarm_Left{i})' * moment_reaction_couple_global.Upperarm_Left_proximal{i};
    
    %% 右上肢
    % 手掌  
    % 手掌远端力偶矩
    moment_reaction_couple_local.Hand_Right_distal{i} = [0;0;0];
    % 手掌近端力偶矩
    moment_reaction_couple_local.Hand_Right_proximal{i} = (segments_RM.Hand_Right{i})' * moment_reaction_couple_global.Hand_Right_proximal{i};
    
    % 前臂
    % 前臂远端力偶矩
    moment_reaction_couple_local.Forearm_Right_distal{i} = (segments_RM.Forearm_Right{i})' * moment_reaction_couple_global.Forearm_Right_distal{i};
    % 前臂近端力偶矩
    moment_reaction_couple_local.Forearm_Right_proximal{i} = (segments_RM.Forearm_Right{i})' * moment_reaction_couple_global.Forearm_Right_proximal{i};
    
    % 上臂
    % 上臂远端力偶矩
    moment_reaction_couple_local.Upperarm_Right_distal{i} = (segments_RM.Upperarm_Right{i})' * moment_reaction_couple_global.Upperarm_Right_distal{i};
    % 上臂近端力偶矩
    moment_reaction_couple_local.Upperarm_Right_proximal{i} = (segments_RM.Upperarm_Right{i})' * moment_reaction_couple_global.Upperarm_Right_proximal{i};
    
    %% 头颈
    % 头颈
    % 头颈远端力偶矩
    moment_reaction_couple_local.HeadNeck_distal{i} = [0;0;0];
    % 头颈近端力偶矩
    moment_reaction_couple_local.HeadNeck_proximal{i} = (segments_RM.HeadNeck{i})' * moment_reaction_couple_global.HeadNeck_proximal{i};
    
    %% 躯干
    % 各段力偶矩
    moment_reaction_couple_local.Trunk_Lower_Left_proximal{i} = (segments_RM.Trunk{i})' * moment_reaction_couple_global.Trunk_Lower_Left_proximal{i};
    moment_reaction_couple_local.Trunk_Lower_Right_proximal{i} = (segments_RM.Trunk{i})' * moment_reaction_couple_global.Trunk_Lower_Right_proximal{i};
    moment_reaction_couple_local.Trunk_Upper_Left_diatal{i} = (segments_RM.Trunk{i})' * moment_reaction_couple_global.Trunk_Upper_Left_diatal{i};
    moment_reaction_couple_local.Trunk_Upper_Right_diatal{i} = (segments_RM.Trunk{i})' * moment_reaction_couple_global.Trunk_Upper_Right_diatal{i};
    moment_reaction_couple_local.Trunk_Upper_Middle_distal{i} = (segments_RM.Trunk{i})' * moment_reaction_couple_global.Trunk_Upper_Middle_distal{i};   
end

names = fieldnames(moment_reaction_couple_local);
for i = 1:length(names)
    name = names{i};
    for j = 1:lengthStream
        moment_reaction_couple_local_new.(name).x(j,1) = moment_reaction_couple_local.(name){1,j}(1);
        moment_reaction_couple_local_new.(name).y(j,1) = moment_reaction_couple_local.(name){1,j}(2);
        moment_reaction_couple_local_new.(name).z(j,1) = moment_reaction_couple_local.(name){1,j}(3);
        moment_reaction_couple_global_new.(name).x(j,1) = moment_reaction_couple_global.(name){1,j}(1);
        moment_reaction_couple_global_new.(name).y(j,1) = moment_reaction_couple_global.(name){1,j}(2);
        moment_reaction_couple_global_new.(name).z(j,1) = moment_reaction_couple_global.(name){1,j}(3);
    end
end

names = fieldnames(moment_couple_global);
for i = 1:length(names)
    name = names{i};
    for j = 1:lengthStream
        moment_couple_global_new.(name).x(j,1) = moment_couple_global.(name){1,j}(1);
        moment_couple_global_new.(name).y(j,1) = moment_couple_global.(name){1,j}(2);
        moment_couple_global_new.(name).z(j,1) = moment_couple_global.(name){1,j}(3);
        moment_from_reaction_force_new.(name).x(j,1) = moment_from_reaction_force.(name){1,j}(1);
        moment_from_reaction_force_new.(name).y(j,1) = moment_from_reaction_force.(name){1,j}(2);
        moment_from_reaction_force_new.(name).z(j,1) = moment_from_reaction_force.(name){1,j}(3);
    end
end