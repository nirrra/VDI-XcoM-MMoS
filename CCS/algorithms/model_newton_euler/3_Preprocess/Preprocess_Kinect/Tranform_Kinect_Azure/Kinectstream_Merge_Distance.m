% distance是Mas开始失效时离步道坐标原点(统一坐标系)的距离,用距离信息来融合两台kinect数据
function Kinectstream = Kinectstream_Merge_Distance(Kinect_Mas_stream,Kinect_Sub_stream,start_Proximal,distance)
if start_Proximal == 1 %从靠近kinect侧开始行走
    for i=1:length(Kinect_Mas_stream.name)
        outofrange_flag1 = Kinect_Mas_stream.PELVIS.y(i)   < distance;
        outofrange_flag2 = Kinect_Mas_stream.PELVIS.y(i+1) < distance;
        outofrange_flag3 = Kinect_Mas_stream.PELVIS.y(i+2) < distance;
        if (outofrange_flag1 && outofrange_flag2 && outofrange_flag3)
            time0 = Kinect_Mas_stream.wtime(i);%表示开始超出范围时的初始时间
            break;
        end
    end
    
    %% start merge
    % 提取Mas数据
    Mas_index = find(Kinect_Mas_stream.wtime < time0);
    Kinectstream0 = Extract_K(Kinect_Mas_stream,Mas_index);
    
    % 提取Sub数据
    Sub_index = find(Kinect_Sub_stream.wtime >= time0);
    Kinectstream1 = Extract_K(Kinect_Sub_stream,Sub_index);
    %合并数据
    Kinectstream = Merge_K(Kinectstream0,Kinectstream1);
    %% end  merge
else %从远离kinect侧开始行走
    for i=1:length(Kinect_Mas_stream.name)
        outofrange_flag1 = Kinect_Mas_stream.PELVIS.y(i)   > distance;
        outofrange_flag2 = Kinect_Mas_stream.PELVIS.y(i+1) > distance;
        outofrange_flag3 = Kinect_Mas_stream.PELVIS.y(i+2) > distance;
        if (outofrange_flag1 && outofrange_flag2 && outofrange_flag3)
            time1 = Kinect_Mas_stream.wtime(i);%表示开始在范围内的初始时间
            break;
        end
    end
    
    %% start merge
    % 提取Mas数据
    Mas_index = find(Kinect_Mas_stream.wtime > time1);
    Kinectstream0 = Extract_K(Kinect_Mas_stream,Mas_index);
    
    % 提取Sub数据
    Sub_index = find(Kinect_Sub_stream.wtime <= time1);
    Kinectstream1 = Extract_K(Kinect_Sub_stream,Sub_index);
    %合并数据
    Kinectstream = Merge_K(Kinectstream1,Kinectstream0);
    %% end  merge
end
end
%% 提取数据
function kinectstream = Extract_K(Kinectstream,index)
kinectstream.wtime  = Kinectstream.wtime(index);
kinectstream.ktime  = Kinectstream.ktime(index);
kinectstream.name  = Kinectstream.name(index);

kinectstream.PELVIS.x = Kinectstream.PELVIS.x(index);
kinectstream.PELVIS.y = Kinectstream.PELVIS.y(index);
kinectstream.PELVIS.z = Kinectstream.PELVIS.z(index);
kinectstream.PELVIS.Quaternion.w = Kinectstream.PELVIS.Quaternion.w(index);
kinectstream.PELVIS.Quaternion.x = Kinectstream.PELVIS.Quaternion.x(index);
kinectstream.PELVIS.Quaternion.y = Kinectstream.PELVIS.Quaternion.y(index);
kinectstream.PELVIS.Quaternion.z = Kinectstream.PELVIS.Quaternion.z(index);

kinectstream.SPINE_NAVAL.x = Kinectstream.SPINE_NAVAL.x(index);
kinectstream.SPINE_NAVAL.y = Kinectstream.SPINE_NAVAL.y(index);
kinectstream.SPINE_NAVAL.z = Kinectstream.SPINE_NAVAL.z(index);
kinectstream.SPINE_NAVAL.Quaternion.w = Kinectstream.SPINE_NAVAL.Quaternion.w(index);
kinectstream.SPINE_NAVAL.Quaternion.x = Kinectstream.SPINE_NAVAL.Quaternion.x(index);
kinectstream.SPINE_NAVAL.Quaternion.y = Kinectstream.SPINE_NAVAL.Quaternion.y(index);
kinectstream.SPINE_NAVAL.Quaternion.z = Kinectstream.SPINE_NAVAL.Quaternion.z(index);

kinectstream.SPINE_CHEST.x = Kinectstream.SPINE_CHEST.x(index);
kinectstream.SPINE_CHEST.y = Kinectstream.SPINE_CHEST.y(index);
kinectstream.SPINE_CHEST.z = Kinectstream.SPINE_CHEST.z(index);
kinectstream.SPINE_CHEST.Quaternion.w = Kinectstream.SPINE_CHEST.Quaternion.w(index);
kinectstream.SPINE_CHEST.Quaternion.x = Kinectstream.SPINE_CHEST.Quaternion.x(index);
kinectstream.SPINE_CHEST.Quaternion.y = Kinectstream.SPINE_CHEST.Quaternion.y(index);
kinectstream.SPINE_CHEST.Quaternion.z = Kinectstream.SPINE_CHEST.Quaternion.z(index);

kinectstream.NECK.x = Kinectstream.NECK.x(index);
kinectstream.NECK.y = Kinectstream.NECK.y(index);
kinectstream.NECK.z = Kinectstream.NECK.z(index);
kinectstream.NECK.Quaternion.w = Kinectstream.NECK.Quaternion.w(index);
kinectstream.NECK.Quaternion.x = Kinectstream.NECK.Quaternion.x(index);
kinectstream.NECK.Quaternion.y = Kinectstream.NECK.Quaternion.y(index);
kinectstream.NECK.Quaternion.z = Kinectstream.NECK.Quaternion.z(index);

kinectstream.CLAVICLE_LEFT.x = Kinectstream.CLAVICLE_LEFT.x(index);
kinectstream.CLAVICLE_LEFT.y = Kinectstream.CLAVICLE_LEFT.y(index);
kinectstream.CLAVICLE_LEFT.z = Kinectstream.CLAVICLE_LEFT.z(index);
kinectstream.CLAVICLE_LEFT.Quaternion.w = Kinectstream.CLAVICLE_LEFT.Quaternion.w(index);
kinectstream.CLAVICLE_LEFT.Quaternion.x = Kinectstream.CLAVICLE_LEFT.Quaternion.x(index);
kinectstream.CLAVICLE_LEFT.Quaternion.y = Kinectstream.CLAVICLE_LEFT.Quaternion.y(index);
kinectstream.CLAVICLE_LEFT.Quaternion.z = Kinectstream.CLAVICLE_LEFT.Quaternion.z(index);

kinectstream.SHOULDER_LEFT.x = Kinectstream.SHOULDER_LEFT.x(index);
kinectstream.SHOULDER_LEFT.y = Kinectstream.SHOULDER_LEFT.y(index);
kinectstream.SHOULDER_LEFT.z = Kinectstream.SHOULDER_LEFT.z(index);
kinectstream.SHOULDER_LEFT.Quaternion.w = Kinectstream.SHOULDER_LEFT.Quaternion.w(index);
kinectstream.SHOULDER_LEFT.Quaternion.x = Kinectstream.SHOULDER_LEFT.Quaternion.x(index);
kinectstream.SHOULDER_LEFT.Quaternion.y = Kinectstream.SHOULDER_LEFT.Quaternion.y(index);
kinectstream.SHOULDER_LEFT.Quaternion.z = Kinectstream.SHOULDER_LEFT.Quaternion.z(index);

kinectstream.ELBOW_LEFT.x = Kinectstream.ELBOW_LEFT.x(index);
kinectstream.ELBOW_LEFT.y = Kinectstream.ELBOW_LEFT.y(index);
kinectstream.ELBOW_LEFT.z = Kinectstream.ELBOW_LEFT.z(index);
kinectstream.ELBOW_LEFT.Quaternion.w = Kinectstream.ELBOW_LEFT.Quaternion.w(index);
kinectstream.ELBOW_LEFT.Quaternion.x = Kinectstream.ELBOW_LEFT.Quaternion.x(index);
kinectstream.ELBOW_LEFT.Quaternion.y = Kinectstream.ELBOW_LEFT.Quaternion.y(index);
kinectstream.ELBOW_LEFT.Quaternion.z = Kinectstream.ELBOW_LEFT.Quaternion.z(index);

