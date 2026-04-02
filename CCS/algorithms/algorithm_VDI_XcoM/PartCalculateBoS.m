pressurePlantar2DInter_smooth = smoothdata(pressurePlantar2DInter, 1, 'gaussian', 5);
pressureHip2DInter_smooth = smoothdata(pressureHip2DInter, 1, 'gaussian', 5);

%% BoS参数（可调）
point_th_ratio = 0.01;       % 单点压力阈值 = max(img)*ratio
total_th_ratio = 0.01;       % 总压力阈值 = max(total)*ratio
contact_count_th = 10;       % 接触点数量阈值
erode_size = 1;              % 腐蚀核大小（square）
upsample_factor = 4;         % 32x32 -> 128x128

%% 多GRF时：合并BoS
Fz_plantar_f = interp1(times.vicon,Fz_plantar,times.union,'pchip');
Fz_buttock_f = interp1(times.vicon,Fz_buttock,times.union,'pchip');
Fz_sum_f = Fz_plantar_f+Fz_buttock_f;
Fx_plantar_f = interp1(times.vicon,Fx_plantar,times.union,'pchip');
Fy_plantar_f = interp1(times.vicon,Fy_plantar,times.union,'pchip');
Fx_buttock_f = interp1(times.vicon,Fx_buttock,times.union,'pchip');
Fy_buttock_f = interp1(times.vicon,Fy_buttock,times.union,'pchip');

% 使用阵列的GRF
% Fz_plantar_f = grfPlantar_F.z;
% Fz_buttock_f = grfHip_F.z;
% Fz_sum_f = Fz_plantar_f+Fz_buttock_f;

%% 足底/臀底/参考 BoS（逐帧整体计算）
bos_plantar = struct();
bos_plantar.x = cell(length(times.union),1);
bos_plantar.y = cell(length(times.union),1);

bos_buttock = struct();
bos_buttock.x = cell(length(times.union),1);
bos_buttock.y = cell(length(times.union),1);

bos_new = struct();
bos_new.x = cell(length(times.union),1);
bos_new.y = cell(length(times.union),1);

totalPlantarSeries = sum(pressurePlantar2DInter_smooth,[2,3]);
totalButtockSeries = sum(pressureHip2DInter_smooth,[2,3]);
total_th_plantar = total_th_ratio * max(totalPlantarSeries);
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
idxFrame_plantar = find(totalPlantarSeries >= total_th_plantar, 1, 'first');
idxFrame_buttock = find(totalButtockSeries >= total_th_buttock, 1, 'first');
imgPlantar = reshape(pressurePlantar2DInter_smooth(idxFrame_plantar,:),32,32);
imgButtock = reshape(pressureHip2DInter_smooth(idxFrame_buttock,:),32,32);
[bos_x_p, bos_y_p, mask_p] = CalBoS_new(imgPlantar, point_th_ratio, erode_size, upsample_factor, true);
[bos_x_b, bos_y_b, mask_b] = CalBoS_new(imgButtock, point_th_ratio, erode_size, upsample_factor, true);

%% 计算BoS
alphas = zeros(length(times.union),1);
deltas = zeros(length(times.union),2);
for idxFrame = 1:length(times.union)
    imgPlantar = reshape(pressurePlantar2DInter_smooth(idxFrame,:),32,32);
    imgButtock = reshape(pressureHip2DInter_smooth(idxFrame,:),32,32);

    [bos_x_p, bos_y_p, mask_p] = CalBoS_new(imgPlantar, point_th_ratio, erode_size, upsample_factor);
    [bos_x_b, bos_y_b, mask_b] = CalBoS_new(imgButtock, point_th_ratio, erode_size, upsample_factor);

    bos_x_p = bos_x_p + transform_plantar2vicon(1);
    bos_y_p = -bos_y_p + transform_plantar2vicon(2);
    bos_x_b = bos_x_b + transform_buttock2vicon(1);
    bos_y_b = -bos_y_b + transform_buttock2vicon(2);

    hasPlantar = totalPlantarSeries(idxFrame) >= total_th_plantar && nnz(mask_p) >= contact_count_th;
    hasButtock = totalButtockSeries(idxFrame) >= total_th_buttock && nnz(mask_b) >= contact_count_th;

    if hasPlantar
        bos_plantar.x{idxFrame} = bos_x_p;
        bos_plantar.y{idxFrame} = bos_y_p;
    else
        bos_plantar.x{idxFrame} = [];
        bos_plantar.y{idxFrame} = [];
    end

    if hasButtock
        bos_buttock.x{idxFrame} = bos_x_b;
        bos_buttock.y{idxFrame} = bos_y_b;
    else
        bos_buttock.x{idxFrame} = [];
        bos_buttock.y{idxFrame} = [];
    end

    if ~hasPlantar && ~hasButtock
        bos_new.x{idxFrame} = [];
        bos_new.y{idxFrame} = [];
        continue;
    end

    % 仅足底接触：参考BoS = 足底BoS
    if hasPlantar && ~hasButtock
        bos_new.x{idxFrame} = bos_plantar.x{idxFrame};
        bos_new.y{idxFrame} = bos_plantar.y{idxFrame};
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
    p_f = sample_points_in_polygon(bos_plantar.x{idxFrame}, bos_plantar.y{idxFrame}, nSample);
    p_s = sample_points_in_polygon(bos_buttock.x{idxFrame}, bos_buttock.y{idxFrame}, nSample);

    alpha = Fz_plantar_f(idxFrame) / Fz_sum_f(idxFrame);
    delta = -height_sit / Fz_sum_f(idxFrame) * [Fx_buttock_f(idxFrame), Fy_buttock_f(idxFrame)];

    p_f_rep = kron(p_f, ones(size(p_s,1),1));
    p_s_rep = repmat(p_s, size(p_f,1), 1);
    p_new = alpha * p_f_rep + (1 - alpha) * p_s_rep + delta;

    k = convhull(p_new(:,1), p_new(:,2));
    bos_new.x{idxFrame} = p_new(k,1);
    bos_new.y{idxFrame} = p_new(k,2);

    alphas(idxFrame) = alpha;
    deltas(idxFrame,:) = delta;
end