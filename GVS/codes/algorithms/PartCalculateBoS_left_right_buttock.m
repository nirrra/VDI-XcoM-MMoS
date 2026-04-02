pressurePlantar2DInter_smooth = smoothdata(pressurePlantar2DInter, 1, 'gaussian', 5);
pressureHip2DInter_smooth = smoothdata(pressureHip2DInter, 1, 'gaussian', 5);
pressurePlantar2DInter_left_smooth =pressurePlantar2DInter_smooth;
pressurePlantar2DInter_left_smooth(:,:,17:32) = 0;
pressurePlantar2DInter_right_smooth = pressurePlantar2DInter_smooth;
pressurePlantar2DInter_right_smooth(:,:,1:16) = 0;

%% BoS参数（可调）
point_th_ratio = 0.01;       % 单点压力阈值 = max(img)*ratio
total_th_ratio = 0.01;       % 总压力阈值 = max(total)*ratio
contact_count_th_buttock = 10;       % 接触点数量阈值
contact_count_th_plantar = 10; % 足底接触点数量阈值
contact_count_th_single_plantar = 5; % 单侧足底接触点数量阈值
erode_size = 1;              % 腐蚀核大小（square）
upsample_factor = 4;         % 32x32 -> 128x128

%% 多GRF时：合并BoS
%% 足底/臀底/参考 BoS（逐帧整体计算）
bos_plantar_left = struct();
bos_plantar_left.x = cell(length(times.union),1);
bos_plantar_left.y = cell(length(times.union),1);

bos_plantar_right = struct();
bos_plantar_right.x = cell(length(times.union),1);
bos_plantar_right.y = cell(length(times.union),1);

bos_buttock = struct();
bos_buttock.x = cell(length(times.union),1);
bos_buttock.y = cell(length(times.union),1);

bos_new = struct();
bos_new.x = cell(length(times.union),1);
bos_new.y = cell(length(times.union),1);

totalPlantarSeries_left = sum(pressurePlantar2DInter_left_smooth,[2,3]);
totalPlantarSeries_right = sum(pressurePlantar2DInter_right_smooth,[2,3]);
totalButtockSeries = sum(pressureHip2DInter_smooth,[2,3]);
total_th_plantar_left = total_th_ratio * max(totalPlantarSeries_left);
total_th_plantar_right = total_th_ratio * max(totalPlantarSeries_right);
total_th_buttock = total_th_ratio * max(totalButtockSeries);

%% 验证参数选取
% figure; 
% subplot(2,1,1); hold on;
% plot(totalPlantarSeries);
% yline(total_th_plantar,'r--');
% hold off; title('足底压力阈值');
% subplot(2,1,2); hold on;
% plot(totalButtockSeries);
% yline(total_th_buttock,'r--');
% hold off; title('臀底压力阈值');

%% 选取足底和臀底两帧，验证参数选取
idxFrame_plantar_left = find(totalPlantarSeries_left >= total_th_plantar_left, 1, 'first');
idxFrame_plantar_right = find(totalPlantarSeries_right >= total_th_plantar_right, 1, 'first');
idxFrame_buttock = find(totalButtockSeries >= total_th_buttock, 1, 'first');
imgPlantar_left = reshape(pressurePlantar2DInter_left_smooth(idxFrame_plantar_left,:),32,32);
imgPlantar_right = reshape(pressurePlantar2DInter_right_smooth(idxFrame_plantar_right,:),32,32);
imgButtock = reshape(pressureHip2DInter_smooth(idxFrame_buttock,:),32,32);
[bos_x_p_left, bos_y_p_left, mask_p_left] = CalBoS_new(imgPlantar_left, point_th_ratio, erode_size, upsample_factor, flag_show_figs);
[bos_x_p_right, bos_y_p_right, mask_p_right] = CalBoS_new(imgPlantar_right, point_th_ratio, erode_size, upsample_factor, flag_show_figs);
[bos_x_b, bos_y_b, mask_b] = CalBoS_new(imgButtock, point_th_ratio, erode_size, upsample_factor, flag_show_figs);

