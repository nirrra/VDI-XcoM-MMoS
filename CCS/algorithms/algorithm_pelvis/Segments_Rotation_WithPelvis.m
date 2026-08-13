% 求局部坐标系到全局坐标系的旋转矩阵
function [r_all_segments, origin_segments] = Segments_Rotation_WithPelvis(kinectstream)
% 足部：原点为ANKLE，Y轴：ANKLE→FOOT
% 小腿：原点为ANKLE，Z轴：ANKLE→KNEE
% 大腿：原点为KNEE，Z轴：KNEE→HIP
% 骨盆，原点为Pelvis，X轴：HIP_LEFT→HIP_RIGHT；Z轴：mean(HIP_LEFT,HIP_RIGHT)→PELVIS
% 躯干，原点为SPINE_NAVAL，Z轴：SPINE_NAVAL→SPINE_CHEST
% 头颈：原点为NECK，Z轴：NECK→HEAD

%% 头颈
global_vector_HeadNeck      = [kinectstream.HEAD.x, kinectstream.HEAD.y, kinectstream.HEAD.z]...
    - [kinectstream.NECK.x, kinectstream.NECK.y, kinectstream.NECK.z];
origin_segments.HeadNeck = [kinectstream.NECK.x, kinectstream.NECK.y, kinectstream.NECK.z];

%% 左侧肢体
global_vector_Upperarm_Left = [kinectstream.ELBOW_LEFT.x, kinectstream.ELBOW_LEFT.y, kinectstream.ELBOW_LEFT.z]...
    - [kinectstream.SHOULDER_LEFT.x, kinectstream.SHOULDER_LEFT.y, kinectstream.SHOULDER_LEFT.z];
origin_segments.Upperarm_Left = [kinectstream.SHOULDER_LEFT.x, kinectstream.SHOULDER_LEFT.y, kinectstream.SHOULDER_LEFT.z];

global_vector_Forearm_Left  = [kinectstream.WRIST_LEFT.x, kinectstream.WRIST_LEFT.y, kinectstream.WRIST_LEFT.z]...
    - [kinectstream.ELBOW_LEFT.x, kinectstream.ELBOW_LEFT.y, kinectstream.ELBOW_LEFT.z];
origin_segments.Forearm_Left = [kinectstream.ELBOW_LEFT.x, kinectstream.ELBOW_LEFT.y, kinectstream.ELBOW_LEFT.z];

global_vector_Hand_Left     = [kinectstream.HAND_LEFT.x, kinectstream.HAND_LEFT.y, kinectstream.HAND_LEFT.z]...
    - [kinectstream.WRIST_LEFT.x, kinectstream.WRIST_LEFT.y, kinectstream.WRIST_LEFT.z];
origin_segments.Hand_Left = [kinectstream.WRIST_LEFT.x, kinectstream.WRIST_LEFT.y, kinectstream.WRIST_LEFT.z];

global_vector_Thigh_Left    = [kinectstream.KNEE_LEFT.x, kinectstream.KNEE_LEFT.y, kinectstream.KNEE_LEFT.z]...
    - [kinectstream.HIP_LEFT.x, kinectstream.HIP_LEFT.y, kinectstream.HIP_LEFT.z];
origin_segments.Thigh_Left = [kinectstream.KNEE_LEFT.x, kinectstream.KNEE_LEFT.y, kinectstream.KNEE_LEFT.z];

global_vector_Shank_Left    = [kinectstream.ANKLE_LEFT.x, kinectstream.ANKLE_LEFT.y, kinectstream.ANKLE_LEFT.z]...
    - [kinectstream.KNEE_LEFT.x, kinectstream.KNEE_LEFT.y, kinectstream.KNEE_LEFT.z];
origin_segments.Shank_Left = [kinectstream.ANKLE_LEFT.x, kinectstream.ANKLE_LEFT.y, kinectstream.ANKLE_LEFT.z];

global_vector_Foot_Left     = [kinectstream.FOOT_LEFT.x, kinectstream.FOOT_LEFT.y, kinectstream.FOOT_LEFT.z]...
    - [kinectstream.ANKLE_LEFT.x, kinectstream.ANKLE_LEFT.y, kinectstream.ANKLE_LEFT.z];
origin_segments.Foot_Left = [kinectstream.ANKLE_LEFT.x, kinectstream.ANKLE_LEFT.y, kinectstream.ANKLE_LEFT.z];