kinectstream.WRIST_LEFT.x = Kinectstream.WRIST_LEFT.x(index);
kinectstream.WRIST_LEFT.y = Kinectstream.WRIST_LEFT.y(index);
kinectstream.WRIST_LEFT.z = Kinectstream.WRIST_LEFT.z(index);
kinectstream.WRIST_LEFT.Quaternion.w = Kinectstream.WRIST_LEFT.Quaternion.w(index);
kinectstream.WRIST_LEFT.Quaternion.x = Kinectstream.WRIST_LEFT.Quaternion.x(index);
kinectstream.WRIST_LEFT.Quaternion.y = Kinectstream.WRIST_LEFT.Quaternion.y(index);
kinectstream.WRIST_LEFT.Quaternion.z = Kinectstream.WRIST_LEFT.Quaternion.z(index);

kinectstream.HAND_LEFT.x = Kinectstream.HAND_LEFT.x(index);
kinectstream.HAND_LEFT.y = Kinectstream.HAND_LEFT.y(index);
kinectstream.HAND_LEFT.z = Kinectstream.HAND_LEFT.z(index);
kinectstream.HAND_LEFT.Quaternion.w = Kinectstream.HAND_LEFT.Quaternion.w(index);
kinectstream.HAND_LEFT.Quaternion.x = Kinectstream.HAND_LEFT.Quaternion.x(index);
kinectstream.HAND_LEFT.Quaternion.y = Kinectstream.HAND_LEFT.Quaternion.y(index);
kinectstream.HAND_LEFT.Quaternion.z = Kinectstream.HAND_LEFT.Quaternion.z(index);

kinectstream.HANDTIP_LEFT.x = Kinectstream.HANDTIP_LEFT.x(index);
kinectstream.HANDTIP_LEFT.y = Kinectstream.HANDTIP_LEFT.y(index);
kinectstream.HANDTIP_LEFT.z = Kinectstream.HANDTIP_LEFT.z(index);
kinectstream.HANDTIP_LEFT.Quaternion.w = Kinectstream.HANDTIP_LEFT.Quaternion.w(index);
kinectstream.HANDTIP_LEFT.Quaternion.x = Kinectstream.HANDTIP_LEFT.Quaternion.x(index);
kinectstream.HANDTIP_LEFT.Quaternion.y = Kinectstream.HANDTIP_LEFT.Quaternion.y(index);
kinectstream.HANDTIP_LEFT.Quaternion.z = Kinectstream.HANDTIP_LEFT.Quaternion.z(index);

kinectstream.THUMB_LEFT.x = Kinectstream.THUMB_LEFT.x(index);
kinectstream.THUMB_LEFT.y = Kinectstream.THUMB_LEFT.y(index);
kinectstream.THUMB_LEFT.z = Kinectstream.THUMB_LEFT.z(index);
kinectstream.THUMB_LEFT.Quaternion.w = Kinectstream.THUMB_LEFT.Quaternion.w(index);
kinectstream.THUMB_LEFT.Quaternion.x = Kinectstream.THUMB_LEFT.Quaternion.x(index);
kinectstream.THUMB_LEFT.Quaternion.y = Kinectstream.THUMB_LEFT.Quaternion.y(index);
kinectstream.THUMB_LEFT.Quaternion.z = Kinectstream.THUMB_LEFT.Quaternion.z(index);

kinectstream.CLAVICLE_RIGHT.x = Kinectstream.CLAVICLE_RIGHT.x(index);
kinectstream.CLAVICLE_RIGHT.y = Kinectstream.CLAVICLE_RIGHT.y(index);
kinectstream.CLAVICLE_RIGHT.z = Kinectstream.CLAVICLE_RIGHT.z(index);
kinectstream.CLAVICLE_RIGHT.Quaternion.w = Kinectstream.CLAVICLE_RIGHT.Quaternion.w(index);
kinectstream.CLAVICLE_RIGHT.Quaternion.x = Kinectstream.CLAVICLE_RIGHT.Quaternion.x(index);
kinectstream.CLAVICLE_RIGHT.Quaternion.y = Kinectstream.CLAVICLE_RIGHT.Quaternion.y(index);
kinectstream.CLAVICLE_RIGHT.Quaternion.z = Kinectstream.CLAVICLE_RIGHT.Quaternion.z(index);

kinectstream.SHOULDER_RIGHT.x = Kinectstream.SHOULDER_RIGHT.x(index);
kinectstream.SHOULDER_RIGHT.y = Kinectstream.SHOULDER_RIGHT.y(index);
kinectstream.SHOULDER_RIGHT.z = Kinectstream.SHOULDER_RIGHT.z(index);
kinectstream.SHOULDER_RIGHT.Quaternion.w = Kinectstream.SHOULDER_RIGHT.Quaternion.w(index);
kinectstream.SHOULDER_RIGHT.Quaternion.x = Kinectstream.SHOULDER_RIGHT.Quaternion.x(index);
kinectstream.SHOULDER_RIGHT.Quaternion.y = Kinectstream.SHOULDER_RIGHT.Quaternion.y(index);
kinectstream.SHOULDER_RIGHT.Quaternion.z = Kinectstream.SHOULDER_RIGHT.Quaternion.z(index);

kinectstream.ELBOW_RIGHT.x = Kinectstream.ELBOW_RIGHT.x(index);
kinectstream.ELBOW_RIGHT.y = Kinectstream.ELBOW_RIGHT.y(index);
kinectstream.ELBOW_RIGHT.z = Kinectstream.ELBOW_RIGHT.z(index);
kinectstream.ELBOW_RIGHT.Quaternion.w = Kinectstream.ELBOW_RIGHT.Quaternion.w(index);
kinectstream.ELBOW_RIGHT.Quaternion.x = Kinectstream.ELBOW_RIGHT.Quaternion.x(index);
kinectstream.ELBOW_RIGHT.Quaternion.y = Kinectstream.ELBOW_RIGHT.Quaternion.y(index);
kinectstream.ELBOW_RIGHT.Quaternion.z = Kinectstream.ELBOW_RIGHT.Quaternion.z(index);

kinectstream.WRIST_RIGHT.x = Kinectstream.WRIST_RIGHT.x(index);
kinectstream.WRIST_RIGHT.y = Kinectstream.WRIST_RIGHT.y(index);
kinectstream.WRIST_RIGHT.z = Kinectstream.WRIST_RIGHT.z(index);
kinectstream.WRIST_RIGHT.Quaternion.w = Kinectstream.WRIST_RIGHT.Quaternion.w(index);
kinectstream.WRIST_RIGHT.Quaternion.x = Kinectstream.WRIST_RIGHT.Quaternion.x(index);
kinectstream.WRIST_RIGHT.Quaternion.y = Kinectstream.WRIST_RIGHT.Quaternion.y(index);
kinectstream.WRIST_RIGHT.Quaternion.z = Kinectstream.WRIST_RIGHT.Quaternion.z(index);


kinectstream.HAND_RIGHT.x = Kinectstream.HAND_RIGHT.x(index);
kinectstream.HAND_RIGHT.y = Kinectstream.HAND_RIGHT.y(index);
kinectstream.HAND_RIGHT.z = Kinectstream.HAND_RIGHT.z(index);
kinectstream.HAND_RIGHT.Quaternion.w = Kinectstream.HAND_RIGHT.Quaternion.w(index);
kinectstream.HAND_RIGHT.Quaternion.x = Kinectstream.HAND_RIGHT.Quaternion.x(index);
kinectstream.HAND_RIGHT.Quaternion.y = Kinectstream.HAND_RIGHT.Quaternion.y(index);
kinectstream.HAND_RIGHT.Quaternion.z = Kinectstream.HAND_RIGHT.Quaternion.z(index);

kinectstream.HANDTIP_RIGHT.x = Kinectstream.HANDTIP_RIGHT.x(index);
kinectstream.HANDTIP_RIGHT.y = Kinectstream.HANDTIP_RIGHT.y(index);
kinectstream.HANDTIP_RIGHT.z = Kinectstream.HANDTIP_RIGHT.z(index);
kinectstream.HANDTIP_RIGHT.Quaternion.w = Kinectstream.HANDTIP_RIGHT.Quaternion.w(index);
kinectstream.HANDTIP_RIGHT.Quaternion.x = Kinectstream.HANDTIP_RIGHT.Quaternion.x(index);
kinectstream.HANDTIP_RIGHT.Quaternion.y = Kinectstream.HANDTIP_RIGHT.Quaternion.y(index);
kinectstream.HANDTIP_RIGHT.Quaternion.z = Kinectstream.HANDTIP_RIGHT.Quaternion.z(index);

