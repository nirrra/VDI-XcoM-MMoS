function [bos_x, bos_y, mask_contact] = CalBoS_new(img, point_th_ratio, erode_size, upsample_factor, show_fig)
% 计算BoS（更通用/平滑）
% img: 32x32压力图
% point_th_ratio: 单点阈值比例
% erode_size: 腐蚀核大小（square）
% upsample_factor: 上采样倍数（如4 -> 128x128）

    if nargin < 2 || isempty(point_th_ratio)
        point_th_ratio = 0.02;
    end
    if nargin < 3 || isempty(erode_size)
        erode_size = 2;
    end
    if nargin < 4 || isempty(upsample_factor)
        upsample_factor = 4;
    end
    if nargin < 5 || isempty(show_fig)
        show_fig = false;
    end

    bos_x = [];
    bos_y = [];

    max_val = max(img(:));
    if max_val <= 0
        mask_contact = false(size(img));
        return;
    end

    point_th = max_val * point_th_ratio;
    mask_contact = img > point_th;
    if ~any(mask_contact(:))
        return;
    end

    mask_proc = mask_contact;
    if erode_size > 0
        se = strel('square', erode_size);
        mask_proc = imerode(mask_proc, se);
    end
    if ~any(mask_proc(:))
        return;
    end

    mask_up = mask_proc;
    if upsample_factor > 1
        mask_up = imresize(mask_up, upsample_factor, 'nearest');
    end

    mask_hull = bwconvhull(mask_up);
    boundary = bwboundaries(mask_hull, 'noholes');
    if isempty(boundary)
        return;
    end

    boundary = boundary{1};
    cols = boundary(:, 2);
    rows = boundary(:, 1);

    pixel_size_mm = 11.5 / upsample_factor;
    bos_x = (cols - 0.5) * pixel_size_mm;
    bos_y = (rows - 0.5) * pixel_size_mm;

    bos_x(end+1) = bos_x(1);
    bos_y(end+1) = bos_y(1);

    bos_x = bos_x ./ 1000;
    bos_y = bos_y ./ 1000;

    if show_fig
        figure('Name','CalBoS\_new Debug','Color','w');
        set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1], 'color', 'w');
        subplot(2,3,1);
        imagesc(img); axis image; colormap parula; colorbar;
        title('原始 img');

        subplot(2,3,2);
        imagesc(mask_contact); axis image; colormap gray;
        title('接触点筛选');

        subplot(2,3,3);
        imagesc(mask_proc); axis image; colormap gray;
        title('腐蚀后');

        subplot(2,3,4);
        imagesc(mask_up); axis image; colormap gray;
        title('上采样后');

        subplot(2,3,5);
        imagesc(mask_hull); axis image; colormap gray; hold on;
        if ~isempty(boundary)
            plot(boundary(:,2), boundary(:,1), 'r-', 'LineWidth', 1.5);
        end
        hold off;
        title('凸包线');
    end
end