%% 计算BoS
alphas_left = zeros(length(times.union),1);
alphas_right = zeros(length(times.union),1);
deltas = zeros(length(times.union),2);
for idxFrame = 1:length(times.union)
    imgPlantar_left = reshape(pressurePlantar2DInter_left_smooth(idxFrame,:),32,32);
    imgPlantar_right = reshape(pressurePlantar2DInter_right_smooth(idxFrame,:),32,32);
    imgPlantar = reshape(pressurePlantar2DInter_smooth(idxFrame,:),32,32);
    imgButtock = reshape(pressureHip2DInter_smooth(idxFrame,:),32,32);

    [bos_x_p, bos_y_p, mask_p] = CalBoS_new(imgPlantar, point_th_ratio, erode_size, upsample_factor);
    [bos_x_p_left, bos_y_p_left, mask_p_left] = CalBoS_new(imgPlantar_left, point_th_ratio, erode_size, upsample_factor);
    [bos_x_p_right, bos_y_p_right, mask_p_right] = CalBoS_new(imgPlantar_right, point_th_ratio, erode_size, upsample_factor);
    [bos_x_b, bos_y_b, mask_b] = CalBoS_new(imgButtock, point_th_ratio, erode_size, upsample_factor);

    bos_x_p_left = bos_x_p_left + transform_plantar2vicon(1);
    bos_y_p_left = -bos_y_p_left + transform_plantar2vicon(2);
    bos_x_p_right = bos_x_p_right + transform_plantar2vicon(1);
    bos_y_p_right = -bos_y_p_right + transform_plantar2vicon(2);
    bos_x_p = bos_x_p + transform_plantar2vicon(1);
    bos_y_p = -bos_y_p + transform_plantar2vicon(2);
    bos_x_b = bos_x_b + transform_buttock2vicon(1);
    bos_y_b = -bos_y_b + transform_buttock2vicon(2);

    hasPlantar_left = totalPlantarSeries_left(idxFrame) >= total_th_plantar_left && nnz(mask_p_left) >= contact_count_th_single_plantar;
    hasPlantar_right = totalPlantarSeries_right(idxFrame) >= total_th_plantar_right && nnz(mask_p_right) >= contact_count_th_single_plantar;
    hasButtock = totalButtockSeries(idxFrame) >= total_th_buttock && nnz(mask_b) >= contact_count_th_buttock;

    if hasPlantar_left
        bos_plantar_left.x{idxFrame} = bos_x_p_left;
        bos_plantar_left.y{idxFrame} = bos_y_p_left;
    else
        bos_plantar_left.x{idxFrame} = [];
        bos_plantar_left.y{idxFrame} = [];
    end

    if hasPlantar_right
        bos_plantar_right.x{idxFrame} = bos_x_p_right;
        bos_plantar_right.y{idxFrame} = bos_y_p_right;
    else
        bos_plantar_right.x{idxFrame} = [];
        bos_plantar_right.y{idxFrame} = [];
    end

    if hasButtock
        bos_buttock.x{idxFrame} = bos_x_b;
        bos_buttock.y{idxFrame} = bos_y_b;
    else
        bos_buttock.x{idxFrame} = [];
        bos_buttock.y{idxFrame} = [];
    end

    hasPlantar = hasPlantar_left || hasPlantar_right;
    if hasPlantar
        bos_plantar.x{idxFrame} = bos_x_p;
        bos_plantar.y{idxFrame} = bos_y_p;
    else
        bos_plantar.x{idxFrame} = [];
        bos_plantar.y{idxFrame} = [];
    end

    if ~hasPlantar && ~hasButtock
        bos_new.x{idxFrame} = [];
        bos_new.y{idxFrame} = [];
        continue;
    end

    % 仅足底接触：参考BoS = 足底BoS
    if hasPlantar && ~hasButtock
        if hasPlantar_left && hasPlantar_right
            p_lr = [bos_plantar_left.x{idxFrame}, bos_plantar_left.y{idxFrame}; ...
                    bos_plantar_right.x{idxFrame}, bos_plantar_right.y{idxFrame}];
            k_lr = convhull(p_lr(:,1), p_lr(:,2));
            bos_new.x{idxFrame} = p_lr(k_lr,1);
            bos_new.y{idxFrame} = p_lr(k_lr,2);
        elseif hasPlantar_left
            bos_new.x{idxFrame} = bos_plantar_left.x{idxFrame};
            bos_new.y{idxFrame} = bos_plantar_left.y{idxFrame};
        else
            bos_new.x{idxFrame} = bos_plantar_right.x{idxFrame};
            bos_new.y{idxFrame} = bos_plantar_right.y{idxFrame};
        end
        continue;
    end

    % 仅臀底接触：参考BoS = 臀底BoS - h*Fy_s/Fz_s（沿y方向平移）
    if ~hasPlantar && hasButtock
        shift_y = -height_sit * Fy_buttock_f(idxFrame) / Fz_buttock_f(idxFrame);
        bos_new.x{idxFrame} = bos_buttock.x{idxFrame};
        bos_new.y{idxFrame} = bos_buttock.y{idxFrame} + shift_y;
        continue;
    end

    nSample = 100;
    if hasPlantar_left
        p_left = sample_points_in_polygon(bos_plantar_left.x{idxFrame}, bos_plantar_left.y{idxFrame}, nSample);
    else
        p_left = zeros(nSample,2);
    end
    if hasPlantar_right
        p_right = sample_points_in_polygon(bos_plantar_right.x{idxFrame}, bos_plantar_right.y{idxFrame}, nSample);
    else
        p_right = zeros(nSample,2);
    end
    if hasButtock
        p_b = sample_points_in_polygon(bos_buttock.x{idxFrame}, bos_buttock.y{idxFrame}, nSample);
    else
        p_b = zeros(nSample,2);
    end

    if (hasPlantar_left && size(p_left,1) < 3) || (hasPlantar_right && size(p_right,1) < 3) || (hasButtock && size(p_b,1) < 3)
        bos_new.x{idxFrame} = [];
        bos_new.y{idxFrame} = [];
        continue;
    end

    n_use = nSample;
    if hasPlantar_left
        n_use = min(n_use, size(p_left,1));
    end
    if hasPlantar_right
        n_use = min(n_use, size(p_right,1));
    end
    if hasButtock
        n_use = min(n_use, size(p_b,1));
    end
    if n_use < 3
        bos_new.x{idxFrame} = [];
        bos_new.y{idxFrame} = [];
        continue;
    end
    p_left = p_left(1:n_use,:);
    p_right = p_right(1:n_use,:);
    p_b = p_b(1:n_use,:);

    alpha_left = Fz_plantar_left_f(idxFrame) / Fz_sum_f(idxFrame);
    alpha_right = Fz_plantar_right_f(idxFrame) / Fz_sum_f(idxFrame);
    alpha_buttock = Fz_buttock_f(idxFrame) / Fz_sum_f(idxFrame);
    delta = -height_sit / Fz_sum_f(idxFrame) * [Fx_buttock_f(idxFrame), Fy_buttock_f(idxFrame)];

    p_new = alpha_left * p_left + alpha_right * p_right + alpha_buttock * p_b + delta;

    k = convhull(p_new(:,1), p_new(:,2));
    bos_new.x{idxFrame} = p_new(k,1);
    bos_new.y{idxFrame} = p_new(k,2);

    alphas_left(idxFrame) = alpha_left;
    alphas_right(idxFrame) = alpha_right;
    deltas(idxFrame,:) = delta;
