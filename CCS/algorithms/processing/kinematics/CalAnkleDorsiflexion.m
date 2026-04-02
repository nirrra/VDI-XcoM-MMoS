%% 计算踝关节背屈角度的时间序列，单位degree
function [ankleDorsiflexion] = CalAnkleDorsiflexion(stream)
    dataLength = length(stream.ANKLE_LEFT.x);
    ankleDorsiflexionLeft = zeros(dataLength,1);
    ankleDorsiflexionRight = zeros(dataLength,1);
    vectorFloor = [0,0,-1];
    for i = 1:dataLength
        knee = [stream.KNEE_LEFT.x(i),stream.KNEE_LEFT.y(i),stream.KNEE_LEFT.z(i)];
        ankle = [stream.ANKLE_LEFT.x(i),stream.ANKLE_LEFT.y(i),stream.ANKLE_LEFT.z(i)];
        foot = [stream.FOOT_LEFT.x(i),stream.FOOT_LEFT.y(i),stream.FOOT_LEFT.z(i)];
%         ankleDorsiflexionLeft(i) = acosd(dot(knee-ankle,foot-ankle)/(norm(knee-ankle)*norm(foot-ankle))); % 小腿与足部
        ankleDorsiflexionLeft(i) = acosd(dot(knee-ankle,vectorFloor)/(norm(knee-ankle)*norm(vectorFloor))); % 小腿与地面
        
        knee = [stream.KNEE_RIGHT.x(i),stream.KNEE_RIGHT.y(i),stream.KNEE_RIGHT.z(i)];
        ankle = [stream.ANKLE_RIGHT.x(i),stream.ANKLE_RIGHT.y(i),stream.ANKLE_RIGHT.z(i)];
        foot = [stream.FOOT_RIGHT.x(i),stream.FOOT_RIGHT.y(i),stream.FOOT_RIGHT.z(i)];
%         ankleDorsiflexionRight(i) = acosd(dot(knee-ankle,foot-ankle)/(norm(knee-ankle)*norm(foot-ankle))); % 小腿与足部
        ankleDorsiflexionRight(i) = acosd(dot(knee-ankle,vectorFloor)/(norm(knee-ankle)*norm(vectorFloor))); % 小腿与地面
    end
    ankleDorsiflexion = mean([ankleDorsiflexionLeft,ankleDorsiflexionRight],2);
end