%% 时间变成了秒
function kinectstream = Kinect_ArrayToStruct(kinect_cell_arrays)
    L = length(kinect_cell_arrays);
    
    for i=1:L
        if class(kinect_cell_arrays{1}.time) == "double"%表示原有时间是秒
            kinectstream.wtime(i,1) = double(kinect_cell_arrays{i}.time);
        else
            kinectstream.wtime(i,1) = double(kinect_cell_arrays{i}.time) / 1000;
        end
        [kinectstream.PELVIS.x(i,1),kinectstream.PELVIS.y(i,1),kinectstream.PELVIS.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(1,:));
        [kinectstream.HEAD.x(i,1),kinectstream.HEAD.y(i,1),kinectstream.HEAD.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(2,:));
        [kinectstream.SHOULDER_LEFT.x(i,1),kinectstream.SHOULDER_LEFT.y(i,1),kinectstream.SHOULDER_LEFT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(3,:));
        [kinectstream.ELBOW_LEFT.x(i,1),kinectstream.ELBOW_LEFT.y(i,1),kinectstream.ELBOW_LEFT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(4,:));
        [kinectstream.WRIST_LEFT.x(i,1),kinectstream.WRIST_LEFT.y(i,1),kinectstream.WRIST_LEFT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(5,:));
        [kinectstream.HAND_LEFT.x(i,1),kinectstream.HAND_LEFT.y(i,1),kinectstream.HAND_LEFT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(6,:));
        [kinectstream.SHOULDER_RIGHT.x(i,1),kinectstream.SHOULDER_RIGHT.y(i,1),kinectstream.SHOULDER_RIGHT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(7,:));
        [kinectstream.ELBOW_RIGHT.x(i,1),kinectstream.ELBOW_RIGHT.y(i,1),kinectstream.ELBOW_RIGHT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(8,:));
        [kinectstream.WRIST_RIGHT.x(i,1),kinectstream.WRIST_RIGHT.y(i,1),kinectstream.WRIST_RIGHT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(9,:));
        [kinectstream.HAND_RIGHT.x(i,1),kinectstream.HAND_RIGHT.y(i,1),kinectstream.HAND_RIGHT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(10,:));
        [kinectstream.HIP_LEFT.x(i,1),kinectstream.HIP_LEFT.y(i,1),kinectstream.HIP_LEFT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(11,:));
        [kinectstream.KNEE_LEFT.x(i,1),kinectstream.KNEE_LEFT.y(i,1),kinectstream.KNEE_LEFT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(12,:));
        [kinectstream.ANKLE_LEFT.x(i,1),kinectstream.ANKLE_LEFT.y(i,1),kinectstream.ANKLE_LEFT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(13,:));
        [kinectstream.FOOT_LEFT.x(i,1),kinectstream.FOOT_LEFT.y(i,1),kinectstream.FOOT_LEFT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(14,:));
        [kinectstream.HIP_RIGHT.x(i,1),kinectstream.HIP_RIGHT.y(i,1),kinectstream.HIP_RIGHT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(15,:));
        [kinectstream.KNEE_RIGHT.x(i,1),kinectstream.KNEE_RIGHT.y(i,1),kinectstream.KNEE_RIGHT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(16,:));
        [kinectstream.ANKLE_RIGHT.x(i,1),kinectstream.ANKLE_RIGHT.y(i,1),kinectstream.ANKLE_RIGHT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(17,:));
        [kinectstream.FOOT_RIGHT.x(i,1),kinectstream.FOOT_RIGHT.y(i,1),kinectstream.FOOT_RIGHT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(18,:));
        
        if length(kinect_cell_arrays{i}.joints) < 24
            [kinectstream.SPINE_SHOULDER.x(i,1),kinectstream.SPINE_SHOULDER.y(i,1),kinectstream.SPINE_SHOULDER.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(19,:));
            [kinectstream.NECK.x(i,1),kinectstream.NECK.y(i,1),kinectstream.NECK.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(20,:));
            [kinectstream.SPINE_NAVAL.x(i,1),kinectstream.SPINE_NAVAL.y(i,1),kinectstream.SPINE_NAVAL.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(21,:));
            [kinectstream.SPINE_CHEST.x(i,1),kinectstream.SPINE_CHEST.y(i,1),kinectstream.SPINE_CHEST.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(22,:));
            [kinectstream.NOSE.x(i,1),kinectstream.NOSE.y(i,1),kinectstream.NOSE.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(23,:));
        else
            [kinectstream.CLAVICLE_LEFT.x(i,1),kinectstream.CLAVICLE_LEFT.y(i,1),kinectstream.CLAVICLE_LEFT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(19,:));
            [kinectstream.CLAVICLE_RIGHT.x(i,1),kinectstream.CLAVICLE_RIGHT.y(i,1),kinectstream.CLAVICLE_RIGHT.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(20,:));
            [kinectstream.NECK.x(i,1),kinectstream.NECK.y(i,1),kinectstream.NECK.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(21,:));
            [kinectstream.SPINE_NAVAL.x(i,1),kinectstream.SPINE_NAVAL.y(i,1),kinectstream.SPINE_NAVAL.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(22,:));
            [kinectstream.SPINE_CHEST.x(i,1),kinectstream.SPINE_CHEST.y(i,1),kinectstream.SPINE_CHEST.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(23,:));
            [kinectstream.NOSE.x(i,1),kinectstream.NOSE.y(i,1),kinectstream.NOSE.z(i,1)] = One2Three(kinect_cell_arrays{i}.joints(24,:));
        end
        
    end


end

function [a,b,c] = One2Three(abc)
    a= abc(1);
    b= abc(2);
    c= abc(3);
end