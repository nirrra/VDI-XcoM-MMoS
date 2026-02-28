%% FUNC GravityKinectAzure：根据stream得到COM
% COM方向（面向人体时，相对于人体）：X向左，Y向下，Z向后，单位m
function [xcom_human, ycom_human, zcom_human] = GravityKinectAzure(kinectstream, sex)
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

%头颈段
xcom_HeadNeck = (Lcs.HeadNeck * (kinectstream.HEAD.x - kinectstream.NECK.x) + kinectstream.NECK.x) * M.HeadNeck;
ycom_HeadNeck = (Lcs.HeadNeck * (kinectstream.HEAD.y - kinectstream.NECK.y) + kinectstream.NECK.y) * M.HeadNeck;
zcom_HeadNeck = (Lcs.HeadNeck * (kinectstream.HEAD.z - kinectstream.NECK.z) + kinectstream.NECK.z) * M.HeadNeck;

%躯干
xcom_Trunk = (Lcs.Trunk * ((kinectstream.HIP_LEFT.x + kinectstream.HIP_RIGHT.x)/2 - (kinectstream.SHOULDER_LEFT.x...
    +kinectstream.SHOULDER_RIGHT.x)/2)+ (kinectstream.SHOULDER_LEFT.x + kinectstream.SHOULDER_RIGHT.x)/2) * M.Trunk;
ycom_Trunk = (Lcs.Trunk * ((kinectstream.HIP_LEFT.y + kinectstream.HIP_RIGHT.y)/2 - (kinectstream.SHOULDER_LEFT.y...
    +kinectstream.SHOULDER_RIGHT.y)/2)+ (kinectstream.SHOULDER_LEFT.y + kinectstream.SHOULDER_RIGHT.y)/2) * M.Trunk;
zcom_Trunk = (Lcs.Trunk * ((kinectstream.HIP_LEFT.z + kinectstream.HIP_RIGHT.z)/2 - (kinectstream.SHOULDER_LEFT.z...
    +kinectstream.SHOULDER_RIGHT.z)/2)+ (kinectstream.SHOULDER_LEFT.z + kinectstream.SHOULDER_RIGHT.z)/2) * M.Trunk;

%上臂
 %左上臂
xcom_Upperarm_Left = (Lcs.Upperarm * (kinectstream.ELBOW_LEFT.x - kinectstream.SHOULDER_LEFT.x) + kinectstream.SHOULDER_LEFT.x) * M.Upperarm;
ycom_Upperarm_Left = (Lcs.Upperarm * (kinectstream.ELBOW_LEFT.y - kinectstream.SHOULDER_LEFT.y) + kinectstream.SHOULDER_LEFT.y) * M.Upperarm;
zcom_Upperarm_Left = (Lcs.Upperarm * (kinectstream.ELBOW_LEFT.z - kinectstream.SHOULDER_LEFT.z) + kinectstream.SHOULDER_LEFT.z) * M.Upperarm;
 %右上臂
xcom_Upperarm_Right = (Lcs.Upperarm * (kinectstream.ELBOW_RIGHT.x - kinectstream.SHOULDER_RIGHT.x) + kinectstream.SHOULDER_RIGHT.x) * M.Upperarm;
ycom_Upperarm_Right = (Lcs.Upperarm * (kinectstream.ELBOW_RIGHT.y - kinectstream.SHOULDER_RIGHT.y) + kinectstream.SHOULDER_RIGHT.y) * M.Upperarm;
zcom_Upperarm_Right = (Lcs.Upperarm * (kinectstream.ELBOW_RIGHT.z - kinectstream.SHOULDER_RIGHT.z) + kinectstream.SHOULDER_RIGHT.z) * M.Upperarm;

%前臂
 %左前臂
