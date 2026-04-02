% 计算小腿和地面的角度（degree），以及分别在yz,xz,xy平面（矢状面、冠状面、水平面）的角度
function [jointAngle,jointAnglePlane] = CalKinectAnkleAngle(A,B,C)
jointAngle = zeros(length(A.x),1);
jointAnglePlane = cell(3,1);
vABs = [B.x-A.x,B.y-A.y,B.z-A.z];
vCBs = zeros(size(vABs));
if nargin < 3
    vCBs(:,1) = 0; vCBs(:,2) = -1; vCBs(:,3) = 0;
else 
    vCBs = [B.x-C.x,B.y-C.y,B.z-C.z];
    vCBs(:,3) = 0; % 踝、足置于同一高度
end

for i = 1:length(A.x)
    vAB = vABs(i,:); vCB = vCBs(i,:);
    jointAngle(i) = acosd(dot(vAB,vCB)/(norm(vAB)*norm(vCB)));
    for j = 1:3
        idx = setdiff(1:3,j);
        jointAnglePlane{j}(i) = acosd(dot(vAB(idx),vCB(idx))/(norm(vAB(idx))*norm(vCB(idx))));
    end
end