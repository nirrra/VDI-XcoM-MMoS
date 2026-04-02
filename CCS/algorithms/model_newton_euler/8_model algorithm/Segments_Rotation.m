
%% segments rotation R, 体段坐标系到全局坐标系的旋转矩阵  ，除了Trunk 其它体段都视为细棍模型直径忽略,即忽略绕长轴的旋转
%Trunk是该模型下 唯一的具有体积的刚体
function r_all_segments = Segments_Rotation(kinectstream)

%% 肢体在全局坐标系下的向量表示
global_vector_HeadNeck      = [kinectstream.HEAD.x, kinectstream.HEAD.y, kinectstream.HEAD.z]...
                     - [kinectstream.NECK.x, kinectstream.NECK.y, kinectstream.NECK.z]; 
%左侧肢体
global_vector_Upperarm_Left = [kinectstream.ELBOW_LEFT.x, kinectstream.ELBOW_LEFT.y, kinectstream.ELBOW_LEFT.z]...
                     - [kinectstream.SHOULDER_LEFT.x, kinectstream.SHOULDER_LEFT.y, kinectstream.SHOULDER_LEFT.z];
                 
global_vector_Forearm_Left  = [kinectstream.WRIST_LEFT.x, kinectstream.WRIST_LEFT.y, kinectstream.WRIST_LEFT.z]...
                     - [kinectstream.ELBOW_LEFT.x, kinectstream.ELBOW_LEFT.y, kinectstream.ELBOW_LEFT.z];
                 
global_vector_Hand_Left     = [kinectstream.HAND_LEFT.x, kinectstream.HAND_LEFT.y, kinectstream.HAND_LEFT.z]...
                     - [kinectstream.WRIST_LEFT.x, kinectstream.WRIST_LEFT.y, kinectstream.WRIST_LEFT.z];
                 
global_vector_Thigh_Left    = [kinectstream.KNEE_LEFT.x, kinectstream.KNEE_LEFT.y, kinectstream.KNEE_LEFT.z]...
                     - [kinectstream.HIP_LEFT.x, kinectstream.HIP_LEFT.y, kinectstream.HIP_LEFT.z];

global_vector_Shank_Left    = [kinectstream.ANKLE_LEFT.x, kinectstream.ANKLE_LEFT.y, kinectstream.ANKLE_LEFT.z]...
                     - [kinectstream.KNEE_LEFT.x, kinectstream.KNEE_LEFT.y, kinectstream.KNEE_LEFT.z];

global_vector_Foot_Left     = [kinectstream.FOOT_LEFT.x, kinectstream.FOOT_LEFT.y, kinectstream.FOOT_LEFT.z]...
                     - [kinectstream.ANKLE_LEFT.x, kinectstream.ANKLE_LEFT.y, kinectstream.ANKLE_LEFT.z];
       %右侧肢体
global_vector_Upperarm_Right = [kinectstream.ELBOW_RIGHT.x, kinectstream.ELBOW_RIGHT.y, kinectstream.ELBOW_RIGHT.z]...
                      - [kinectstream.SHOULDER_RIGHT.x, kinectstream.SHOULDER_RIGHT.y, kinectstream.SHOULDER_RIGHT.z];
                 
global_vector_Forearm_Right  = [kinectstream.WRIST_RIGHT.x, kinectstream.WRIST_RIGHT.y, kinectstream.WRIST_RIGHT.z]...
                      - [kinectstream.ELBOW_RIGHT.x, kinectstream.ELBOW_RIGHT.y, kinectstream.ELBOW_RIGHT.z];
                 
global_vector_Hand_Right     = [kinectstream.HAND_RIGHT.x, kinectstream.HAND_RIGHT.y, kinectstream.HAND_RIGHT.z]...
                      - [kinectstream.WRIST_RIGHT.x, kinectstream.WRIST_RIGHT.y, kinectstream.WRIST_RIGHT.z];
                 
global_vector_Thigh_Right    = [kinectstream.KNEE_RIGHT.x, kinectstream.KNEE_RIGHT.y, kinectstream.KNEE_RIGHT.z]...
                      - [kinectstream.HIP_RIGHT.x, kinectstream.HIP_RIGHT.y, kinectstream.HIP_RIGHT.z];

global_vector_Shank_Right    = [kinectstream.ANKLE_RIGHT.x, kinectstream.ANKLE_RIGHT.y, kinectstream.ANKLE_RIGHT.z]...
                      - [kinectstream.KNEE_RIGHT.x, kinectstream.KNEE_RIGHT.y, kinectstream.KNEE_RIGHT.z];

global_vector_Foot_Right     = [kinectstream.FOOT_RIGHT.x, kinectstream.FOOT_RIGHT.y, kinectstream.FOOT_RIGHT.z]...
                      - [kinectstream.ANKLE_RIGHT.x, kinectstream.ANKLE_RIGHT.y, kinectstream.ANKLE_RIGHT.z];

             
%% 体段坐标系到全局坐标系的旋转矩阵    
for i=1:length(kinectstream.wtime)
    r_HeadNeck{i} =  vrrotvec2mat(vrrotvec([0 0 1],global_vector_HeadNeck(i,:) ));
    % 左侧体段
    r_Upperarm_Left{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Upperarm_Left(i,:)));
    
    r_Forearm_Left{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Forearm_Left(i,:)));
    
    r_Hand_Left{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Hand_Left(i,:)));
    
    r_Thigh_Left{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Thigh_Left(i,:)));
    
    r_Shank_Left{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Shank_Left(i,:)));
    
    r_Foot_Left{i} = vrrotvec2mat(vrrotvec([0 1 0],global_vector_Foot_Left(i,:)));
    
    % 右侧体段
    r_Upperarm_Right{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Upperarm_Right(i,:)));
    
    r_Forearm_Right{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Forearm_Right(i,:)));
    
    r_Hand_Right{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Hand_Right(i,:)));
    
    r_Thigh_Right{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Thigh_Right(i,:)));
    
    r_Shank_Right{i} = vrrotvec2mat(vrrotvec([0 0 -1],global_vector_Shank_Right(i,:)));
    
    r_Foot_Right{i} = vrrotvec2mat(vrrotvec([0 1 0],global_vector_Foot_Right(i,:)));
end
% 躯干
r_Trunk = Rotation_Trunk(kinectstream);
%% 写入结果
r_all_segments.HeadNeck = r_HeadNeck;
r_all_segments.Trunk = r_Trunk;
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

