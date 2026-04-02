function [jointAngles] = CalJointAngles_segments_RM(stream)
% CalJointAngles_segments_RM - 基于相邻刚体变换矩阵计算关节角度
% 
% 输入:
%   stream - 包含关节坐标的数据结构
%
% 输出:
%   jointAngles - 包含各关节在三个解剖平面上角度的结构体
%                 输出格式与 CalKinectJointAngle 一致:
%                 knee_left, knee_right - 膝关节角度 (左/右)
%                 ankle_left, ankle_right - 踝关节角度 (左/右)
%                 hip_left, hip_right - 髋关节角度 (左/右)
%                 lumbar - 腰椎角度
%                 每个字段包含三个子字段:
%                   .x - 矢状面角度 (屈曲/伸展)
%                   .y - 冠状面角度 (内收/外展 或 侧屈)
%                   .z - 横断面角度 (内旋/外旋 或 旋转)
%
% 解剖平面定义:
%   x - sagittal (矢状面): 屈曲/伸展 (flexion/extension)
%   y - frontal (冠状面): 内收/外展 (adduction/abduction) 或 侧屈 (lateral flexion)
%   z - transverse (横断面): 内旋/外旋 (internal/external rotation) 或 旋转 (rotation)

%% 腰椎关节角度计算 (躯干-骨盆段)

% 腰椎关节 (骨盆到躯干的相对角度)
[lumbar_angles] = calculateJointAngles_RM(...
    [stream.PELVIS.x, stream.PELVIS.y, stream.PELVIS.z], ...
    [stream.SPINE_NAVAL.x, stream.SPINE_NAVAL.y, stream.SPINE_NAVAL.z], ...
    [(stream.HIP_LEFT.x + stream.HIP_RIGHT.x)/2, ...
     (stream.HIP_LEFT.y + stream.HIP_RIGHT.y)/2, ...
     (stream.HIP_LEFT.z + stream.HIP_RIGHT.z)/2], ...
    [stream.SPINE_CHEST.x, stream.SPINE_CHEST.y, stream.SPINE_CHEST.z]);

% 将角度转换为与 CalKinectJointAngle 相同的格式 (struct with x, y, z fields)
lumbar.x = lumbar_angles(:,1);    % 屈曲/伸展 (sagittal)
lumbar.y = lumbar_angles(:,2);    % 侧屈 (frontal)
lumbar.z = lumbar_angles(:,3);    % 旋转 (transverse)

%% 左侧关节角度计算

% 左髋关节 (骨盆-大腿段)
[hipL_angles] = calculateJointAngles_RM(...
    [stream.PELVIS.x, stream.PELVIS.y, stream.PELVIS.z], ...
    [stream.HIP_LEFT.x, stream.HIP_LEFT.y, stream.HIP_LEFT.z], ...
    [stream.SPINE_NAVAL.x, stream.SPINE_NAVAL.y, stream.SPINE_NAVAL.z], ...
    [stream.KNEE_LEFT.x, stream.KNEE_LEFT.y, stream.KNEE_LEFT.z]);

hip_left.x = hipL_angles(:,1);    % 屈曲/伸展 (sagittal)
hip_left.y = hipL_angles(:,2);    % 内收/外展 (frontal)
hip_left.z = hipL_angles(:,3);    % 内旋/外旋 (transverse)

% 左膝关节 (大腿-小腿段)
[kneeL_angles] = calculateJointAngles_RM(...
    [stream.HIP_LEFT.x, stream.HIP_LEFT.y, stream.HIP_LEFT.z], ...
    [stream.KNEE_LEFT.x, stream.KNEE_LEFT.y, stream.KNEE_LEFT.z], ...
    [stream.PELVIS.x, stream.PELVIS.y, stream.PELVIS.z], ...
    [stream.ANKLE_LEFT.x, stream.ANKLE_LEFT.y, stream.ANKLE_LEFT.z]);

