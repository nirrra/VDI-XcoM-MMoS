function [cop_ML,cop_AP] = Ground_COP(stream,grfLeft,grfRight,grmLeft,grmRight,rzbias)
if nargin < 6
    rzbias = 0; %
end

% Z轴移动
grmLeft_new.x = grmLeft.x - rzbias * grfLeft.y;
grmLeft_new.y = grmLeft.y + rzbias * grfLeft.x;

grmRight_new.x = grmRight.x - rzbias* grfRight.y;
grmRight_new.y = grmRight.y + rzbias* grfRight.x;

% 水平面移动至全局坐标系原点
rLeft.x = stream.ANKLE_LEFT.x; rLeft.y = stream.ANKLE_LEFT.y;
rRight.x = stream.ANKLE_RIGHT.x; rRight.y = stream.ANKLE_RIGHT.y;

cop_ML = (-grmLeft_new.y - grmRight_new.y...
    + rLeft.x .* grfLeft.z + rRight.x .* grfRight.z)./(grfLeft.z + grfRight.z);

cop_AP = ( grmLeft_new.x + grmRight_new.x...
    + rLeft.y .* grfLeft.z + rRight.y .* grfRight.z)./(grfLeft.z + grfRight.z);