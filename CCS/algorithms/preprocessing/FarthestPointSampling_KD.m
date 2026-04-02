function [M_points] = FarthestPointSampling_KD(points, M)
    % 不准确的方法
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
    kdtree = KDTreeSearcher(points(~selected, :));
    
    % 循环直到采样到M个点
    for i = 1:(M-1)
        % 计算所有剩余点到已采样点集中所有点的距离
        max_distance = -inf;
        farthest_idx = 0;
        for j = 1:size(M_points, 1)
            % 使用KD树找到每个点到当前点集的最近邻
            [idx, D] = knnsearch(kdtree, M_points(j, :), 'K', 1);
            if D > max_distance
                max_distance = D;
                farthest_idx = idx;
            end
        end
        

        % 找到距离最远的点
        aux = find(~selected); % 获取未被选中的点的全局索引
        farthest_idx_global = aux(farthest_idx); % 将局部索引转换为全局索引
        farthest_point = points(farthest_idx_global, :);
        
        % 将最远点添加到采样点集中
        M_points = [M_points; farthest_point];
        
        % 标记为已选择
        selected(farthest_idx_global) = true; % 使用全局索引标记
        
        % 更新KD树
        kdtree = KDTreeSearcher(points(~selected, :));
    end
end