end

%% 计算固定的BoS
imgPlantar = reshape(mean(pressurePlantar2DInter_smooth,1),32,32);
imgButtock = reshape(mean(pressureHip2DInter_smooth,1),32,32);
imgPlantar(imgPlantar<1) = 0;
imgButtock(imgButtock<1) = 0;

[bos_x_p_fixed, bos_y_p_fixed, mask_p_fixed] = CalBoS_new(imgPlantar, point_th_ratio, erode_size, upsample_factor);
bos_x_p_fixed = bos_x_p_fixed + transform_plantar2vicon(1);
bos_y_p_fixed = -bos_y_p_fixed + transform_plantar2vicon(2);
[bos_x_b_fixed, bos_y_b_fixed, mask_b_fixed] = CalBoS_new(imgButtock, point_th_ratio, erode_size, upsample_factor);
bos_x_b_fixed = bos_x_b_fixed + transform_buttock2vicon(1);
bos_y_b_fixed = -bos_y_b_fixed + transform_buttock2vicon(2);

% 计算足底和臀底的total bos
nSample_fixed = 1000;
p_p_fixed = sample_points_in_polygon(bos_x_p_fixed, bos_y_p_fixed, nSample_fixed);
p_b_fixed = sample_points_in_polygon(bos_x_b_fixed, bos_y_b_fixed, nSample_fixed);
p_total_fixed = [p_p_fixed; p_b_fixed];
k_fixed = convhull(p_total_fixed(:,1), p_total_fixed(:,2));

for idx_frame = 1:length(times.union)
    bos_plantar_fixed.x{idx_frame} = bos_x_p_fixed;
    bos_plantar_fixed.y{idx_frame} = bos_y_p_fixed;
    bos_buttock_fixed.x{idx_frame} = bos_x_b_fixed;
    bos_buttock_fixed.y{idx_frame} = bos_y_b_fixed;

    hasButtock_fixed = totalButtockSeries(idx_frame) >= total_th_buttock;
    if ~hasButtock_fixed
        bos_total_fixed.x{idx_frame} = bos_plantar_fixed.x{idx_frame};
        bos_total_fixed.y{idx_frame} = bos_plantar_fixed.y{idx_frame};
    else
        bos_total_fixed.x{idx_frame} = p_total_fixed(k_fixed,1);
        bos_total_fixed.y{idx_frame} = p_total_fixed(k_fixed,2);
    end
end
