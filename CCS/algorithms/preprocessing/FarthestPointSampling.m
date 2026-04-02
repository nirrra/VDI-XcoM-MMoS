function [M_points] = FarthestPointSampling(points, M)
    % 输入的点云数据 (N,3)
    % M: 需要采样的点的数量
    % 输出采样后的点云 (M,3)
    
    % 检查输入点云是否为空
    if isempty(points)
        error('输入的点云数据不能为空');
    end
    
    % 初始化采样点集
    M_points = [];
    
    % 随机选择第一个点作为起始点
    farthest_idx = randi(size(points, 1));
    current_point = points(farthest_idx, :);
    M_points = [M_points; current_point];
    
    % 剩余点集
    remaining_points = points;
    remaining_points(farthest_idx, :) = [];
    
    % 循环直到采样到M个点
    for i = 1:(M-1)
        % 计算剩余点到已采样点集中所有点的最小距离
        distances = zeros(size(remaining_points, 1), 1);
        for j = 1:size(remaining_points, 1)
            dist = sqrt(min(sum((remaining_points(j, :) - M_points).^2, 2)));
            distances(j) = dist;
        end
        
        % 找到距离最远的点
        [~, farthest_idx] = max(distances);
        farthest_point = remaining_points(farthest_idx, :);
        
        % 将最远点添加到采样点集中
        M_points = [M_points; farthest_point];
        
        % 从剩余点集中移除已采样的点
        remaining_points(farthest_idx, :) = [];
    end
end