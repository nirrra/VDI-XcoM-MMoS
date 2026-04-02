function [mkc_sum] = MKC_SegmentScaled(sog1,sog2,obj)
    % 计算两个SoG的多变量高斯核相关（MKC），通过体段权重的，参考公式12和13
    % 输入：
    %   sog1：点云的SoG
    %   sog2: 模型的SoG，格式为 n*4的矩阵，n*[x, y, z, σ^2]
    % 输出：
    %   mkc: MKC值

    % 计算mkc
    mkc_sum = 0;

    for i = 1:size(sog1,1)
        % headNeck
        for j = 1:1
            mkc = MKC_point(sog1(i,:),sog2(j,:));
            mkc_sum = mkc_sum+1/obj.segments.headNeck.w*mkc;
        end
        % trunk
        for j = 2:25
            mkc = MKC_point(sog1(i,:),sog2(j,:));
            mkc_sum = mkc_sum+1/obj.segments.trunk.w*mkc;
        end
        % leftArm
        for j = 26:29
            mkc = MKC_point(sog1(i,:),sog2(j,:));
            mkc_sum = mkc_sum+1/obj.segments.leftArm.w*mkc;
        end
        % rightArm
        for j = 30:33
            mkc = MKC_point(sog1(i,:),sog2(j,:));
            mkc_sum = mkc_sum+1/obj.segments.rightArm.w*mkc;
        end
        % leftForearm
        for j = 34:37
            mkc = MKC_point(sog1(i,:),sog2(j,:));
            mkc_sum = mkc_sum+1/obj.segments.leftForearm.w*mkc;
        end
        % rightForearm
        for j = 38:41
            mkc = MKC_point(sog1(i,:),sog2(j,:));
            mkc_sum = mkc_sum+1/obj.segments.rightForearm.w*mkc;
        end
        % leftThigh
        for j = 42:45
            mkc = MKC_point(sog1(i,:),sog2(j,:));
            mkc_sum = mkc_sum+1/obj.segments.leftThigh.w*mkc;
        end
        % rightThigh
        for j = 46:49
            mkc = MKC_point(sog1(i,:),sog2(j,:));
            mkc_sum = mkc_sum+1/obj.segments.rightThigh.w*mkc;
        end
        % leftShank
        for j = 50:53
            mkc = MKC_point(sog1(i,:),sog2(j,:));
            mkc_sum = mkc_sum+1/obj.segments.leftShank.w*mkc;
        end
        % rightShank
        for j = 54:57
            mkc = MKC_point(sog1(i,:),sog2(j,:));
            mkc_sum = mkc_sum+1/obj.segments.rightShank.w*mkc;
        end
    end

    mkc_sum = -mkc_sum; % 求最小值
end