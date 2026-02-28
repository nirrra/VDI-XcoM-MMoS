function Kinectstream = Transform_Azure(T,stream)
Kinectstream = stream;
if isfield(stream,'ktime')
    Kinectstream.ktime = stream.ktime;
end
if isfield(stream,'wtime')
    Kinectstream.wtime = stream.wtime;
end
if isfield(stream,'name')
    Kinectstream.name = stream.name;
end
one = ones(length(stream.wtime),1);

if isfield(stream,'PELVIS')
    Kinectstream.PELVIS.x = (T(1,:) *  [stream.PELVIS.x,stream.PELVIS.y,stream.PELVIS.z,one]')';
    Kinectstream.PELVIS.y = (T(2,:) *  [stream.PELVIS.x,stream.PELVIS.y,stream.PELVIS.z,one]')';
    Kinectstream.PELVIS.z = (T(3,:) *  [stream.PELVIS.x,stream.PELVIS.y,stream.PELVIS.z,one]')';

end
if isfield(stream,'SPINE_NAVAL')
    Kinectstream.SPINE_NAVAL.x = (T(1,:) *  [stream.SPINE_NAVAL.x,stream.SPINE_NAVAL.y,stream.SPINE_NAVAL.z,one]')';
    Kinectstream.SPINE_NAVAL.y = (T(2,:) *  [stream.SPINE_NAVAL.x,stream.SPINE_NAVAL.y,stream.SPINE_NAVAL.z,one]')';
    Kinectstream.SPINE_NAVAL.z = (T(3,:) *  [stream.SPINE_NAVAL.x,stream.SPINE_NAVAL.y,stream.SPINE_NAVAL.z,one]')';
end
if isfield(stream,'SPINE_CHEST')
    Kinectstream.SPINE_CHEST.x = (T(1,:) *  [stream.SPINE_CHEST.x,stream.SPINE_CHEST.y,stream.SPINE_CHEST.z,one]')';
    Kinectstream.SPINE_CHEST.y = (T(2,:) *  [stream.SPINE_CHEST.x,stream.SPINE_CHEST.y,stream.SPINE_CHEST.z,one]')';
    Kinectstream.SPINE_CHEST.z = (T(3,:) *  [stream.SPINE_CHEST.x,stream.SPINE_CHEST.y,stream.SPINE_CHEST.z,one]')';
end
if isfield(stream,'SPINE_SHOULDER')
    Kinectstream.SPINE_SHOULDER.x = (T(1,:) *  [stream.SPINE_SHOULDER.x,stream.SPINE_SHOULDER.y,stream.SPINE_SHOULDER.z,one]')';
    Kinectstream.SPINE_SHOULDER.y = (T(2,:) *  [stream.SPINE_SHOULDER.x,stream.SPINE_SHOULDER.y,stream.SPINE_SHOULDER.z,one]')';
    Kinectstream.SPINE_SHOULDER.z = (T(3,:) *  [stream.SPINE_SHOULDER.x,stream.SPINE_SHOULDER.y,stream.SPINE_SHOULDER.z,one]')';
end

if isfield(stream,'NECK')
    Kinectstream.NECK.x = (T(1,:) *  [stream.NECK.x,stream.NECK.y,stream.NECK.z,one]')';
    Kinectstream.NECK.y = (T(2,:) *  [stream.NECK.x,stream.NECK.y,stream.NECK.z,one]')';
    Kinectstream.NECK.z = (T(3,:) *  [stream.NECK.x,stream.NECK.y,stream.NECK.z,one]')';
end
if isfield(stream,'CLAVICLE_LEFT')
    Kinectstream.CLAVICLE_LEFT.x = (T(1,:) *  [stream.CLAVICLE_LEFT.x,stream.CLAVICLE_LEFT.y,stream.CLAVICLE_LEFT.z,one]')';
    Kinectstream.CLAVICLE_LEFT.y = (T(2,:) *  [stream.CLAVICLE_LEFT.x,stream.CLAVICLE_LEFT.y,stream.CLAVICLE_LEFT.z,one]')';
    Kinectstream.CLAVICLE_LEFT.z = (T(3,:) *  [stream.CLAVICLE_LEFT.x,stream.CLAVICLE_LEFT.y,stream.CLAVICLE_LEFT.z,one]')';
end
if isfield(stream,'SHOULDER_LEFT')

    Kinectstream.SHOULDER_LEFT.x = (T(1,:) *  [stream.SHOULDER_LEFT.x,stream.SHOULDER_LEFT.y,stream.SHOULDER_LEFT.z,one]')';
    Kinectstream.SHOULDER_LEFT.y = (T(2,:) *  [stream.SHOULDER_LEFT.x,stream.SHOULDER_LEFT.y,stream.SHOULDER_LEFT.z,one]')';
    Kinectstream.SHOULDER_LEFT.z = (T(3,:) *  [stream.SHOULDER_LEFT.x,stream.SHOULDER_LEFT.y,stream.SHOULDER_LEFT.z,one]')';
end
if isfield(stream,'ELBOW_LEFT')
    Kinectstream.ELBOW_LEFT.x = (T(1,:) *  [stream.ELBOW_LEFT.x,stream.ELBOW_LEFT.y,stream.ELBOW_LEFT.z,one]')';
    Kinectstream.ELBOW_LEFT.y = (T(2,:) *  [stream.ELBOW_LEFT.x,stream.ELBOW_LEFT.y,stream.ELBOW_LEFT.z,one]')';
    Kinectstream.ELBOW_LEFT.z = (T(3,:) *  [stream.ELBOW_LEFT.x,stream.ELBOW_LEFT.y,stream.ELBOW_LEFT.z,one]')';
end
if isfield(stream,'WRIST_LEFT')

    Kinectstream.WRIST_LEFT.x = (T(1,:) *  [stream.WRIST_LEFT.x,stream.WRIST_LEFT.y,stream.WRIST_LEFT.z,one]')';
    Kinectstream.WRIST_LEFT.y = (T(2,:) *  [stream.WRIST_LEFT.x,stream.WRIST_LEFT.y,stream.WRIST_LEFT.z,one]')';
    Kinectstream.WRIST_LEFT.z = (T(3,:) *  [stream.WRIST_LEFT.x,stream.WRIST_LEFT.y,stream.WRIST_LEFT.z,one]')';
end
if isfield(stream,'HAND_LEFT')
    Kinectstream.HAND_LEFT.x = (T(1,:) *  [stream.HAND_LEFT.x,stream.HAND_LEFT.y,stream.HAND_LEFT.z,one]')';
    Kinectstream.HAND_LEFT.y = (T(2,:) *  [stream.HAND_LEFT.x,stream.HAND_LEFT.y,stream.HAND_LEFT.z,one]')';
    Kinectstream.HAND_LEFT.z = (T(3,:) *  [stream.HAND_LEFT.x,stream.HAND_LEFT.y,stream.HAND_LEFT.z,one]')';
end
if isfield(stream,'HANDTIP_LEFT')
    Kinectstream.HANDTIP_LEFT.x = (T(1,:) *  [stream.HANDTIP_LEFT.x,stream.HANDTIP_LEFT.y,stream.HANDTIP_LEFT.z,one]')';
    Kinectstream.HANDTIP_LEFT.y = (T(2,:) *  [stream.HANDTIP_LEFT.x,stream.HANDTIP_LEFT.y,stream.HANDTIP_LEFT.z,one]')';
    Kinectstream.HANDTIP_LEFT.z = (T(3,:) *  [stream.HANDTIP_LEFT.x,stream.HANDTIP_LEFT.y,stream.HANDTIP_LEFT.z,one]')';
end
if isfield(stream,'THUMB_LEFT')
    Kinectstream.THUMB_LEFT.x = (T(1,:) *  [stream.THUMB_LEFT.x,stream.THUMB_LEFT.y,stream.THUMB_LEFT.z,one]')';
    Kinectstream.THUMB_LEFT.y = (T(2,:) *  [stream.THUMB_LEFT.x,stream.THUMB_LEFT.y,stream.THUMB_LEFT.z,one]')';
    Kinectstream.THUMB_LEFT.z = (T(3,:) *  [stream.THUMB_LEFT.x,stream.THUMB_LEFT.y,stream.THUMB_LEFT.z,one]')';
end
if isfield(stream,'CLAVICLE_RIGHT')

    Kinectstream.CLAVICLE_RIGHT.x = (T(1,:) *  [stream.CLAVICLE_RIGHT.x,stream.CLAVICLE_RIGHT.y,stream.CLAVICLE_RIGHT.z,one]')';
    Kinectstream.CLAVICLE_RIGHT.y = (T(2,:) *  [stream.CLAVICLE_RIGHT.x,stream.CLAVICLE_RIGHT.y,stream.CLAVICLE_RIGHT.z,one]')';
    Kinectstream.CLAVICLE_RIGHT.z = (T(3,:) *  [stream.CLAVICLE_RIGHT.x,stream.CLAVICLE_RIGHT.y,stream.CLAVICLE_RIGHT.z,one]')';
end
if isfield(stream,'SHOULDER_RIGHT')
    Kinectstream.SHOULDER_RIGHT.x = (T(1,:) *  [stream.SHOULDER_RIGHT.x,stream.SHOULDER_RIGHT.y,stream.SHOULDER_RIGHT.z,one]')';
    Kinectstream.SHOULDER_RIGHT.y = (T(2,:) *  [stream.SHOULDER_RIGHT.x,stream.SHOULDER_RIGHT.y,stream.SHOULDER_RIGHT.z,one]')';
    Kinectstream.SHOULDER_RIGHT.z = (T(3,:) *  [stream.SHOULDER_RIGHT.x,stream.SHOULDER_RIGHT.y,stream.SHOULDER_RIGHT.z,one]')';
end
if isfield(stream,'ELBOW_RIGHT')
    Kinectstream.ELBOW_RIGHT.x = (T(1,:) *  [stream.ELBOW_RIGHT.x,stream.ELBOW_RIGHT.y,stream.ELBOW_RIGHT.z,one]')';
    Kinectstream.ELBOW_RIGHT.y = (T(2,:) *  [stream.ELBOW_RIGHT.x,stream.ELBOW_RIGHT.y,stream.ELBOW_RIGHT.z,one]')';
    Kinectstream.ELBOW_RIGHT.z = (T(3,:) *  [stream.ELBOW_RIGHT.x,stream.ELBOW_RIGHT.y,stream.ELBOW_RIGHT.z,one]')';
end
if isfield(stream,'WRIST_RIGHT')
    Kinectstream.WRIST_RIGHT.x = (T(1,:) *  [stream.WRIST_RIGHT.x,stream.WRIST_RIGHT.y,stream.WRIST_RIGHT.z,one]')';
    Kinectstream.WRIST_RIGHT.y = (T(2,:) *  [stream.WRIST_RIGHT.x,stream.WRIST_RIGHT.y,stream.WRIST_RIGHT.z,one]')';
    Kinectstream.WRIST_RIGHT.z = (T(3,:) *  [stream.WRIST_RIGHT.x,stream.WRIST_RIGHT.y,stream.WRIST_RIGHT.z,one]')';
end
if isfield(stream,'HAND_RIGHT')
    Kinectstream.HAND_RIGHT.x = (T(1,:) *  [stream.HAND_RIGHT.x,stream.HAND_RIGHT.y,stream.HAND_RIGHT.z,one]')';
    Kinectstream.HAND_RIGHT.y = (T(2,:) *  [stream.HAND_RIGHT.x,stream.HAND_RIGHT.y,stream.HAND_RIGHT.z,one]')';
    Kinectstream.HAND_RIGHT.z = (T(3,:) *  [stream.HAND_RIGHT.x,stream.HAND_RIGHT.y,stream.HAND_RIGHT.z,one]')';
end
if isfield(stream,'HANDTIP_RIGHT')
    Kinectstream.HANDTIP_RIGHT.x = (T(1,:) *  [stream.HANDTIP_RIGHT.x,stream.HANDTIP_RIGHT.y,stream.HANDTIP_RIGHT.z,one]')';
    Kinectstream.HANDTIP_RIGHT.y = (T(2,:) *  [stream.HANDTIP_RIGHT.x,stream.HANDTIP_RIGHT.y,stream.HANDTIP_RIGHT.z,one]')';
    Kinectstream.HANDTIP_RIGHT.z = (T(3,:) *  [stream.HANDTIP_RIGHT.x,stream.HANDTIP_RIGHT.y,stream.HANDTIP_RIGHT.z,one]')';
end
if isfield(stream,'THUMB_RIGHT')

    Kinectstream.THUMB_RIGHT.x = (T(1,:) *  [stream.THUMB_RIGHT.x,stream.THUMB_RIGHT.y,stream.THUMB_RIGHT.z,one]')';
    Kinectstream.THUMB_RIGHT.y = (T(2,:) *  [stream.THUMB_RIGHT.x,stream.THUMB_RIGHT.y,stream.THUMB_RIGHT.z,one]')';
    Kinectstream.THUMB_RIGHT.z = (T(3,:) *  [stream.THUMB_RIGHT.x,stream.THUMB_RIGHT.y,stream.THUMB_RIGHT.z,one]')';
end
if isfield(stream,'HIP_LEFT')

    Kinectstream.HIP_LEFT.x = (T(1,:) *  [stream.HIP_LEFT.x,stream.HIP_LEFT.y,stream.HIP_LEFT.z,one]')';
    Kinectstream.HIP_LEFT.y = (T(2,:) *  [stream.HIP_LEFT.x,stream.HIP_LEFT.y,stream.HIP_LEFT.z,one]')';
    Kinectstream.HIP_LEFT.z = (T(3,:) *  [stream.HIP_LEFT.x,stream.HIP_LEFT.y,stream.HIP_LEFT.z,one]')';
end
if isfield(stream,'KNEE_LEFT')
    Kinectstream.KNEE_LEFT.x = (T(1,:) *  [stream.KNEE_LEFT.x,stream.KNEE_LEFT.y,stream.KNEE_LEFT.z,one]')';
    Kinectstream.KNEE_LEFT.y = (T(2,:) *  [stream.KNEE_LEFT.x,stream.KNEE_LEFT.y,stream.KNEE_LEFT.z,one]')';
    Kinectstream.KNEE_LEFT.z = (T(3,:) *  [stream.KNEE_LEFT.x,stream.KNEE_LEFT.y,stream.KNEE_LEFT.z,one]')';
end
if isfield(stream,'ANKLE_LEFT')
    Kinectstream.ANKLE_LEFT.x = (T(1,:) *  [stream.ANKLE_LEFT.x,stream.ANKLE_LEFT.y,stream.ANKLE_LEFT.z,one]')';
    Kinectstream.ANKLE_LEFT.y = (T(2,:) *  [stream.ANKLE_LEFT.x,stream.ANKLE_LEFT.y,stream.ANKLE_LEFT.z,one]')';
    Kinectstream.ANKLE_LEFT.z = (T(3,:) *  [stream.ANKLE_LEFT.x,stream.ANKLE_LEFT.y,stream.ANKLE_LEFT.z,one]')';
end
if isfield(stream,'FOOT_LEFT')

    Kinectstream.FOOT_LEFT.x = (T(1,:) *  [stream.FOOT_LEFT.x,stream.FOOT_LEFT.y,stream.FOOT_LEFT.z,one]')';
    Kinectstream.FOOT_LEFT.y = (T(2,:) *  [stream.FOOT_LEFT.x,stream.FOOT_LEFT.y,stream.FOOT_LEFT.z,one]')';
    Kinectstream.FOOT_LEFT.z = (T(3,:) *  [stream.FOOT_LEFT.x,stream.FOOT_LEFT.y,stream.FOOT_LEFT.z,one]')';

end
if isfield(stream,'HIP_RIGHT')
    Kinectstream.HIP_RIGHT.x = (T(1,:) *  [stream.HIP_RIGHT.x,stream.HIP_RIGHT.y,stream.HIP_RIGHT.z,one]')';
    Kinectstream.HIP_RIGHT.y = (T(2,:) *  [stream.HIP_RIGHT.x,stream.HIP_RIGHT.y,stream.HIP_RIGHT.z,one]')';
    Kinectstream.HIP_RIGHT.z = (T(3,:) *  [stream.HIP_RIGHT.x,stream.HIP_RIGHT.y,stream.HIP_RIGHT.z,one]')';
end
if isfield(stream,'KNEE_RIGHT')
    Kinectstream.KNEE_RIGHT.x = (T(1,:) *  [stream.KNEE_RIGHT.x,stream.KNEE_RIGHT.y,stream.KNEE_RIGHT.z,one]')';
    Kinectstream.KNEE_RIGHT.y = (T(2,:) *  [stream.KNEE_RIGHT.x,stream.KNEE_RIGHT.y,stream.KNEE_RIGHT.z,one]')';
    Kinectstream.KNEE_RIGHT.z = (T(3,:) *  [stream.KNEE_RIGHT.x,stream.KNEE_RIGHT.y,stream.KNEE_RIGHT.z,one]')';
end
if isfield(stream,'ANKLE_RIGHT')

    Kinectstream.ANKLE_RIGHT.x = (T(1,:) *  [stream.ANKLE_RIGHT.x,stream.ANKLE_RIGHT.y,stream.ANKLE_RIGHT.z,one]')';
    Kinectstream.ANKLE_RIGHT.y = (T(2,:) *  [stream.ANKLE_RIGHT.x,stream.ANKLE_RIGHT.y,stream.ANKLE_RIGHT.z,one]')';
    Kinectstream.ANKLE_RIGHT.z = (T(3,:) *  [stream.ANKLE_RIGHT.x,stream.ANKLE_RIGHT.y,stream.ANKLE_RIGHT.z,one]')';
end
if isfield(stream,'FOOT_RIGHT')
    Kinectstream.FOOT_RIGHT.x = (T(1,:) *  [stream.FOOT_RIGHT.x,stream.FOOT_RIGHT.y,stream.FOOT_RIGHT.z,one]')';
    Kinectstream.FOOT_RIGHT.y = (T(2,:) *  [stream.FOOT_RIGHT.x,stream.FOOT_RIGHT.y,stream.FOOT_RIGHT.z,one]')';
    Kinectstream.FOOT_RIGHT.z = (T(3,:) *  [stream.FOOT_RIGHT.x,stream.FOOT_RIGHT.y,stream.FOOT_RIGHT.z,one]')';
end
if isfield(stream,'HEAD')
    Kinectstream.HEAD.x = (T(1,:) *  [stream.HEAD.x,stream.HEAD.y,stream.HEAD.z,one]')';
    Kinectstream.HEAD.y = (T(2,:) *  [stream.HEAD.x,stream.HEAD.y,stream.HEAD.z,one]')';
    Kinectstream.HEAD.z = (T(3,:) *  [stream.HEAD.x,stream.HEAD.y,stream.HEAD.z,one]')';
end
if isfield(stream,'NOSE')

    Kinectstream.NOSE.x = (T(1,:) *  [stream.NOSE.x,stream.NOSE.y,stream.NOSE.z,one]')';
    Kinectstream.NOSE.y = (T(2,:) *  [stream.NOSE.x,stream.NOSE.y,stream.NOSE.z,one]')';
    Kinectstream.NOSE.z = (T(3,:) *  [stream.NOSE.x,stream.NOSE.y,stream.NOSE.z,one]')';
end
if isfield(stream,'EYE_LEFT')

    Kinectstream.EYE_LEFT.x = (T(1,:) *  [stream.EYE_LEFT.x,stream.EYE_LEFT.y,stream.EYE_LEFT.z,one]')';
    Kinectstream.EYE_LEFT.y = (T(2,:) *  [stream.EYE_LEFT.x,stream.EYE_LEFT.y,stream.EYE_LEFT.z,one]')';
    Kinectstream.EYE_LEFT.z = (T(3,:) *  [stream.EYE_LEFT.x,stream.EYE_LEFT.y,stream.EYE_LEFT.z,one]')';
end
if isfield(stream,'EAR_LEFT')

    Kinectstream.EAR_LEFT.x = (T(1,:) *  [stream.EAR_LEFT.x,stream.EAR_LEFT.y,stream.EAR_LEFT.z,one]')';
    Kinectstream.EAR_LEFT.y = (T(2,:) *  [stream.EAR_LEFT.x,stream.EAR_LEFT.y,stream.EAR_LEFT.z,one]')';
    Kinectstream.EAR_LEFT.z = (T(3,:) *  [stream.EAR_LEFT.x,stream.EAR_LEFT.y,stream.EAR_LEFT.z,one]')';
end
if isfield(stream,'EYE_RIGHT')

    Kinectstream.EYE_RIGHT.x = (T(1,:) *  [stream.EYE_RIGHT.x,stream.EYE_RIGHT.y,stream.EYE_RIGHT.z,one]')';
    Kinectstream.EYE_RIGHT.y = (T(2,:) *  [stream.EYE_RIGHT.x,stream.EYE_RIGHT.y,stream.EYE_RIGHT.z,one]')';
    Kinectstream.EYE_RIGHT.z = (T(3,:) *  [stream.EYE_RIGHT.x,stream.EYE_RIGHT.y,stream.EYE_RIGHT.z,one]')';
end
if isfield(stream,'EAR_RIGHT')

    Kinectstream.EAR_RIGHT.x = (T(1,:) *  [stream.EAR_RIGHT.x,stream.EAR_RIGHT.y,stream.EAR_RIGHT.z,one]')';
    Kinectstream.EAR_RIGHT.y = (T(2,:) *  [stream.EAR_RIGHT.x,stream.EAR_RIGHT.y,stream.EAR_RIGHT.z,one]')';
    Kinectstream.EAR_RIGHT.z = (T(3,:) *  [stream.EAR_RIGHT.x,stream.EAR_RIGHT.y,stream.EAR_RIGHT.z,one]')';
end
end