function [xcom_human, ycom_human, zcom_human] = Gravity_Kinectarray(joints_position_model, sex)

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
    (Lcs.HeadNeck * joints_position_model(2,:)  + (1-Lcs.HeadNeck) *  joints_position_model(19,:))  * M.HeadNeck + ...
    (Lcs.Trunk * (joints_position_model(11,:) + joints_position_model(15,:)) / 2  +...
    (1-Lcs.Trunk) *  (joints_position_model(3,:) + joints_position_model(7,:)) / 2)  * M.Trunk + ...
    (Lcs.Upperarm * joints_position_model(4,:)  + (1-Lcs.Upperarm) *  joints_position_model(3,:))  * M.Upperarm + ...
    (Lcs.Upperarm * joints_position_model(8,:)  + (1-Lcs.Upperarm) *  joints_position_model(7,:))  * M.Upperarm + ...
    (Lcs.Forearm * joints_position_model(5,:)  + (1-Lcs.Forearm) *  joints_position_model(4,:))  * M.Forearm + ...
    (Lcs.Forearm * joints_position_model(9,:)  + (1-Lcs.Forearm) *  joints_position_model(8,:))  * M.Forearm + ...
    (Lcs.Thigh * joints_position_model(12,:)  + (1-Lcs.Thigh) *  joints_position_model(11,:))  * M.Thigh + ...
    (Lcs.Thigh * joints_position_model(16,:)  + (1-Lcs.Thigh) *  joints_position_model(15,:))  * M.Thigh + ...
    (Lcs.Shank * joints_position_model(13,:)  + (1-Lcs.Shank) *  joints_position_model(12,:))  * M.Shank + ...
    (Lcs.Shank * joints_position_model(17,:)  + (1-Lcs.Shank) *  joints_position_model(16,:))  * M.Shank + ...
    (Lcs.Hand * joints_position_model(6,:)  + (1-Lcs.Hand) *  joints_position_model(5,:))  * M.Hand + ...
    (Lcs.Hand * joints_position_model(10,:)  + (1-Lcs.Hand) *  joints_position_model(9,:))  * M.Hand + ...
    (Lcs.Foot * joints_position_model(14,:)  + (1-Lcs.Foot) *  joints_position_model(13,:))  * M.Foot +...
    (Lcs.Foot * joints_position_model(18,:)  + (1-Lcs.Foot) *  joints_position_model(17,:))  * M.Foot;

xcom_human = com_human(1);
ycom_human = com_human(2);
zcom_human = com_human(3);
end