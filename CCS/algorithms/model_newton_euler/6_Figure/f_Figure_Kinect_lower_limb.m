function f_Figure_Kinect_lower_limb(joint_angles,gaitphase,color3)
% joint_angles,4*n



Thigh_length = 0.5;
Shank_length = 0.5;

HipLeft = [1,1];
%
%figure;

%% 坐标赋值

HipRight = HipLeft;
%
KneeLeft(1) = sin(joint_angles(1)/180*pi) * Thigh_length + HipLeft(1);
KneeLeft(2) = HipLeft(2) - cos(joint_angles(1)/180*pi) * Thigh_length;

KneeRight(1) = sin(joint_angles(2)/180*pi) * Thigh_length + HipRight(1);
KneeRight(2) = HipRight(2) - cos(joint_angles(2)/180*pi) * Thigh_length;

%
AnkleLeft(1) = cos((joint_angles(3) + 90 - joint_angles(1))/180*pi) * Shank_length + KneeLeft(1);
AnkleLeft(2) = KneeLeft(2) - sin((joint_angles(3) + 90 - joint_angles(1))/180*pi) * Shank_length ;

AnkleRight(1) = cos((joint_angles(4) + 90 - joint_angles(2))/180*pi) * Shank_length + KneeRight(1);
AnkleRight(2) = KneeRight(2) - sin((joint_angles(4) + 90 - joint_angles(2))/180*pi) * Shank_length ;


ThighLeft{1} = HipLeft;
ThighLeft{2} = KneeLeft;

ThighRight{1} = HipRight;
ThighRight{2} = KneeRight;

ShankLeft{1} = KneeLeft;
ShankLeft{2} = AnkleLeft;

ShankRight{1} = KneeRight;
ShankRight{2} = AnkleRight;

%% 绘图外壳
p= plot([ThighLeft{1}(1),ThighLeft{2}(1)],[ThighLeft{1}(2),ThighLeft{2}(2)],...
    [ThighRight{1}(1),ThighRight{2}(1)],[ThighRight{1}(2),ThighRight{2}(2)],...
    [ShankLeft{1}(1),ShankLeft{2}(1)],[ShankLeft{1}(2),ShankLeft{2}(2)],...
    [ShankRight{1}(1),ShankRight{2}(1)],[ShankRight{1}(2),ShankRight{2}(2)]);
%设置线条属性
LW = 3;
p(1).LineWidth=LW;%
p(1).Color=color3{2};

p(2).LineWidth=LW;%
p(2).Color=color3{3};

p(3).LineWidth=LW;%
p(3).Color=color3{2};
p(4).LineWidth=LW;%
p(4).Color=color3{3};


%hold on
title(gaitphase)
%% 绘制关节点
p1= plot([ThighLeft{1}(1),ThighLeft{2}(1)],[ThighLeft{1}(2),ThighLeft{2}(2)],'.',...
    [ThighRight{1}(1),ThighRight{2}(1)],[ThighRight{1}(2),ThighRight{2}(2)],'.',...
    [ShankLeft{1}(1),ShankLeft{2}(1)],[ShankLeft{1}(2),ShankLeft{2}(2)],'.',...
    [ShankRight{1}(1),ShankRight{2}(1)],[ShankRight{1}(2),ShankRight{2}(2)],'.');
%设置线条属性
MS = 15;
p1(1).MarkerSize=MS;
p1(1).Color=color3{1};

p1(2).MarkerSize=MS;
p1(2).Color=color3{3};

p1(3).MarkerSize=MS;
p1(3).Color=color3{1};
p1(4).MarkerSize=MS;
p1(4).Color=color3{3};

axis equal;


end
