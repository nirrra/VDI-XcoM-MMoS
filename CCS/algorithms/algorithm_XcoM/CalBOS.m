% 计算BoS，单位m
function [bos_x, bos_y, mask_convhull] = CalBOS(img, th)
    if nargin < 2, th = 0; end
    
%     % 通过压力占比50%以上确定阈值
%     ratio = 0.5;
%     th = find_half_sum_threshold(img, ratio);

    th = max(img(:))./100;
    mask = img > th;

    th = max(img(1:32,:))./100;
    mask_plantar = [img(1:32,:);zeros(32,32)]>th;

    mask = mask | mask_plantar;
    mask(1,:) = 0;
    mask(1:32,[1,32]) = 0;
    mask(32:33,:) = 0;
    
%     figure; 
%     subplot(1,2,1);
%     imshow(mat2gray(img),'InitialMagnification','fit'); colormap default; title('原始图像');
%     subplot(1,2,2);
%     imshow(mat2gray(img.*mask),'InitialMagnification','fit'); colormap default; title('加掩模后的图像');
    
    % 开操作
    se = [0,1,0;1,1,1;0,1,0];
    mask_opened = imopen(mask, se);
    
    mask_opened = mask;
    
    for i = 1:64
        for j = 1:32
            if sum(mask(max(1,i-1):min(64,i+1),max(1,j-1):min(32,j+1)),"all") == mask(i,j)
                mask_opened(i,j) = 0;
            end
        end
    end
    
    se = strel('square', 3);
    mask_dilated = imdilate(mask_opened,se);
    mask_dilated = mask_dilated | mask_opened;

    mask_convhull = bwconvhull(mask_dilated);
    
%     figure;
%     subplot(1,3,1); imshow(mask);
%     subplot(1,3,2); imshow(mask_opened); title('开操作');
%     subplot(1,3,3); imshow(mask_convhull); title('包络面');
    
    boundary = bwboundaries(mask_convhull, 'noholes'); % 不包含内部孔洞
    
    bos_x = []; bos_y = [];
    
    if ~isempty(boundary)
        boundary = boundary{1};
        
        % 提取列和行坐标（转换为x和y方向）
        cols = boundary(:, 2); % x方向对应列
        rows = boundary(:, 1); % y方向对应行
        
        % 像素坐标转换为实际坐标（单位：mm）
        % 每个像素的左上角原点为坐标系，转换公式如下：
        bos_x = (cols - 0.5) * 11.5; % x实际坐标
        bos_y = (rows - 0.5) * 11.5; % y实际坐标
        
        % 闭合多边形（将最后一个点与第一个点连接）
        bos_x(end+1) = bos_x(1);
        bos_y(end+1) = bos_y(1);
    end
    
    bos_x = bos_x./1000;
    bos_y = bos_y./1000; % 转化到m
end

function th = find_half_sum_threshold(img, ratio)
    total_sum = sum(img(:)); % 计算总和
    half_sum = total_sum * ratio; % 一半的总和
    
    % 获取所有可能的候选阈值（降序排序）
    unique_vals = unique(img(:));
    unique_vals = sort(unique_vals, 'descend'); % 从大到小排序
    
    % 初始化
    found = false;
    
    % 遍历候选阈值
    for i = 1:length(unique_vals)
        current_th = unique_vals(i);
        mask = img >= current_th;
        sum_above_th = sum(img(mask));
        
        if sum_above_th >= half_sum
            th = current_th;
            found = true;
            break;
        end

    end
    
    % 如果所有 sum_above_th < half_sum，则取最小值
    if ~found
        th = min(img(:));
    end
end