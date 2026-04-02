function [ground_couple_moment_global_Left,ground_couple_moment_global_Right,moment_couple_global_new,...
    moment_com_global_new,moment_gravity_global_human_new] = Ground_Moment(mass,sex,kinectstream,...
    segments_com_position,segments_com_acceleration,hip_force_Left,hip_force_Right,...
    ground_force_Left,ground_force_Right,r_all_segments,segments_W_L,segments_Alpha_L,ratioLR)
if nargin<13
    ratioLR = 0.5; % 0.5表示左右平分，1表示左右分开
end
%% 各体段测量参数
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
%% 转动惯量与数据来源有关，分为3个方向，绕着Sagittal，Transverse，Longitudinal（长轴方向），一般分别指绕着Y，X，Z，
%% 脚（Foot）除外，脚的Sagittal，Transverse，Longitudinal 指， Z， X，Y

Moment_of_Inertia.HeadNeck = zeros(3,3);
Moment_of_Inertia.Trunk = zeros(3,3);
Moment_of_Inertia.Upperarm = zeros(3,3);
Moment_of_Inertia.Forearm = zeros(3,3);
Moment_of_Inertia.Hand = zeros(3,3);
Moment_of_Inertia.Thigh = zeros(3,3);
Moment_of_Inertia.Shank = zeros(3,3);
Moment_of_Inertia.Foot = zeros(3,3);
%% 计算各体段长度
Segments_Length = Get_Segments_Length_Struct(kinectstream);

if sex == 'M'
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

