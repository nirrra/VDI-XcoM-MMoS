function I = CalRotaryInertia(gender,weight,stream,posCOMSegments) 

%% 初始化

if gender == 'M'
    M.HeadNeck = 0.0694;
    M.Trunk = 0.4346;
    M.Upperarm = 0.0271;
    M.Forearm = 0.0162;
    M.Hand = 0.0061;
    M.Thigh = 0.1416;
    M.Shank = 0.0433;
    M.Foot = 0.0137;
elseif gender == 'F'
    M.HeadNeck = 0.0669;%为了将体重凑到100%
    M.Trunk = 0.4257;
    M.Upperarm = 0.0255;
    M.Forearm = 0.0138;
    M.Hand = 0.0056;
    M.Thigh = 0.1478;
    M.Shank = 0.0481;
    M.Foot = 0.0129;
end

%% 各体段长度

Segments_Length = Get_Segments_Length_Struct(stream);

%% 体段绕质心的转动惯量


% 转动惯量，分为3个方向，绕着Sagittal，Transverse，Longitudinal（长轴方向），一般分别指绕着Y，X，Z，
% 脚（Foot）除外，脚的Sagittal，Transverse，Longitudinal 指， Z，X，Y
Moment_of_Inertia.HeadNeck = zeros(3,3);
Moment_of_Inertia.Trunk = zeros(3,3);
Moment_of_Inertia.Upperarm = zeros(3,3);
Moment_of_Inertia.Forearm = zeros(3,3);
Moment_of_Inertia.Hand = zeros(3,3);
Moment_of_Inertia.Thigh = zeros(3,3);
Moment_of_Inertia.Shank = zeros(3,3);
Moment_of_Inertia.Foot = zeros(3,3);

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

I1 = struct();
names = fieldnames(Moment_of_Inertia);
for i = 1:length(names)
    I1.(names{i}) = weight*M.(names{i})*(Moment_of_Inertia.(names{i})(1,1)+Moment_of_Inertia.(names{i})(2,2)+Moment_of_Inertia.(names{i})(3,3));
end

%% 平移到原点

names = fieldnames(posCOMSegments);
I = zeros(length(stream.wtime),1);
for idxFrame = 1:length(stream.wtime)
    
    I2 = struct();
    for i = 1:length(names)-1
        nameLR = names{i};
        if contains(nameLR,'_')
            name = nameLR(1:strfind(nameLR,'_')-1);
        else
            name = nameLR;
        end

        I2.(nameLR) = weight*M.(name)*...
            (posCOMSegments.(nameLR).x(idxFrame)^2+posCOMSegments.(nameLR).y(idxFrame)^2+posCOMSegments.(nameLR).z(idxFrame)^2);
    
        I(idxFrame,1) = I(idxFrame,1)+I1.(name)+I2.(nameLR);
    end
    
end



