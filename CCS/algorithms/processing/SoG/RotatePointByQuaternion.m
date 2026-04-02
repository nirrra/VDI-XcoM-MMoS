function [vec_rot] = RotatePointByQuaternion(vec, q)
    % 原点
    origin = [0, 0, 0];

    % 将点平移到原点
    vec_centered = vec - origin;
    
    % 确保四元数是单位四元数
    q = q / norm(q);
    
    % 将点转换为纯四元数 [0, x, y, z]
    p = [0, vec_centered];
    
    % 计算q的共轭（四元数的逆）
    q_conj = [q(1), -q(2), -q(3), -q(4)];
    
    % 执行四元数乘法 p * q_conj
    temp = quaternionMultiply(p, q_conj);
    
    % 执行四元数乘法 q * temp
    rotated = quaternionMultiply(q, temp);
    
    % 提取旋转后的向量部分（后三个分量）并平移回原始位置
    vec_rot = rotated(2:4) + origin;
end

function result = quaternionMultiply(q1, q2)
    % 四元数乘法
    % q1, q2: [w, x, y, z]
    w1 = q1(1); x1 = q1(2); y1 = q1(3); z1 = q1(4);
    w2 = q2(1); x2 = q2(2); y2 = q2(3); z2 = q2(4);
    
    % 计算结果
    w = w1*w2 - x1*x2 - y1*y2 - z1*z2;
    x = w1*x2 + x1*w2 + y1*z2 - z1*y2;
    y = w1*y2 - x1*z2 + y1*w2 + z1*x2;
    z = w1*z2 + x1*y2 - y1*x2 + z1*w2;
    
    result = [w, x, y, z];
end