%% 各体段旋转所需的力偶矩，格式3*1
% 欧拉：N = Iw' + w × Iw
len_Alfa = length(segments_Alpha_L.HeadNeck);
for i=1:len_Alfa
    moment_couple_global.HeadNeck{i} = (r_all_segments.HeadNeck{i}) * ((mass * M.HeadNeck * Moment_of_Inertia.HeadNeck) * ...
        [segments_Alpha_L.HeadNeck{i}(3,2);segments_Alpha_L.HeadNeck{i}(1,3);segments_Alpha_L.HeadNeck{i}(2,1)]...
        + segments_W_L.HeadNeck{i} * (mass * M.HeadNeck * Moment_of_Inertia.HeadNeck) * ...
        [segments_W_L.HeadNeck{i}(3,2);segments_W_L.HeadNeck{i}(1,3);segments_W_L.HeadNeck{i}(2,1)]);
    
    moment_couple_global.Trunk{i} = (r_all_segments.Trunk{i}) * ((mass * M.Trunk * Moment_of_Inertia.Trunk) * ...
        [segments_Alpha_L.Trunk{i}(3,2);segments_Alpha_L.Trunk{i}(1,3);segments_Alpha_L.Trunk{i}(2,1)]...
        + segments_W_L.Trunk{i} * (mass * M.Trunk * Moment_of_Inertia.Trunk) * ...
        [segments_W_L.Trunk{i}(3,2);segments_W_L.Trunk{i}(1,3);segments_W_L.Trunk{i}(2,1)]);
    
    moment_couple_global.Upperarm_Left{i} = (r_all_segments.Upperarm_Left{i}) * ((mass * M.Upperarm * Moment_of_Inertia.Upperarm) * ...
        [segments_Alpha_L.Upperarm_Left{i}(3,2);segments_Alpha_L.Upperarm_Left{i}(1,3);segments_Alpha_L.Upperarm_Left{i}(2,1)]...
        + segments_W_L.Upperarm_Left{i} * (mass * M.Upperarm * Moment_of_Inertia.Upperarm) * ...
        [segments_W_L.Upperarm_Left{i}(3,2);segments_W_L.Upperarm_Left{i}(1,3);segments_W_L.Upperarm_Left{i}(2,1)]);
    
    moment_couple_global.Upperarm_Right{i} = (r_all_segments.Upperarm_Right{i}) * ((mass * M.Upperarm * Moment_of_Inertia.Upperarm) * ...
        [segments_Alpha_L.Upperarm_Right{i}(3,2);segments_Alpha_L.Upperarm_Right{i}(1,3);segments_Alpha_L.Upperarm_Right{i}(2,1)]...
        + segments_W_L.Upperarm_Right{i} * (mass * M.Upperarm * Moment_of_Inertia.Upperarm) * ...
        [segments_W_L.Upperarm_Right{i}(3,2);segments_W_L.Upperarm_Right{i}(1,3);segments_W_L.Upperarm_Right{i}(2,1)]);
    
    moment_couple_global.Forearm_Left{i} = (r_all_segments.Forearm_Left{i}) * ((mass * M.Forearm * Moment_of_Inertia.Forearm) * ...
        [segments_Alpha_L.Forearm_Left{i}(3,2);segments_Alpha_L.Forearm_Left{i}(1,3);segments_Alpha_L.Forearm_Left{i}(2,1)]...
        + segments_W_L.Forearm_Left{i} * (mass * M.Forearm * Moment_of_Inertia.Forearm) * ...
        [segments_W_L.Forearm_Left{i}(3,2);segments_W_L.Forearm_Left{i}(1,3);segments_W_L.Forearm_Left{i}(2,1)]);
    
    moment_couple_global.Forearm_Right{i} = (r_all_segments.Forearm_Right{i}) * ((mass * M.Forearm * Moment_of_Inertia.Forearm) * ...
        [segments_Alpha_L.Forearm_Right{i}(3,2);segments_Alpha_L.Forearm_Right{i}(1,3);segments_Alpha_L.Forearm_Right{i}(2,1)]...
        + segments_W_L.Forearm_Right{i} * (mass * M.Forearm * Moment_of_Inertia.Forearm) * ...
        [segments_W_L.Forearm_Right{i}(3,2);segments_W_L.Forearm_Right{i}(1,3);segments_W_L.Forearm_Right{i}(2,1)]);
    
    moment_couple_global.Hand_Left{i} = (r_all_segments.Hand_Left{i}) * ((mass * M.Hand * Moment_of_Inertia.Hand) * ...
        [segments_Alpha_L.Hand_Left{i}(3,2);segments_Alpha_L.Hand_Left{i}(1,3);segments_Alpha_L.Hand_Left{i}(2,1)]...
        + segments_W_L.Hand_Left{i} * (mass * M.Hand * Moment_of_Inertia.Hand) * ...
        [segments_W_L.Hand_Left{i}(3,2);segments_W_L.Hand_Left{i}(1,3);segments_W_L.Hand_Left{i}(2,1)]);
    
    moment_couple_global.Hand_Right{i} = (r_all_segments.Hand_Right{i}) * ((mass * M.Hand * Moment_of_Inertia.Hand) * ...
        [segments_Alpha_L.Hand_Right{i}(3,2);segments_Alpha_L.Hand_Right{i}(1,3);segments_Alpha_L.Hand_Right{i}(2,1)]...
        + segments_W_L.Hand_Right{i} * (mass * M.Hand * Moment_of_Inertia.Hand) * ...
        [segments_W_L.Hand_Right{i}(3,2);segments_W_L.Hand_Right{i}(1,3);segments_W_L.Hand_Right{i}(2,1)]);
    
    moment_couple_global.Thigh_Left{i} = (r_all_segments.Thigh_Left{i}) * ((mass * M.Thigh * Moment_of_Inertia.Thigh) * ...
        [segments_Alpha_L.Thigh_Left{i}(3,2);segments_Alpha_L.Thigh_Left{i}(1,3);segments_Alpha_L.Thigh_Left{i}(2,1)]...
        + segments_W_L.Thigh_Left{i} * (mass * M.Thigh * Moment_of_Inertia.Thigh) * ...
        [segments_W_L.Thigh_Left{i}(3,2);segments_W_L.Thigh_Left{i}(1,3);segments_W_L.Thigh_Left{i}(2,1)]);
    
    moment_couple_global.Thigh_Right{i} = (r_all_segments.Thigh_Right{i}) * ((mass * M.Thigh * Moment_of_Inertia.Thigh) * ...
        [segments_Alpha_L.Thigh_Right{i}(3,2);segments_Alpha_L.Thigh_Right{i}(1,3);segments_Alpha_L.Thigh_Right{i}(2,1)]...
        + segments_W_L.Thigh_Right{i} * (mass * M.Thigh * Moment_of_Inertia.Thigh) * ...
        [segments_W_L.Thigh_Right{i}(3,2);segments_W_L.Thigh_Right{i}(1,3);segments_W_L.Thigh_Right{i}(2,1)]);
    
    moment_couple_global.Shank_Left{i} = (r_all_segments.Shank_Left{i}) * ((mass * M.Shank * Moment_of_Inertia.Shank) * ...
        [segments_Alpha_L.Shank_Left{i}(3,2);segments_Alpha_L.Shank_Left{i}(1,3);segments_Alpha_L.Shank_Left{i}(2,1)]...
        + segments_W_L.Shank_Left{i} * (mass * M.Shank * Moment_of_Inertia.Shank) * ...
        [segments_W_L.Shank_Left{i}(3,2);segments_W_L.Shank_Left{i}(1,3);segments_W_L.Shank_Left{i}(2,1)]);
    
    moment_couple_global.Shank_Right{i} = (r_all_segments.Shank_Right{i}) * ((mass * M.Shank * Moment_of_Inertia.Shank) * ...
        [segments_Alpha_L.Shank_Right{i}(3,2);segments_Alpha_L.Shank_Right{i}(1,3);segments_Alpha_L.Shank_Right{i}(2,1)]...
        + segments_W_L.Shank_Right{i} * (mass * M.Shank * Moment_of_Inertia.Shank) * ...
        [segments_W_L.Shank_Right{i}(3,2);segments_W_L.Shank_Right{i}(1,3);segments_W_L.Shank_Right{i}(2,1)]);
    
    moment_couple_global.Foot_Left{i} = (r_all_segments.Foot_Left{i}) * ((mass * M.Foot * Moment_of_Inertia.Foot) * ...
        [segments_Alpha_L.Foot_Left{i}(3,2);segments_Alpha_L.Foot_Left{i}(1,3);segments_Alpha_L.Foot_Left{i}(2,1)]...
        + segments_W_L.Foot_Left{i} * (mass * M.Foot * Moment_of_Inertia.Foot) * ...
        [segments_W_L.Foot_Left{i}(3,2);segments_W_L.Foot_Left{i}(1,3);segments_W_L.Foot_Left{i}(2,1)]);
    
    moment_couple_global.Foot_Right{i} = (r_all_segments.Foot_Right{i}) * ((mass * M.Foot * Moment_of_Inertia.Foot) * ...
        [segments_Alpha_L.Foot_Right{i}(3,2);segments_Alpha_L.Foot_Right{i}(1,3);segments_Alpha_L.Foot_Right{i}(2,1)]...
        + segments_W_L.Foot_Right{i} * (mass * M.Foot * Moment_of_Inertia.Foot) * ...
        [segments_W_L.Foot_Right{i}(3,2);segments_W_L.Foot_Right{i}(1,3);segments_W_L.Foot_Right{i}(2,1)]);
    
    % 所有体段力偶矩之和
    moment_couple_global.human{i} = moment_couple_global.HeadNeck{i} + moment_couple_global.Trunk{i} + moment_couple_global.Upperarm_Left{i}...
        + moment_couple_global.Upperarm_Right{i} + moment_couple_global.Forearm_Left{i} + moment_couple_global.Forearm_Right{i}...
        + moment_couple_global.Hand_Left{i} + moment_couple_global.Hand_Right{i} + moment_couple_global.Thigh_Left{i}...
        + moment_couple_global.Thigh_Right{i} + moment_couple_global.Shank_Left{i} + moment_couple_global.Shank_Right{i}...
        + moment_couple_global.Foot_Left{i} + moment_couple_global.Foot_Right{i};