kinectstream.THUMB_RIGHT.x = Kinectstream.THUMB_RIGHT.x(index);
kinectstream.THUMB_RIGHT.y = Kinectstream.THUMB_RIGHT.y(index);
kinectstream.THUMB_RIGHT.z = Kinectstream.THUMB_RIGHT.z(index);
kinectstream.THUMB_RIGHT.Quaternion.w = Kinectstream.THUMB_RIGHT.Quaternion.w(index);
kinectstream.THUMB_RIGHT.Quaternion.x = Kinectstream.THUMB_RIGHT.Quaternion.x(index);
kinectstream.THUMB_RIGHT.Quaternion.y = Kinectstream.THUMB_RIGHT.Quaternion.y(index);
kinectstream.THUMB_RIGHT.Quaternion.z = Kinectstream.THUMB_RIGHT.Quaternion.z(index);

kinectstream.HIP_LEFT.x = Kinectstream.HIP_LEFT.x(index);
kinectstream.HIP_LEFT.y = Kinectstream.HIP_LEFT.y(index);
kinectstream.HIP_LEFT.z = Kinectstream.HIP_LEFT.z(index);
kinectstream.HIP_LEFT.Quaternion.w = Kinectstream.HIP_LEFT.Quaternion.w(index);
kinectstream.HIP_LEFT.Quaternion.x = Kinectstream.HIP_LEFT.Quaternion.x(index);
kinectstream.HIP_LEFT.Quaternion.y = Kinectstream.HIP_LEFT.Quaternion.y(index);
kinectstream.HIP_LEFT.Quaternion.z = Kinectstream.HIP_LEFT.Quaternion.z(index);

kinectstream.KNEE_LEFT.x = Kinectstream.KNEE_LEFT.x(index);
kinectstream.KNEE_LEFT.y = Kinectstream.KNEE_LEFT.y(index);
kinectstream.KNEE_LEFT.z = Kinectstream.KNEE_LEFT.z(index);
kinectstream.KNEE_LEFT.Quaternion.w = Kinectstream.KNEE_LEFT.Quaternion.w(index);
kinectstream.KNEE_LEFT.Quaternion.x = Kinectstream.KNEE_LEFT.Quaternion.x(index);
kinectstream.KNEE_LEFT.Quaternion.y = Kinectstream.KNEE_LEFT.Quaternion.y(index);
kinectstream.KNEE_LEFT.Quaternion.z = Kinectstream.KNEE_LEFT.Quaternion.z(index);

kinectstream.ANKLE_LEFT.x = Kinectstream.ANKLE_LEFT.x(index);
kinectstream.ANKLE_LEFT.y = Kinectstream.ANKLE_LEFT.y(index);
kinectstream.ANKLE_LEFT.z = Kinectstream.ANKLE_LEFT.z(index);
kinectstream.ANKLE_LEFT.Quaternion.w = Kinectstream.ANKLE_LEFT.Quaternion.w(index);
kinectstream.ANKLE_LEFT.Quaternion.x = Kinectstream.ANKLE_LEFT.Quaternion.x(index);
kinectstream.ANKLE_LEFT.Quaternion.y = Kinectstream.ANKLE_LEFT.Quaternion.y(index);
kinectstream.ANKLE_LEFT.Quaternion.z = Kinectstream.ANKLE_LEFT.Quaternion.z(index);

kinectstream.FOOT_LEFT.x = Kinectstream.FOOT_LEFT.x(index);
kinectstream.FOOT_LEFT.y = Kinectstream.FOOT_LEFT.y(index);
kinectstream.FOOT_LEFT.z = Kinectstream.FOOT_LEFT.z(index);
kinectstream.FOOT_LEFT.Quaternion.w = Kinectstream.FOOT_LEFT.Quaternion.w(index);
kinectstream.FOOT_LEFT.Quaternion.x = Kinectstream.FOOT_LEFT.Quaternion.x(index);
kinectstream.FOOT_LEFT.Quaternion.y = Kinectstream.FOOT_LEFT.Quaternion.y(index);
kinectstream.FOOT_LEFT.Quaternion.z = Kinectstream.FOOT_LEFT.Quaternion.z(index);

kinectstream.HIP_RIGHT.x = Kinectstream.HIP_RIGHT.x(index);
kinectstream.HIP_RIGHT.y = Kinectstream.HIP_RIGHT.y(index);
kinectstream.HIP_RIGHT.z = Kinectstream.HIP_RIGHT.z(index);
kinectstream.HIP_RIGHT.Quaternion.w = Kinectstream.HIP_RIGHT.Quaternion.w(index);
kinectstream.HIP_RIGHT.Quaternion.x = Kinectstream.HIP_RIGHT.Quaternion.x(index);
kinectstream.HIP_RIGHT.Quaternion.y = Kinectstream.HIP_RIGHT.Quaternion.y(index);
kinectstream.HIP_RIGHT.Quaternion.z = Kinectstream.HIP_RIGHT.Quaternion.z(index);

kinectstream.KNEE_RIGHT.x = Kinectstream.KNEE_RIGHT.x(index);
kinectstream.KNEE_RIGHT.y = Kinectstream.KNEE_RIGHT.y(index);
kinectstream.KNEE_RIGHT.z = Kinectstream.KNEE_RIGHT.z(index);
kinectstream.KNEE_RIGHT.Quaternion.w = Kinectstream.KNEE_RIGHT.Quaternion.w(index);
kinectstream.KNEE_RIGHT.Quaternion.x = Kinectstream.KNEE_RIGHT.Quaternion.x(index);
kinectstream.KNEE_RIGHT.Quaternion.y = Kinectstream.KNEE_RIGHT.Quaternion.y(index);
kinectstream.KNEE_RIGHT.Quaternion.z = Kinectstream.KNEE_RIGHT.Quaternion.z(index);

kinectstream.ANKLE_RIGHT.x = Kinectstream.ANKLE_RIGHT.x(index);
kinectstream.ANKLE_RIGHT.y = Kinectstream.ANKLE_RIGHT.y(index);
kinectstream.ANKLE_RIGHT.z = Kinectstream.ANKLE_RIGHT.z(index);
kinectstream.ANKLE_RIGHT.Quaternion.w = Kinectstream.ANKLE_RIGHT.Quaternion.w(index);
kinectstream.ANKLE_RIGHT.Quaternion.x = Kinectstream.ANKLE_RIGHT.Quaternion.x(index);
kinectstream.ANKLE_RIGHT.Quaternion.y = Kinectstream.ANKLE_RIGHT.Quaternion.y(index);
kinectstream.ANKLE_RIGHT.Quaternion.z = Kinectstream.ANKLE_RIGHT.Quaternion.z(index);

kinectstream.FOOT_RIGHT.x = Kinectstream.FOOT_RIGHT.x(index);
kinectstream.FOOT_RIGHT.y = Kinectstream.FOOT_RIGHT.y(index);
kinectstream.FOOT_RIGHT.z = Kinectstream.FOOT_RIGHT.z(index);
kinectstream.FOOT_RIGHT.Quaternion.w = Kinectstream.FOOT_RIGHT.Quaternion.w(index);
kinectstream.FOOT_RIGHT.Quaternion.x = Kinectstream.FOOT_RIGHT.Quaternion.x(index);
kinectstream.FOOT_RIGHT.Quaternion.y = Kinectstream.FOOT_RIGHT.Quaternion.y(index);
kinectstream.FOOT_RIGHT.Quaternion.z = Kinectstream.FOOT_RIGHT.Quaternion.z(index);

kinectstream.HEAD.x = Kinectstream.HEAD.x(index);
kinectstream.HEAD.y = Kinectstream.HEAD.y(index);
kinectstream.HEAD.z = Kinectstream.HEAD.z(index);
kinectstream.HEAD.Quaternion.w = Kinectstream.HEAD.Quaternion.w(index);
kinectstream.HEAD.Quaternion.x = Kinectstream.HEAD.Quaternion.x(index);
kinectstream.HEAD.Quaternion.y = Kinectstream.HEAD.Quaternion.y(index);
kinectstream.HEAD.Quaternion.z = Kinectstream.HEAD.Quaternion.z(index);

kinectstream.NOSE.x = Kinectstream.NOSE.x(index);
kinectstream.NOSE.y = Kinectstream.NOSE.y(index);
kinectstream.NOSE.z = Kinectstream.NOSE.z(index);
kinectstream.NOSE.Quaternion.w = Kinectstream.NOSE.Quaternion.w(index);
kinectstream.NOSE.Quaternion.x = Kinectstream.NOSE.Quaternion.x(index);
kinectstream.NOSE.Quaternion.y = Kinectstream.NOSE.Quaternion.y(index);
kinectstream.NOSE.Quaternion.z = Kinectstream.NOSE.Quaternion.z(index);

kinectstream.EYE_LEFT.x = Kinectstream.EYE_LEFT.x(index);
kinectstream.EYE_LEFT.y = Kinectstream.EYE_LEFT.y(index);
kinectstream.EYE_LEFT.z = Kinectstream.EYE_LEFT.z(index);
kinectstream.EYE_LEFT.Quaternion.w = Kinectstream.EYE_LEFT.Quaternion.w(index);
kinectstream.EYE_LEFT.Quaternion.x = Kinectstream.EYE_LEFT.Quaternion.x(index);
kinectstream.EYE_LEFT.Quaternion.y = Kinectstream.EYE_LEFT.Quaternion.y(index);
kinectstream.EYE_LEFT.Quaternion.z = Kinectstream.EYE_LEFT.Quaternion.z(index);

