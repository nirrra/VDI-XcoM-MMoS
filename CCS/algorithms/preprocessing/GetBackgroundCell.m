function [flagKeepPts,rangeXYZ,gridX,gridY,gridZ] = GetBackgroundCell(cellPC,cellPC_bg)
%% 获取背景噪声单元格
pointclouds_bg = cellPC_bg;
pointclouds = cellPC;
%% 获取点云范围
maxXYZ = ones(1,3)*-10e6;
minXYZ = ones(1,3)*10e6;
for i = 1:numel(pointclouds)
    aux = pointclouds{1,i};
    maxXYZ = max([maxXYZ;aux]);
    minXYZ = min([minXYZ;aux]);
end
for i = 1:numel(pointclouds_bg)
    aux = pointclouds_bg{1,i};
    maxXYZ = max([maxXYZ;aux]);
    minXYZ = min([minXYZ;aux]);
end
%% 将空间划分为多个单元
step = 30; % 单位mm

% 创建每个轴上的点
gridX = ceil(minXYZ(1)./step)*step:step:maxXYZ(1);
gridY = ceil(minXYZ(2)./step)*step:step:maxXYZ(2);
gridZ = ceil(minXYZ(3)./step)*step:step:maxXYZ(3);

% 生成三维网格
[X, Y, Z] = meshgrid(gridX, gridY, gridZ);

% 初始化计数器
cntPts = zeros(length(gridX)-1, length(gridY)-1, length(gridZ)-1);

% 遍历噪声点集
for i = 1:size(pointclouds_bg,2)
    points = pointclouds_bg{1,i};
    for j = 1:size(points,1)
        % 找到点所在的单元格
        xi = find(gridX >= points(j, 1), 1, 'first');
        yi = find(gridY >= points(j, 2), 1, 'first');
        zi = find(gridZ >= points(j, 3), 1, 'first');
        
        % 检查点是否在边界内
        if ~isempty(xi) && ~isempty(yi) && ~isempty(zi) && xi>1 && yi>1 && zi>1
            % 更新计数器
            xi = xi-1; yi = yi-1; zi = zi-1;
            cntPts(xi, yi, zi) = cntPts(xi, yi, zi) + 1;
        end
    end
end

flagKeepPts = cntPts<max(cntPts(:))*0.01;

%% 有效空间范围
rangeXYZ = zeros(3,2);

aux = sum(~flagKeepPts,[2 3]);
for i = 6:length(aux)-5
    if min(aux(i-5:i+5))>0
        rangeXYZ(1,1) = i;
        break;
    end
end
for i = length(aux)-5:-1:6
    if min(aux(i-5:i+5))>0
        rangeXYZ(1,2) = i;
        break;
    end
end

aux = sum(~flagKeepPts,[1 3]);
for i = 6:length(aux)-5
    if min(aux(i-5:i+5))>0
        rangeXYZ(2,1) = i;
        break;
    end
end
for i = length(aux)-5:-1:6
    if min(aux(i-5:i+5))>0
        rangeXYZ(2,2) = i;
        break;
    end
end

aux = sum(~flagKeepPts,[1 2]);
for i = 6:length(aux)-5
    if min(aux(i-5:i+5))>0
        rangeXYZ(3,1) = i;
        break;
    end
end
for i = length(aux)-5:-1:6
    if min(aux(i-5:i+5))>0
        rangeXYZ(3,2) = i;
        break;
    end
end
