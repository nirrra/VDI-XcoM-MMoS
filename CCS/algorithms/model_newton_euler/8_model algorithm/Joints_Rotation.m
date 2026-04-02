function r_all_joints = Joints_Rotation(streamInter)
%% 关节在全局坐标系下的向量表示
global_vector_ankle_left = [streamInter.KNEE_LEFT.x, streamInter.KNEE_LEFT.y, streamInter.KNEE_LEFT.z]...
                     - [streamInter.ANKLE_LEFT.x, streamInter.ANKLE_LEFT.y, streamInter.ANKLE_LEFT.z]; 
global_vector_ankle_right = [streamInter.KNEE_RIGHT.x, streamInter.KNEE_RIGHT.y, streamInter.KNEE_RIGHT.z]...
                     - [streamInter.ANKLE_RIGHT.x, streamInter.ANKLE_RIGHT.y, streamInter.ANKLE_RIGHT.z]; 
global_vector_knee_left = [streamInter.HIP_LEFT.x, streamInter.HIP_LEFT.y, streamInter.HIP_LEFT.z]...
                     - [streamInter.KNEE_LEFT.x, streamInter.KNEE_LEFT.y, streamInter.KNEE_LEFT.z]; 
global_vector_knee_right = [streamInter.HIP_RIGHT.x, streamInter.HIP_RIGHT.y, streamInter.HIP_RIGHT.z]...
                     - [streamInter.KNEE_RIGHT.x, streamInter.KNEE_RIGHT.y, streamInter.KNEE_RIGHT.z]; 
global_vector_hip_left = [streamInter.SPINE_NAVAL.x, streamInter.SPINE_NAVAL.y, streamInter.SPINE_NAVAL.z]...
                     - [streamInter.PELVIS.x, streamInter.PELVIS.y, streamInter.PELVIS.z]; 
global_vector_hip_right = [streamInter.SPINE_NAVAL.x, streamInter.SPINE_NAVAL.y, streamInter.SPINE_NAVAL.z]...
                     - [streamInter.PELVIS.x, streamInter.PELVIS.y, streamInter.PELVIS.z];
global_vector_neck = [streamInter.SPINE_CHEST.x, streamInter.SPINE_CHEST.y, streamInter.SPINE_CHEST.z]...
                     - [streamInter.SPINE_NAVAL.x, streamInter.SPINE_NAVAL.y, streamInter.SPINE_NAVAL.z];



%% 体段坐标系到全局坐标系的旋转矩阵    
for i=1:length(streamInter.wtime)
    r_AnkleLeft{i} = vrrotvec2mat(vrrotvec([0 0 1],global_vector_ankle_left(i,:)));
    r_AnkleRight{i} = vrrotvec2mat(vrrotvec([0 0 1],global_vector_ankle_right(i,:)));
    r_KneeLeft{i} = vrrotvec2mat(vrrotvec([0 0 1],global_vector_knee_left(i,:)));
    r_KneeRight{i} = vrrotvec2mat(vrrotvec([0 0 1],global_vector_knee_right(i,:)));
    r_HipLeft{i} = vrrotvec2mat(vrrotvec([0 0 1],global_vector_hip_left(i,:)));
    r_HipRight{i} = vrrotvec2mat(vrrotvec([0 0 1],global_vector_hip_right(i,:)));
    r_Neck{i} = vrrotvec2mat(vrrotvec([0 0 1],global_vector_neck(i,:)));
end
%% 写入结果
r_all_joints.Neck = r_Neck;
r_all_joints.HipLeft = r_HipLeft;
r_all_joints.HipRight = r_HipRight;
r_all_joints.KneeLeft = r_KneeLeft;
r_all_joints.KneeRight = r_KneeRight;
r_all_joints.AnkleLeft = r_AnkleLeft;
r_all_joints.AnkleRight = r_AnkleRight;