kinectstream.EAR_LEFT.x = Kinectstream.EAR_LEFT.x(index);
kinectstream.EAR_LEFT.y = Kinectstream.EAR_LEFT.y(index);
kinectstream.EAR_LEFT.z = Kinectstream.EAR_LEFT.z(index);
kinectstream.EAR_LEFT.Quaternion.w = Kinectstream.EAR_LEFT.Quaternion.w(index);
kinectstream.EAR_LEFT.Quaternion.x = Kinectstream.EAR_LEFT.Quaternion.x(index);
kinectstream.EAR_LEFT.Quaternion.y = Kinectstream.EAR_LEFT.Quaternion.y(index);
kinectstream.EAR_LEFT.Quaternion.z = Kinectstream.EAR_LEFT.Quaternion.z(index);

kinectstream.EYE_RIGHT.x = Kinectstream.EYE_RIGHT.x(index);
kinectstream.EYE_RIGHT.y = Kinectstream.EYE_RIGHT.y(index);
kinectstream.EYE_RIGHT.z = Kinectstream.EYE_RIGHT.z(index);
kinectstream.EYE_RIGHT.Quaternion.w = Kinectstream.EYE_RIGHT.Quaternion.w(index);
kinectstream.EYE_RIGHT.Quaternion.x = Kinectstream.EYE_RIGHT.Quaternion.x(index);
kinectstream.EYE_RIGHT.Quaternion.y = Kinectstream.EYE_RIGHT.Quaternion.y(index);
kinectstream.EYE_RIGHT.Quaternion.z = Kinectstream.EYE_RIGHT.Quaternion.z(index);

kinectstream.EAR_RIGHT.x = Kinectstream.EAR_RIGHT.x(index);
kinectstream.EAR_RIGHT.y = Kinectstream.EAR_RIGHT.y(index);
kinectstream.EAR_RIGHT.z = Kinectstream.EAR_RIGHT.z(index);
kinectstream.EAR_RIGHT.Quaternion.w = Kinectstream.EAR_RIGHT.Quaternion.w(index);
kinectstream.EAR_RIGHT.Quaternion.x = Kinectstream.EAR_RIGHT.Quaternion.x(index);
kinectstream.EAR_RIGHT.Quaternion.y = Kinectstream.EAR_RIGHT.Quaternion.y(index);
kinectstream.EAR_RIGHT.Quaternion.z = Kinectstream.EAR_RIGHT.Quaternion.z(index);
end

