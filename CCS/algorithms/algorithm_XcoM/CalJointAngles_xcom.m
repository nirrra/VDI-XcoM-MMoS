function [jointAngles] = CalJointAngles_xcom(stream, flagfromRM)
% x: sagittal (矢状面): 屈曲/伸展 (flexion/extension)
% y: frontal (冠状面): 内收/外展 (adduction/abduction) 或 侧屈 (lateral flexion)
% z: transverse (横断面): 内旋/外旋 (internal/external rotation) 或 旋转 (rotation)
if nargin<2
    flagfromRM = false;
end

if flagfromRM
    jointAngles = CalJointAngles_segments_RM(stream);
else
    % 膝关节角度
    [~,aux] = CalKinectJointAngle(stream.ANKLE_LEFT,stream.KNEE_LEFT,stream.HIP_LEFT);
    knee_left.x = aux{1}; knee_left.y = aux{2}; knee_left.z = aux{3};
    [~,aux] = CalKinectJointAngle(stream.ANKLE_RIGHT,stream.KNEE_RIGHT,stream.HIP_RIGHT);
    knee_right.x = aux{1}; knee_right.y = aux{2}; knee_right.z = aux{3};
    % kneeAngleL = kneeAngleL-180; kneeAngleR = kneeAngleR-180; % 变为OpenSim角度
    % 踝关节角度
    [~,aux] = CalKinectJointAngle(stream.KNEE_LEFT,stream.ANKLE_LEFT,stream.FOOT_LEFT);
    ankle_left.x = aux{1}; ankle_left.y = aux{2}; ankle_left.z = aux{3};
    [~,aux] = CalKinectJointAngle(stream.KNEE_RIGHT,stream.ANKLE_RIGHT,stream.FOOT_RIGHT);
    ankle_right.x = aux{1}; ankle_right.y = aux{2}; ankle_right.z = aux{3};
    % ankleAngleL = 100-ankleAngleL; ankleAngleR = 100-ankleAngleR; % 变为OpenSim角度
    % 髋关节角度
    [~,aux] = CalKinectJointAngle(stream.SPINE_NAVAL,stream.HIP_LEFT,stream.KNEE_LEFT);
    hip_left.x = aux{1}; hip_left.y = aux{2}; hip_left.z = aux{3};
    [~,aux] = CalKinectJointAngle(stream.SPINE_NAVAL,stream.HIP_RIGHT,stream.KNEE_RIGHT);
    hip_right.x = aux{1}; hip_right.y = aux{2}; hip_right.z = aux{3};
    % hipFlexionL = 170-hipFlexionL; hipFlexionR = 170-hipFlexionR; % 变为OpenSim角度
    
    % hipFlexionL = 30+hipFlexionL; hipFlexionR = 30+hipFlexionR; % 修正 +30度
    
    % 腰椎角度
    [~,aux] = CalKinectJointAngle(stream.SPINE_CHEST,stream.SPINE_NAVAL,stream.PELVIS);
    lumbar.x = aux{1}; lumbar.y = aux{2}; lumbar.z = aux{3};
    % lumbarFlexion = lumbarFlexion-190;
    
    jointAngles = struct('knee_left',knee_left,'knee_right',knee_right,...
        'ankle_left',ankle_left,'ankle_right',ankle_right,...
        'hip_left',hip_left,'hip_right',hip_right,...
        'lumbar',lumbar);
end
