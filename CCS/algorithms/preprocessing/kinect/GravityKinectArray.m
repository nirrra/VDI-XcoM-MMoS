%% FUNC GravityKinectArray：根据单帧的jointArray得到COM
function [xcom_human, ycom_human, zcom_human] = GravityKinectArray(jointArray, sex)
if sex == 'M'
    Lcs.HeadNeck = 0.5;
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
    Lcs.HeadNeck = 0.5;
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

com_human = ...
    (Lcs.HeadNeck * jointArray(2,:)  + (1-Lcs.HeadNeck) *  jointArray(19,:))  * M.HeadNeck + ...
    (Lcs.Trunk * (jointArray(11,:) + jointArray(15,:)) / 2  +...
    (1-Lcs.Trunk) *  (jointArray(3,:) + jointArray(7,:)) / 2)  * M.Trunk + ...
    (Lcs.Upperarm * jointArray(4,:)  + (1-Lcs.Upperarm) *  jointArray(3,:))  * M.Upperarm + ...
    (Lcs.Upperarm * jointArray(8,:)  + (1-Lcs.Upperarm) *  jointArray(7,:))  * M.Upperarm + ...
    (Lcs.Forearm * jointArray(5,:)  + (1-Lcs.Forearm) *  jointArray(4,:))  * M.Forearm + ...
    (Lcs.Forearm * jointArray(9,:)  + (1-Lcs.Forearm) *  jointArray(8,:))  * M.Forearm + ...
    (Lcs.Thigh * jointArray(12,:)  + (1-Lcs.Thigh) *  jointArray(11,:))  * M.Thigh + ...
    (Lcs.Thigh * jointArray(16,:)  + (1-Lcs.Thigh) *  jointArray(15,:))  * M.Thigh + ...
    (Lcs.Shank * jointArray(13,:)  + (1-Lcs.Shank) *  jointArray(12,:))  * M.Shank + ...
    (Lcs.Shank * jointArray(17,:)  + (1-Lcs.Shank) *  jointArray(16,:))  * M.Shank + ...
    (Lcs.Hand * jointArray(6,:)  + (1-Lcs.Hand) *  jointArray(5,:))  * M.Hand + ...
    (Lcs.Hand * jointArray(10,:)  + (1-Lcs.Hand) *  jointArray(9,:))  * M.Hand + ...
    (Lcs.Foot * jointArray(14,:)  + (1-Lcs.Foot) *  jointArray(13,:))  * M.Foot +...
    (Lcs.Foot * jointArray(18,:)  + (1-Lcs.Foot) *  jointArray(17,:))  * M.Foot;

xcom_human = com_human(1);
ycom_human = com_human(2);
zcom_human = com_human(3);
end