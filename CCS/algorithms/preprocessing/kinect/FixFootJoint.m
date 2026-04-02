function stream = FixFootJoint(stream,method)
if nargin < 2
    method = 1;
end
% 1：取足-踝向量中位数
ankle2FootLeft = median([stream.FOOT_LEFT.x,stream.FOOT_LEFT.y,stream.FOOT_LEFT.z]-...
    [stream.ANKLE_LEFT.x,stream.ANKLE_LEFT.y,stream.ANKLE_LEFT.z]);
ankle2FootRight = median([stream.FOOT_RIGHT.x,stream.FOOT_RIGHT.y,stream.FOOT_RIGHT.z]-...
    [stream.ANKLE_RIGHT.x,stream.ANKLE_RIGHT.y,stream.ANKLE_RIGHT.z]);
if method == 2 % 2：足踝向量z为0
    ankle2FootLeft(3) = 0; ankle2FootRight(3) = 0;
end
if method == 3 % 3：固定长度，xz方向为0
    ankle2FootLeft = [0,norm(ankle2FootLeft),0]; ankle2FootRight = [0,norm(ankle2FootRight),0];
end
stream.FOOT_LEFT.x = stream.ANKLE_LEFT.x+ankle2FootLeft;
stream.FOOT_LEFT.y = stream.ANKLE_LEFT.y+ankle2FootLeft;
stream.FOOT_LEFT.z = stream.ANKLE_LEFT.z+ankle2FootLeft;
stream.FOOT_RIGHT.x = stream.ANKLE_RIGHT.x+ankle2FootRight;
stream.FOOT_RIGHT.y = stream.ANKLE_RIGHT.y+ankle2FootRight;
stream.FOOT_RIGHT.z = stream.ANKLE_RIGHT.z+ankle2FootRight;