end
%% 各体段质心相对全局坐标系原点平移所需的力矩，格式3*1
% M = r × F = mr × a
for i=1:len_Alfa
    moment_com_global.HeadNeck{i} = mass * M.HeadNeck *cross( [segments_com_position.HeadNeck.x(i),segments_com_position.HeadNeck.y(i),segments_com_position.HeadNeck.z(i)],...
        [segments_com_acceleration.HeadNeck.x(i),segments_com_acceleration.HeadNeck.y(i),segments_com_acceleration.HeadNeck.z(i)])';
    
    moment_com_global.Trunk{i} = mass * M.Trunk *cross( [segments_com_position.Trunk.x(i),segments_com_position.Trunk.y(i),segments_com_position.Trunk.z(i)],...
        [segments_com_acceleration.Trunk.x(i),segments_com_acceleration.Trunk.y(i),segments_com_acceleration.Trunk.z(i)])';
    
    moment_com_global.Upperarm_Left{i} = mass * M.Upperarm *cross( [segments_com_position.Upperarm_Left.x(i),segments_com_position.Upperarm_Left.y(i),segments_com_position.Upperarm_Left.z(i)],...
        [segments_com_acceleration.Upperarm_Left.x(i),segments_com_acceleration.Upperarm_Left.y(i),segments_com_acceleration.Upperarm_Left.z(i)])';
    
    moment_com_global.Upperarm_Right{i} = mass * M.Upperarm *cross( [segments_com_position.Upperarm_Right.x(i),segments_com_position.Upperarm_Right.y(i),segments_com_position.Upperarm_Right.z(i)],...
        [segments_com_acceleration.Upperarm_Right.x(i),segments_com_acceleration.Upperarm_Right.y(i),segments_com_acceleration.Upperarm_Right.z(i)])';
    
    moment_com_global.Forearm_Left{i} = mass * M.Forearm *cross( [segments_com_position.Forearm_Left.x(i),segments_com_position.Forearm_Left.y(i),segments_com_position.Forearm_Left.z(i)],...
        [segments_com_acceleration.Forearm_Left.x(i),segments_com_acceleration.Forearm_Left.y(i),segments_com_acceleration.Forearm_Left.z(i)])';
    
    moment_com_global.Forearm_Right{i} = mass * M.Forearm *cross( [segments_com_position.Forearm_Right.x(i),segments_com_position.Forearm_Right.y(i),segments_com_position.Forearm_Right.z(i)],...
        [segments_com_acceleration.Forearm_Right.x(i),segments_com_acceleration.Forearm_Right.y(i),segments_com_acceleration.Forearm_Right.z(i)])';
    
    moment_com_global.Hand_Left{i} = mass * M.Hand *cross( [segments_com_position.Hand_Left.x(i),segments_com_position.Hand_Left.y(i),segments_com_position.Hand_Left.z(i)],...
        [segments_com_acceleration.Hand_Left.x(i),segments_com_acceleration.Hand_Left.y(i),segments_com_acceleration.Hand_Left.z(i)])';
    
    moment_com_global.Hand_Right{i} = mass * M.Hand *cross( [segments_com_position.Hand_Right.x(i),segments_com_position.Hand_Right.y(i),segments_com_position.Hand_Right.z(i)],...
        [segments_com_acceleration.Hand_Right.x(i),segments_com_acceleration.Hand_Right.y(i),segments_com_acceleration.Hand_Right.z(i)])';
    
    moment_com_global.Thigh_Left{i} = mass * M.Thigh *cross( [segments_com_position.Thigh_Left.x(i),segments_com_position.Thigh_Left.y(i),segments_com_position.Thigh_Left.z(i)],...
        [segments_com_acceleration.Thigh_Left.x(i),segments_com_acceleration.Thigh_Left.y(i),segments_com_acceleration.Thigh_Left.z(i)])';
    
    moment_com_global.Thigh_Right{i} = mass * M.Thigh *cross( [segments_com_position.Thigh_Right.x(i),segments_com_position.Thigh_Right.y(i),segments_com_position.Thigh_Right.z(i)],...
        [segments_com_acceleration.Thigh_Right.x(i),segments_com_acceleration.Thigh_Right.y(i),segments_com_acceleration.Thigh_Right.z(i)])';
    
    moment_com_global.Shank_Left{i} = mass * M.Shank *cross( [segments_com_position.Shank_Left.x(i),segments_com_position.Shank_Left.y(i),segments_com_position.Shank_Left.z(i)],...
        [segments_com_acceleration.Shank_Left.x(i),segments_com_acceleration.Shank_Left.y(i),segments_com_acceleration.Shank_Left.z(i)])';
    
    moment_com_global.Shank_Right{i} = mass * M.Shank *cross( [segments_com_position.Shank_Right.x(i),segments_com_position.Shank_Right.y(i),segments_com_position.Shank_Right.z(i)],...
        [segments_com_acceleration.Shank_Right.x(i),segments_com_acceleration.Shank_Right.y(i),segments_com_acceleration.Shank_Right.z(i)])';
    
    moment_com_global.Foot_Left{i} = mass * M.Foot *cross( [segments_com_position.Foot_Left.x(i),segments_com_position.Foot_Left.y(i),segments_com_position.Foot_Left.z(i)],...
        [segments_com_acceleration.Foot_Left.x(i),segments_com_acceleration.Foot_Left.y(i),segments_com_acceleration.Foot_Left.z(i)])';
    
    moment_com_global.Foot_Right{i} = mass * M.Foot *cross( [segments_com_position.Foot_Right.x(i),segments_com_position.Foot_Right.y(i),segments_com_position.Foot_Right.z(i)],...
        [segments_com_acceleration.Foot_Right.x(i),segments_com_acceleration.Foot_Right.y(i),segments_com_acceleration.Foot_Right.z(i)])';
    
    % 所有体段质心相对全局原点力矩之和
    moment_com_global.human{i} = moment_com_global.HeadNeck{i} + moment_com_global.Trunk{i} + moment_com_global.Upperarm_Left{i}...
        + moment_com_global.Upperarm_Right{i} + moment_com_global.Forearm_Left{i} + moment_com_global.Forearm_Right{i}...
        + moment_com_global.Hand_Left{i} + moment_com_global.Hand_Right{i} + moment_com_global.Thigh_Left{i}...
        + moment_com_global.Thigh_Right{i} + moment_com_global.Shank_Left{i} + moment_com_global.Shank_Right{i}...
        + moment_com_global.Foot_Left{i} + moment_com_global.Foot_Right{i};
