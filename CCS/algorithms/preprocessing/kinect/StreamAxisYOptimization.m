function [cost] = StreamAxisYOptimization(params,stream,idxStream)
    rotAngleY = params; 
    
    rotateMatrixY = [cosd(rotAngleY),0,sind(rotAngleY);0,1,0;-sind(rotAngleY),0,cosd(rotAngleY)];

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
    vx = [-1,0,0]; vz = [0,0,-1];
    for i = 1:length(idxStream)
        t = idxStream(i);
        %% 根据肩、髋、膝与水平向量
        vShoulder = vShoulders(t,:); vHip = vHips(t,:); vKnee = vKnees(t,:);
        vShoulder = (rotateMatrixY*vShoulder')';
        vHip = (rotateMatrixY*vHip')';
        vKnee = (rotateMatrixY*vKnee')';
        % 余弦值作为评价指标，余弦值大说明相近
        % 与x轴负向的余弦值
%         cost = cost+dot(vShoulder,vx)/(norm(vShoulder)*norm(vx));
%         cost = cost+dot(vHip,vx)/(norm(vHip)*norm(vx));
%         cost = cost+dot(vKnee,vx)/(norm(vKnee)*norm(vx));
        %% 根据脊柱与竖直向量
        vSpine = vSpines(t,:);
        vSpine2 = vSpines2(t,:);
        vSpine = (rotateMatrixY*vSpine')';
        vSpine2 = (rotateMatrixY*vSpine2')';
        % 余弦值作为评价指标，余弦值大说明相近
        cost = cost+0*dot(vSpine,vz)/(norm(vSpine)*norm(vz));
        cost = cost+dot(vSpine2,vz)/(norm(vSpine2)*norm(vz));
    end