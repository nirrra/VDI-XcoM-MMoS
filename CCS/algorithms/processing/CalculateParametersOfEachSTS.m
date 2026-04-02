function [seg] = CalculateParametersOfEachSTS(time_union,seg,streamInter,...
    pressurePlantar2DInter,pressureHip2DInter,...
    pressurePlantarInter,pressureHipInter,...
    pressurePlantarInter_left,pressurePlantarInter_right,...
    pressureHipInter_left,pressureHipInter_right,...
    transform_plantar2kinect,fsInter)

g = 9.79;

gender = seg.info.gender;
weight = seg.info.weight;
height = seg.info.height;

%% 简单函数

funcSumXYZ = @(x,y,z) (x.^2+y.^2+z.^2).^0.5;
DivMean = @(a)(a-mean(a));
ScaleData = @(a,b)((a-min(a))./range(a)*range(b)+min(b));
funcDiffAngle = @(a,t) (interp1(t(1:end-1)+diff(t)/2,diff(a)./diff(t),t,'linear','extrap'));

%% 计算关节角
flag_RM = false;
jointAngles = CalJointAngles_xcom(streamInter,flag_RM);

%% STS分期
% 开始 → p1骨盆最低 → p2臀部离开坐垫 → p3踝关节最大背屈 → p4髋关节第一次停止伸展 → 结束

% 定位PELVIS，HIP_LEFT，HIP_RIGHT的最低点
aux = median([streamInter.PELVIS.z,streamInter.HIP_LEFT.z,streamInter.HIP_RIGHT.z],2);
[~,idx_p1] = min(aux); 
time_p1 = time_union(idx_p1);

% 定位臀部离开坐垫时间
aux = pressureHipInter;
for idx_p2 = 1+2:length(aux)-2
    if max(aux(idx_p2-2:idx_p2+2))<100
        break;
    end
end
time_p2 = time_union(idx_p2);

% 定位最大踝关节背屈（踝关节角最小值）
aux = jointAngles.ankle_left.x+jointAngles.ankle_right.x;
[~,idx_p3] = min(aux); 
time_p3 = time_union(idx_p3);

% 定位髋关节第一次停止伸展（髋关节角最大值）
aux = jointAngles.hip_left.x+jointAngles.hip_right.x;
[~,idx_p4] = max(aux); 
time_p4 = time_union(idx_p4);

%% ======== 动力学参数 =======
%% 计算左右脚压力
grfPlantar.z = pressurePlantarInter; 
grfPlantar.x = zeros(size(grfPlantar.z)); grfPlantar.y = zeros(size(grfPlantar.z));
grfPlantarLeft.z = pressurePlantarInter_left; 
grfPlantarLeft.x = zeros(size(grfPlantarLeft.z)); grfPlantarLeft.y = zeros(size(grfPlantarLeft.z));
grfPlantarRight.z = pressurePlantarInter_right; 
grfPlantarRight.x = zeros(size(grfPlantarRight.z)); grfPlantarRight.y = zeros(size(grfPlantarRight.z));

grfHipLeft.z = pressureHipInter_left; 
grfHipLeft.x = zeros(size(grfHipLeft.z)); grfHipLeft.y = zeros(size(grfHipLeft.z));
grfHipRight.z = pressureHipInter_right; 
grfHipRight.x = zeros(size(grfHipRight.z)); grfHipRight.y = zeros(size(grfHipRight.z));

grfSum.z = pressurePlantarInter + pressureHipInter;
grfSum.x = zeros(size(grfSum.z)); grfSum.y = zeros(size(grfSum.z));

% % 对地面反力数据进行滤波以减少噪声
% fprintf('对地面反力数据进行12Hz低通滤波...\n');
% grfPlantarLeft = FilterGRFData(grfPlantarLeft, fsInter, 12);
% grfPlantarRight = FilterGRFData(grfPlantarRight, fsInter, 12);
% grfHipLeft = FilterGRFData(grfHipLeft, fsInter, 12);
% grfHipRight = FilterGRFData(grfHipRight, fsInter, 12);
% grfSum = FilterGRFData(grfSum, fsInter, 12);

%% 重新计算带骨盆的体段质心
[posCOMSegments,vCOMSegments,accCOMSegments] = Segments_Velocity_Acceleration_WithPelvis(streamInter,gender,fsInter);

com = posCOMSegments.human;
vcom = vCOMSegments.human;
acom = accCOMSegments.human;

% 计算对COM的转动惯量
inertia_rotary = CalRotaryInertia(gender,weight,streamInter,posCOMSegments);

% 对运动学数据进行滤波以减少噪声
streamInter = FilterStreamInter(streamInter, fsInter, 12);

%% 旋转矩阵（体段坐标系到全局坐标系）
[segments_RM, segments_origin] = Segments_Rotation_WithPelvis(streamInter);