xcom_Forearm_Left = (Lcs.Forearm * (kinectstream.WRIST_LEFT.x - kinectstream.ELBOW_LEFT.x) + kinectstream.ELBOW_LEFT.x) * M.Forearm;
ycom_Forearm_Left = (Lcs.Forearm * (kinectstream.WRIST_LEFT.y - kinectstream.ELBOW_LEFT.y) + kinectstream.ELBOW_LEFT.y) * M.Forearm;
zcom_Forearm_Left = (Lcs.Forearm * (kinectstream.WRIST_LEFT.z - kinectstream.ELBOW_LEFT.z) + kinectstream.ELBOW_LEFT.z) * M.Forearm;
 %右前臂
xcom_Forearm_Right = (Lcs.Forearm * (kinectstream.WRIST_RIGHT.x - kinectstream.ELBOW_RIGHT.x) + kinectstream.ELBOW_RIGHT.x) * M.Forearm;
ycom_Forearm_Right = (Lcs.Forearm * (kinectstream.WRIST_RIGHT.y - kinectstream.ELBOW_RIGHT.y) + kinectstream.ELBOW_RIGHT.y) * M.Forearm;
zcom_Forearm_Right = (Lcs.Forearm * (kinectstream.WRIST_RIGHT.z - kinectstream.ELBOW_RIGHT.z) + kinectstream.ELBOW_RIGHT.z) * M.Forearm;

%手掌
%左手掌
xcom_Hand_Left = (Lcs.Hand * (kinectstream.HAND_LEFT.x - kinectstream.WRIST_LEFT.x) + kinectstream.WRIST_LEFT.x) * M.Hand;
ycom_Hand_Left = (Lcs.Hand * (kinectstream.HAND_LEFT.y - kinectstream.WRIST_LEFT.y) + kinectstream.WRIST_LEFT.y) * M.Hand;
zcom_Hand_Left = (Lcs.Hand * (kinectstream.HAND_LEFT.z - kinectstream.WRIST_LEFT.z) + kinectstream.WRIST_LEFT.z) * M.Hand;
%右手掌
xcom_Hand_Right = (Lcs.Hand * (kinectstream.HAND_RIGHT.x - kinectstream.WRIST_RIGHT.x) + kinectstream.WRIST_RIGHT.x) * M.Hand;
ycom_Hand_Right = (Lcs.Hand * (kinectstream.HAND_RIGHT.y - kinectstream.WRIST_RIGHT.y) + kinectstream.WRIST_RIGHT.y) * M.Hand;
zcom_Hand_Right = (Lcs.Hand * (kinectstream.HAND_RIGHT.z - kinectstream.WRIST_RIGHT.z) + kinectstream.WRIST_RIGHT.z) * M.Hand;

%大腿 
 %左大腿
xcom_Thigh_Left = (Lcs.Thigh * (kinectstream.KNEE_LEFT.x - kinectstream.HIP_LEFT.x) + kinectstream.HIP_LEFT.x) * M.Thigh;
ycom_Thigh_Left = (Lcs.Thigh * (kinectstream.KNEE_LEFT.y - kinectstream.HIP_LEFT.y) + kinectstream.HIP_LEFT.y) * M.Thigh;
zcom_Thigh_Left = (Lcs.Thigh * (kinectstream.KNEE_LEFT.z - kinectstream.HIP_LEFT.z) + kinectstream.HIP_LEFT.z) * M.Thigh;
 %右大腿
xcom_Thigh_Right = (Lcs.Thigh * (kinectstream.KNEE_RIGHT.x - kinectstream.HIP_RIGHT.x) + kinectstream.HIP_RIGHT.x) * M.Thigh;
ycom_Thigh_Right = (Lcs.Thigh * (kinectstream.KNEE_RIGHT.y - kinectstream.HIP_RIGHT.y) + kinectstream.HIP_RIGHT.y) * M.Thigh;
zcom_Thigh_Right = (Lcs.Thigh * (kinectstream.KNEE_RIGHT.z - kinectstream.HIP_RIGHT.z) + kinectstream.HIP_RIGHT.z) * M.Thigh;

%小腿
 %左小腿
