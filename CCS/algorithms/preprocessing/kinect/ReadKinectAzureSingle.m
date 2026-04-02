%% FUNC ReadKinectAzureSingle：读取文件，转化为stream
% 32个关节点：https://learn.microsoft.com/zh-cn/azure/kinect-dk/body-joints
function Mas_stream = ReadKinectAzureSingle(fileName)
% Kinect坐标：向右 x；向下 y；向前 z

% 原始数据读取
fileID = fopen(fileName);
% %[^\n]表示之后的数字都读到一个结构体里面去，包括分隔符
c = textscan(fileID, '%s %{yyyy-MM-dd HH:mm:ss:SSS}D %64d %d %d   %[^\n]', 'delimiter', ',');
fclose(fileID);

%% Mas与Sub分开
kinectName = zeros(length(c{1, 1}),1);
for i = 1:length(c{1, 1})
    if strcmp(c{1, 1}{i},'MASTER')
        kinectName(i) = 0; % mas
    else
        kinectName(i) = 1; % sub
    end
end
%% 提取MASTER
Mas_index = kinectName == 0;
for i=1:6
    cMas{1,i} = c{1,i}(Mas_index);
end
if sum(cMas{1,4}) == 0 % 若没有检测到人体
    Mas_stream = struct();
else
    Mas_stream = Decode_k(cMas);
end
end


%% FUNC Decode_k：数据帧解析
function stream = Decode_k(c)
%% 找出所有的bodyID
cntFrame = 0;
for i = 1: 1: length(c{1, 6})
    numBody = c{1, 4}(i);
    frame = str2num(c{1, 6}{i});
    if numBody < 1   % 确定kinect没有捕捉到了人的数据
        continue;
    else
        for j = 1:numBody
            cntFrame = cntFrame + 1;
            bodyIDAll(cntFrame) = frame((j-1)*257+1); %将bodyid存储，32*（3+4+1）+1=257
        end
    end