%% 角速度和角加速度
[segments_W_G,segments_W_L,segments_W_G_xyz,segments_W_L_xyz] = Segments_Rotation_Angular_velocity(segments_RM,fsInter);
[segments_Alpha_G,segments_Alpha_L,segments_Alpha_G_xyz,segments_Alpha_L_xyz] = Segments_Rotation_Angular_Acceleration(segments_W_G,segments_W_L,fsInter);

%% 关节力
jointForces = Segments_Force_WithPelvis(weight,gender,grfPlantarLeft,grfPlantarRight,grfHipLeft,grfHipRight,accCOMSegments);

%% GRM,作用点在足的前端FootLeft和FootRight
[grmLeft,grmRight,~,~,~] = Ground_Moment_WithPelvis(weight,gender,streamInter,...
    posCOMSegments,accCOMSegments,grfHipLeft,grfHipRight,grfPlantarLeft,grfPlantarRight,segments_RM,segments_W_L,segments_Alpha_L);

%% 关节矩
[jointMomentGlobal,jointMomentLocal,~,~,~] = Segments_Moment_WithPelvis(weight,gender,streamInter,...
    posCOMSegments,jointForces,segments_RM,segments_W_L,segments_Alpha_L,grmLeft,grmRight);

%% ======== XcoM =======
% PartCalculatePXcoM;

%% 计算关节功率
jointPower = struct();
jointPower.hip_l.x = jointMomentGlobal.Thigh_Left_proximal.x.*funcDiffAngle(jointAngles.hip_left.x,time_union);
jointPower.hip_l.y = jointMomentGlobal.Thigh_Left_proximal.y.*funcDiffAngle(jointAngles.hip_left.y,time_union);
jointPower.hip_l.z = jointMomentGlobal.Thigh_Left_proximal.z.*funcDiffAngle(jointAngles.hip_left.z,time_union);
jointPower.hip_r.x = jointMomentGlobal.Thigh_Right_proximal.x.*funcDiffAngle(jointAngles.hip_right.x,time_union);
jointPower.hip_r.y = jointMomentGlobal.Thigh_Right_proximal.y.*funcDiffAngle(jointAngles.hip_right.y,time_union);
jointPower.hip_r.z = jointMomentGlobal.Thigh_Right_proximal.z.*funcDiffAngle(jointAngles.hip_right.z,time_union);
jointPower.knee_l.x = jointMomentGlobal.Shank_Left_proximal.x.*funcDiffAngle(jointAngles.knee_left.x,time_union);
jointPower.knee_l.y = jointMomentGlobal.Shank_Left_proximal.y.*funcDiffAngle(jointAngles.knee_left.y,time_union);
jointPower.knee_l.z = jointMomentGlobal.Shank_Left_proximal.z.*funcDiffAngle(jointAngles.knee_left.z,time_union);
jointPower.knee_r.x = jointMomentGlobal.Shank_Right_proximal.x.*funcDiffAngle(jointAngles.knee_right.x,time_union);
jointPower.knee_r.y = jointMomentGlobal.Shank_Right_proximal.y.*funcDiffAngle(jointAngles.knee_right.y,time_union);
jointPower.knee_r.z = jointMomentGlobal.Shank_Right_proximal.z.*funcDiffAngle(jointAngles.knee_right.z,time_union);
jointPower.ankle_l.x = jointMomentGlobal.Foot_Left_proximal.x.*funcDiffAngle(jointAngles.ankle_left.x,time_union);
jointPower.ankle_l.y = jointMomentGlobal.Foot_Left_proximal.y.*funcDiffAngle(jointAngles.ankle_left.y,time_union);
jointPower.ankle_l.z = jointMomentGlobal.Foot_Left_proximal.z.*funcDiffAngle(jointAngles.ankle_left.z,time_union);
jointPower.ankle_r.x = jointMomentGlobal.Foot_Right_proximal.x.*funcDiffAngle(jointAngles.ankle_right.x,time_union);
jointPower.ankle_r.y = jointMomentGlobal.Foot_Right_proximal.y.*funcDiffAngle(jointAngles.ankle_right.y,time_union);
jointPower.ankle_r.z = jointMomentGlobal.Foot_Right_proximal.z.*funcDiffAngle(jointAngles.ankle_right.z,time_union);
jointPower.lumbar.x = jointMomentGlobal.Trunk_Lower_proximal.x.*funcDiffAngle(jointAngles.lumbar.x,time_union);
jointPower.lumbar.y = jointMomentGlobal.Trunk_Lower_proximal.y.*funcDiffAngle(jointAngles.lumbar.y,time_union);
jointPower.lumbar.z = jointMomentGlobal.Trunk_Lower_proximal.z.*funcDiffAngle(jointAngles.lumbar.z,time_union);
           
%% 记录

% 区间
seg.idx.idx_start = 1;
seg.idx.idx_p1 = idx_p1;
seg.idx.idx_p2 = idx_p2;
seg.idx.idx_p3 = idx_p3;
seg.idx.idx_p4 = idx_p4;
seg.idx.idx_end = length(seg.idx.idx_origin);