xcom_Shank_Left = (Lcs.Shank * (kinectstream.ANKLE_LEFT.x - kinectstream.KNEE_LEFT.x) + kinectstream.KNEE_LEFT.x) * M.Shank;
ycom_Shank_Left = (Lcs.Shank * (kinectstream.ANKLE_LEFT.y - kinectstream.KNEE_LEFT.y) + kinectstream.KNEE_LEFT.y) * M.Shank;
zcom_Shank_Left = (Lcs.Shank * (kinectstream.ANKLE_LEFT.z - kinectstream.KNEE_LEFT.z) + kinectstream.KNEE_LEFT.z) * M.Shank;
 %右小腿
xcom_Shank_Right = (Lcs.Shank * (kinectstream.ANKLE_RIGHT.x - kinectstream.KNEE_RIGHT.x) + kinectstream.KNEE_RIGHT.x) * M.Shank;
ycom_Shank_Right = (Lcs.Shank * (kinectstream.ANKLE_RIGHT.y - kinectstream.KNEE_RIGHT.y) + kinectstream.KNEE_RIGHT.y) * M.Shank;
zcom_Shank_Right = (Lcs.Shank * (kinectstream.ANKLE_RIGHT.z - kinectstream.KNEE_RIGHT.z) + kinectstream.KNEE_RIGHT.z) * M.Shank;


%足
 %左足
xcom_Foot_Left = (Lcs.Foot * (kinectstream.FOOT_LEFT.x - kinectstream.ANKLE_LEFT.x) +  kinectstream.ANKLE_LEFT.x)* M.Foot;
ycom_Foot_Left = (Lcs.Foot * (kinectstream.FOOT_LEFT.y - kinectstream.ANKLE_LEFT.y) +  kinectstream.ANKLE_LEFT.y)* M.Foot;
zcom_Foot_Left = (Lcs.Foot * (kinectstream.FOOT_LEFT.z - kinectstream.ANKLE_LEFT.z) +  kinectstream.ANKLE_LEFT.z)* M.Foot;
 %右足
xcom_Foot_Right = (Lcs.Foot * (kinectstream.FOOT_RIGHT.x - kinectstream.ANKLE_RIGHT.x) +  kinectstream.ANKLE_RIGHT.x)* M.Foot;
ycom_Foot_Right = (Lcs.Foot * (kinectstream.FOOT_RIGHT.y - kinectstream.ANKLE_RIGHT.y) +  kinectstream.ANKLE_RIGHT.y)* M.Foot;
zcom_Foot_Right = (Lcs.Foot * (kinectstream.FOOT_RIGHT.z - kinectstream.ANKLE_RIGHT.z) +  kinectstream.ANKLE_RIGHT.z)* M.Foot;

%% 求解总体线质心位置
xcom_human = xcom_HeadNeck + xcom_Trunk + xcom_Upperarm_Left + xcom_Upperarm_Right + xcom_Forearm_Left + xcom_Forearm_Right...
    + xcom_Hand_Left + xcom_Hand_Right + xcom_Thigh_Left + xcom_Thigh_Right + xcom_Shank_Left + xcom_Shank_Right...
    + xcom_Foot_Left + xcom_Foot_Right;

ycom_human = ycom_HeadNeck + ycom_Trunk + ycom_Upperarm_Left + ycom_Upperarm_Right + ycom_Forearm_Left + ycom_Forearm_Right...
    + ycom_Hand_Left + ycom_Hand_Right + ycom_Thigh_Left + ycom_Thigh_Right + ycom_Shank_Left + ycom_Shank_Right...
    + ycom_Foot_Left + ycom_Foot_Right;

zcom_human = zcom_HeadNeck + zcom_Trunk + zcom_Upperarm_Left + zcom_Upperarm_Right + zcom_Forearm_Left + zcom_Forearm_Right...
    + zcom_Hand_Left + zcom_Hand_Right + zcom_Thigh_Left + zcom_Thigh_Right + zcom_Shank_Left + zcom_Shank_Right...
    + zcom_Foot_Left + zcom_Foot_Right;

end