%% 右侧肢体
global_vector_Upperarm_Right = [kinectstream.ELBOW_RIGHT.x, kinectstream.ELBOW_RIGHT.y, kinectstream.ELBOW_RIGHT.z]...
    - [kinectstream.SHOULDER_RIGHT.x, kinectstream.SHOULDER_RIGHT.y, kinectstream.SHOULDER_RIGHT.z];
origin_segments.Upperarm_Right = [kinectstream.SHOULDER_RIGHT.x, kinectstream.SHOULDER_RIGHT.y, kinectstream.SHOULDER_RIGHT.z];

global_vector_Forearm_Right  = [kinectstream.WRIST_RIGHT.x, kinectstream.WRIST_RIGHT.y, kinectstream.WRIST_RIGHT.z]...
    - [kinectstream.ELBOW_RIGHT.x, kinectstream.ELBOW_RIGHT.y, kinectstream.ELBOW_RIGHT.z];
origin_segments.Forearm_Right = [kinectstream.ELBOW_RIGHT.x, kinectstream.ELBOW_RIGHT.y, kinectstream.ELBOW_RIGHT.z];

global_vector_Hand_Right     = [kinectstream.HAND_RIGHT.x, kinectstream.HAND_RIGHT.y, kinectstream.HAND_RIGHT.z]...
    - [kinectstream.WRIST_RIGHT.x, kinectstream.WRIST_RIGHT.y, kinectstream.WRIST_RIGHT.z];
origin_segments.Hand_Right = [kinectstream.WRIST_RIGHT.x, kinectstream.WRIST_RIGHT.y, kinectstream.WRIST_RIGHT.z];

global_vector_Thigh_Right    = [kinectstream.KNEE_RIGHT.x, kinectstream.KNEE_RIGHT.y, kinectstream.KNEE_RIGHT.z]...
    - [kinectstream.HIP_RIGHT.x, kinectstream.HIP_RIGHT.y, kinectstream.HIP_RIGHT.z];
origin_segments.Thigh_Right = [kinectstream.KNEE_RIGHT.x, kinectstream.KNEE_RIGHT.y, kinectstream.KNEE_RIGHT.z];

global_vector_Shank_Right    = [kinectstream.ANKLE_RIGHT.x, kinectstream.ANKLE_RIGHT.y, kinectstream.ANKLE_RIGHT.z]...
    - [kinectstream.KNEE_RIGHT.x, kinectstream.KNEE_RIGHT.y, kinectstream.KNEE_RIGHT.z];
origin_segments.Shank_Right = [kinectstream.ANKLE_RIGHT.x, kinectstream.ANKLE_RIGHT.y, kinectstream.ANKLE_RIGHT.z];

global_vector_Foot_Right     = [kinectstream.FOOT_RIGHT.x, kinectstream.FOOT_RIGHT.y, kinectstream.FOOT_RIGHT.z]...
    - [kinectstream.ANKLE_RIGHT.x, kinectstream.ANKLE_RIGHT.y, kinectstream.ANKLE_RIGHT.z];
origin_segments.Foot_Right = [kinectstream.ANKLE_RIGHT.x, kinectstream.ANKLE_RIGHT.y, kinectstream.ANKLE_RIGHT.z];


%% 体段坐标系到全局坐标系的旋转矩阵
for i = 1:length(kinectstream.wtime)
%     r_HeadNeck{i} =  vrrotvec2mat(vrrotvec([0 0 1],global_vector_HeadNeck(i,:) ));
    % 左侧体段
    r_Upperarm_Left{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Upperarm_Left(i,:)));

    r_Forearm_Left{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Forearm_Left(i,:)));

    r_Hand_Left{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Hand_Left(i,:)));

%     r_Thigh_Left{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Thigh_Left(i,:)));
% 
%     r_Shank_Left{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Shank_Left(i,:)));
% 
%     r_Foot_Left{i} = vrrotvec2mat(vrrotvec([0 1 0],global_vector_Foot_Left(i,:)));

    % 右侧体段
    r_Upperarm_Right{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Upperarm_Right(i,:)));

    r_Forearm_Right{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Forearm_Right(i,:)));

    r_Hand_Right{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Hand_Right(i,:)));

