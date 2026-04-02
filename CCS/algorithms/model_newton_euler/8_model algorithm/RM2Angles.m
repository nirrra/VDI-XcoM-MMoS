%% 函数：旋转矩阵获取旋转角度
function rotateAngles = RM2Angles(rmSegments)
    dataLength = length(rmSegments.HeadNeck);
    names = fieldnames(rmSegments);
    for idxName = 1:length(names)
        name = names{idxName};
        for i = 1:dataLength
            R = rmSegments.(name){1,i};
            [V,D] = eig(R); % V特征向量矩阵，D对角矩阵
            % 找到最大特征值对应的列
            [~,idx] = max(diag(D));
            rotation_axis = V(:,idx); % 旋转轴的方向向量
            % 旋转角度
            angle = acosd((trace(R)-1)/2);
            rotateAngles.(name)(i) = angle;
        end
    end

end