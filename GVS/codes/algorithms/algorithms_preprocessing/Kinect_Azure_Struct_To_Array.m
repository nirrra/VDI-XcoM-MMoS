function kinect_cell_arrays = Kinect_Azure_Struct_To_Array(kinectstream)
L = length(kinectstream.wtime);
if isfield(kinectstream,'CLAVICLE_LEFT')
    for i=1:L
        kinect_cell_arrays{i}.time = kinectstream.wtime(i);
        kinect_cell_arrays{i}.joints(1,:) = [kinectstream.PELVIS.x(i),kinectstream.PELVIS.y(i),kinectstream.PELVIS.z(i)];
        kinect_cell_arrays{i}.joints(2,:) = [kinectstream.HEAD.x(i),kinectstream.HEAD.y(i),kinectstream.HEAD.z(i)];
        kinect_cell_arrays{i}.joints(3,:) = [kinectstream.SHOULDER_LEFT.x(i),kinectstream.SHOULDER_LEFT.y(i),kinectstream.SHOULDER_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(4,:) = [kinectstream.ELBOW_LEFT.x(i),kinectstream.ELBOW_LEFT.y(i),kinectstream.ELBOW_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(5,:) = [kinectstream.WRIST_LEFT.x(i),kinectstream.WRIST_LEFT.y(i),kinectstream.WRIST_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(6,:) = [kinectstream.HAND_LEFT.x(i),kinectstream.HAND_LEFT.y(i),kinectstream.HAND_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(7,:) = [kinectstream.SHOULDER_RIGHT.x(i),kinectstream.SHOULDER_RIGHT.y(i),kinectstream.SHOULDER_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(8,:) = [kinectstream.ELBOW_RIGHT.x(i),kinectstream.ELBOW_RIGHT.y(i),kinectstream.ELBOW_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(9,:) = [kinectstream.WRIST_RIGHT.x(i),kinectstream.WRIST_RIGHT.y(i),kinectstream.WRIST_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(10,:) = [kinectstream.HAND_RIGHT.x(i),kinectstream.HAND_RIGHT.y(i),kinectstream.HAND_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(11,:) = [kinectstream.HIP_LEFT.x(i),kinectstream.HIP_LEFT.y(i),kinectstream.HIP_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(12,:) = [kinectstream.KNEE_LEFT.x(i),kinectstream.KNEE_LEFT.y(i),kinectstream.KNEE_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(13,:) = [kinectstream.ANKLE_LEFT.x(i),kinectstream.ANKLE_LEFT.y(i),kinectstream.ANKLE_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(14,:) = [kinectstream.FOOT_LEFT.x(i),kinectstream.FOOT_LEFT.y(i),kinectstream.FOOT_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(15,:) = [kinectstream.HIP_RIGHT.x(i),kinectstream.HIP_RIGHT.y(i),kinectstream.HIP_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(16,:) = [kinectstream.KNEE_RIGHT.x(i),kinectstream.KNEE_RIGHT.y(i),kinectstream.KNEE_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(17,:) = [kinectstream.ANKLE_RIGHT.x(i),kinectstream.ANKLE_RIGHT.y(i),kinectstream.ANKLE_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(18,:) = [kinectstream.FOOT_RIGHT.x(i),kinectstream.FOOT_RIGHT.y(i),kinectstream.FOOT_RIGHT.z(i)];
        
        kinect_cell_arrays{i}.joints(19,:) = [kinectstream.CLAVICLE_LEFT.x(i),kinectstream.CLAVICLE_LEFT.y(i),kinectstream.CLAVICLE_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(20,:) = [kinectstream.CLAVICLE_RIGHT.x(i),kinectstream.CLAVICLE_RIGHT.y(i),kinectstream.CLAVICLE_RIGHT.z(i)];

        % 后续添加
        kinect_cell_arrays{i}.joints(21,:) = [kinectstream.NECK.x(i),kinectstream.NECK.y(i),kinectstream.NECK.z(i)];
        kinect_cell_arrays{i}.joints(22,:) = [kinectstream.SPINE_NAVAL.x(i),kinectstream.SPINE_NAVAL.y(i),kinectstream.SPINE_NAVAL.z(i)];
        kinect_cell_arrays{i}.joints(23,:) = [kinectstream.SPINE_CHEST.x(i),kinectstream.SPINE_CHEST.y(i),kinectstream.SPINE_CHEST.z(i)];
        kinect_cell_arrays{i}.joints(24,:) = [kinectstream.NOSE.x(i),kinectstream.NOSE.y(i),kinectstream.NOSE.z(i)];
    end
else
    for i=1:L
        kinect_cell_arrays{i}.time = kinectstream.wtime(i);
        kinect_cell_arrays{i}.joints(1,:) = [kinectstream.PELVIS.x(i),kinectstream.PELVIS.y(i),kinectstream.PELVIS.z(i)];
        kinect_cell_arrays{i}.joints(2,:) = [kinectstream.HEAD.x(i),kinectstream.HEAD.y(i),kinectstream.HEAD.z(i)];
        kinect_cell_arrays{i}.joints(3,:) = [kinectstream.SHOULDER_LEFT.x(i),kinectstream.SHOULDER_LEFT.y(i),kinectstream.SHOULDER_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(4,:) = [kinectstream.ELBOW_LEFT.x(i),kinectstream.ELBOW_LEFT.y(i),kinectstream.ELBOW_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(5,:) = [kinectstream.WRIST_LEFT.x(i),kinectstream.WRIST_LEFT.y(i),kinectstream.WRIST_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(6,:) = [kinectstream.HAND_LEFT.x(i),kinectstream.HAND_LEFT.y(i),kinectstream.HAND_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(7,:) = [kinectstream.SHOULDER_RIGHT.x(i),kinectstream.SHOULDER_RIGHT.y(i),kinectstream.SHOULDER_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(8,:) = [kinectstream.ELBOW_RIGHT.x(i),kinectstream.ELBOW_RIGHT.y(i),kinectstream.ELBOW_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(9,:) = [kinectstream.WRIST_RIGHT.x(i),kinectstream.WRIST_RIGHT.y(i),kinectstream.WRIST_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(10,:) = [kinectstream.HAND_RIGHT.x(i),kinectstream.HAND_RIGHT.y(i),kinectstream.HAND_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(11,:) = [kinectstream.HIP_LEFT.x(i),kinectstream.HIP_LEFT.y(i),kinectstream.HIP_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(12,:) = [kinectstream.KNEE_LEFT.x(i),kinectstream.KNEE_LEFT.y(i),kinectstream.KNEE_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(13,:) = [kinectstream.ANKLE_LEFT.x(i),kinectstream.ANKLE_LEFT.y(i),kinectstream.ANKLE_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(14,:) = [kinectstream.FOOT_LEFT.x(i),kinectstream.FOOT_LEFT.y(i),kinectstream.FOOT_LEFT.z(i)];
        kinect_cell_arrays{i}.joints(15,:) = [kinectstream.HIP_RIGHT.x(i),kinectstream.HIP_RIGHT.y(i),kinectstream.HIP_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(16,:) = [kinectstream.KNEE_RIGHT.x(i),kinectstream.KNEE_RIGHT.y(i),kinectstream.KNEE_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(17,:) = [kinectstream.ANKLE_RIGHT.x(i),kinectstream.ANKLE_RIGHT.y(i),kinectstream.ANKLE_RIGHT.z(i)];
        kinect_cell_arrays{i}.joints(18,:) = [kinectstream.FOOT_RIGHT.x(i),kinectstream.FOOT_RIGHT.y(i),kinectstream.FOOT_RIGHT.z(i)];
        
        kinect_cell_arrays{i}.joints(19,:) = [kinectstream.SPINE_SHOULDER.x(i),kinectstream.SPINE_SHOULDER.y(i),kinectstream.SPINE_SHOULDER.z(i)];
        
        % 后续添加
        kinect_cell_arrays{i}.joints(20,:) = [kinectstream.NECK.x(i),kinectstream.NECK.y(i),kinectstream.NECK.z(i)];
        kinect_cell_arrays{i}.joints(21,:) = [kinectstream.SPINE_NAVAL.x(i),kinectstream.SPINE_NAVAL.y(i),kinectstream.SPINE_NAVAL.z(i)];
        kinect_cell_arrays{i}.joints(22,:) = [kinectstream.SPINE_CHEST.x(i),kinectstream.SPINE_CHEST.y(i),kinectstream.SPINE_CHEST.z(i)];
        kinect_cell_arrays{i}.joints(23,:) = [kinectstream.NOSE.x(i),kinectstream.NOSE.y(i),kinectstream.NOSE.z(i)];
        
    end
    
end
end