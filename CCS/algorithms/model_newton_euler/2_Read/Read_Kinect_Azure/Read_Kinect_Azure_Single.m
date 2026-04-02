function Mas_stream = Read_Kinect_Azure_Single(filename)
% kinect视角的前方为z，原始kinect坐标是向下为y，向右是x


%原始数据读取
fileID = fopen(filename);
% %[^\n]表示之后的数字都读到一个结构体里面去，包括分隔符
c = textscan(fileID, '%s %{yyyy-MM-dd HH:mm:ss:SSS}D %64d %d %d   %[^\n]', 'delimiter', ',');
fclose(fileID);

%% Mas 与sub 分开
for i = 1:length(c{1, 1})
    if strcmp(c{1, 1}{i},'MASTER')
        name(i) = 0;%mas
    else
        name(i) = 1;%sub
    end
end
%% 提取MASTER
Mas_index = name == 0;
for i=1:6
    c_Mas{1,i} = c{1,i}(Mas_index);
end
Mas_stream = Decode_k(c_Mas);
end
%% 数据帧解析
function stream = Decode_k(c)

%% 找出所有的bodyid
count = 0;
for i = 1: 1: length(c{1, 6})
    numbody = c{1, 4}(i);
    frame = str2num(c{1, 6}{i});
    if numbody < 1   % 确定kinect没有捕捉到了人的数据
        continue;
    else
        for j=1:numbody
            count = count + 1;
            bodyid_all(count) = frame((j-1)*257+1); %将bodyid存储，32*（3+4+1）+1=257
        end
    end
