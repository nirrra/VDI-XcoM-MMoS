pressurePlantar2DInter_smooth = smoothdata(pressurePlantar2DInter, 1, 'gaussian', 5);
pressureHip2DInter_smooth = smoothdata(pressureHip2DInter, 1, 'gaussian', 5);

%% 足底BoS
bos_plantar = struct();
bos_plantar.x = cell(length(times.union),1);
bos_plantar.y = cell(length(times.union),1);
bos_plantar.mask_bos = cell(length(times.union),1);

[x,y] = meshgrid(1:32,1:32);
x = x(:); y = y(:);

for idxFrame = 1:length(times.union)
    imgPlantar = reshape(pressurePlantar2DInter_smooth(idxFrame,:),32,32);

    % 固定足底部分
%     imgPlantar = reshape(mean(pressurePlantar2DInter_smooth(max([1,idxFrame-50]):min([length(times.union),idxFrame+50]),:,:)),32,32);

    img = [imgPlantar;zeros(32,32)];

    [bos_x, bos_y, mask_bos] = CalBOS(img,0);
    
    % bos转移至kinect坐标系
    bos_plantar.x{idxFrame} = bos_x;
    bos_plantar.y{idxFrame} = -bos_y;
    bos_plantar.mask_bos{idxFrame} = mask_bos;
end

%% 臀底BoS
bos_buttock = struct();
bos_buttock.x = cell(length(times.union),1);
bos_buttock.y = cell(length(times.union),1);
bos_buttock.mask_bos = cell(length(times.union),1);

[x,y] = meshgrid(1:32,1:32);
x = x(:); y = y(:);

for idxFrame = 1:length(times.union)
    imgButtock = reshape(pressureHip2DInter_smooth(idxFrame,:),32,32);

    % 固定足底部分
%     imgPlantar = reshape(mean(pressurePlantar2DInter_smooth(max([1,idxFrame-50]):min([length(times.union),idxFrame+50]),:,:)),32,32);

    img = [imgButtock;zeros(32,32)];

    [bos_x, bos_y, mask_bos] = CalBOS(img,0);
    
    % bos转移至kinect坐标系
    bos_buttock.x{idxFrame} = bos_x;
    bos_buttock.y{idxFrame} = -bos_y;
    bos_buttock.mask_bos{idxFrame} = mask_bos;
end

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

figure; 
subplot(2,1,1); hold on;
plot(Fz_plantar_f);
plot(Fz_buttock_f); hold off;
legend('Fz\_plantar\_f','Fz\_buttock\_f');
subplot(2,1,2); 
plot(Fz_plantar_f./Fz_sum_f);
legend('alpha');

bos_new = struct();
bos_new.x = cell(length(times.union),1);
bos_new.y = cell(length(times.union),1);
alphas = Fz_plantar_f./Fz_sum_f;
deltas = zeros(length(times.union),2);
for idx_frame = 1:length(times.union)
    bos_plantar_x = bos_plantar.x{idx_frame}+transform_plantar2vicon(1); 
    bos_plantar_y = bos_plantar.y{idx_frame}+transform_plantar2vicon(2);
    bos_buttock_x = bos_buttock.x{idx_frame}+transform_buttock2vicon(1); 
    bos_buttock_y = bos_buttock.y{idx_frame}+transform_buttock2vicon(2);

    % 合并BoS（Monte Carlo近似的effective BoS）
    % 在bos_plantar和bos_buttock中，分别随机取1000个点
    if isempty(bos_plantar_x) || isempty(bos_buttock_x)
        bos_new.x{idx_frame} = [];
        bos_new.y{idx_frame} = [];
        continue;
    end
    if ~isfinite(Fz_sum_f(idx_frame)) || abs(Fz_sum_f(idx_frame)) < 1e-6
        bos_new.x{idx_frame} = [];
        bos_new.y{idx_frame} = [];
        continue;
    end

    nSample = 100;
    p_f = sample_points_in_polygon(bos_plantar_x, bos_plantar_y, nSample);
    p_s = sample_points_in_polygon(bos_buttock_x, bos_buttock_y, nSample);
    if size(p_f,1) < 3 || size(p_s,1) < 3
        bos_new.x{idx_frame} = [];
        bos_new.y{idx_frame} = [];
        continue;
    end

    % 两层for循环，1000个点和1000个点两两配对，根据u_R公式计算新的点
    deltas(idx_frame,:) = -height_sit / Fz_sum_f(idx_frame) * [Fx_buttock_f(idx_frame), Fy_buttock_f(idx_frame)];

    p_f_rep = kron(p_f, ones(size(p_s,1),1));
    p_s_rep = repmat(p_s, size(p_f,1), 1);
    p_new = alphas(idx_frame) * p_f_rep + (1 - alphas(idx_frame)) * p_s_rep + deltas(idx_frame,:);

    % 对新的点进行凸包计算，得到新的BoS
    k = convhull(p_new(:,1), p_new(:,2));
    bos_new.x{idx_frame} = p_new(k,1);
    bos_new.y{idx_frame} = p_new(k,2);
end