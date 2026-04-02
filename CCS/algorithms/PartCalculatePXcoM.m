%% 计算CoM-踝关节和竖直方向的夹角，及速度，加速度
% 计算踝关节中点坐标

%         origin.x = (streamInter.ANKLE_LEFT.x + streamInter.ANKLE_RIGHT.x) / 2;
%         origin.y = (streamInter.ANKLE_LEFT.y + streamInter.ANKLE_RIGHT.y) / 2;
%         origin.z = (streamInter.ANKLE_LEFT.z + streamInter.ANKLE_RIGHT.z) / 2;

% 坐标系原点
origin.x = 0.*(streamInter.ANKLE_LEFT.x + streamInter.ANKLE_RIGHT.x) / 2;
origin.y = 0.*(streamInter.ANKLE_LEFT.y + streamInter.ANKLE_RIGHT.y) / 2;
origin.z = 0.*(streamInter.ANKLE_LEFT.z + streamInter.ANKLE_RIGHT.z) / 2;

% 计算 CoM 到踝关节中点的向量
vector.x = origin.x - com.x;
vector.y = origin.y - com.y;
vector.z = origin.z - com.z;

% 计算向量长度
vector_length = sqrt(vector.x.^2 + vector.y.^2 + vector.z.^2);

% 计算与z轴的夹角（弧度）
% 使用点积公式：a·b = |a||b|cosθ，这里b是z轴单位向量[0,0,1]
cos_theta = vector.z ./ vector_length;
theta_deg = acos(cos_theta);  % 角度(弧度)

omega_deg = FiniteDifference(theta_deg,fsInter);
alpha_deg = FiniteDifference(omega_deg,fsInter);

%         % 将结果转换为度
%         theta_deg = rad2deg(theta_deg);
%         omega_deg = rad2deg(omega_deg);
%         alpha_deg = rad2deg(alpha_deg);

%% 计算摆长

% pendulum_length = inertia_rotary./com.z;
pendulum_length = vector_length;

pendulum_length_d = FiniteDifference(pendulum_length,fsInter);
pendulum_length_d2 = FiniteDifference(pendulum_length_d,fsInter);

%% 计算XcoM
% Hof的方法
% xcom_hof.x = com.x+vcom.x./(g/median(pendulum_length)).^0.5;
% xcom_hof.y = com.y+vcom.y./(g/median(pendulum_length)).^0.5;
xcom_hof.x = com.x+vcom.x./(g./pendulum_length).^0.5;
xcom_hof.y = com.y+vcom.y./(g./pendulum_length).^0.5;

% 原方法
pxcom.x = com.x+vcom.x./(weight.*(g-acom.z).*com.z./inertia_rotary).^0.5;
pxcom.y = com.y+vcom.y./(weight.*(g-acom.z).*com.z./inertia_rotary).^0.5;

%% ======== MoS_CMP =======
% 说明：
% 坐标系按工程定义：x向右，y向前，z向上
% 在矢状面(y-z)内计算，输出为前后向(y)上的MoS_CMP

%% CoP -> Kinect坐标系（与CoM对齐）
[copPlantarInter.x,copPlantarInter.y] = calCOP(pressurePlantar2DInter,1);
copPlantarInter.x = copPlantarInter.x*0.001 + transform_plantar2kinect(1);
copPlantarInter.y = -copPlantarInter.y*0.001 + transform_plantar2kinect(2);

u_x = copPlantarInter.x;
u_y = copPlantarInter.y;

%% 使用加速度估计地面反力分量
F_x = weight .* acom.x;
F_y = weight .* acom.y;
F_z = weight .* (acom.z + g);
% F_z = grfSum.z;

% 处理F_z，去除异常点

%% 计算瞬时频率与捕获点
omega2 = F_z ./ (weight .* com.z);
omega = sqrt(omega2);

%% 质心角动量率（关于CoM，基于分段角动量求和）
% 优先使用分段角动量法（不依赖CoP），若可用则包含转动项
flag_trans_only = false;
dot_h_z = CalDotHzCoM(posCOMSegments, vCOMSegments, com, vcom, gender, weight, fsInter, streamInter, segments_W_G_xyz, flag_trans_only);

%% CMP修正支撑点与MoS_CMP
capture_point_x = com.x + vcom.x ./ omega;
capture_point_y = com.y + vcom.y ./ omega;
u_cmp_x = u_x - dot_h_z ./ F_z;
u_cmp_y = u_y - dot_h_z ./ F_z;

