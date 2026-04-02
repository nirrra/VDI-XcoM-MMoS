function [M_points] = FarthestPointSampling_KD2(points, M)
    % 相比于直接计算速度更慢
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
    current_point_idx = randi(size(points, 1));
    current_point = points(current_point_idx, :);
    M_points = [M_points; current_point];
    
    % 标记已选择的点
    selected = false(size(points, 1), 1);
    selected(current_point_idx) = true;
    
    % 创建KD树
    remaining_points = points(~selected, :);
    kdtree = KDTreeSearcher(M_points);
    
    % 循环直到采样到M个点
    for i = 1:(M-1)
        % 计算所有剩余点到已采样点集中所有点的距离
        distances = zeros(size(remaining_points,1),1);
        for j = 1:size(remaining_points,1)
            [~, D] = knnsearch(kdtree,remaining_points(j,:));
            distances(j) = D;
        end

        % 找到距离最远的点
        [~, farthest_idx] = max(distances);
        farthest_point = remaining_points(farthest_idx, :);

        M_points = [M_points; farthest_point];

        % 标记为已选择
        selected(farthest_idx) = true; % 使用全局索引标记

        % 更新KD树
        remaining_points(farthest_idx, :) = [];
        kdtree = KDTreeSearcher(M_points);
    end
end