knee_left.x = kneeL_angles(:,1);    % 屈曲/伸展 (sagittal)
knee_left.y = kneeL_angles(:,2);    % 内翻/外翻 (frontal)
knee_left.z = kneeL_angles(:,3);    % 内旋/外旋 (transverse)

% 左踝关节 (小腿-足段)
[ankleL_angles] = calculateJointAngles_RM(...
    [stream.KNEE_LEFT.x, stream.KNEE_LEFT.y, stream.KNEE_LEFT.z], ...
    [stream.ANKLE_LEFT.x, stream.ANKLE_LEFT.y, stream.ANKLE_LEFT.z], ...
    [stream.HIP_LEFT.x, stream.HIP_LEFT.y, stream.HIP_LEFT.z], ...
    [stream.FOOT_LEFT.x, stream.FOOT_LEFT.y, stream.FOOT_LEFT.z]);

ankle_left.x = ankleL_angles(:,1);    % 背屈/跖屈 (sagittal)
ankle_left.y = ankleL_angles(:,2);    % 内翻/外翻 (frontal)
ankle_left.z = ankleL_angles(:,3);    % 内旋/外旋 (transverse)

%% 右侧关节角度计算

% 右髋关节 (骨盆-大腿段)
[hipR_angles] = calculateJointAngles_RM(...
    [stream.PELVIS.x, stream.PELVIS.y, stream.PELVIS.z], ...
    [stream.HIP_RIGHT.x, stream.HIP_RIGHT.y, stream.HIP_RIGHT.z], ...
    [stream.SPINE_NAVAL.x, stream.SPINE_NAVAL.y, stream.SPINE_NAVAL.z], ...
    [stream.KNEE_RIGHT.x, stream.KNEE_RIGHT.y, stream.KNEE_RIGHT.z]);

hip_right.x = hipR_angles(:,1);    % 屈曲/伸展 (sagittal)
hip_right.y = hipR_angles(:,2);    % 内收/外展 (frontal)
hip_right.z = hipR_angles(:,3);    % 内旋/外旋 (transverse)

% 右膝关节 (大腿-小腿段)
[kneeR_angles] = calculateJointAngles_RM(...
    [stream.HIP_RIGHT.x, stream.HIP_RIGHT.y, stream.HIP_RIGHT.z], ...
    [stream.KNEE_RIGHT.x, stream.KNEE_RIGHT.y, stream.KNEE_RIGHT.z], ...
    [stream.PELVIS.x, stream.PELVIS.y, stream.PELVIS.z], ...
    [stream.ANKLE_RIGHT.x, stream.ANKLE_RIGHT.y, stream.ANKLE_RIGHT.z]);

knee_right.x = kneeR_angles(:,1);    % 屈曲/伸展 (sagittal)
knee_right.y = kneeR_angles(:,2);    % 内翻/外翻 (frontal)
knee_right.z = kneeR_angles(:,3);    % 内旋/外旋 (transverse)

% 右踝关节 (小腿-足段)
[ankleR_angles] = calculateJointAngles_RM(...
    [stream.KNEE_RIGHT.x, stream.KNEE_RIGHT.y, stream.KNEE_RIGHT.z], ...
    [stream.ANKLE_RIGHT.x, stream.ANKLE_RIGHT.y, stream.ANKLE_RIGHT.z], ...
    [stream.HIP_RIGHT.x, stream.HIP_RIGHT.y, stream.HIP_RIGHT.z], ...
    [stream.FOOT_RIGHT.x, stream.FOOT_RIGHT.y, stream.FOOT_RIGHT.z]);

ankle_right.x = ankleR_angles(:,1);    % 背屈/跖屈 (sagittal)
ankle_right.y = ankleR_angles(:,2);    % 内翻/外翻 (frontal)
ankle_right.z = ankleR_angles(:,3);    % 内旋/外旋 (transverse)

%% 组合输出结构体，与 CalKinectJointAngle 格式一致
jointAngles = struct('knee_left',knee_left,'knee_right',knee_right,...
    'ankle_left',ankle_left,'ankle_right',ankle_right,...
    'hip_left',hip_left,'hip_right',hip_right,...
    'lumbar',lumbar);

