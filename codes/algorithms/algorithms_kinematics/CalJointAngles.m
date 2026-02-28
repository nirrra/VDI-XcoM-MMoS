function [jointAngles] = CalJointAngles(stream)
% 膝关节角度，越小表示膝盖向后屈曲
[kneeAngleL,~] = CalKinectJointAngle(stream.ANKLE_LEFT,stream.KNEE_LEFT,stream.HIP_LEFT);
[kneeAngleR,~] = CalKinectJointAngle(stream.ANKLE_RIGHT,stream.KNEE_RIGHT,stream.HIP_RIGHT);
kneeAngleL = kneeAngleL-180; kneeAngleR = kneeAngleR-180; % 变为OpenSim角度
% 踝关节角度，越大表示背屈（向上）
% [ankleAngleL,~] = CalKinectAnkleAngle(stream.KNEE_LEFT,stream.ANKLE_LEFT,stream.FOOT_LEFT);
% [ankleAngleR,~] = CalKinectAnkleAngle(stream.KNEE_RIGHT,stream.ANKLE_RIGHT,stream.FOOT_RIGHT);
[ankleAngleL,~] = CalKinectJointAngle(stream.KNEE_LEFT,stream.ANKLE_LEFT,stream.FOOT_LEFT);
[ankleAngleR,~] = CalKinectJointAngle(stream.KNEE_RIGHT,stream.ANKLE_RIGHT,stream.FOOT_RIGHT);
ankleAngleL = 100-ankleAngleL; ankleAngleR = 100-ankleAngleR; % 变为OpenSim角度
% 髋关节角度，越大表示屈曲（抬腿）
[~,hipFlexionL] = CalKinectJointAngle(stream.SPINE_NAVAL,stream.HIP_LEFT,stream.KNEE_LEFT);
[~,hipFlexionR] = CalKinectJointAngle(stream.SPINE_NAVAL,stream.HIP_RIGHT,stream.KNEE_RIGHT);
hipFlexionL = hipFlexionL{1}; hipFlexionR = hipFlexionR{1};
hipFlexionL = 170-hipFlexionL; hipFlexionR = 170-hipFlexionR; % 变为OpenSim角度

hipFlexionL = 30+hipFlexionL; hipFlexionR = 30+hipFlexionR; % 修正 +30度

% 腰椎角度，越大表示伸展，越小表示屈曲
[lumbarFlexion,~] = CalKinectJointAngle(stream.SPINE_CHEST,stream.SPINE_NAVAL,stream.PELVIS);
lumbarFlexion = lumbarFlexion-190;

jointAngles = struct('kneeAngleL',kneeAngleL,'kneeAngleR',kneeAngleR,'ankleAngleL',ankleAngleL,'ankleAngleR',ankleAngleR,...
    'hipFlexionL',hipFlexionL,'hipFlexionR',hipFlexionR,'lumbarFlexion',lumbarFlexion);