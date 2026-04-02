%% FUNC getCtrsPts：获取DBSCAN每部分的形心
function [ctrsPts] = getCtrsPts(pts, labels)
    labelsImg = zeros(32,32);
    for i = 1:size(pts,1)
        labelsImg(pts(i,2),pts(i,1)) = labels(i);
    end
    stat = regionprops(labelsImg, 'centroid');% regionprops()度量图像区域属性
    ctrsPts = zeros(numel(stat),2);
    for i = 1:numel(stat)
        ctrsPts(i,:) = [stat(i).Centroid(1),stat(i).Centroid(2)];
    end
end