end

function [angles] = calculateJointAngles_RM(proximal_joint, distal_joint, proximal_ref, distal_ref)
% calculateJointAngles_RM - 基于刚体变换矩阵计算关节角度
%
% 输入:
%   proximal_joint - 近端关节坐标 [n×3]
%   distal_joint - 远端关节坐标 [n×3]
%   proximal_ref - 近端参考点坐标 [n×3] (用于构建近端刚体坐标系)
%   distal_ref - 远端参考点坐标 [n×3] (用于构建远端刚体坐标系)
%
% 输出:
%   angles - 三个解剖平面的角度 [n×3] (矢状面, 冠状面, 横断面)

nFrames = size(proximal_joint, 1);
angles = zeros(nFrames, 3);

for i = 1:nFrames
    % 构建近端刚体坐标系
    R_proximal = buildSegmentCoordinateSystem(...
        proximal_joint(i,:), distal_joint(i,:), proximal_ref(i,:));
    
    % 构建远端刚体坐标系
    R_distal = buildSegmentCoordinateSystem(...
        distal_joint(i,:), distal_ref(i,:), proximal_joint(i,:));
    
    % 计算相对旋转矩阵
    R_relative = R_distal' * R_proximal;
    
    % 从旋转矩阵提取欧拉角 (ZYX顺序，对应解剖学角度)
    angles(i,:) = rotationMatrixToEulerAngles(R_relative);
end

end

function R = buildSegmentCoordinateSystem(joint1, joint2, ref_point)
% buildSegmentCoordinateSystem - 构建刚体段坐标系
%
% 输入:
%   joint1 - 关节1坐标 [1×3]
%   joint2 - 关节2坐标 [1×3] 
%   ref_point - 参考点坐标 [1×3]
%
% 输出:
%   R - 3×3旋转矩阵

% 计算主轴 (沿着骨段方向)
z_axis = joint2 - joint1;
z_axis = z_axis / norm(z_axis);

% 计算辅助向量
aux_vector = ref_point - joint1;
aux_vector = aux_vector / norm(aux_vector);

% 计算y轴 (垂直于主轴和辅助向量的平面)
y_axis = cross(z_axis, aux_vector);
y_axis = y_axis / norm(y_axis);

% 计算x轴 (右手坐标系)
x_axis = cross(y_axis, z_axis);
x_axis = x_axis / norm(x_axis);

% 构建旋转矩阵
R = [x_axis; y_axis; z_axis]';

end

function euler_angles = rotationMatrixToEulerAngles(R)
% rotationMatrixToEulerAngles - 从旋转矩阵提取欧拉角
%
% 输入:
%   R - 3×3旋转矩阵
%
% 输出:
%   euler_angles - [1×3] 欧拉角 [sagittal, frontal, transverse] (度)

% 使用ZYX欧拉角顺序 (对应解剖学角度定义)
% sagittal (绕X轴旋转) - 屈曲/伸展
% frontal (绕Y轴旋转) - 内收/外展 或 内翻/外翻
% transverse (绕Z轴旋转) - 内旋/外旋

% 提取欧拉角 (ZYX顺序)
sy = sqrt(R(1,1)^2 + R(2,1)^2);

singular = sy < 1e-6;

if ~singular
    x = atan2(R(3,2), R(3,3));  % 绕X轴 (sagittal)
    y = atan2(-R(3,1), sy);     % 绕Y轴 (frontal)
    z = atan2(R(2,1), R(1,1));  % 绕Z轴 (transverse)
else
    x = atan2(-R(2,3), R(2,2)); % 绕X轴 (sagittal)
    y = atan2(-R(3,1), sy);     % 绕Y轴 (frontal)
    z = 0;                      % 绕Z轴 (transverse)
end

% 转换为度并输出
euler_angles = rad2deg([x, y, z]);

end
