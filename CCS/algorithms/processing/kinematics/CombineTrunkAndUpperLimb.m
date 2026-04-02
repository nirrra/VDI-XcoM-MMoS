% 合并躯干和上肢的质心、速度、加速度
function [posCOMSegments,vCOMSegments,accCOMSegments] = CombineTrunkAndUpperLimb(posCOMSegments,vCOMSegments,accCOMSegments,gender)
    if gender == 'M'
        M.HeadNeck = 0.0694;
        M.Trunk = 0.4346;
        M.Upperarm = 0.0271;
        M.Forearm = 0.0162;
        M.Hand = 0.0061;
        M.Thigh = 0.1416;
        M.Shank = 0.0433;
        M.Foot = 0.0137;
    elseif gender == 'F'
        M.HeadNeck = 0.0669;%为了将体重凑到100%
        M.Trunk = 0.4257;
        M.Upperarm = 0.0255;
        M.Forearm = 0.0138;
        M.Hand = 0.0056;
        M.Thigh = 0.1478;
        M.Shank = 0.0481;
        M.Foot = 0.0129;
    end
    
    M.TrunkWithLimb = M.Trunk+2*(M.Upperarm+M.Forearm+M.Hand);
    posCOMSegments = CalWeightMean(M,posCOMSegments);
    vCOMSegments = CalWeightMean(M,vCOMSegments);
    accCOMSegments = CalWeightMean(M,accCOMSegments);
end

function data = CalWeightMean(M,data)
    axis = 'x';
    data.TrunkWithLimb.(axis) = (M.Trunk*data.Trunk.(axis)+M.Upperarm*(data.Upperarm_Left.(axis)+data.Upperarm_Right.(axis))...
        +M.Forearm*(data.Forearm_Left.(axis)+data.Forearm_Right.(axis))+M.Hand*(data.Hand_Left.(axis)+data.Hand_Right.(axis)))...
        ./M.TrunkWithLimb;
    axis = 'y';
    data.TrunkWithLimb.(axis) = (M.Trunk*data.Trunk.(axis)+M.Upperarm*(data.Upperarm_Left.(axis)+data.Upperarm_Right.(axis))...
        +M.Forearm*(data.Forearm_Left.(axis)+data.Forearm_Right.(axis))+M.Hand*(data.Hand_Left.(axis)+data.Hand_Right.(axis)))...
        ./M.TrunkWithLimb;
    axis = 'z';
    data.TrunkWithLimb.(axis) = (M.Trunk*data.Trunk.(axis)+M.Upperarm*(data.Upperarm_Left.(axis)+data.Upperarm_Right.(axis))...
        +M.Forearm*(data.Forearm_Left.(axis)+data.Forearm_Right.(axis))+M.Hand*(data.Hand_Left.(axis)+data.Hand_Right.(axis)))...
        ./M.TrunkWithLimb;
end