%     r_Thigh_Right{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Thigh_Right(i,:)));
% 
%     r_Shank_Right{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Shank_Right(i,:)));
% 
%     r_Foot_Right{i} = vrrotvec2mat(vrrotvec([0 1 0],global_vector_Foot_Right(i,:)));
end

%% 骨盆
local_vec = [[1,0,0]',[0,0,1]'];
for i = 1:length(kinectstream.wtime)
%     a_x = [kinectstream.HIP_RIGHT.x(i);kinectstream.HIP_RIGHT.y(i);kinectstream.HIP_RIGHT.z(i)]-...
%         [kinectstream.HIP_LEFT.x(i);kinectstream.HIP_LEFT.y(i);kinectstream.HIP_LEFT.z(i)];
%     a_z =[kinectstream.SPINE_NAVAL.x(i);kinectstream.SPINE_NAVAL.y(i);kinectstream.SPINE_NAVAL.z(i)]-...
%         [kinectstream.PELVIS.x(i);kinectstream.PELVIS.y(i);kinectstream.PELVIS.z(i)];
%     global_vec = zeros(3,2);
%     global_vec(:,1) = a_x;
%     global_vec(:,2) = a_z;
% 
%     [U,S,V] = svd(local_vec*global_vec');
%     % V*U'的行列式可能为-1.即R可能求到的不是旋转矩阵而是反射矩阵，为此引入一个中间矩阵M
%     M = eye(3,3);
%     M(3,3) = det(V*U');
%     r_Pelvis{i}=V * M * U'; %R可以表示体段坐标系到全局坐标系的转动

    % 只采用x轴
    r_Pelvis{i} = vrrotvec2mat(vrrotvec([1 0 0],[kinectstream.HIP_RIGHT.x(i);kinectstream.HIP_RIGHT.y(i);kinectstream.HIP_RIGHT.z(i)]-...
        [kinectstream.HIP_LEFT.x(i);kinectstream.HIP_LEFT.y(i);kinectstream.HIP_LEFT.z(i)]));
end
origin_segments.Pelvis = [kinectstream.PELVIS.x, kinectstream.PELVIS.y, kinectstream.PELVIS.z];

%% 躯干
local_vec = [[1,0,0]',[0,0,1]'];
for i = 1:length(kinectstream.wtime)
    a_x = [kinectstream.SHOULDER_RIGHT.x(i);kinectstream.SHOULDER_RIGHT.y(i);kinectstream.SHOULDER_RIGHT.z(i)]-...
        [kinectstream.SHOULDER_LEFT.x(i);kinectstream.SHOULDER_LEFT.y(i);kinectstream.SHOULDER_LEFT.z(i)]+...
        [kinectstream.CLAVICLE_RIGHT.x(i);kinectstream.CLAVICLE_RIGHT.y(i);kinectstream.CLAVICLE_RIGHT.z(i)]-...
        [kinectstream.CLAVICLE_LEFT.x(i);kinectstream.CLAVICLE_LEFT.y(i);kinectstream.CLAVICLE_LEFT.z(i)];
    a_z = [kinectstream.SPINE_CHEST.x(i);kinectstream.SPINE_CHEST.y(i);kinectstream.SPINE_CHEST.z(i)]-...
    [kinectstream.SPINE_NAVAL.x(i);kinectstream.SPINE_NAVAL.y(i);kinectstream.SPINE_NAVAL.z(i)];
    global_vec = zeros(3,2);
    global_vec(:,1) = a_x;
    global_vec(:,2) = a_z;

    [U,S,V] = svd(local_vec*global_vec');
    % V*U'的行列式可能为-1.即R可能求到的不是旋转矩阵而是反射矩阵，为此引入一个中间矩阵M
    M = eye(3,3);
    M(3,3) = det(V*U');
    r_Trunk{i}=V * M * U'; %R可以表示体段坐标系到全局坐标系的转动
end
origin_segments.Trunk = [kinectstream.SPINE_NAVAL.x, kinectstream.SPINE_NAVAL.y, kinectstream.SPINE_NAVAL.z];

%% 其他部位
%% 头颈
local_vec = [[1,0,0]',[0,0,1]'];
for i = 1:length(kinectstream.wtime)
    a_z = [kinectstream.HEAD.x(i);kinectstream.HEAD.y(i);kinectstream.HEAD.z(i)]-...
        [kinectstream.NECK.x(i);kinectstream.NECK.y(i);kinectstream.NECK.z(i)];
    a_x = closest_orthogonal(a_z,[1,0,0]');
    global_vec = zeros(3,2);
    global_vec(:,1) = a_x;
    global_vec(:,2) = a_z;

    [U,S,V] = svd(local_vec*global_vec');
    % V*U'的行列式可能为-1.即R可能求到的不是旋转矩阵而是反射矩阵，为此引入一个中间矩阵M
    M = eye(3,3);
    M(3,3) = det(V*U');
    r_HeadNeck{i}=V * M * U'; %R可以表示体段坐标系到全局坐标系的转动
end
%% 大腿
local_vec = [[1,0,0]',[0,0,-1]'];
for i = 1:length(kinectstream.wtime)
    a_z = [kinectstream.KNEE_LEFT.x(i);kinectstream.KNEE_LEFT.y(i);kinectstream.KNEE_LEFT.z(i)]-...
        [kinectstream.HIP_LEFT.x(i);kinectstream.HIP_LEFT.y(i);kinectstream.HIP_LEFT.z(i)];
    a_x = closest_orthogonal(a_z,[1,0,0]');
    global_vec = zeros(3,2);
    global_vec(:,1) = a_x;
    global_vec(:,2) = a_z;

    [U,S,V] = svd(local_vec*global_vec');
    % V*U'的行列式可能为-1.即R可能求到的不是旋转矩阵而是反射矩阵，为此引入一个中间矩阵M
    M = eye(3,3);
    M(3,3) = det(V*U');
    r_Thigh_Left{i}=V * M * U'; %R可以表示体段坐标系到全局坐标系的转动
end

local_vec = [[1,0,0]',[0,0,-1]'];
for i = 1:length(kinectstream.wtime)
    a_z = [kinectstream.KNEE_RIGHT.x(i);kinectstream.KNEE_RIGHT.y(i);kinectstream.KNEE_RIGHT.z(i)]-...
        [kinectstream.HIP_RIGHT.x(i);kinectstream.HIP_RIGHT.y(i);kinectstream.HIP_RIGHT.z(i)];
    a_x = closest_orthogonal(a_z,[1,0,0]');
    global_vec = zeros(3,2);
    global_vec(:,1) = a_x;
    global_vec(:,2) = a_z;

    [U,S,V] = svd(local_vec*global_vec');
    % V*U'的行列式可能为-1.即R可能求到的不是旋转矩阵而是反射矩阵，为此引入一个中间矩阵M
    M = eye(3,3);
    M(3,3) = det(V*U');
    r_Thigh_Right{i}=V * M * U'; %R可以表示体段坐标系到全局坐标系的转动
end
%% 小腿
local_vec = [[1,0,0]',[0,0,-1]'];
for i = 1:length(kinectstream.wtime)
    a_z = [kinectstream.ANKLE_LEFT.x(i);kinectstream.ANKLE_LEFT.y(i);kinectstream.ANKLE_LEFT.z(i)]-...
        [kinectstream.KNEE_LEFT.x(i);kinectstream.KNEE_LEFT.y(i);kinectstream.KNEE_LEFT.z(i)];
    a_x = closest_orthogonal(a_z,[1,0,0]');
    global_vec = zeros(3,2);
    global_vec(:,1) = a_x;
    global_vec(:,2) = a_z;

    [U,S,V] = svd(local_vec*global_vec');
    % V*U'的行列式可能为-1.即R可能求到的不是旋转矩阵而是反射矩阵，为此引入一个中间矩阵M
    M = eye(3,3);
    M(3,3) = det(V*U');
    r_Shank_Left{i}=V * M * U'; %R可以表示体段坐标系到全局坐标系的转动
end

local_vec = [[1,0,0]',[0,0,-1]'];
for i = 1:length(kinectstream.wtime)
    a_z = [kinectstream.ANKLE_RIGHT.x(i);kinectstream.ANKLE_RIGHT.y(i);kinectstream.ANKLE_RIGHT.z(i)]-...
        [kinectstream.KNEE_RIGHT.x(i);kinectstream.KNEE_RIGHT.y(i);kinectstream.KNEE_RIGHT.z(i)];
    a_x = closest_orthogonal(a_z,[1,0,0]');
    global_vec = zeros(3,2);
    global_vec(:,1) = a_x;
    global_vec(:,2) = a_z;

    [U,S,V] = svd(local_vec*global_vec');
    % V*U'的行列式可能为-1.即R可能求到的不是旋转矩阵而是反射矩阵，为此引入一个中间矩阵M
    M = eye(3,3);
    M(3,3) = det(V*U');
    r_Shank_Right{i}=V * M * U'; %R可以表示体段坐标系到全局坐标系的转动
end
%% 足部
local_vec = [[1,0,0]',[0,1,0]'];
for i = 1:length(kinectstream.wtime)
    a_y = [kinectstream.FOOT_LEFT.x(i);kinectstream.FOOT_LEFT.y(i);kinectstream.FOOT_LEFT.z(i)]-...
        [kinectstream.ANKLE_LEFT.x(i);kinectstream.ANKLE_LEFT.y(i);kinectstream.ANKLE_LEFT.z(i)];
    a_x = closest_orthogonal(a_y,[1,0,0]');
    global_vec = zeros(3,2);
    global_vec(:,1) = a_x;
    global_vec(:,2) = a_y;

    [U,S,V] = svd(local_vec*global_vec');
    % V*U'的行列式可能为-1.即R可能求到的不是旋转矩阵而是反射矩阵，为此引入一个中间矩阵M
    M = eye(3,3);
    M(3,3) = det(V*U');
    r_Foot_Left{i}=V * M * U'; %R可以表示体段坐标系到全局坐标系的转动
end

local_vec = [[1,0,0]',[0,1,0]'];
for i = 1:length(kinectstream.wtime)
    a_y = [kinectstream.FOOT_RIGHT.x(i);kinectstream.FOOT_RIGHT.y(i);kinectstream.FOOT_RIGHT.z(i)]-...
        [kinectstream.ANKLE_RIGHT.x(i);kinectstream.ANKLE_RIGHT.y(i);kinectstream.ANKLE_RIGHT.z(i)];
    a_x = closest_orthogonal(a_y,[1,0,0]');
    global_vec = zeros(3,2);
    global_vec(:,1) = a_x;
    global_vec(:,2) = a_y;

    [U,S,V] = svd(local_vec*global_vec');
    % V*U'的行列式可能为-1.即R可能求到的不是旋转矩阵而是反射矩阵，为此引入一个中间矩阵M
    M = eye(3,3);
    M(3,3) = det(V*U');
    r_Foot_Right{i}=V * M * U'; %R可以表示体段坐标系到全局坐标系的转动
end

%% 写入结果
r_all_segments.HeadNeck = r_HeadNeck;
r_all_segments.Trunk = r_Trunk;
r_all_segments.Pelvis = r_Pelvis;
r_all_segments.Upperarm_Left = r_Upperarm_Left;
r_all_segments.Forearm_Left = r_Forearm_Left;
r_all_segments.Hand_Left = r_Hand_Left;
r_all_segments.Thigh_Left = r_Thigh_Left;
r_all_segments.Shank_Left = r_Shank_Left;
r_all_segments.Foot_Left = r_Foot_Left;
r_all_segments.Upperarm_Right = r_Upperarm_Right;
r_all_segments.Forearm_Right = r_Forearm_Right;
r_all_segments.Hand_Right = r_Hand_Right;
r_all_segments.Thigh_Right = r_Thigh_Right;
r_all_segments.Shank_Right = r_Shank_Right;
r_all_segments.Foot_Right = r_Foot_Right;

end

function b = closest_orthogonal(a,u)
    % 输入：向量 a,目标向量 u % [1; 0; 0]
    % 输出：与 a 正交且最接近 (1,0,0) 的单位向量 b
    
    % 计算 u 在 a 方向上的投影
    proj_a_u = (dot(a, u) / dot(a, a)) * a;
    
    % 计算 u 的正交分量
    u_perp = u - proj_a_u;
    
    % 归一化
    if norm(u_perp) < eps
        % 如果 a 平行于 (1,0,0)，则选择 (0,1,0) 或 (0,0,1)
        b = [0; 1; 0];  % 或者 [0; 0; 1]
    else
        b = u_perp / norm(u_perp);
    end
end

function c = find_common_orthogonal(a, b)
    % 输入：两个正交向量 a 和 b
    % 输出：与 a 和 b 都正交的单位向量 c

    % 计算叉积
    c = cross(a, b);
    
    % 归一化
    c = c / norm(c);
end
