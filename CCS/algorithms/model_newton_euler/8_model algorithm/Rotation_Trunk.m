%Trunk是该模型下 唯一的具有体积的刚体
%体段坐标系下的坐标点
function R = Rotation_Trunk(kinectstream)

segments_length = Get_Segments_Length_Struct(kinectstream);

% local_HIP_LEFT=[kinectstream.HIP_LEFT.x(1);kinectstream.HIP_LEFT.y(1);kinectstream.HIP_LEFT.z(1)];
% local_HIP_RIGHT=[kinectstream.HIP_RIGHT.x(1);kinectstream.HIP_RIGHT.y(1);kinectstream.HIP_RIGHT.z(1)];
% local_SHOULDER_LEFT=[kinectstream.SHOULDER_LEFT.x(1);kinectstream.SHOULDER_LEFT.y(1);kinectstream.SHOULDER_LEFT.z(1)];
% local_SHOULDER_RIGHT=[kinectstream.SHOULDER_RIGHT.x(1);kinectstream.SHOULDER_RIGHT.y(1);kinectstream.SHOULDER_RIGHT.z(1)];
% local_Trunk_Center=(local_HIP_LEFT+local_HIP_RIGHT+local_SHOULDER_LEFT+local_SHOULDER_RIGHT)/4;
% x1=local_HIP_LEFT-local_Trunk_Center;
% x2=local_HIP_RIGHT-local_Trunk_Center;
% x3=local_SHOULDER_LEFT-local_Trunk_Center;
% x4=local_SHOULDER_RIGHT-local_Trunk_Center;
x1 = [-segments_length.Pelvis / 2; 0; -segments_length.Trunk/2]; % 左下
x2 = [segments_length.Pelvis / 2; 0; -segments_length.Trunk/2]; % 右下
x3 = [-segments_length.Shoulders / 2; 0; segments_length.Trunk/2]; % 左上
x4 = [segments_length.Shoulders / 2; 0; segments_length.Trunk/2]; % 右上

local_Trunk = [x1,x2,x3,x4];
for i=1:length(kinectstream.wtime)

%全局坐标系坐标点
global_HIP_LEFT=[kinectstream.HIP_LEFT.x(i);kinectstream.HIP_LEFT.y(i);kinectstream.HIP_LEFT.z(i)];
global_HIP_RIGHT=[kinectstream.HIP_RIGHT.x(i);kinectstream.HIP_RIGHT.y(i);kinectstream.HIP_RIGHT.z(i)];
global_SHOULDER_LEFT=[kinectstream.SHOULDER_LEFT.x(i);kinectstream.SHOULDER_LEFT.y(i);kinectstream.SHOULDER_LEFT.z(i)];
global_SHOULDER_RIGHT=[kinectstream.SHOULDER_RIGHT.x(i);kinectstream.SHOULDER_RIGHT.y(i);kinectstream.SHOULDER_RIGHT.z(i)];
global_Trunk_Center=(global_HIP_LEFT+global_HIP_RIGHT+global_SHOULDER_LEFT+global_SHOULDER_RIGHT)/4;
y1=global_HIP_LEFT-global_Trunk_Center;
y2=global_HIP_RIGHT-global_Trunk_Center;
y3=global_SHOULDER_LEFT-global_Trunk_Center;
y4=global_SHOULDER_RIGHT-global_Trunk_Center;
global_Trunk=[y1,y2,y3,y4];

[U,S,V] = svd(local_Trunk*global_Trunk');
% V*U'的行列式可能为-1.即R可能求到的不是旋转矩阵而是反射矩阵，为此引入一个中间矩阵M
M = eye(3,3);
M(3,3) = det(V*U');
R{i}=V * M * U';%R可以表示全局坐标系到体段坐标系的转动，即体段在全局坐标系下的转动！！！！！！！！！！！
end
%t=global_Trunk-R*local_Trunk_Center;