%% 计算多体段的平均加速度
function acc = CalMeanAcc(accCOMSegments,names,gender)
    if nargin<3, gender ='M'; end
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
    sumAccX = 0; sumAccY = 0;sumAccZ = 0; 
    sumM = 0;
    for i = 1:length(names)
        nameLR = names{i};
        if contains(nameLR,'_')
            name = nameLR(1:strfind(nameLR,'_')-1);
        else
            name = nameLR;
        end
        sumAccX = sumAccX+M.(name).*accCOMSegments.(nameLR).x;
        sumAccY = sumAccY+M.(name).*accCOMSegments.(nameLR).y;
        sumAccZ = sumAccZ+M.(name).*accCOMSegments.(nameLR).z;
        sumM = sumM+M.(name);
    end
    acc.x = sumAccX./sumM;
    acc.y = sumAccY./sumM;
    acc.z = sumAccZ./sumM;
end