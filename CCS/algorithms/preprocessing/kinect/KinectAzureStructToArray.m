%% FUNC KinectAzureStructToArray：根据单个body的stream生成每帧的关节矩阵
function jointArrayCell = KinectAzureStructToArray(stream)
dataLength = length(stream.wtime);
jointArrayCell = cell(1,dataLength);
if isfield(stream,'CLAVICLE_LEFT') % Kinect V3
    for i = 1:dataLength
        jointArrayCell{i}.time = stream.wtime(i);
        jointArrayCell{i}.joints(1,:) = [stream.PELVIS.x(i),stream.PELVIS.y(i),stream.PELVIS.z(i)];
        jointArrayCell{i}.joints(2,:) = [stream.HEAD.x(i),stream.HEAD.y(i),stream.HEAD.z(i)];
        jointArrayCell{i}.joints(3,:) = [stream.SHOULDER_LEFT.x(i),stream.SHOULDER_LEFT.y(i),stream.SHOULDER_LEFT.z(i)];
        jointArrayCell{i}.joints(4,:) = [stream.ELBOW_LEFT.x(i),stream.ELBOW_LEFT.y(i),stream.ELBOW_LEFT.z(i)];
        jointArrayCell{i}.joints(5,:) = [stream.WRIST_LEFT.x(i),stream.WRIST_LEFT.y(i),stream.WRIST_LEFT.z(i)];
        jointArrayCell{i}.joints(6,:) = [stream.HAND_LEFT.x(i),stream.HAND_LEFT.y(i),stream.HAND_LEFT.z(i)];
        jointArrayCell{i}.joints(7,:) = [stream.SHOULDER_RIGHT.x(i),stream.SHOULDER_RIGHT.y(i),stream.SHOULDER_RIGHT.z(i)];
        jointArrayCell{i}.joints(8,:) = [stream.ELBOW_RIGHT.x(i),stream.ELBOW_RIGHT.y(i),stream.ELBOW_RIGHT.z(i)];
        jointArrayCell{i}.joints(9,:) = [stream.WRIST_RIGHT.x(i),stream.WRIST_RIGHT.y(i),stream.WRIST_RIGHT.z(i)];
        jointArrayCell{i}.joints(10,:) = [stream.HAND_RIGHT.x(i),stream.HAND_RIGHT.y(i),stream.HAND_RIGHT.z(i)];
        jointArrayCell{i}.joints(11,:) = [stream.HIP_LEFT.x(i),stream.HIP_LEFT.y(i),stream.HIP_LEFT.z(i)];
        jointArrayCell{i}.joints(12,:) = [stream.KNEE_LEFT.x(i),stream.KNEE_LEFT.y(i),stream.KNEE_LEFT.z(i)];
        jointArrayCell{i}.joints(13,:) = [stream.ANKLE_LEFT.x(i),stream.ANKLE_LEFT.y(i),stream.ANKLE_LEFT.z(i)];
        jointArrayCell{i}.joints(14,:) = [stream.FOOT_LEFT.x(i),stream.FOOT_LEFT.y(i),stream.FOOT_LEFT.z(i)];
        jointArrayCell{i}.joints(15,:) = [stream.HIP_RIGHT.x(i),stream.HIP_RIGHT.y(i),stream.HIP_RIGHT.z(i)];
        jointArrayCell{i}.joints(16,:) = [stream.KNEE_RIGHT.x(i),stream.KNEE_RIGHT.y(i),stream.KNEE_RIGHT.z(i)];
        jointArrayCell{i}.joints(17,:) = [stream.ANKLE_RIGHT.x(i),stream.ANKLE_RIGHT.y(i),stream.ANKLE_RIGHT.z(i)];
        jointArrayCell{i}.joints(18,:) = [stream.FOOT_RIGHT.x(i),stream.FOOT_RIGHT.y(i),stream.FOOT_RIGHT.z(i)];
        % 锁骨中点
        jointArrayCell{i}.joints(19,:) = [0.5 * stream.CLAVICLE_LEFT.x(i) + 0.5* stream.CLAVICLE_RIGHT.x(i),...
            0.5 * stream.CLAVICLE_LEFT.y(i) + 0.5* stream.CLAVICLE_RIGHT.y(i),...
            0.5 * stream.CLAVICLE_LEFT.z(i) + 0.5* stream.CLAVICLE_RIGHT.z(i)]; % 和kinect2不一样，kinect2是SpineShoulder

        jointArrayCell{i}.joints(20,:) = [stream.SPINE_NAVAL.x(i),stream.SPINE_NAVAL.y(i),stream.SPINE_NAVAL.z(i)];
        jointArrayCell{i}.joints(21,:) = [stream.SPINE_CHEST.x(i),stream.SPINE_CHEST.y(i),stream.SPINE_CHEST.z(i)];
        
    end
