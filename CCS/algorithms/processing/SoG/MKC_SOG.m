function [mkc_sum] = MKC_SOG(sog1,sog2)
    % 计算两个SoG的多变量高斯核相关（MKC）
    % 输入：
    %   sog1, sog2: 两个SoG，格式为 n*4的矩阵，n*[x, y, z, σ^2]
    % 输出：
    %   mkc: MKC值
    mkc_sum = 0;
    for i = 1:size(sog1,1)
        for j = 1:size(sog2,1)
            mkc = MKC_point(sog1(i,:),sog2(j,:));
            mkc_sum = mkc_sum+mkc;
        end
    end

    mkc_sum = -mkc_sum; % 求最小值
end