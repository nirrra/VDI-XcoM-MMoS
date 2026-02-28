function [cost] = StreamAxisXOptimization(params,stream,idxStream)
    rotAngleX = params; 
    
    rotateMatrixX = [1,0,0;0,cosd(rotAngleX),-sind(rotAngleX);0,sind(rotAngleX),cosd(rotAngleX)];

    cost = 0;

    vShoulders = [stream.SHOULDER_RIGHT.x-stream.SHOULDER_LEFT.x,stream.SHOULDER_RIGHT.y-stream.SHOULDER_LEFT.y,stream.SHOULDER_RIGHT.z-stream.SHOULDER_LEFT.z];
    vHips = [stream.HIP_RIGHT.x-stream.HIP_LEFT.x,stream.HIP_RIGHT.y-stream.HIP_LEFT.y,stream.HIP_RIGHT.z-stream.HIP_LEFT.z];
    vKnees = [stream.KNEE_RIGHT.x-stream.KNEE_LEFT.x,stream.KNEE_RIGHT.y-stream.KNEE_LEFT.y,stream.KNEE_RIGHT.z-stream.KNEE_LEFT.z];

    vSpines = [stream.SPINE_CHEST.x,stream.SPINE_CHEST.y,stream.SPINE_CHEST.z]-[stream.SPINE_NAVAL.x,stream.SPINE_NAVAL.y,stream.SPINE_NAVAL.z];
    if isfield(stream,'CLAVICLE_LEFT')
        vSpines2 = ([stream.CLAVICLE_LEFT.x,stream.CLAVICLE_LEFT.y,stream.CLAVICLE_LEFT.z]+[stream.CLAVICLE_RIGHT.x,stream.CLAVICLE_RIGHT.y,stream.CLAVICLE_RIGHT.z])./2-...
            ([stream.HIP_LEFT.x,stream.HIP_LEFT.y,stream.HIP_LEFT.z]+[stream.HIP_RIGHT.x,stream.HIP_RIGHT.y,stream.HIP_RIGHT.z])./2;
    else
        vSpines2 = [stream.SPINE_SHOULDER.x,stream.SPINE_SHOULDER.y,stream.SPINE_SHOULDER.z]-...
            ([stream.HIP_LEFT.x,stream.HIP_LEFT.y,stream.HIP_LEFT.z]+[stream.HIP_RIGHT.x,stream.HIP_RIGHT.y,stream.HIP_RIGHT.z])./2;
    end
    % 下到上
    vHead2Ankles = [stream.HEAD.x,stream.HEAD.y,stream.HEAD.z]-...
        ([stream.ANKLE_LEFT.x,stream.ANKLE_LEFT.y,stream.ANKLE_LEFT.z]+[stream.ANKLE_RIGHT.x,stream.ANKLE_RIGHT.y,stream.ANKLE_RIGHT.z])./2;
    vThighLefts = [stream.HIP_LEFT.x,stream.HIP_LEFT.y,stream.HIP_LEFT.z]-[stream.KNEE_LEFT.x,stream.KNEE_LEFT.y,stream.KNEE_LEFT.z];
    vThighRights = [stream.HIP_RIGHT.x,stream.HIP_RIGHT.y,stream.HIP_RIGHT.z]-[stream.KNEE_RIGHT.x,stream.KNEE_RIGHT.y,stream.KNEE_RIGHT.z];
    % 上到下
    vz = [0,0,-1];
    for i = 1:length(idxStream)
        t = idxStream(i);
        %% 根据肩、髋、膝与水平向量
        vShoulder = vShoulders(t,:); vHip = vHips(t,:); vKnee = vKnees(t,:);
        vShoulder = (rotateMatrixX*vShoulder')';
        vHip = (rotateMatrixX*vHip')';
        vKnee = (rotateMatrixX*vKnee')';
        % 余弦值作为评价指标，余弦值大说明相近
        % 与x轴负向的余弦值
%         cost = cost+dot(vShoulder,vx)/(norm(vShoulder)*norm(vx));
%         cost = cost+dot(vHip,vx)/(norm(vHip)*norm(vx));
%         cost = cost+dot(vKnee,vx)/(norm(vKnee)*norm(vx));
        %% 根据脊柱与竖直向量
        vSpine = vSpines(t,:);
        vSpine2 = vSpines2(t,:);
        vSpine = (rotateMatrixX*vSpine')';
        vSpine2 = (rotateMatrixX*vSpine2')';
        % 余弦值作为评价指标，余弦值大说明相近
%         cost = cost+0*dot(vSpine,vz)/(norm(vSpine)*norm(vz));
%         cost = cost+dot(vSpine2,vz)/(norm(vSpine2)*norm(vz));
        %% 根据Head与足跟、Hip与Knee
        vHead2Ankle = vHead2Ankles(t,:);
        vThighLeft = vThighLefts(t,:);
        vThighRight = vThighRights(t,:);
        
        vHead2Ankle = (rotateMatrixX*vHead2Ankle')';
        vThighLeft = (rotateMatrixX*vThighLeft')';
        vThighRight = (rotateMatrixX*vThighRight')';
        % 余弦值作为评价指标，余弦值小说明相反
        cost = cost+dot(vHead2Ankle,vz)/(norm(vHead2Ankle)*norm(vz))+...
            0*dot(vThighLeft,vz)/(norm(vThighLeft)*norm(vz))+...
            0*dot(vThighRight,vz)/(norm(vThighRight)*norm(vz));
    end