function [cost] = StreamAxisZOptimization(params,stream,idxStream)
    rotAngleZ = params; 
    
    rotateMatrixZ = [cosd(rotAngleZ),-sind(rotAngleZ),0;sind(rotAngleZ),cosd(rotAngleZ),0;0,0,1];

    cost = 0;

    vShoulders = [stream.SHOULDER_RIGHT.x-stream.SHOULDER_LEFT.x,stream.SHOULDER_RIGHT.y-stream.SHOULDER_LEFT.y,stream.SHOULDER_RIGHT.z-stream.SHOULDER_LEFT.z];
    vHips = [stream.HIP_RIGHT.x-stream.HIP_LEFT.x,stream.HIP_RIGHT.y-stream.HIP_LEFT.y,stream.HIP_RIGHT.z-stream.HIP_LEFT.z];
    vKnees = [stream.KNEE_RIGHT.x-stream.KNEE_LEFT.x,stream.KNEE_RIGHT.y-stream.KNEE_LEFT.y,stream.KNEE_RIGHT.z-stream.KNEE_LEFT.z];

    vx = [-1,0,0];
    for i = 1:length(idxStream)
        t = idxStream(i);
        vShoulder = vShoulders(t,:); vHip = vHips(t,:); vKnee = vKnees(t,:);
        vShoulder = (rotateMatrixZ*vShoulder')';
        vHip = (rotateMatrixZ*vHip')';
        vKnee = (rotateMatrixZ*vKnee')';
        % 余弦值作为评价指标，余弦值大说明相近
        % 与x轴负向的余弦值
        cost = cost+dot(vShoulder,vx)/(norm(vShoulder)*norm(vx));
        cost = cost+dot(vHip,vx)/(norm(vHip)*norm(vx));
        cost = cost+0*dot(vKnee,vx)/(norm(vKnee)*norm(vx));
    end