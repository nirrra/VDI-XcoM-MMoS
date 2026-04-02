%% FUNC calCOP：计算COP（得到的COP坐标系为：x向右，y向下；单位mm）
% 以左前单元左前顶点为坐标系原点 
function [copX, copY] = calCOP(data2D, unitScaling)
    if nargin < 2
        unitScaling = 1;
    end
    frameNum = size(data2D,1);
    copX = zeros(frameNum,1);
    copY = zeros(frameNum,1);
    weight = (repmat(1:32,32,1)-0.5).*11.5; % 单位mm
    for i = 1:frameNum
        data = double(reshape(data2D(i,:),32,32));
        copX(i) = sum(sum(data.*weight))/sum(sum(data));
        copY(i) = sum(sum(data.*weight'))/sum(sum(data));
        if sum(sum(data)) <= 2*unitScaling % 默认电平值
            copX(i) = -1; copY(i) = -1;
        end
    end
end