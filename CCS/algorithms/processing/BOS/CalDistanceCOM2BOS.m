% distances_min：COM到BOS边界的最短距离（垂线）
% distances_axis：COM到BOS边界的水平与竖直方向的最短距离
function [distances_min] = CalDistanceCOM2BOS(com, bos)

distances_min = struct();
distances_min.dis = zeros(length(com.x),1);
distances_min.dis_x = zeros(length(com.x),1);
distances_min.dis_y = zeros(length(com.x),1);

for idx_frame = 1:length(com.x)
    com_x = com.x(idx_frame);
    com_y = com.y(idx_frame);
    bos_x = bos.x{idx_frame};
    bos_y = bos.y{idx_frame};
        
    % 检查 COM 是否在 BOS 内
    is_inside = inpolygon(com_x, com_y, bos_x, bos_y);
    
    % 初始化最小距离和对应的端点
    min_distance = inf;
    closest_point1 = [0, 0];
    closest_point2 = [0, 0];
    
    % 检查点到点的距离
    distances = sqrt((com_x - bos_x).^2 + (com_y - bos_y).^2);
    [point_min_dist, point_idx] = min(distances);
    if point_min_dist < min_distance
        min_distance = point_min_dist;
        closest_point1 = [com_x, com_y];
        closest_point2 = [bos_x(point_idx), bos_y(point_idx)];
    end
    
    % 检查点到边的距离
    for i = 1:length(bos_x) - 1
        % 边的两个端点
        edge_p1 = [bos_x(i), bos_y(i)];
        edge_p2 = [bos_x(i+1), bos_y(i+1)];
        
        % 计算边的向量
        edge_vector = edge_p2 - edge_p1;
        point_vector = [com_x - edge_p1(1), com_y - edge_p1(2)];
        
        % 计算垂线距离
        perpendicular_distance = abs((edge_vector(2)*point_vector(1) - edge_vector(1)*point_vector(2))) / norm(edge_vector);
        
        % 计算垂点参数t
        t = dot(point_vector, edge_vector) / dot(edge_vector, edge_vector);
        
        if t >= 0 && t <= 1
            % 垂点在边上
            if perpendicular_distance < min_distance
                min_distance = perpendicular_distance;
                % 计算垂足坐标
                foot_point = edge_p1 + t * edge_vector;
                closest_point1 = [com_x, com_y];
                closest_point2 = foot_point;
            end
        end
    end
    
    % 如果 COM 在 BOS 外，距离取负
    if ~is_inside
        min_distance = -min_distance;
    end

    % 保存最小距离
    distances_min.dis(idx_frame) = min_distance;
    
    % 计算x和y方向的分量
    vector = closest_point2 - closest_point1;
    distances_min.dis_x(idx_frame) = vector(1);
    distances_min.dis_y(idx_frame) = vector(2);
end

%% 计算到x和y边界的距离
distances_min.x_left = zeros(length(com.x),1);
distances_min.x_right = zeros(length(com.x),1);
distances_min.y_front = zeros(length(com.x),1);
distances_min.y_back = zeros(length(com.x),1);
distances_min.x = zeros(length(com.x),1);
distances_min.y = zeros(length(com.x),1);

for idx_frame = 1:length(com.x)
    com_x = com.x(idx_frame);
    com_y = com.y(idx_frame);
    bos_x = bos.x{idx_frame};
    bos_y = bos.y{idx_frame};
    
    distances_min.x_left(idx_frame) = com_x-min(bos_x);
    distances_min.x_right(idx_frame) = com_x-max(bos_x);
    distances_min.y_front(idx_frame) = com_y-max(bos_y);
    distances_min.y_back(idx_frame) = com_y-min(bos_y);

    if com_x > max(bos_x) || com_x < min(bos_x)
        distances_min.x(idx_frame) = -min(abs(com_x-min(bos_x)),abs(com_x-max(bos_x)));
    else
        distances_min.x(idx_frame) = min(abs(com_x-min(bos_x)),abs(com_x-max(bos_x)));
    end

    if com_y > max(bos_y) || com_y < min(bos_y)
        distances_min.y(idx_frame) = -min(abs(com_y-min(bos_y)),abs(com_y-max(bos_y)));
    else
        distances_min.y(idx_frame) = min(abs(com_y-min(bos_y)),abs(com_y-max(bos_y)));
    end

end

%% 作图验证
if false
    idx_frame = 100;
    com_x = com.x(idx_frame);
    com_y = com.y(idx_frame);
    bos_x = bos.x{idx_frame};
    bos_y = bos.y{idx_frame};
    
    figure;
    hold on;
    plot(com_x,-com_y,'ro');
    plot(bos_x, -bos_y, 'b-');
    plot(com_x+min_distance*cos(linspace(0,2*pi,100)),-com_y+min_distance*sin(linspace(0,2*pi,100)),'g-');
    hold off;
    axis equal;
    xlabel('X (m)');
    ylabel('-Y (m)');
end

