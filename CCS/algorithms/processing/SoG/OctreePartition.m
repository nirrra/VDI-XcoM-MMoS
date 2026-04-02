function [clusters, centers, variances] = OctreePartition(points, max_level, depth_thresh)
% OctreePartition: 使用八叉树划分点云
% 输入:
%   points: Nx3 点云数据
%   max_level: 最大划分层级
%   depth_thresh: 深度方向标准差阈值
% 输出:
%   clusters: 每个点所属的簇标签
%   centers: 每个叶子节点的中心点
%   variances: 每个叶子节点的方差

    % 获取点云的边界框
    min_bounds = min(points);
    max_bounds = max(points);
    
    % 初始化根节点
    root = struct('points', points, ...
                 'bounds_min', min_bounds, ...
                 'bounds_max', max_bounds, ...
                 'level', 0, ...
                 'children', [], ...
                 'is_leaf', false);
    
    % 递归构建八叉树
    leaf_nodes = {};
    buildOctree(root);
    
    % 为每个叶子节点分配标签
    clusters = zeros(size(points, 1), 1);
    centers = zeros(length(leaf_nodes), 3);
    variances = zeros(length(leaf_nodes), 1);
    
    for i = 1:length(leaf_nodes)
        node = leaf_nodes{i};
        if ~isempty(node.points)
            % 为该节点中的所有点分配相同的标签
            point_indices = findPointIndices(points, node.points);
            clusters(point_indices) = i;
            
            % 计算中心点和方差
            centers(i,:) = mean(node.points, 1);
            % 方差设置为立方体边长的一半的平方
            cube_size = norm(node.bounds_max - node.bounds_min) / 2;
            variances(i) = cube_size^2;
        end
    end

    function buildOctree(node)
        if node.level >= max_level
            node.is_leaf = true;
            leaf_nodes{end+1} = node;
            return;
        end
        
        % 计算三个方向的标准差
        std_x = std(node.points(:,1));
        std_y = std(node.points(:,2));
        std_z = std(node.points(:,3));
        
        % 使用三个方向标准差的最大值作为判断依据
        depth_std = max([std_x, std_y, std_z]);
%         depth_std = std_z;
        
        if depth_std <= depth_thresh || size(node.points, 1) <= 1
            node.is_leaf = true;
            leaf_nodes{end+1} = node;
            return;
        end
        
        % 计算中心点
        center = (node.bounds_min + node.bounds_max) / 2;
        
        % 创建8个子节点
        node.children = cell(8,1);
        for oct = 1:8
            % 确定子节点的边界
            [min_bound, max_bound] = getOctantBounds(node.bounds_min, node.bounds_max, center, oct);
            
            % 找到属于这个子节点的点
            mask = points_in_bounds(node.points, min_bound, max_bound);
            sub_points = node.points(mask, :);
            
            if ~isempty(sub_points)
                child = struct('points', sub_points, ...
                             'bounds_min', min_bound, ...
                             'bounds_max', max_bound, ...
                             'level', node.level + 1, ...
                             'children', [], ...
                             'is_leaf', false);
                node.children{oct} = child;
                buildOctree(child);
            end
        end
    end
end

function [min_bound, max_bound] = getOctantBounds(min_bounds, max_bounds, center, octant)
    % 根据八分体编号确定边界
    min_bound = min_bounds;
    max_bound = max_bounds;
    
    if mod(octant-1, 2) == 0
        max_bound(1) = center(1);
    else
        min_bound(1) = center(1);
    end
    
    if mod(floor((octant-1)/2), 2) == 0
        max_bound(2) = center(2);
    else
        min_bound(2) = center(2);
    end
    
    if mod(floor((octant-1)/4), 2) == 0
        max_bound(3) = center(3);
    else
        min_bound(3) = center(3);
    end
end

function mask = points_in_bounds(points, min_bound, max_bound)
    % 判断点是否在边界内
    mask = all(points >= min_bound & points <= max_bound, 2);
end

function indices = findPointIndices(all_points, subset_points)
    % 找到子集点在原始点云中的索引
    indices = zeros(size(subset_points, 1), 1);
    for i = 1:size(subset_points, 1)
        [~, idx] = min(sum((all_points - subset_points(i,:)).^2, 2));
        indices(i) = idx;
    end
end