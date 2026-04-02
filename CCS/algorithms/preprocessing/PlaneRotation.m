function rotation_matrix = PlaneRotation(points)
    % points: 3x3矩阵，每一行是一个点的XYZ坐标
    
    % 提取点的坐标
    p1 = points(1, :);
    p2 = points(2, :);
    p3 = points(3, :);
    
    % 计算平面法向量
    v1 = p2 - p1;
    v2 = p3 - p1;
    normal_vector = cross(v1, v2);
    normal_vector = normal_vector / norm(normal_vector); % 单位化
    
    % 计算旋转矩阵
    % 目标是将法向量旋转到与Z轴对齐
    z_axis = [0; 0; -1];
    rotation_axis = cross(normal_vector, z_axis);
    rotation_axis = rotation_axis / norm(rotation_axis); % 单位化
    
    % 计算旋转角度
    rotation_angle = acos(dot(normal_vector, z_axis));
    
    % 使用 Rodrigues 旋转公式计算旋转矩阵
    K = [0 -rotation_axis(3) rotation_axis(2);
         rotation_axis(3) 0 -rotation_axis(1);
         -rotation_axis(2) rotation_axis(1) 0];
    rotation_matrix = eye(3) + sin(rotation_angle) * K + (1 - cos(rotation_angle)) * K^2;
    
    % 输出旋转矩阵
    disp('旋转矩阵:');
    disp(rotation_matrix);
end