else % Kinect V2
    for i = 1:dataLength
        jointArrayCell{i}.time = stream.wtime(i);
        jointArrayCell{i}.joints(1,:) = [stream.PELVIS.x(i),stream.PELVIS.y(i),stream.PELVIS.z(i)];
        jointArrayCell{i}.joints(2,:) = [stream.HEAD.x(i),stream.HEAD.y(i),stream.HEAD.z(i)];
        jointArrayCell{i}.joints(3,:) = [stream.SHOULDER_LEFT.x(i),stream.SHOULDER_LEFT.y(i),stream.SHOULDER_LEFT.z(i)];
        jointArrayCell{i}.joints(4,:) = [stream.ELBOW_LEFT.x(i),stream.ELBOW_LEFT.y(i),stream.ELBOW_LEFT.z(i)];
        jointArrayCell{i}.joints(5,:) = [stream.WRIST_LEFT.x(i),stream.WRIST_LEFT.y(i),stream.WRIST_LEFT.z(i)];
        jointArrayCell{i}.joints(6,:) = [stream.HAND_LEFT.x(i),stream.HAND_LEFT.y(i),stream.HAND_LEFT.z(i)];
        jointArrayCell{i}.joints(7,:) = [stream.SHOULDER_RIGHT.x(i),stream.SHOULDER_RIGHT.y(i),stream.SHOULDER_RIGHT.z(i)];
        jointArrayCell{i}.joints(8,:) = [stream.ELBOW_RIGHT.x(i),stream.ELBOW_RIGHT.y(i),stream.ELBOW_RIGHT.z(i)];
        jointArrayCell{i}.joints(9,:) = [stream.WRIST_RIGHT.x(i),stream.WRIST_RIGHT.y(i),stream.WRIST_RIGHT.z(i)];
        jointArrayCell{i}.joints(10,:) = [stream.HAND_RIGHT.x(i),stream.HAND_RIGHT.y(i),stream.HAND_RIGHT.z(i)];
        jointArrayCell{i}.joints(11,:) = [stream.HIP_LEFT.x(i),stream.HIP_LEFT.y(i),stream.HIP_LEFT.z(i)];
        jointArrayCell{i}.joints(12,:) = [stream.KNEE_LEFT.x(i),stream.KNEE_LEFT.y(i),stream.KNEE_LEFT.z(i)];
        jointArrayCell{i}.joints(13,:) = [stream.ANKLE_LEFT.x(i),stream.ANKLE_LEFT.y(i),stream.ANKLE_LEFT.z(i)];
        jointArrayCell{i}.joints(14,:) = [stream.FOOT_LEFT.x(i),stream.FOOT_LEFT.y(i),stream.FOOT_LEFT.z(i)];
        jointArrayCell{i}.joints(15,:) = [stream.HIP_RIGHT.x(i),stream.HIP_RIGHT.y(i),stream.HIP_RIGHT.z(i)];
        jointArrayCell{i}.joints(16,:) = [stream.KNEE_RIGHT.x(i),stream.KNEE_RIGHT.y(i),stream.KNEE_RIGHT.z(i)];
        jointArrayCell{i}.joints(17,:) = [stream.ANKLE_RIGHT.x(i),stream.ANKLE_RIGHT.y(i),stream.ANKLE_RIGHT.z(i)];
        jointArrayCell{i}.joints(18,:) = [stream.FOOT_RIGHT.x(i),stream.FOOT_RIGHT.y(i),stream.FOOT_RIGHT.z(i)];
        
        jointArrayCell{i}.joints(19,:) = [stream.SPINE_SHOULDER.x(i),stream.SPINE_SHOULDER.y(i),stream.SPINE_SHOULDER.z(i)];
        
    end
    
end
end