end

%% 整个人体对全局原点所需的力矩 格式3*1
for i=1:len_Alfa
    moment_couple_and_com_global.human{i} = moment_couple_global.human{i} + moment_com_global.human{i};
end

%% 地面反力偶矩,假设地面反作用力作用在ankleleft 和ankleRight 的投影点

for i=1:len_Alfa    
    % 每个体段重力产生的力矩之和
    moment_gravity_global_human{i} = cross([segments_com_position.HeadNeck.x(i),segments_com_position.HeadNeck.y(i),segments_com_position.HeadNeck.z(i)],[0,0,-mass * M.HeadNeck*9.8])'...
        +cross([segments_com_position.Trunk.x(i),segments_com_position.Trunk.y(i),segments_com_position.Trunk.z(i)],[0,0,-mass * M.Trunk*9.8])'...
        +cross([segments_com_position.Upperarm_Left.x(i),segments_com_position.Upperarm_Left.y(i),segments_com_position.Upperarm_Left.z(i)],[0,0,-mass * M.Upperarm*9.8])'...
        +cross([segments_com_position.Upperarm_Right.x(i),segments_com_position.Upperarm_Right.y(i),segments_com_position.Upperarm_Right.z(i)],[0,0,-mass * M.Upperarm*9.8])'...
        +cross([segments_com_position.Forearm_Left.x(i),segments_com_position.Forearm_Left.y(i),segments_com_position.Forearm_Left.z(i)],[0,0,-mass * M.Forearm*9.8])'...
        +cross([segments_com_position.Forearm_Right.x(i),segments_com_position.Forearm_Right.y(i),segments_com_position.Forearm_Right.z(i)],[0,0,-mass * M.Forearm*9.8])'...
        +cross([segments_com_position.Hand_Left.x(i),segments_com_position.Hand_Left.y(i),segments_com_position.Hand_Left.z(i)],[0,0,-mass * M.Hand*9.8])'...
        +cross([segments_com_position.Hand_Right.x(i),segments_com_position.Hand_Right.y(i),segments_com_position.Hand_Right.z(i)],[0,0,-mass * M.Hand*9.8])'...
        +cross([segments_com_position.Thigh_Left.x(i),segments_com_position.Thigh_Left.y(i),segments_com_position.Thigh_Left.z(i)],[0,0,-mass * M.Thigh*9.8])'...
        +cross([segments_com_position.Thigh_Right.x(i),segments_com_position.Thigh_Right.y(i),segments_com_position.Thigh_Right.z(i)],[0,0,-mass * M.Thigh*9.8])'...
        +cross([segments_com_position.Shank_Left.x(i),segments_com_position.Shank_Left.y(i),segments_com_position.Shank_Left.z(i)],[0,0,-mass * M.Shank*9.8])'...
        +cross([segments_com_position.Shank_Right.x(i),segments_com_position.Shank_Right.y(i),segments_com_position.Shank_Right.z(i)],[0,0,-mass * M.Shank*9.8])'...
        +cross([segments_com_position.Foot_Left.x(i),segments_com_position.Foot_Left.y(i),segments_com_position.Foot_Left.z(i)],[0,0,-mass * M.Foot*9.8])'...
        +cross([segments_com_position.Foot_Right.x(i),segments_com_position.Foot_Right.y(i),segments_com_position.Foot_Right.z(i)],[0,0,-mass * M.Foot*9.8])';
    % 地面反力偶矩,有坐垫参与
    ground_couple_moment_global = moment_couple_and_com_global.human{i} - moment_gravity_global_human{i}...
        -cross([kinectstream.HIP_RIGHT.x(i)-0.05,kinectstream.HIP_RIGHT.y(i),kinectstream.HIP_RIGHT.z(i)-0.1],...
        [hip_force_Right.x(i),hip_force_Right.y(i),hip_force_Right.z(i)])'...
        -cross([kinectstream.HIP_LEFT.x(i)+0.05,kinectstream.HIP_LEFT.y(i),kinectstream.HIP_LEFT.z(i)-0.1],...
        [hip_force_Left.x(i),hip_force_Left.y(i),hip_force_Left.z(i)])';
    aux = 0.5*ground_couple_moment_global-ratioLR*cross([kinectstream.ANKLE_LEFT.x(i),kinectstream.ANKLE_LEFT.y(i),0],...
        [ground_force_Left.x(i),ground_force_Left.y(i),ground_force_Left.z(i)])'...
        -(1-ratioLR)*cross([kinectstream.ANKLE_RIGHT.x(i),kinectstream.ANKLE_RIGHT.y(i),0],...
        [ground_force_Right.x(i),ground_force_Right.y(i),ground_force_Right.z(i)])';
    ground_couple_moment_global_Left.x(i) = aux(1);
    ground_couple_moment_global_Left.y(i) = aux(2);
    ground_couple_moment_global_Left.z(i) = aux(3);
    aux = 0.5*ground_couple_moment_global-(1-ratioLR)*cross([kinectstream.ANKLE_LEFT.x(i),kinectstream.ANKLE_LEFT.y(i),0],...
        [ground_force_Left.x(i),ground_force_Left.y(i),ground_force_Left.z(i)])'...
        -ratioLR*cross([kinectstream.ANKLE_RIGHT.x(i),kinectstream.ANKLE_RIGHT.y(i),0],...
        [ground_force_Right.x(i),ground_force_Right.y(i),ground_force_Right.z(i)])';
    ground_couple_moment_global_Right.x(i) = aux(1);
    ground_couple_moment_global_Right.y(i) = aux(2);
    ground_couple_moment_global_Right.z(i) = aux(3);
end


%% 地面反力偶矩 在两足上的分配
% [ground_couple_moment_global_Left,ground_couple_moment_global_Right] = Ground_Moment_Distribution(ground_couple_moment_global);


names = fieldnames(moment_couple_global);
for i = 1:length(names)
    name = names{i};
    for j = 1:len_Alfa
        moment_couple_global_new.(name).x(j,1) = moment_couple_global.(name){1,j}(1);
        moment_couple_global_new.(name).y(j,1) = moment_couple_global.(name){1,j}(2);
        moment_couple_global_new.(name).z(j,1) = moment_couple_global.(name){1,j}(3);
        moment_com_global_new.(name).x(j,1) = moment_com_global.(name){1,j}(1);
        moment_com_global_new.(name).y(j,1) = moment_com_global.(name){1,j}(2);
        moment_com_global_new.(name).z(j,1) = moment_com_global.(name){1,j}(3);
    end
end
for j = 1:len_Alfa
    moment_gravity_global_human_new.x(j,1) = moment_gravity_global_human{1,j}(1);
    moment_gravity_global_human_new.y(j,1) = moment_gravity_global_human{1,j}(2);
    moment_gravity_global_human_new.z(j,1) = moment_gravity_global_human{1,j}(3);
end