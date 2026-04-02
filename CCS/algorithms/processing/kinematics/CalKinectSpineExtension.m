% 计算脊椎伸展的角度（degree），即与(0,0,-1)的夹角，以及分别在yz,xz,xy平面（矢状面、冠状面、水平面）的角度
function [jointAngle,jointAnglePlane] = CalKinectSpineExtension(A,B)
jointAngle = zeros(length(A.x),1);
jointAnglePlane = cell(3,1);
vABs = [B.x-A.x,B.y-A.y,B.z-A.z];
for i = 1:length(A.x)
    vAB = vABs(i,:); vCB = [0,0,-1];
    jointAngle(i) = acosd(dot(vAB,vCB)/(norm(vAB)*norm(vCB)));
    for j = 1:3
        idx = setdiff(1:3,j);
        jointAnglePlane{j}(i) = acosd(dot(vAB(idx),vCB(idx))/(norm(vAB(idx))*norm(vCB(idx))));
    end
end