end
bodyID = unique(bodyIDAll);
%%
for id = 1:length(bodyID)
    cntFrame = 0;
    for i = 1: 1: length(c{1, 6}) % 逐帧读取数据
        numBody = c{1, 4}(i); % 该帧的人体个数
        frame = str2num(c{1, 6}{i});
        if numBody < 1  % 确定kinect没有捕捉到人的数据
            continue;
        else
            id_flag = 0;
            for j = 1:numBody % 判断id是否存在于该帧
                if bodyID(id) == frame((j-1)*257+1) % 将bodyID存储，32*(3+4+1)+1=257
                    id_flag = j;
                end
            end
            if id_flag >0
                cntFrame = cntFrame + 1;
                stream{id}.name(cntFrame, 1) = c{1, 1}(i);
                stream{id}.wtime(cntFrame, 1) = c{1, 2}(i); % 上位机时间
                stream{id}.ktime(cntFrame, 1) = c{1, 3}(i); % Kinect机器时间
                
                
                b=1+(id_flag-1)*257; % b为body数据的起始位置
                stream{id}.PELVIS.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.PELVIS.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.PELVIS.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.PELVIS.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.PELVIS.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.PELVIS.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.PELVIS.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.PELVIS.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.SPINE_NAVAL.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.SPINE_NAVAL.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.SPINE_NAVAL.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.SPINE_NAVAL.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.SPINE_NAVAL.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.SPINE_NAVAL.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.SPINE_NAVAL.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.SPINE_NAVAL.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.SPINE_CHEST.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.SPINE_CHEST.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.SPINE_CHEST.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.SPINE_CHEST.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.SPINE_CHEST.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.SPINE_CHEST.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.SPINE_CHEST.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.SPINE_CHEST.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.NECK.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.NECK.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.NECK.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.NECK.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.NECK.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.NECK.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.NECK.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.NECK.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.CLAVICLE_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.CLAVICLE_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.CLAVICLE_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.CLAVICLE_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.CLAVICLE_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.CLAVICLE_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.CLAVICLE_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.CLAVICLE_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.SHOULDER_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.SHOULDER_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.SHOULDER_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.SHOULDER_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.SHOULDER_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.SHOULDER_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.SHOULDER_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.SHOULDER_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.ELBOW_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.ELBOW_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.ELBOW_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.ELBOW_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.ELBOW_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.ELBOW_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.ELBOW_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.ELBOW_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.WRIST_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.WRIST_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.WRIST_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.WRIST_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.WRIST_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.WRIST_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.WRIST_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.WRIST_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.HAND_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.HAND_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.HAND_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.HAND_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.HAND_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.HAND_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.HAND_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.HAND_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.HANDTIP_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.HANDTIP_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.HANDTIP_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.HANDTIP_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.HANDTIP_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.HANDTIP_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.HANDTIP_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.HANDTIP_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.THUMB_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.THUMB_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.THUMB_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.THUMB_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.THUMB_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.THUMB_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.THUMB_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.THUMB_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.CLAVICLE_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.CLAVICLE_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.CLAVICLE_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.CLAVICLE_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.CLAVICLE_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.CLAVICLE_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.CLAVICLE_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.CLAVICLE_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.SHOULDER_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.SHOULDER_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.SHOULDER_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.SHOULDER_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.SHOULDER_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.SHOULDER_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.SHOULDER_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.SHOULDER_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.ELBOW_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.ELBOW_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.ELBOW_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.ELBOW_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.ELBOW_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.ELBOW_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.ELBOW_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.ELBOW_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.WRIST_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.WRIST_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.WRIST_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.WRIST_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.WRIST_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.WRIST_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.WRIST_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.WRIST_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.HAND_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.HAND_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.HAND_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.HAND_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.HAND_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.HAND_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.HAND_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.HAND_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                
                b=b+8;
                stream{id}.HANDTIP_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.HANDTIP_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.HANDTIP_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.HANDTIP_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.HANDTIP_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.HANDTIP_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.HANDTIP_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.HANDTIP_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.THUMB_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.THUMB_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.THUMB_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.THUMB_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.THUMB_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.THUMB_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.THUMB_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.THUMB_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.HIP_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.HIP_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.HIP_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.HIP_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.HIP_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.HIP_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.HIP_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.HIP_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.KNEE_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.KNEE_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.KNEE_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.KNEE_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.KNEE_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.KNEE_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.KNEE_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.KNEE_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.ANKLE_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.ANKLE_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.ANKLE_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.ANKLE_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.ANKLE_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.ANKLE_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.ANKLE_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.ANKLE_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.FOOT_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.FOOT_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.FOOT_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.FOOT_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.FOOT_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.FOOT_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.FOOT_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.FOOT_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.HIP_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.HIP_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.HIP_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.HIP_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.HIP_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.HIP_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.HIP_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.HIP_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.KNEE_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.KNEE_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.KNEE_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.KNEE_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.KNEE_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.KNEE_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.KNEE_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.KNEE_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.ANKLE_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.ANKLE_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.ANKLE_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.ANKLE_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.ANKLE_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.ANKLE_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.ANKLE_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.ANKLE_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.FOOT_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.FOOT_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.FOOT_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.FOOT_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.FOOT_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.FOOT_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.FOOT_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.FOOT_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.HEAD.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.HEAD.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.HEAD.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.HEAD.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.HEAD.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.HEAD.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.HEAD.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.HEAD.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.NOSE.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.NOSE.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.NOSE.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.NOSE.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.NOSE.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.NOSE.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.NOSE.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.NOSE.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.EYE_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.EYE_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.EYE_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.EYE_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.EYE_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.EYE_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.EYE_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.EYE_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.EAR_LEFT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.EAR_LEFT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.EAR_LEFT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.EAR_LEFT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.EAR_LEFT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.EAR_LEFT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.EAR_LEFT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.EAR_LEFT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.EYE_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.EYE_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.EYE_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.EYE_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.EYE_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.EYE_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.EYE_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.EYE_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
                
                b=b+8;
                stream{id}.EAR_RIGHT.Confidence(cntFrame, 1) = frame(1+b);
                stream{id}.EAR_RIGHT.x(cntFrame, 1) = frame(2+b)/1000;
                stream{id}.EAR_RIGHT.y(cntFrame, 1) = frame(3+b)/1000;
                stream{id}.EAR_RIGHT.z(cntFrame, 1) = frame(4+b)/1000;
                stream{id}.EAR_RIGHT.Quaternion.w(cntFrame, 1) = frame(5+b);
                stream{id}.EAR_RIGHT.Quaternion.x(cntFrame, 1) = frame(6+b);
                stream{id}.EAR_RIGHT.Quaternion.y(cntFrame, 1) = frame(7+b);
                stream{id}.EAR_RIGHT.Quaternion.z(cntFrame, 1) = frame(8+b);
            end
        end
    end
end
end