end
bodyid = unique(bodyid_all);
%%
for id = 1:length(bodyid)
    
    count = 0;
    for i = 1: 1: length(c{1, 6})
        numbody = c{1, 4}(i);
        frame = str2num(c{1, 6}{i});
        if numbody < 1     % 确定kinect没有捕捉到了人的数据
            continue;
        else
            id_flag = 0;
            for j=1:numbody
                if bodyid(id) == frame((j-1)*257+1) %将bodyid存储，32*（3+4+1）+1=257
                    id_flag = j;
                end
            end
            if id_flag >0
                count = count + 1;
                stream{id}.name(count, 1) = c{1, 1}(i);
                stream{id}.wtime(count, 1) = c{1, 2}(i);
                stream{id}.ktime(count, 1) = c{1, 3}(i);
                
                
                b=1+(id_flag-1)*257;
                stream{id}.PELVIS.Confidence(count, 1) = frame(1+b);
                stream{id}.PELVIS.x(count, 1) = frame(2+b)/1000;
                stream{id}.PELVIS.y(count, 1) = frame(3+b)/1000;
                stream{id}.PELVIS.z(count, 1) = frame(4+b)/1000;
                stream{id}.PELVIS.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.PELVIS.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.PELVIS.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.PELVIS.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.SPINE_NAVAL.Confidence(count, 1) = frame(1+b);
                stream{id}.SPINE_NAVAL.x(count, 1) = frame(2+b)/1000;
                stream{id}.SPINE_NAVAL.y(count, 1) = frame(3+b)/1000;
                stream{id}.SPINE_NAVAL.z(count, 1) = frame(4+b)/1000;
                stream{id}.SPINE_NAVAL.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.SPINE_NAVAL.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.SPINE_NAVAL.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.SPINE_NAVAL.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.SPINE_CHEST.Confidence(count, 1) = frame(1+b);
                stream{id}.SPINE_CHEST.x(count, 1) = frame(2+b)/1000;
                stream{id}.SPINE_CHEST.y(count, 1) = frame(3+b)/1000;
                stream{id}.SPINE_CHEST.z(count, 1) = frame(4+b)/1000;
                stream{id}.SPINE_CHEST.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.SPINE_CHEST.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.SPINE_CHEST.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.SPINE_CHEST.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.NECK.Confidence(count, 1) = frame(1+b);
                stream{id}.NECK.x(count, 1) = frame(2+b)/1000;
                stream{id}.NECK.y(count, 1) = frame(3+b)/1000;
                stream{id}.NECK.z(count, 1) = frame(4+b)/1000;
                stream{id}.NECK.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.NECK.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.NECK.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.NECK.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.CLAVICLE_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.CLAVICLE_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.CLAVICLE_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.CLAVICLE_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.CLAVICLE_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.CLAVICLE_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.CLAVICLE_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.CLAVICLE_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.SHOULDER_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.SHOULDER_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.SHOULDER_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.SHOULDER_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.SHOULDER_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.SHOULDER_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.SHOULDER_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.SHOULDER_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.ELBOW_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.ELBOW_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.ELBOW_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.ELBOW_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.ELBOW_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.ELBOW_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.ELBOW_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.ELBOW_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.WRIST_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.WRIST_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.WRIST_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.WRIST_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.WRIST_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.WRIST_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.WRIST_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.WRIST_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.HAND_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.HAND_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.HAND_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.HAND_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.HAND_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.HAND_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.HAND_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.HAND_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.HANDTIP_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.HANDTIP_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.HANDTIP_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.HANDTIP_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.HANDTIP_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.HANDTIP_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.HANDTIP_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.HANDTIP_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.THUMB_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.THUMB_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.THUMB_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.THUMB_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.THUMB_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.THUMB_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.THUMB_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.THUMB_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.CLAVICLE_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.CLAVICLE_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.CLAVICLE_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.CLAVICLE_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.CLAVICLE_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.CLAVICLE_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.CLAVICLE_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.CLAVICLE_RIGHT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.SHOULDER_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.SHOULDER_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.SHOULDER_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.SHOULDER_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.SHOULDER_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.SHOULDER_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.SHOULDER_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.SHOULDER_RIGHT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.ELBOW_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.ELBOW_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.ELBOW_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.ELBOW_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.ELBOW_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.ELBOW_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.ELBOW_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.ELBOW_RIGHT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.WRIST_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.WRIST_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.WRIST_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.WRIST_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.WRIST_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.WRIST_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.WRIST_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.WRIST_RIGHT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.HAND_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.HAND_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.HAND_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.HAND_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.HAND_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.HAND_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.HAND_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.HAND_RIGHT.Quaternion.z(count, 1) = frame(8+b);
                
                
                b=b+8;
                stream{id}.HANDTIP_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.HANDTIP_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.HANDTIP_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.HANDTIP_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.HANDTIP_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.HANDTIP_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.HANDTIP_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.HANDTIP_RIGHT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.THUMB_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.THUMB_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.THUMB_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.THUMB_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.THUMB_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.THUMB_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.THUMB_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.THUMB_RIGHT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.HIP_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.HIP_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.HIP_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.HIP_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.HIP_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.HIP_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.HIP_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.HIP_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.KNEE_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.KNEE_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.KNEE_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.KNEE_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.KNEE_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.KNEE_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.KNEE_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.KNEE_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.ANKLE_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.ANKLE_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.ANKLE_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.ANKLE_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.ANKLE_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.ANKLE_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.ANKLE_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.ANKLE_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.FOOT_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.FOOT_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.FOOT_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.FOOT_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.FOOT_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.FOOT_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.FOOT_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.FOOT_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.HIP_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.HIP_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.HIP_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.HIP_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.HIP_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.HIP_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.HIP_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.HIP_RIGHT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.KNEE_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.KNEE_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.KNEE_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.KNEE_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.KNEE_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.KNEE_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.KNEE_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.KNEE_RIGHT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.ANKLE_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.ANKLE_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.ANKLE_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.ANKLE_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.ANKLE_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.ANKLE_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.ANKLE_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.ANKLE_RIGHT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.FOOT_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.FOOT_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.FOOT_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.FOOT_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.FOOT_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.FOOT_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.FOOT_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.FOOT_RIGHT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.HEAD.Confidence(count, 1) = frame(1+b);
                stream{id}.HEAD.x(count, 1) = frame(2+b)/1000;
                stream{id}.HEAD.y(count, 1) = frame(3+b)/1000;
                stream{id}.HEAD.z(count, 1) = frame(4+b)/1000;
                stream{id}.HEAD.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.HEAD.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.HEAD.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.HEAD.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.NOSE.Confidence(count, 1) = frame(1+b);
                stream{id}.NOSE.x(count, 1) = frame(2+b)/1000;
                stream{id}.NOSE.y(count, 1) = frame(3+b)/1000;
                stream{id}.NOSE.z(count, 1) = frame(4+b)/1000;
                stream{id}.NOSE.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.NOSE.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.NOSE.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.NOSE.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.EYE_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.EYE_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.EYE_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.EYE_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.EYE_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.EYE_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.EYE_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.EYE_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.EAR_LEFT.Confidence(count, 1) = frame(1+b);
                stream{id}.EAR_LEFT.x(count, 1) = frame(2+b)/1000;
                stream{id}.EAR_LEFT.y(count, 1) = frame(3+b)/1000;
                stream{id}.EAR_LEFT.z(count, 1) = frame(4+b)/1000;
                stream{id}.EAR_LEFT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.EAR_LEFT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.EAR_LEFT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.EAR_LEFT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.EYE_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.EYE_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.EYE_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.EYE_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.EYE_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.EYE_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.EYE_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.EYE_RIGHT.Quaternion.z(count, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.EAR_RIGHT.Confidence(count, 1) = frame(1+b);
                stream{id}.EAR_RIGHT.x(count, 1) = frame(2+b)/1000;
                stream{id}.EAR_RIGHT.y(count, 1) = frame(3+b)/1000;
                stream{id}.EAR_RIGHT.z(count, 1) = frame(4+b)/1000;
                stream{id}.EAR_RIGHT.Quaternion.w(count, 1) = frame(5+b);
                stream{id}.EAR_RIGHT.Quaternion.x(count, 1) = frame(6+b);
                stream{id}.EAR_RIGHT.Quaternion.y(count, 1) = frame(7+b);
                stream{id}.EAR_RIGHT.Quaternion.z(count, 1) = frame(8+b);
            end
        end
    end
end
end