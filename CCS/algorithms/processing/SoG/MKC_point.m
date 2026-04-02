function mkc = MKC_point(g1,g2)
    % 计算两个高斯核的多变量高斯核相关（MKC）
    % 输入：
    %   g1, g2: 两个高斯核，格式为 [x, y, z, σ^2]
    % 输出：
    %   mkc: MKC值

    % 提取均值和方差
    mu1 = g1(1:3)'; % 3*1的格式
    variance1 = g1(4);
    mu2 = g2(1:3)'; % 3*1的格式
    variance2 = g2(4);
    
    % 将方差转换成协方差矩阵（因为是各向同性高斯）
    Sigma1 = variance1 * eye(3);
    Sigma2 = variance2 * eye(3);
    
    % 计算Sigma1和Sigma2的逆矩阵之和
    SigmaInvSum = inv(Sigma1) + inv(Sigma2);
    
    % 计算Sigma1和Sigma2之和的逆矩阵
    SigmaSum = Sigma1 + Sigma2;
    SigmaSumInv = SigmaSum \ eye(3);
%     SigmaSumInv = inv(Sigma1 + Sigma2);
    
    % 计算MKC
    n = length(mu1); % 空间的维度
    mkc = (2 * pi)^(n/2) / (det(SigmaInvSum))^(n/2) * exp(-0.5 * (mu1 - mu2)' * SigmaSumInv * (mu1 - mu2));

end