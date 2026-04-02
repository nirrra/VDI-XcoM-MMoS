%% 计算髋关节屈曲角度的时间序列，单位degree
function [pelvisFlexion] = CalPelvisFlexion(stream)
    dataLength = length(stream.ANKLE_LEFT.x);
    pelvisFlexionLeft = zeros(dataLength,1);
    pelvisFlexionRight = zeros(dataLength,1);
    for i = 1:dataLength
        spine_naval = [stream.SPINE_NAVAL.x(i),stream.SPINE_NAVAL.y(i),stream.SPINE_NAVAL.z(i)];
        pelvis = [stream.PELVIS.x(i),stream.PELVIS.y(i),stream.PELVIS.z(i)];
        hip_left = [stream.HIP_LEFT.x(i),stream.HIP_LEFT.y(i),stream.HIP_LEFT.z(i)];
        hip_right = [stream.HIP_RIGHT.x(i),stream.HIP_RIGHT.y(i),stream.HIP_RIGHT.z(i)];
        knee_left = [stream.KNEE_LEFT.x(i),stream.KNEE_LEFT.y(i),stream.KNEE_LEFT.z(i)];
        knee_right = [stream.KNEE_RIGHT.x(i),stream.KNEE_RIGHT.y(i),stream.KNEE_RIGHT.z(i)];
        
        vectorTrunk = spine_naval-pelvis; vectorTrunk(1) = 0;
        vectorLeftThigh = knee_left-hip_left; vectorLeftThigh(1) = 0;
        vectorRightThigh = knee_right-hip_right; vectorRightThigh(1) = 0;

%         pelvisFlexionLeft(i) = acosd(dot(spine_naval-pelvis,knee_left-hip_left)/(norm(spine_naval-pelvis)*norm(knee_left-hip_left)));
%         pelvisFlexionRight(i) = acosd(dot(spine_naval-pelvis,knee_right-hip_right)/(norm(spine_naval-pelvis)*norm(knee_right-hip_right)));
        pelvisFlexionLeft(i) = acosd(dot(vectorTrunk,vectorLeftThigh)./(norm(vectorTrunk)*norm(vectorLeftThigh)));
        pelvisFlexionRight(i) = acosd(dot(vectorTrunk,vectorRightThigh)./(norm(vectorTrunk)*norm(vectorRightThigh)));
    end
    pelvisFlexion = mean([pelvisFlexionLeft,pelvisFlexionRight],2);
end