%% 合并数据
function Kinectstream = Merge_K(Kinectstream0,Kinectstream1)
Kinectstream.wtime = [Kinectstream0.wtime ;Kinectstream1.wtime ];
Kinectstream.ktime = [Kinectstream0.ktime ;Kinectstream1.ktime ];
Kinectstream.name  = [Kinectstream0.name  ;Kinectstream1.name  ];
Kinectstream.PELVIS.x = [Kinectstream0.PELVIS.x ;Kinectstream1.PELVIS.x ];
Kinectstream.PELVIS.y = [Kinectstream0.PELVIS.y ;Kinectstream1.PELVIS.y ];
Kinectstream.PELVIS.z = [Kinectstream0.PELVIS.z ;Kinectstream1.PELVIS.z ];
Kinectstream.PELVIS.Quaternion.w = [Kinectstream0.PELVIS.Quaternion.w ;Kinectstream1.PELVIS.Quaternion.w ];
Kinectstream.PELVIS.Quaternion.x = [Kinectstream0.PELVIS.Quaternion.x ;Kinectstream1.PELVIS.Quaternion.x ];
Kinectstream.PELVIS.Quaternion.y = [Kinectstream0.PELVIS.Quaternion.y ;Kinectstream1.PELVIS.Quaternion.y ];
Kinectstream.PELVIS.Quaternion.z = [Kinectstream0.PELVIS.Quaternion.z ;Kinectstream1.PELVIS.Quaternion.z ];
Kinectstream.SPINE_NAVAL.x = [Kinectstream0.SPINE_NAVAL.x ;Kinectstream1.SPINE_NAVAL.x ];
Kinectstream.SPINE_NAVAL.y = [Kinectstream0.SPINE_NAVAL.y ;Kinectstream1.SPINE_NAVAL.y ];
Kinectstream.SPINE_NAVAL.z = [Kinectstream0.SPINE_NAVAL.z ;Kinectstream1.SPINE_NAVAL.z ];
Kinectstream.SPINE_NAVAL.Quaternion.w = [Kinectstream0.SPINE_NAVAL.Quaternion.w ;Kinectstream1.SPINE_NAVAL.Quaternion.w ];
Kinectstream.SPINE_NAVAL.Quaternion.x = [Kinectstream0.SPINE_NAVAL.Quaternion.x ;Kinectstream1.SPINE_NAVAL.Quaternion.x ];
Kinectstream.SPINE_NAVAL.Quaternion.y = [Kinectstream0.SPINE_NAVAL.Quaternion.y ;Kinectstream1.SPINE_NAVAL.Quaternion.y ];
Kinectstream.SPINE_NAVAL.Quaternion.z = [Kinectstream0.SPINE_NAVAL.Quaternion.z ;Kinectstream1.SPINE_NAVAL.Quaternion.z ];
Kinectstream.SPINE_CHEST.x = [Kinectstream0.SPINE_CHEST.x ;Kinectstream1.SPINE_CHEST.x ];
Kinectstream.SPINE_CHEST.y = [Kinectstream0.SPINE_CHEST.y ;Kinectstream1.SPINE_CHEST.y ];
Kinectstream.SPINE_CHEST.z = [Kinectstream0.SPINE_CHEST.z ;Kinectstream1.SPINE_CHEST.z ];
Kinectstream.SPINE_CHEST.Quaternion.w = [Kinectstream0.SPINE_CHEST.Quaternion.w ;Kinectstream1.SPINE_CHEST.Quaternion.w ];
Kinectstream.SPINE_CHEST.Quaternion.x = [Kinectstream0.SPINE_CHEST.Quaternion.x ;Kinectstream1.SPINE_CHEST.Quaternion.x ];
Kinectstream.SPINE_CHEST.Quaternion.y = [Kinectstream0.SPINE_CHEST.Quaternion.y ;Kinectstream1.SPINE_CHEST.Quaternion.y ];
Kinectstream.SPINE_CHEST.Quaternion.z = [Kinectstream0.SPINE_CHEST.Quaternion.z ;Kinectstream1.SPINE_CHEST.Quaternion.z ];
Kinectstream.NECK.x = [Kinectstream0.NECK.x ;Kinectstream1.NECK.x ];
Kinectstream.NECK.y = [Kinectstream0.NECK.y ;Kinectstream1.NECK.y ];
Kinectstream.NECK.z = [Kinectstream0.NECK.z ;Kinectstream1.NECK.z ];
Kinectstream.NECK.Quaternion.w = [Kinectstream0.NECK.Quaternion.w ;Kinectstream1.NECK.Quaternion.w ];
Kinectstream.NECK.Quaternion.x = [Kinectstream0.NECK.Quaternion.x ;Kinectstream1.NECK.Quaternion.x ];
Kinectstream.NECK.Quaternion.y = [Kinectstream0.NECK.Quaternion.y ;Kinectstream1.NECK.Quaternion.y ];
Kinectstream.NECK.Quaternion.z = [Kinectstream0.NECK.Quaternion.z ;Kinectstream1.NECK.Quaternion.z ];
Kinectstream.CLAVICLE_LEFT.x = [Kinectstream0.CLAVICLE_LEFT.x ;Kinectstream1.CLAVICLE_LEFT.x ];
Kinectstream.CLAVICLE_LEFT.y = [Kinectstream0.CLAVICLE_LEFT.y ;Kinectstream1.CLAVICLE_LEFT.y ];
Kinectstream.CLAVICLE_LEFT.z = [Kinectstream0.CLAVICLE_LEFT.z ;Kinectstream1.CLAVICLE_LEFT.z ];
Kinectstream.CLAVICLE_LEFT.Quaternion.w = [Kinectstream0.CLAVICLE_LEFT.Quaternion.w ;Kinectstream1.CLAVICLE_LEFT.Quaternion.w ];
Kinectstream.CLAVICLE_LEFT.Quaternion.x = [Kinectstream0.CLAVICLE_LEFT.Quaternion.x ;Kinectstream1.CLAVICLE_LEFT.Quaternion.x ];
Kinectstream.CLAVICLE_LEFT.Quaternion.y = [Kinectstream0.CLAVICLE_LEFT.Quaternion.y ;Kinectstream1.CLAVICLE_LEFT.Quaternion.y ];
Kinectstream.CLAVICLE_LEFT.Quaternion.z = [Kinectstream0.CLAVICLE_LEFT.Quaternion.z ;Kinectstream1.CLAVICLE_LEFT.Quaternion.z ];
Kinectstream.SHOULDER_LEFT.x = [Kinectstream0.SHOULDER_LEFT.x ;Kinectstream1.SHOULDER_LEFT.x ];
Kinectstream.SHOULDER_LEFT.y = [Kinectstream0.SHOULDER_LEFT.y ;Kinectstream1.SHOULDER_LEFT.y ];
Kinectstream.SHOULDER_LEFT.z = [Kinectstream0.SHOULDER_LEFT.z ;Kinectstream1.SHOULDER_LEFT.z ];
Kinectstream.SHOULDER_LEFT.Quaternion.w = [Kinectstream0.SHOULDER_LEFT.Quaternion.w ;Kinectstream1.SHOULDER_LEFT.Quaternion.w ];
Kinectstream.SHOULDER_LEFT.Quaternion.x = [Kinectstream0.SHOULDER_LEFT.Quaternion.x ;Kinectstream1.SHOULDER_LEFT.Quaternion.x ];
Kinectstream.SHOULDER_LEFT.Quaternion.y = [Kinectstream0.SHOULDER_LEFT.Quaternion.y ;Kinectstream1.SHOULDER_LEFT.Quaternion.y ];
Kinectstream.SHOULDER_LEFT.Quaternion.z = [Kinectstream0.SHOULDER_LEFT.Quaternion.z ;Kinectstream1.SHOULDER_LEFT.Quaternion.z ];
Kinectstream.ELBOW_LEFT.x = [Kinectstream0.ELBOW_LEFT.x ;Kinectstream1.ELBOW_LEFT.x ];
Kinectstream.ELBOW_LEFT.y = [Kinectstream0.ELBOW_LEFT.y ;Kinectstream1.ELBOW_LEFT.y ];
Kinectstream.ELBOW_LEFT.z = [Kinectstream0.ELBOW_LEFT.z ;Kinectstream1.ELBOW_LEFT.z ];
Kinectstream.ELBOW_LEFT.Quaternion.w = [Kinectstream0.ELBOW_LEFT.Quaternion.w ;Kinectstream1.ELBOW_LEFT.Quaternion.w ];
Kinectstream.ELBOW_LEFT.Quaternion.x = [Kinectstream0.ELBOW_LEFT.Quaternion.x ;Kinectstream1.ELBOW_LEFT.Quaternion.x ];
Kinectstream.ELBOW_LEFT.Quaternion.y = [Kinectstream0.ELBOW_LEFT.Quaternion.y ;Kinectstream1.ELBOW_LEFT.Quaternion.y ];
Kinectstream.ELBOW_LEFT.Quaternion.z = [Kinectstream0.ELBOW_LEFT.Quaternion.z ;Kinectstream1.ELBOW_LEFT.Quaternion.z ];
Kinectstream.WRIST_LEFT.x = [Kinectstream0.WRIST_LEFT.x ;Kinectstream1.WRIST_LEFT.x ];
Kinectstream.WRIST_LEFT.y = [Kinectstream0.WRIST_LEFT.y ;Kinectstream1.WRIST_LEFT.y ];
Kinectstream.WRIST_LEFT.z = [Kinectstream0.WRIST_LEFT.z ;Kinectstream1.WRIST_LEFT.z ];
Kinectstream.WRIST_LEFT.Quaternion.w = [Kinectstream0.WRIST_LEFT.Quaternion.w ;Kinectstream1.WRIST_LEFT.Quaternion.w ];
Kinectstream.WRIST_LEFT.Quaternion.x = [Kinectstream0.WRIST_LEFT.Quaternion.x ;Kinectstream1.WRIST_LEFT.Quaternion.x ];
Kinectstream.WRIST_LEFT.Quaternion.y = [Kinectstream0.WRIST_LEFT.Quaternion.y ;Kinectstream1.WRIST_LEFT.Quaternion.y ];
Kinectstream.WRIST_LEFT.Quaternion.z = [Kinectstream0.WRIST_LEFT.Quaternion.z ;Kinectstream1.WRIST_LEFT.Quaternion.z ];
Kinectstream.HAND_LEFT.x = [Kinectstream0.HAND_LEFT.x ;Kinectstream1.HAND_LEFT.x ];
Kinectstream.HAND_LEFT.y = [Kinectstream0.HAND_LEFT.y ;Kinectstream1.HAND_LEFT.y ];
Kinectstream.HAND_LEFT.z = [Kinectstream0.HAND_LEFT.z ;Kinectstream1.HAND_LEFT.z ];
Kinectstream.HAND_LEFT.Quaternion.w = [Kinectstream0.HAND_LEFT.Quaternion.w ;Kinectstream1.HAND_LEFT.Quaternion.w ];
Kinectstream.HAND_LEFT.Quaternion.x = [Kinectstream0.HAND_LEFT.Quaternion.x ;Kinectstream1.HAND_LEFT.Quaternion.x ];
Kinectstream.HAND_LEFT.Quaternion.y = [Kinectstream0.HAND_LEFT.Quaternion.y ;Kinectstream1.HAND_LEFT.Quaternion.y ];
Kinectstream.HAND_LEFT.Quaternion.z = [Kinectstream0.HAND_LEFT.Quaternion.z ;Kinectstream1.HAND_LEFT.Quaternion.z ];
Kinectstream.HANDTIP_LEFT.x = [Kinectstream0.HANDTIP_LEFT.x ;Kinectstream1.HANDTIP_LEFT.x ];
Kinectstream.HANDTIP_LEFT.y = [Kinectstream0.HANDTIP_LEFT.y ;Kinectstream1.HANDTIP_LEFT.y ];
Kinectstream.HANDTIP_LEFT.z = [Kinectstream0.HANDTIP_LEFT.z ;Kinectstream1.HANDTIP_LEFT.z ];
Kinectstream.HANDTIP_LEFT.Quaternion.w = [Kinectstream0.HANDTIP_LEFT.Quaternion.w ;Kinectstream1.HANDTIP_LEFT.Quaternion.w ];
Kinectstream.HANDTIP_LEFT.Quaternion.x = [Kinectstream0.HANDTIP_LEFT.Quaternion.x ;Kinectstream1.HANDTIP_LEFT.Quaternion.x ];
Kinectstream.HANDTIP_LEFT.Quaternion.y = [Kinectstream0.HANDTIP_LEFT.Quaternion.y ;Kinectstream1.HANDTIP_LEFT.Quaternion.y ];
Kinectstream.HANDTIP_LEFT.Quaternion.z = [Kinectstream0.HANDTIP_LEFT.Quaternion.z ;Kinectstream1.HANDTIP_LEFT.Quaternion.z ];
Kinectstream.THUMB_LEFT.x = [Kinectstream0.THUMB_LEFT.x ;Kinectstream1.THUMB_LEFT.x ];
Kinectstream.THUMB_LEFT.y = [Kinectstream0.THUMB_LEFT.y ;Kinectstream1.THUMB_LEFT.y ];
Kinectstream.THUMB_LEFT.z = [Kinectstream0.THUMB_LEFT.z ;Kinectstream1.THUMB_LEFT.z ];
Kinectstream.THUMB_LEFT.Quaternion.w = [Kinectstream0.THUMB_LEFT.Quaternion.w ;Kinectstream1.THUMB_LEFT.Quaternion.w ];
Kinectstream.THUMB_LEFT.Quaternion.x = [Kinectstream0.THUMB_LEFT.Quaternion.x ;Kinectstream1.THUMB_LEFT.Quaternion.x ];
Kinectstream.THUMB_LEFT.Quaternion.y = [Kinectstream0.THUMB_LEFT.Quaternion.y ;Kinectstream1.THUMB_LEFT.Quaternion.y ];
Kinectstream.THUMB_LEFT.Quaternion.z = [Kinectstream0.THUMB_LEFT.Quaternion.z ;Kinectstream1.THUMB_LEFT.Quaternion.z ];
Kinectstream.CLAVICLE_RIGHT.x = [Kinectstream0.CLAVICLE_RIGHT.x ;Kinectstream1.CLAVICLE_RIGHT.x ];
Kinectstream.CLAVICLE_RIGHT.y = [Kinectstream0.CLAVICLE_RIGHT.y ;Kinectstream1.CLAVICLE_RIGHT.y ];
Kinectstream.CLAVICLE_RIGHT.z = [Kinectstream0.CLAVICLE_RIGHT.z ;Kinectstream1.CLAVICLE_RIGHT.z ];
Kinectstream.CLAVICLE_RIGHT.Quaternion.w = [Kinectstream0.CLAVICLE_RIGHT.Quaternion.w ;Kinectstream1.CLAVICLE_RIGHT.Quaternion.w ];
Kinectstream.CLAVICLE_RIGHT.Quaternion.x = [Kinectstream0.CLAVICLE_RIGHT.Quaternion.x ;Kinectstream1.CLAVICLE_RIGHT.Quaternion.x ];
Kinectstream.CLAVICLE_RIGHT.Quaternion.y = [Kinectstream0.CLAVICLE_RIGHT.Quaternion.y ;Kinectstream1.CLAVICLE_RIGHT.Quaternion.y ];
Kinectstream.CLAVICLE_RIGHT.Quaternion.z = [Kinectstream0.CLAVICLE_RIGHT.Quaternion.z ;Kinectstream1.CLAVICLE_RIGHT.Quaternion.z ];
Kinectstream.SHOULDER_RIGHT.x = [Kinectstream0.SHOULDER_RIGHT.x ;Kinectstream1.SHOULDER_RIGHT.x ];
Kinectstream.SHOULDER_RIGHT.y = [Kinectstream0.SHOULDER_RIGHT.y ;Kinectstream1.SHOULDER_RIGHT.y ];
Kinectstream.SHOULDER_RIGHT.z = [Kinectstream0.SHOULDER_RIGHT.z ;Kinectstream1.SHOULDER_RIGHT.z ];
Kinectstream.SHOULDER_RIGHT.Quaternion.w = [Kinectstream0.SHOULDER_RIGHT.Quaternion.w ;Kinectstream1.SHOULDER_RIGHT.Quaternion.w ];
Kinectstream.SHOULDER_RIGHT.Quaternion.x = [Kinectstream0.SHOULDER_RIGHT.Quaternion.x ;Kinectstream1.SHOULDER_RIGHT.Quaternion.x ];
Kinectstream.SHOULDER_RIGHT.Quaternion.y = [Kinectstream0.SHOULDER_RIGHT.Quaternion.y ;Kinectstream1.SHOULDER_RIGHT.Quaternion.y ];
Kinectstream.SHOULDER_RIGHT.Quaternion.z = [Kinectstream0.SHOULDER_RIGHT.Quaternion.z ;Kinectstream1.SHOULDER_RIGHT.Quaternion.z ];
Kinectstream.ELBOW_RIGHT.x = [Kinectstream0.ELBOW_RIGHT.x ;Kinectstream1.ELBOW_RIGHT.x ];
Kinectstream.ELBOW_RIGHT.y = [Kinectstream0.ELBOW_RIGHT.y ;Kinectstream1.ELBOW_RIGHT.y ];
Kinectstream.ELBOW_RIGHT.z = [Kinectstream0.ELBOW_RIGHT.z ;Kinectstream1.ELBOW_RIGHT.z ];
Kinectstream.ELBOW_RIGHT.Quaternion.w = [Kinectstream0.ELBOW_RIGHT.Quaternion.w ;Kinectstream1.ELBOW_RIGHT.Quaternion.w ];
Kinectstream.ELBOW_RIGHT.Quaternion.x = [Kinectstream0.ELBOW_RIGHT.Quaternion.x ;Kinectstream1.ELBOW_RIGHT.Quaternion.x ];
Kinectstream.ELBOW_RIGHT.Quaternion.y = [Kinectstream0.ELBOW_RIGHT.Quaternion.y ;Kinectstream1.ELBOW_RIGHT.Quaternion.y ];
Kinectstream.ELBOW_RIGHT.Quaternion.z = [Kinectstream0.ELBOW_RIGHT.Quaternion.z ;Kinectstream1.ELBOW_RIGHT.Quaternion.z ];
Kinectstream.WRIST_RIGHT.x = [Kinectstream0.WRIST_RIGHT.x ;Kinectstream1.WRIST_RIGHT.x ];
Kinectstream.WRIST_RIGHT.y = [Kinectstream0.WRIST_RIGHT.y ;Kinectstream1.WRIST_RIGHT.y ];
Kinectstream.WRIST_RIGHT.z = [Kinectstream0.WRIST_RIGHT.z ;Kinectstream1.WRIST_RIGHT.z ];
Kinectstream.WRIST_RIGHT.Quaternion.w = [Kinectstream0.WRIST_RIGHT.Quaternion.w ;Kinectstream1.WRIST_RIGHT.Quaternion.w ];
Kinectstream.WRIST_RIGHT.Quaternion.x = [Kinectstream0.WRIST_RIGHT.Quaternion.x ;Kinectstream1.WRIST_RIGHT.Quaternion.x ];
Kinectstream.WRIST_RIGHT.Quaternion.y = [Kinectstream0.WRIST_RIGHT.Quaternion.y ;Kinectstream1.WRIST_RIGHT.Quaternion.y ];
Kinectstream.WRIST_RIGHT.Quaternion.z = [Kinectstream0.WRIST_RIGHT.Quaternion.z ;Kinectstream1.WRIST_RIGHT.Quaternion.z ];
Kinectstream.HAND_RIGHT.x = [Kinectstream0.HAND_RIGHT.x ;Kinectstream1.HAND_RIGHT.x ];
Kinectstream.HAND_RIGHT.y = [Kinectstream0.HAND_RIGHT.y ;Kinectstream1.HAND_RIGHT.y ];
Kinectstream.HAND_RIGHT.z = [Kinectstream0.HAND_RIGHT.z ;Kinectstream1.HAND_RIGHT.z ];
Kinectstream.HAND_RIGHT.Quaternion.w = [Kinectstream0.HAND_RIGHT.Quaternion.w ;Kinectstream1.HAND_RIGHT.Quaternion.w ];
Kinectstream.HAND_RIGHT.Quaternion.x = [Kinectstream0.HAND_RIGHT.Quaternion.x ;Kinectstream1.HAND_RIGHT.Quaternion.x ];
Kinectstream.HAND_RIGHT.Quaternion.y = [Kinectstream0.HAND_RIGHT.Quaternion.y ;Kinectstream1.HAND_RIGHT.Quaternion.y ];
Kinectstream.HAND_RIGHT.Quaternion.z = [Kinectstream0.HAND_RIGHT.Quaternion.z ;Kinectstream1.HAND_RIGHT.Quaternion.z ];
Kinectstream.HANDTIP_RIGHT.x = [Kinectstream0.HANDTIP_RIGHT.x ;Kinectstream1.HANDTIP_RIGHT.x ];
Kinectstream.HANDTIP_RIGHT.y = [Kinectstream0.HANDTIP_RIGHT.y ;Kinectstream1.HANDTIP_RIGHT.y ];
Kinectstream.HANDTIP_RIGHT.z = [Kinectstream0.HANDTIP_RIGHT.z ;Kinectstream1.HANDTIP_RIGHT.z ];
Kinectstream.HANDTIP_RIGHT.Quaternion.w = [Kinectstream0.HANDTIP_RIGHT.Quaternion.w ;Kinectstream1.HANDTIP_RIGHT.Quaternion.w ];
Kinectstream.HANDTIP_RIGHT.Quaternion.x = [Kinectstream0.HANDTIP_RIGHT.Quaternion.x ;Kinectstream1.HANDTIP_RIGHT.Quaternion.x ];
Kinectstream.HANDTIP_RIGHT.Quaternion.y = [Kinectstream0.HANDTIP_RIGHT.Quaternion.y ;Kinectstream1.HANDTIP_RIGHT.Quaternion.y ];
Kinectstream.HANDTIP_RIGHT.Quaternion.z = [Kinectstream0.HANDTIP_RIGHT.Quaternion.z ;Kinectstream1.HANDTIP_RIGHT.Quaternion.z ];
Kinectstream.THUMB_RIGHT.x = [Kinectstream0.THUMB_RIGHT.x ;Kinectstream1.THUMB_RIGHT.x ];
Kinectstream.THUMB_RIGHT.y = [Kinectstream0.THUMB_RIGHT.y ;Kinectstream1.THUMB_RIGHT.y ];
Kinectstream.THUMB_RIGHT.z = [Kinectstream0.THUMB_RIGHT.z ;Kinectstream1.THUMB_RIGHT.z ];
Kinectstream.THUMB_RIGHT.Quaternion.w = [Kinectstream0.THUMB_RIGHT.Quaternion.w ;Kinectstream1.THUMB_RIGHT.Quaternion.w ];
Kinectstream.THUMB_RIGHT.Quaternion.x = [Kinectstream0.THUMB_RIGHT.Quaternion.x ;Kinectstream1.THUMB_RIGHT.Quaternion.x ];
Kinectstream.THUMB_RIGHT.Quaternion.y = [Kinectstream0.THUMB_RIGHT.Quaternion.y ;Kinectstream1.THUMB_RIGHT.Quaternion.y ];
Kinectstream.THUMB_RIGHT.Quaternion.z = [Kinectstream0.THUMB_RIGHT.Quaternion.z ;Kinectstream1.THUMB_RIGHT.Quaternion.z ];
Kinectstream.HIP_LEFT.x = [Kinectstream0.HIP_LEFT.x ;Kinectstream1.HIP_LEFT.x ];
Kinectstream.HIP_LEFT.y = [Kinectstream0.HIP_LEFT.y ;Kinectstream1.HIP_LEFT.y ];
Kinectstream.HIP_LEFT.z = [Kinectstream0.HIP_LEFT.z ;Kinectstream1.HIP_LEFT.z ];
Kinectstream.HIP_LEFT.Quaternion.w = [Kinectstream0.HIP_LEFT.Quaternion.w ;Kinectstream1.HIP_LEFT.Quaternion.w ];
Kinectstream.HIP_LEFT.Quaternion.x = [Kinectstream0.HIP_LEFT.Quaternion.x ;Kinectstream1.HIP_LEFT.Quaternion.x ];
Kinectstream.HIP_LEFT.Quaternion.y = [Kinectstream0.HIP_LEFT.Quaternion.y ;Kinectstream1.HIP_LEFT.Quaternion.y ];
Kinectstream.HIP_LEFT.Quaternion.z = [Kinectstream0.HIP_LEFT.Quaternion.z ;Kinectstream1.HIP_LEFT.Quaternion.z ];
Kinectstream.KNEE_LEFT.x = [Kinectstream0.KNEE_LEFT.x ;Kinectstream1.KNEE_LEFT.x ];
Kinectstream.KNEE_LEFT.y = [Kinectstream0.KNEE_LEFT.y ;Kinectstream1.KNEE_LEFT.y ];
Kinectstream.KNEE_LEFT.z = [Kinectstream0.KNEE_LEFT.z ;Kinectstream1.KNEE_LEFT.z ];
Kinectstream.KNEE_LEFT.Quaternion.w = [Kinectstream0.KNEE_LEFT.Quaternion.w ;Kinectstream1.KNEE_LEFT.Quaternion.w ];
Kinectstream.KNEE_LEFT.Quaternion.x = [Kinectstream0.KNEE_LEFT.Quaternion.x ;Kinectstream1.KNEE_LEFT.Quaternion.x ];
Kinectstream.KNEE_LEFT.Quaternion.y = [Kinectstream0.KNEE_LEFT.Quaternion.y ;Kinectstream1.KNEE_LEFT.Quaternion.y ];
Kinectstream.KNEE_LEFT.Quaternion.z = [Kinectstream0.KNEE_LEFT.Quaternion.z ;Kinectstream1.KNEE_LEFT.Quaternion.z ];
Kinectstream.ANKLE_LEFT.x = [Kinectstream0.ANKLE_LEFT.x ;Kinectstream1.ANKLE_LEFT.x ];
Kinectstream.ANKLE_LEFT.y = [Kinectstream0.ANKLE_LEFT.y ;Kinectstream1.ANKLE_LEFT.y ];
Kinectstream.ANKLE_LEFT.z = [Kinectstream0.ANKLE_LEFT.z ;Kinectstream1.ANKLE_LEFT.z ];
Kinectstream.ANKLE_LEFT.Quaternion.w = [Kinectstream0.ANKLE_LEFT.Quaternion.w ;Kinectstream1.ANKLE_LEFT.Quaternion.w ];
Kinectstream.ANKLE_LEFT.Quaternion.x = [Kinectstream0.ANKLE_LEFT.Quaternion.x ;Kinectstream1.ANKLE_LEFT.Quaternion.x ];
Kinectstream.ANKLE_LEFT.Quaternion.y = [Kinectstream0.ANKLE_LEFT.Quaternion.y ;Kinectstream1.ANKLE_LEFT.Quaternion.y ];
Kinectstream.ANKLE_LEFT.Quaternion.z = [Kinectstream0.ANKLE_LEFT.Quaternion.z ;Kinectstream1.ANKLE_LEFT.Quaternion.z ];
Kinectstream.FOOT_LEFT.x = [Kinectstream0.FOOT_LEFT.x ;Kinectstream1.FOOT_LEFT.x ];
Kinectstream.FOOT_LEFT.y = [Kinectstream0.FOOT_LEFT.y ;Kinectstream1.FOOT_LEFT.y ];
Kinectstream.FOOT_LEFT.z = [Kinectstream0.FOOT_LEFT.z ;Kinectstream1.FOOT_LEFT.z ];
Kinectstream.FOOT_LEFT.Quaternion.w = [Kinectstream0.FOOT_LEFT.Quaternion.w ;Kinectstream1.FOOT_LEFT.Quaternion.w ];
Kinectstream.FOOT_LEFT.Quaternion.x = [Kinectstream0.FOOT_LEFT.Quaternion.x ;Kinectstream1.FOOT_LEFT.Quaternion.x ];
Kinectstream.FOOT_LEFT.Quaternion.y = [Kinectstream0.FOOT_LEFT.Quaternion.y ;Kinectstream1.FOOT_LEFT.Quaternion.y ];
Kinectstream.FOOT_LEFT.Quaternion.z = [Kinectstream0.FOOT_LEFT.Quaternion.z ;Kinectstream1.FOOT_LEFT.Quaternion.z ];
Kinectstream.HIP_RIGHT.x = [Kinectstream0.HIP_RIGHT.x ;Kinectstream1.HIP_RIGHT.x ];
Kinectstream.HIP_RIGHT.y = [Kinectstream0.HIP_RIGHT.y ;Kinectstream1.HIP_RIGHT.y ];
Kinectstream.HIP_RIGHT.z = [Kinectstream0.HIP_RIGHT.z ;Kinectstream1.HIP_RIGHT.z ];
Kinectstream.HIP_RIGHT.Quaternion.w = [Kinectstream0.HIP_RIGHT.Quaternion.w ;Kinectstream1.HIP_RIGHT.Quaternion.w ];
Kinectstream.HIP_RIGHT.Quaternion.x = [Kinectstream0.HIP_RIGHT.Quaternion.x ;Kinectstream1.HIP_RIGHT.Quaternion.x ];
Kinectstream.HIP_RIGHT.Quaternion.y = [Kinectstream0.HIP_RIGHT.Quaternion.y ;Kinectstream1.HIP_RIGHT.Quaternion.y ];
Kinectstream.HIP_RIGHT.Quaternion.z = [Kinectstream0.HIP_RIGHT.Quaternion.z ;Kinectstream1.HIP_RIGHT.Quaternion.z ];
Kinectstream.KNEE_RIGHT.x = [Kinectstream0.KNEE_RIGHT.x ;Kinectstream1.KNEE_RIGHT.x ];
Kinectstream.KNEE_RIGHT.y = [Kinectstream0.KNEE_RIGHT.y ;Kinectstream1.KNEE_RIGHT.y ];
Kinectstream.KNEE_RIGHT.z = [Kinectstream0.KNEE_RIGHT.z ;Kinectstream1.KNEE_RIGHT.z ];
Kinectstream.KNEE_RIGHT.Quaternion.w = [Kinectstream0.KNEE_RIGHT.Quaternion.w ;Kinectstream1.KNEE_RIGHT.Quaternion.w ];
Kinectstream.KNEE_RIGHT.Quaternion.x = [Kinectstream0.KNEE_RIGHT.Quaternion.x ;Kinectstream1.KNEE_RIGHT.Quaternion.x ];
Kinectstream.KNEE_RIGHT.Quaternion.y = [Kinectstream0.KNEE_RIGHT.Quaternion.y ;Kinectstream1.KNEE_RIGHT.Quaternion.y ];
Kinectstream.KNEE_RIGHT.Quaternion.z = [Kinectstream0.KNEE_RIGHT.Quaternion.z ;Kinectstream1.KNEE_RIGHT.Quaternion.z ];
Kinectstream.ANKLE_RIGHT.x = [Kinectstream0.ANKLE_RIGHT.x ;Kinectstream1.ANKLE_RIGHT.x ];
Kinectstream.ANKLE_RIGHT.y = [Kinectstream0.ANKLE_RIGHT.y ;Kinectstream1.ANKLE_RIGHT.y ];
Kinectstream.ANKLE_RIGHT.z = [Kinectstream0.ANKLE_RIGHT.z ;Kinectstream1.ANKLE_RIGHT.z ];
Kinectstream.ANKLE_RIGHT.Quaternion.w = [Kinectstream0.ANKLE_RIGHT.Quaternion.w ;Kinectstream1.ANKLE_RIGHT.Quaternion.w ];
Kinectstream.ANKLE_RIGHT.Quaternion.x = [Kinectstream0.ANKLE_RIGHT.Quaternion.x ;Kinectstream1.ANKLE_RIGHT.Quaternion.x ];
Kinectstream.ANKLE_RIGHT.Quaternion.y = [Kinectstream0.ANKLE_RIGHT.Quaternion.y ;Kinectstream1.ANKLE_RIGHT.Quaternion.y ];
Kinectstream.ANKLE_RIGHT.Quaternion.z = [Kinectstream0.ANKLE_RIGHT.Quaternion.z ;Kinectstream1.ANKLE_RIGHT.Quaternion.z ];
Kinectstream.FOOT_RIGHT.x = [Kinectstream0.FOOT_RIGHT.x ;Kinectstream1.FOOT_RIGHT.x ];
Kinectstream.FOOT_RIGHT.y = [Kinectstream0.FOOT_RIGHT.y ;Kinectstream1.FOOT_RIGHT.y ];
Kinectstream.FOOT_RIGHT.z = [Kinectstream0.FOOT_RIGHT.z ;Kinectstream1.FOOT_RIGHT.z ];
Kinectstream.FOOT_RIGHT.Quaternion.w = [Kinectstream0.FOOT_RIGHT.Quaternion.w ;Kinectstream1.FOOT_RIGHT.Quaternion.w ];
Kinectstream.FOOT_RIGHT.Quaternion.x = [Kinectstream0.FOOT_RIGHT.Quaternion.x ;Kinectstream1.FOOT_RIGHT.Quaternion.x ];
Kinectstream.FOOT_RIGHT.Quaternion.y = [Kinectstream0.FOOT_RIGHT.Quaternion.y ;Kinectstream1.FOOT_RIGHT.Quaternion.y ];
Kinectstream.FOOT_RIGHT.Quaternion.z = [Kinectstream0.FOOT_RIGHT.Quaternion.z ;Kinectstream1.FOOT_RIGHT.Quaternion.z ];
Kinectstream.HEAD.x = [Kinectstream0.HEAD.x ;Kinectstream1.HEAD.x ];
Kinectstream.HEAD.y = [Kinectstream0.HEAD.y ;Kinectstream1.HEAD.y ];
Kinectstream.HEAD.z = [Kinectstream0.HEAD.z ;Kinectstream1.HEAD.z ];
Kinectstream.HEAD.Quaternion.w = [Kinectstream0.HEAD.Quaternion.w ;Kinectstream1.HEAD.Quaternion.w ];
Kinectstream.HEAD.Quaternion.x = [Kinectstream0.HEAD.Quaternion.x ;Kinectstream1.HEAD.Quaternion.x ];
Kinectstream.HEAD.Quaternion.y = [Kinectstream0.HEAD.Quaternion.y ;Kinectstream1.HEAD.Quaternion.y ];
Kinectstream.HEAD.Quaternion.z = [Kinectstream0.HEAD.Quaternion.z ;Kinectstream1.HEAD.Quaternion.z ];
Kinectstream.NOSE.x = [Kinectstream0.NOSE.x ;Kinectstream1.NOSE.x ];
Kinectstream.NOSE.y = [Kinectstream0.NOSE.y ;Kinectstream1.NOSE.y ];
Kinectstream.NOSE.z = [Kinectstream0.NOSE.z ;Kinectstream1.NOSE.z ];
Kinectstream.NOSE.Quaternion.w = [Kinectstream0.NOSE.Quaternion.w ;Kinectstream1.NOSE.Quaternion.w ];
Kinectstream.NOSE.Quaternion.x = [Kinectstream0.NOSE.Quaternion.x ;Kinectstream1.NOSE.Quaternion.x ];
Kinectstream.NOSE.Quaternion.y = [Kinectstream0.NOSE.Quaternion.y ;Kinectstream1.NOSE.Quaternion.y ];
Kinectstream.NOSE.Quaternion.z = [Kinectstream0.NOSE.Quaternion.z ;Kinectstream1.NOSE.Quaternion.z ];
Kinectstream.EYE_LEFT.x = [Kinectstream0.EYE_LEFT.x ;Kinectstream1.EYE_LEFT.x ];
Kinectstream.EYE_LEFT.y = [Kinectstream0.EYE_LEFT.y ;Kinectstream1.EYE_LEFT.y ];
Kinectstream.EYE_LEFT.z = [Kinectstream0.EYE_LEFT.z ;Kinectstream1.EYE_LEFT.z ];
Kinectstream.EYE_LEFT.Quaternion.w = [Kinectstream0.EYE_LEFT.Quaternion.w ;Kinectstream1.EYE_LEFT.Quaternion.w ];
Kinectstream.EYE_LEFT.Quaternion.x = [Kinectstream0.EYE_LEFT.Quaternion.x ;Kinectstream1.EYE_LEFT.Quaternion.x ];
Kinectstream.EYE_LEFT.Quaternion.y = [Kinectstream0.EYE_LEFT.Quaternion.y ;Kinectstream1.EYE_LEFT.Quaternion.y ];
Kinectstream.EYE_LEFT.Quaternion.z = [Kinectstream0.EYE_LEFT.Quaternion.z ;Kinectstream1.EYE_LEFT.Quaternion.z ];
Kinectstream.EAR_LEFT.x = [Kinectstream0.EAR_LEFT.x ;Kinectstream1.EAR_LEFT.x ];
Kinectstream.EAR_LEFT.y = [Kinectstream0.EAR_LEFT.y ;Kinectstream1.EAR_LEFT.y ];
Kinectstream.EAR_LEFT.z = [Kinectstream0.EAR_LEFT.z ;Kinectstream1.EAR_LEFT.z ];
Kinectstream.EAR_LEFT.Quaternion.w = [Kinectstream0.EAR_LEFT.Quaternion.w ;Kinectstream1.EAR_LEFT.Quaternion.w ];
Kinectstream.EAR_LEFT.Quaternion.x = [Kinectstream0.EAR_LEFT.Quaternion.x ;Kinectstream1.EAR_LEFT.Quaternion.x ];
Kinectstream.EAR_LEFT.Quaternion.y = [Kinectstream0.EAR_LEFT.Quaternion.y ;Kinectstream1.EAR_LEFT.Quaternion.y ];
Kinectstream.EAR_LEFT.Quaternion.z = [Kinectstream0.EAR_LEFT.Quaternion.z ;Kinectstream1.EAR_LEFT.Quaternion.z ];
Kinectstream.EYE_RIGHT.x = [Kinectstream0.EYE_RIGHT.x ;Kinectstream1.EYE_RIGHT.x ];
Kinectstream.EYE_RIGHT.y = [Kinectstream0.EYE_RIGHT.y ;Kinectstream1.EYE_RIGHT.y ];
Kinectstream.EYE_RIGHT.z = [Kinectstream0.EYE_RIGHT.z ;Kinectstream1.EYE_RIGHT.z ];
Kinectstream.EYE_RIGHT.Quaternion.w = [Kinectstream0.EYE_RIGHT.Quaternion.w ;Kinectstream1.EYE_RIGHT.Quaternion.w ];
Kinectstream.EYE_RIGHT.Quaternion.x = [Kinectstream0.EYE_RIGHT.Quaternion.x ;Kinectstream1.EYE_RIGHT.Quaternion.x ];
Kinectstream.EYE_RIGHT.Quaternion.y = [Kinectstream0.EYE_RIGHT.Quaternion.y ;Kinectstream1.EYE_RIGHT.Quaternion.y ];
Kinectstream.EYE_RIGHT.Quaternion.z = [Kinectstream0.EYE_RIGHT.Quaternion.z ;Kinectstream1.EYE_RIGHT.Quaternion.z ];
Kinectstream.EAR_RIGHT.x = [Kinectstream0.EAR_RIGHT.x ;Kinectstream1.EAR_RIGHT.x ];
Kinectstream.EAR_RIGHT.y = [Kinectstream0.EAR_RIGHT.y ;Kinectstream1.EAR_RIGHT.y ];
Kinectstream.EAR_RIGHT.z = [Kinectstream0.EAR_RIGHT.z ;Kinectstream1.EAR_RIGHT.z ];
Kinectstream.EAR_RIGHT.Quaternion.w = [Kinectstream0.EAR_RIGHT.Quaternion.w ;Kinectstream1.EAR_RIGHT.Quaternion.w ];
Kinectstream.EAR_RIGHT.Quaternion.x = [Kinectstream0.EAR_RIGHT.Quaternion.x ;Kinectstream1.EAR_RIGHT.Quaternion.x ];
Kinectstream.EAR_RIGHT.Quaternion.y = [Kinectstream0.EAR_RIGHT.Quaternion.y ;Kinectstream1.EAR_RIGHT.Quaternion.y ];
Kinectstream.EAR_RIGHT.Quaternion.z = [Kinectstream0.EAR_RIGHT.Quaternion.z ;Kinectstream1.EAR_RIGHT.Quaternion.z ];
end