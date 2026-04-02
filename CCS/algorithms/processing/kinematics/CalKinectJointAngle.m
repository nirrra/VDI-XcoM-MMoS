% 计算角ABC的角度（degree），以及分别在yz,xz,xy平面（矢状面、冠状面、水平面）的角度
function [jointAngle,jointAnglePlane] = CalKinectJointAngle(A,B,C)
jointAngle = zeros(length(A.x),1);
jointAnglePlane = {zeros(length(A.x),1);zeros(length(A.x),1);zeros(length(A.x),1)};
vABs = [B.x-A.x,B.y-A.y,B.z-A.z];
vCBs = [B.x-C.x,B.y-C.y,B.z-C.z];
for i = 1:length(A.x)
    vAB = vABs(i,:); vCB = vCBs(i,:);
    jointAngle(i) = acosd(dot(vAB,vCB)/(norm(vAB)*norm(vCB)));
    for j = 1:3
        idx = setdiff(1:3,j);
        jointAnglePlane{j}(i) = acosd(dot(vAB(idx),vCB(idx))/(norm(vAB(idx))*norm(vCB(idx))));
    end
end