% 转动惯量
seg.inertia = inertia_rotary;

% kinect
seg.stream.pelvis.z = streamInter.PELVIS.z;

% ja
seg.ja.left_hip = jointAngles.hip_left;
seg.ja.right_hip = jointAngles.hip_right;
seg.ja.left_knee = jointAngles.knee_left;
seg.ja.right_knee = jointAngles.knee_right;
seg.ja.left_ankle = jointAngles.ankle_left;
seg.ja.right_ankle = jointAngles.ankle_right;
seg.ja.lumbar = jointAngles.lumbar;

% jrf
seg.jrf.left_hip_x = jointForces.reaction_force_Thigh_Left_proximal.x;
seg.jrf.left_hip_y = jointForces.reaction_force_Thigh_Left_proximal.y;
seg.jrf.left_hip_z = jointForces.reaction_force_Thigh_Left_proximal.z;
seg.jrf.left_knee_x = jointForces.reaction_force_Shank_Left_proximal.x;
seg.jrf.left_knee_y = jointForces.reaction_force_Shank_Left_proximal.y;
seg.jrf.left_knee_z = jointForces.reaction_force_Shank_Left_proximal.z;
seg.jrf.left_ankle_x = jointForces.reaction_force_Foot_Left_proximal.x;
seg.jrf.left_ankle_y = jointForces.reaction_force_Foot_Left_proximal.y;
seg.jrf.left_ankle_z = jointForces.reaction_force_Foot_Left_proximal.z;
seg.jrf.right_hip_x = jointForces.reaction_force_Thigh_Right_proximal.x;
seg.jrf.right_hip_y = jointForces.reaction_force_Thigh_Right_proximal.y;
seg.jrf.right_hip_z = jointForces.reaction_force_Thigh_Right_proximal.z;
seg.jrf.right_knee_x = jointForces.reaction_force_Shank_Right_proximal.x;
seg.jrf.right_knee_y = jointForces.reaction_force_Shank_Right_proximal.y;
seg.jrf.right_knee_z = jointForces.reaction_force_Shank_Right_proximal.z;
seg.jrf.right_ankle_x = jointForces.reaction_force_Foot_Right_proximal.x;
seg.jrf.right_ankle_y = jointForces.reaction_force_Foot_Right_proximal.y;
seg.jrf.right_ankle_z = jointForces.reaction_force_Foot_Right_proximal.z;
seg.jrf.lumbar_x = jointForces.reaction_force_Trunk_Lower_proximal.x;
seg.jrf.lumbar_y = jointForces.reaction_force_Trunk_Lower_proximal.y;
seg.jrf.lumbar_z = jointForces.reaction_force_Trunk_Lower_proximal.z;

seg.jrf.left_hip = funcSumXYZ(seg.jrf.left_hip_x,seg.jrf.left_hip_y,seg.jrf.left_hip_z);
seg.jrf.left_knee = funcSumXYZ(seg.jrf.left_knee_x,seg.jrf.left_knee_y,seg.jrf.left_knee_z);
seg.jrf.left_ankle = funcSumXYZ(seg.jrf.left_ankle_x,seg.jrf.left_ankle_y,seg.jrf.left_ankle_z);

seg.jrf.right_hip = funcSumXYZ(seg.jrf.right_hip_x,seg.jrf.right_hip_y,seg.jrf.right_hip_z);
seg.jrf.right_knee = funcSumXYZ(seg.jrf.right_knee_x,seg.jrf.right_knee_y,seg.jrf.right_knee_z);
seg.jrf.right_ankle = funcSumXYZ(seg.jrf.right_ankle_x,seg.jrf.right_ankle_y,seg.jrf.right_ankle_z);

seg.jrf.lumbar = funcSumXYZ(seg.jrf.lumbar_x,seg.jrf.lumbar_y,seg.jrf.lumbar_z);

% jm
seg.jm.left_hip_flexion = jointMomentGlobal.Thigh_Left_proximal.x;
seg.jm.left_knee = jointMomentGlobal.Shank_Left_proximal.x;
seg.jm.left_ankle = jointMomentGlobal.Foot_Left_proximal.x;
seg.jm.right_hip_flexion = jointMomentGlobal.Thigh_Right_proximal.x;
seg.jm.right_knee = jointMomentGlobal.Shank_Right_proximal.x;
seg.jm.right_ankle = jointMomentGlobal.Foot_Right_proximal.x;
seg.jm.lumbar_extension = jointMomentGlobal.Trunk_Lower_proximal.x;

% 关节功率
seg.jp.left_hip = jointPower.hip_l;
seg.jp.left_knee = jointPower.knee_l;
seg.jp.left_ankle = jointPower.ankle_l;
seg.jp.right_hip = jointPower.hip_r;
seg.jp.right_knee = jointPower.knee_r;
seg.jp.right_ankle = jointPower.ankle_r;
seg.jp.lumbar = jointPower.lumbar;