%% 移项得到对应的xcom（方便结合BoS判断）
xcom_cmp.x = com.x + vcom.x ./ omega + dot_h_z./F_z;
xcom_cmp.y = com.y + vcom.y ./ omega + dot_h_z./F_z;

%% |dot(omega)/omega^2|
omega_dot = FiniteDifference(omega, fsInter);
omega_ratio = abs(omega_dot ./ (omega.^2));

%% ======== BoS =======
%% BOS
pressurePlantar2DInter_smooth = smoothdata(pressurePlantar2DInter, 1, 'gaussian', 5);
pressureHip2DInter_smooth = smoothdata(pressureHip2DInter, 1, 'gaussian', 5);

bos = struct();
bos.x = cell(length(times.union),1);
bos.y = cell(length(times.union),1);
bos.mask_bos = cell(length(times.union),1);

%         imgPlantarMean = reshape(mean(pressurePlantar2DInter_smooth),32,32);
%         figure; imshow(mat2gray(imgPlantarMean),'InitialMagnification','fit'); title('计算足底BoS的平均图像');

for idxFrame = 1:length(times.union)
    imgPlantar = reshape(pressurePlantar2DInter_smooth(idxFrame,:),32,32);
    imgButtock = reshape(pressureHip2DInter_smooth(idxFrame,:),32,32);
%             imgButtock = [zeros(5,32); imgButtock(1:32-5,:)]; % 调整臀底阵列的前后位置

    % 固定足底部分
%             imgPlantar = imgPlantarMean;
    imgPlantar = reshape(mean(pressurePlantar2DInter_smooth(max([1,idxFrame-50]):min([length(times.union),idxFrame+50]),:,:)),32,32);
    
    if max(sum(pressureHip2DInter_smooth(intersect(idxFrame-2:idxFrame+2,1:length(times.union)),:,:),[2,3])) < 100
        img = [imgPlantar;zeros(32,32)];
    else
        img = [imgPlantar;imgButtock];
    end
    
    [bos_x, bos_y, mask_bos] = CalBOS(img,0);
    
    % bos转移至kinect坐标系
    bos.x{idxFrame} = bos_x+transform_plantar2kinect(1);
    bos.y{idxFrame} = -bos_y+transform_plantar2kinect(2);
    bos.mask_bos{idxFrame} = mask_bos;
end

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
%             imgPlantar = imgPlantarMean;
    imgPlantar = reshape(mean(pressurePlantar2DInter_smooth(max([1,idxFrame-50]):min([length(times.union),idxFrame+50]),:,:)),32,32);

    img = [imgPlantar;zeros(32,32)];

    [bos_x, bos_y, mask_bos] = CalBOS(img,0);
    
    % bos转移至kinect坐标系
    bos_plantar.x{idxFrame} = bos_x+transform_plantar2kinect(1);
    bos_plantar.y{idxFrame} = -bos_y+transform_plantar2kinect(2);
    bos_plantar.mask_bos{idxFrame} = mask_bos;
end

%% BoS的边界
bos_plantar_front = zeros(length(times.union),1);
bos_plantar_back = zeros(length(times.union),1);
bos_plantar_left = zeros(length(times.union),1);
bos_plantar_right = zeros(length(times.union),1);

bos_back = zeros(length(times.union),1);
bos_left = zeros(length(times.union),1);
bos_right = zeros(length(times.union),1);

for i = 1:length(bos.x)
    bos_plantar_left(i) = min(bos_plantar.x{i});
    bos_plantar_right(i) = max(bos_plantar.x{i});
    bos_plantar_front(i) = max(bos_plantar.y{i});
    bos_plantar_back(i) = min(bos_plantar.y{i});

    bos_back(i) = min(bos.y{i});
    bos_left(i) = min(bos.x{i});
    bos_right(i) = max(bos.x{i});
end
    
%% CoM到BoS的距离

dis_com_bos = CalDistanceCOM2BOS(com,bos);
dis_com_bos_plantar = CalDistanceCOM2BOS(com,bos_plantar);
dis_pxcom_bos = CalDistanceCOM2BOS(pxcom,bos);
dis_pxcom_bos_plantar = CalDistanceCOM2BOS(pxcom,bos_plantar);
dis_xcom_hof_bos = CalDistanceCOM2BOS(xcom_hof,bos);
dis_xcom_hof_bos_plantar = CalDistanceCOM2BOS(xcom_hof,bos_plantar);
dis_xcom_cmp_bos = CalDistanceCOM2BOS(xcom_cmp,bos);
dis_xcom_cmp_bos_plantar = CalDistanceCOM2BOS(xcom_cmp,bos_plantar);