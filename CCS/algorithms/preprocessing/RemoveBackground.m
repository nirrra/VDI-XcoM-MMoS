function [pointclouds_new] = RemoveBackground(pointclouds,flagKeepPts,rangeXYZ,gridX,gridY,gridZ)
pointclouds_new = cell(1,length(pointclouds));
for i = 1:size(pointclouds,2)
    if mod(i,20) == 0
        disp(['删除背景噪声: ',num2str(i),'/',num2str(length(pointclouds_new))]);
    end
    points = pointclouds{1,i};
    orderKeep = [];
    for j = 1:size(points,1)
        % 找到点所在的单元格
        xi = find(gridX >= points(j, 1), 1, 'first');
        yi = find(gridY >= points(j, 2), 1, 'first');
        zi = find(gridZ >= points(j, 3), 1, 'first');
        
        % 检查点是否在边界内
        if ~isempty(xi) && ~isempty(yi) && ~isempty(zi) && xi>1 && yi>1 && zi>1
            % 判断点所属于的单元格是否flag为true
            xi = xi-1; yi = yi-1; zi = zi-1;
            if flagKeepPts(xi, yi, zi) && xi>rangeXYZ(1,1) && xi<rangeXYZ(1,2) ...
                && yi>rangeXYZ(2,1) && yi<rangeXYZ(2,2) && zi>rangeXYZ(3,1) && zi<rangeXYZ(3,2)
                orderKeep(end+1) = j;
            end
        end

    end
    pointclouds_new{1,i} = points(orderKeep,:);
end