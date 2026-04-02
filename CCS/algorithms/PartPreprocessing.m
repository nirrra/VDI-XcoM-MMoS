%% ======== 数据预处理 =======
%% ======== 时间预处理 =======
%% 统一时间
times = struct();
times.plantar = Datetime2Time(data.plantar.datetimeF);
times.buttock = Datetime2Time([data.plantar.datetimeF(1);data.buttock.datetimeF]); times.buttock = times.buttock(2:end);
times.kinect = Datetime2Time([data.plantar.datetimeF(1);stream.wtime]); times.kinect = times.kinect(2:end);

% 时间对齐修正：
% delay > 0 表示阵列信号相对 Kinect 滞后，因此将阵列时间提前 delay 秒。
delay_kinect_array = 0;
if exist('delay_control', 'var')
    delay_kinect_array = delay_control;
elseif exist('delay_patient', 'var')
    delay_kinect_array = delay_patient;
end
times.plantar = times.plantar - delay_kinect_array;
times.buttock = times.buttock - delay_kinect_array;
times.delay_kinect_array = delay_kinect_array;

times.start = max([times.kinect(1),times.plantar(1),times.buttock(1)]);
times.kinect = times.kinect-times.start;
times.plantar = times.plantar-times.start;
times.buttock = times.buttock-times.start;
times.start = 0;
times.end = min([times.kinect(end),times.plantar(end),times.buttock(end)]);

%% Kinect插值到30Hz
fsInter = 30; % 插值后的频率
order_N = 3; % butter
% stream_inter = Kinectstream_Rmoutliers_Filter_And_Interp_STS2(stream,fsInter,order_N); % kinect关节点与时间插值
stream_inter = Kinectstream_Interp_Simple(stream,fsInter); % kinect关节点与时间插值
stream_inter.wtime = stream_inter.wtime-stream_inter.wtime(1)+times.kinect(1);

%% Kinect滤波
stream = FilterStream(stream_inter,fsInter,12);
times.kinect = stream.wtime;
times.end = min([times.kinect(end),times.plantar(end),times.buttock(end)]);

%% 阵列数据旋转校正
[~,pressurePlantar2D] = SortOriginalData(data.plantar.dataAllOri);
rotK = 2; pressurePlantar2D = rotDataAll(pressurePlantar2D, rotK);
[~,pressureHip2D] = SortOriginalData(data.buttock.dataAllOri);

% pressureHip2D = pressureHip2D.*ratioB2P;

%% 整理压力阵列信号，避免出现同一时间不同值
aux = pressurePlantar2D(1,:,:);
for i = 2:length(times.plantar)
    if times.plantar(i) == times.plantar(i-1)
        aux(size(aux,1),:,:) = (pressurePlantar2D(i-1,:,:)+pressurePlantar2D(i,:,:))./2;
    else
        aux(size(aux,1)+1,:,:) = pressurePlantar2D(i,:,:);
    end
end
pressurePlantar2D = aux;

aux = pressureHip2D(1,:,:);
for i = 2:length(times.buttock)
    if times.buttock(i) == times.buttock(i-1)
        aux(size(aux,1),:,:) = (pressureHip2D(i-1,:,:)+pressureHip2D(i,:,:))./2;
    else
        aux(size(aux,1)+1,:,:) = pressureHip2D(i,:,:);
    end
end
pressureHip2D = aux;

times.plantar = unique(times.plantar);
times.buttock = unique(times.buttock);

%% 将阵列信号插值到Kinect时间
idxUnion = intersect(find(times.kinect>=0),find(times.kinect<=times.end));
times.union = times.kinect(idxUnion);

% 插值
pressurePlantar2DInter = zeros(length(times.union),32,32);
pressureHip2DInter = zeros(length(times.union),32,32);
framelen = 11; order = 5;
for i = 1:32
    for j = 1:32
        aux = pressurePlantar2D(:,i,j);
        aux = sgolayfilt(aux,order,framelen); aux = interp1(times.plantar,aux,times.union,'pchip');
        pressurePlantar2DInter(:,i,j) = aux;

        aux = pressureHip2D(:,i,j);
        aux = sgolayfilt(aux,order,framelen); aux = interp1(times.buttock,aux,times.union,'pchip');
        pressureHip2DInter(:,i,j) = aux;
    end
end
pressurePlantar2DInter(pressurePlantar2DInter<0) = 0;
pressureHip2DInter(pressureHip2DInter<0) = 0;

pressurePlantarInter = interp1(times.plantar,sum(pressurePlantar2D,[2,3]),times.union,'pchip');
pressureHipInter = interp1(times.buttock,sum(pressureHip2D,[2,3]),times.union,'pchip');

% 保留范围内的stream
names = fieldnames(stream);
for i = 1:length(names)
    name = names{i};
    if isfield(stream.(name),'x')
        stream.(name).x = stream.(name).x(idxUnion);
        stream.(name).y = stream.(name).y(idxUnion);
        stream.(name).z = stream.(name).z(idxUnion);
    else
        stream.(name) = stream.(name)(idxUnion);
    end
end

%% ======== 空间预处理 =======
%% 坐标系旋转校准

transform_floor = Read_Floor(filename_floor);
% 骨骼点旋转
stream = Transform_Azure(transform_floor,stream);
% 平移，以两个FOOT中点为原点
transform_foot = [(median(stream.FOOT_LEFT.x)+median(stream.FOOT_RIGHT.x))/2,...
    (median(stream.FOOT_LEFT.y)+median(stream.FOOT_RIGHT.y))/2,...
    (median(stream.FOOT_LEFT.z)+median(stream.FOOT_RIGHT.z))/2];
stream = Transform_Azure([1,0,0,-transform_foot(1);0,1,0,-transform_foot(2);0,0,1,-transform_foot(3);0,0,0,1],stream);

% Kinect（X左，Y后，Z上）转换到人体坐标系（X右，Y前，Z上），根据COM
stream = Transform_Azure([-1,0,0,0;0,-1,0,0;0,0,1,0;0,0,0,1],stream);

% PartFigureFrame;

%% streamInter

streamInter = stream;     

%% 重新计算CoM，CoP
        
[posCOMSegments,vCOMSegments,accCOMSegments] = Segments_Velocity_Acceleration_WithPelvis(streamInter,gender,fsInter);

[copPlantar.x,copPlantar.y] = calCOP(pressurePlantar2D,1); copPlantar.x = copPlantar.x*0.001; copPlantar.y = -copPlantar.y*0.001;
[copHip.x,copHip.y] = calCOP(pressureHip2D,1); copHip.x = copHip.x*0.001; copHip.y = -copHip.y*0.001;

% 计算COP
[copPlantarInter.x,copPlantarInter.y] = calCOP(pressurePlantar2DInter,1); 
copPlantarInter.x = copPlantarInter.x*0.001; copPlantarInter.y = -copPlantarInter.y*0.001;
[copHipInter.x,copHipInter.y] = calCOP(pressureHip2DInter,1); 
copHipInter.x = copHipInter.x*0.001; copHipInter.y = -copHipInter.y*0.001;

% CoM
com = posCOMSegments.human;
vcom = vCOMSegments.human;
acom = accCOMSegments.human;

% 计算对踝关节的转动惯量
inertia_rotary = CalRotaryInertia(gender,weight,streamInter,posCOMSegments);

%% 校准足底阵列与Kinect位置

% 根据静止站立时COP和COM，确定阵列在Kinect坐标系位置
% 获取静止站立段
seg_union = [];
aux = posCOMSegments.Trunk.z;
for i = 1+20:length(aux)-20
    if min(aux(i-20:i+20))>min(aux)+0.7*range(aux) && range(aux(i-20:i+20))<0.05
        seg_union(end+1) = i;
    end
end

% 静止站立段两端时间
time_stable_stand = [seg_union(1)];
for i = 2:length(seg_union)
    if seg_union(i)-seg_union(i-1)>20
        time_stable_stand = [time_stable_stand,seg_union(i-1),seg_union(i)];
    end
end
time_stable_stand(end+1) = seg_union(end);
time_stable_stand = times.union(time_stable_stand);

seg_plantar = GetSegsTime(times.plantar,time_stable_stand);
seg_union = GetSegsTime(times.union,time_stable_stand);

% PartFigureCOPCOM;

transform_plantar2kinect = [median(posCOMSegments.human.x(seg_union)),median(posCOMSegments.human.y(seg_union))] -...
    [median(copPlantar.x(seg_plantar)),median(copPlantar.y(seg_plantar))];
transform_plantar2kinect = [transform_plantar2kinect,0];
transform_buttock2kinect = transform_plantar2kinect+[0,-plantar_buttock_displacement,height_sit];

%% ======== 阵列校准 =======
%% 寻找静坐段和静站段
% 静坐段和静站段对应的值
data0 = streamInter.PELVIS.z;
range_data = range(data0);
num_spilit = 500;
value_cnt = zeros(num_spilit,1);
for i = 1:length(data0)
    aux = data0(i);
    aux = (aux-min(data0))/(range_data/num_spilit);
    aux = min(max(ceil(aux),1),500);
    value_cnt(aux) = value_cnt(aux) + 1;
end
% 平滑
value_cnt = smoothdata(value_cnt, 'movmean', 10);
% 寻找峰值
[~,locPk] = findpeaks(value_cnt,"MinPeakDistance",100,"MinPeakHeight",20,"NPeaks",2);
if length(locPk)<2
    [~,locPk] = findpeaks(value_cnt,"MinPeakDistance",100,"MinPeakHeight",15,"NPeaks",2);
end
if length(locPk)<2
    [~,locPk] = findpeaks(value_cnt,"MinPeakDistance",100,"MinPeakHeight",5,"NPeaks",2);
end

% figure; hold on;
% plot(value_cnt);
% plot(locPk,value_cnt(locPk),'ro');
% hold off;

% 提取两个locPk对应的值范围
value_sitting = min(data0)+range_data*(locPk(1)-0.5)/num_spilit;
value_standing = min(data0)+range_data*(locPk(2)-0.5)/num_spilit;

% 寻找静坐段和静站段
idx_segment_sitting = []; idx_segment_standing = [];
aux = 50;
while isempty(idx_segment_standing) || isempty(idx_segment_sitting)
    idx_segment_sitting = []; idx_segment_standing = [];
    for i = 1+aux:length(times.union)-aux
        if min(streamInter.PELVIS.z(i-aux:i+aux))>value_standing-0.05 ...
                && max(streamInter.PELVIS.z(i-aux:i+aux))<value_standing+0.05 ...
                && range(pressurePlantarInter(i-aux:i+aux))<5e4 && range(pressureHipInter(i-aux:i+aux))<5e4
            idx_segment_standing(end+1) = i;
        end
        if min(streamInter.PELVIS.z(i-aux:i+aux))>value_sitting-0.05 ...
                && max(streamInter.PELVIS.z(i-aux:i+aux))<value_sitting+0.05 ...
                && range(pressurePlantarInter(i-aux:i+aux))<5e4 && range(pressureHipInter(i-aux:i+aux))<5e4
            idx_segment_sitting(end+1) = i;
        end
    end
    aux = aux-10;
end

%% 阵列单位校准到N
ratioPlantar2Pressure = weight*g/median(pressurePlantarInter(idx_segment_standing));
ratioHip2Pressure = (weight*g-ratioPlantar2Pressure*median(pressurePlantarInter(idx_segment_sitting)))/median(pressureHipInter(idx_segment_sitting));

if true
    figure;
    set(gcf, 'position', [100, 100, 1280, 960], 'color', 'w');
    subplot(2,1,1); hold on;
    plot(times.union,pressurePlantarInter);
    plot(times.union,pressureHipInter);
    plot(times.union,streamInter.PELVIS.z*1000000);
    plot(times.union(idx_segment_sitting),streamInter.PELVIS.z(idx_segment_sitting)*1000000,'ro');
    plot(times.union(idx_segment_standing),streamInter.PELVIS.z(idx_segment_standing)*1000000,'go');
    yline([value_standing,value_sitting]*1000000);
    hold off; legend('足底压力','臀底压力','关节点','坐下段','站起段'); title('校准前');
    subplot(2,1,2); hold on; 
    plot(times.union,pressurePlantarInter*ratioPlantar2Pressure);
    plot(times.union,pressureHipInter*ratioHip2Pressure);
    plot(times.union(idx_segment_sitting),pressurePlantarInter(idx_segment_sitting)*ratioPlantar2Pressure,'ro');
    plot(times.union(idx_segment_standing),pressurePlantarInter(idx_segment_standing)*ratioPlantar2Pressure,'r*');
    plot(times.union(idx_segment_sitting),pressureHipInter(idx_segment_sitting)*ratioHip2Pressure,'go');
    plot(times.union(idx_segment_standing),pressureHipInter(idx_segment_standing)*ratioHip2Pressure,'g*');
    hold off; legend('足底压力','臀底压力'); title('校准后');
    sgtitle('传感器阵列压力校准');
    
    out_dir = fullfile('.', 'outputs', 'pressure_calibration', str_group);
    if ~exist(out_dir, 'dir'); mkdir(out_dir); end
    out_png = fullfile(out_dir, [num2str(idx_file), '.png']);
    print(gcf, out_png, '-dpng', '-r300');
end

pressurePlantar2DInter = pressurePlantar2DInter .* ratioPlantar2Pressure;
pressureHip2DInter = pressureHip2DInter .* ratioHip2Pressure;
pressurePlantarInter = pressurePlantarInter .* ratioPlantar2Pressure;
pressureHipInter = pressureHipInter .* ratioHip2Pressure;
pressurePlantar2D = pressurePlantar2D .* ratioPlantar2Pressure;
pressureHip2D = pressureHip2D .* ratioHip2Pressure;

%% 臀底压力分布图像的水平校准

% 手动校准
if flag_select_paras
    PartSelectButtockShift;
else
    dj_buttock = buttock_shifts(idx_file);
end

% 阵列水平位移
pressureHip2DInter_shifted = pressureHip2DInter;
for i = 1:size(pressureHip2DInter)
    img = reshape(pressureHip2DInter(i,:,:),32,32);

    img_shifted = circshift(img, [0, dj_buttock]);

    % 将超出范围的部分置为0
    if dj_buttock > 0
        img_shifted(:, 1:dj_buttock) = 0; % 向右平移，左侧超出部分置0
    elseif dj_buttock < 0
        img_shifted(:, end+dj_buttock+1:end) = 0; % 向左平移，右侧超出部分置0
    end

    pressureHip2DInter_shifted(i,:,:) = img_shifted;
end
% PartFigureButtockShift;
pressureHip2DInter = pressureHip2DInter_shifted;

pressureHip2D_shifted = pressureHip2D;
for i = 1:size(pressureHip2D)
    img = reshape(pressureHip2D(i,:,:),32,32);
    img_shifted = circshift(img, [0, dj_buttock]);
    if dj_buttock > 0
        img_shifted(:, 1:dj_buttock) = 0; % 向右平移，左侧超出部分置0
    elseif dj_buttock < 0
        img_shifted(:, end+dj_buttock+1:end) = 0; % 向左平移，右侧超出部分置0
    end
    pressureHip2D_shifted(i,:,:) = img_shifted;
end
pressureHip2D = pressureHip2D_shifted;

%% 计算左右脚压力
pressurePlantar_left = sum(pressurePlantar2D(:,:,1:16),[2,3]);
pressurePlantar_right = sum(pressurePlantar2D(:,:,17:32),[2,3]);
pressureHip_left = sum(pressureHip2D(:,:,1:16),[2,3]);
pressureHip_right = sum(pressureHip2D(:,:,17:32),[2,3]);    

pressurePlantarInter_left = interp1(times.plantar,pressurePlantar_left,times.union,'pchip');
pressurePlantarInter_right = interp1(times.plantar,pressurePlantar_right,times.union,'pchip');
pressureHipInter_left = interp1(times.buttock,pressureHip_left,times.union,'pchip');
pressureHipInter_right = interp1(times.buttock,pressureHip_right,times.union,'pchip');

%% 定义GRF（供VDI-XcoM/BoS/MoS流程使用）
Fz_plantar_left_f = max(pressurePlantarInter_left,0);
Fz_plantar_right_f = max(pressurePlantarInter_right,0);
Fz_plantar_f = max(pressurePlantarInter,0);
Fz_buttock_f = max(pressureHipInter,0);
Fz_sum_f = Fz_plantar_left_f + Fz_plantar_right_f + Fz_buttock_f;

Fx_plantar_f = zeros(size(Fz_plantar_f));
Fx_plantar_left_f = zeros(size(Fz_plantar_left_f));
Fx_plantar_right_f = zeros(size(Fz_plantar_right_f));
Fx_buttock_f = zeros(size(Fz_buttock_f));

Fy_plantar_f = zeros(size(Fz_plantar_f));
Fy_plantar_left_f = zeros(size(Fz_plantar_left_f));
Fy_plantar_right_f = zeros(size(Fz_plantar_right_f));
Fy_buttock_f = zeros(size(Fz_buttock_f));

GRF = struct();
GRF.plantar_left = struct('x',Fx_plantar_left_f,'y',Fy_plantar_left_f,'z',Fz_plantar_left_f);
GRF.plantar_right = struct('x',Fx_plantar_right_f,'y',Fy_plantar_right_f,'z',Fz_plantar_right_f);
GRF.buttock = struct('x',Fx_buttock_f,'y',Fy_buttock_f,'z',Fz_buttock_f);
GRF.sum = struct('x',Fx_plantar_left_f,'y',Fy_plantar_f,'z',Fz_sum_f);

%% 使用预测的GRF
if flag_use_predict_grf
    % 仅替换切向力(x/y)，z方向仍使用阵列原始估计值
    n_union = numel(times.union);
    mat_name = sprintf('trial_%03d_tangential_pred_aligned.mat', idx_file);
    mat_path = fullfile('.', 'predicted_tangential_mat', str_group, mat_name);
    
    S = load(mat_path); % 读取预测的GRF，是人体对地面的
    % 转换变地面对人体的
    lx = -S.pred.left.x(:);
    ly = -S.pred.left.y(:);
    rx = -S.pred.right.x(:);
    ry = -S.pred.right.y(:);
    if numel(lx) == n_union
        Fx_plantar_left_f = lx;
        Fy_plantar_left_f = ly;
        Fx_plantar_right_f = rx;
        Fy_plantar_right_f = ry;
    else
        Fx_plantar_left_f = interp1(t_src, lx, times.union(:), 'linear', 'extrap');
        Fy_plantar_left_f = interp1(t_src, ly, times.union(:), 'linear', 'extrap');
        Fx_plantar_right_f = interp1(t_src, rx, times.union(:), 'linear', 'extrap');
        Fy_plantar_right_f = interp1(t_src, ry, times.union(:), 'linear', 'extrap');
    end
    Fx_plantar_left_f(~isfinite(Fx_plantar_left_f)) = 0;
    Fy_plantar_left_f(~isfinite(Fy_plantar_left_f)) = 0;
    Fx_plantar_right_f(~isfinite(Fx_plantar_right_f)) = 0;
    Fy_plantar_right_f(~isfinite(Fy_plantar_right_f)) = 0;

    % 根据 F=ma 计算臀底的Fx/y
    Fx_buttock_f = weight*acom.x-Fx_plantar_left_f-Fx_plantar_right_f;
    Fy_buttock_f = weight*acom.y-Fy_plantar_left_f-Fy_plantar_right_f;
end

% 离座后不再保留臀部切向力，避免残余残差继续平移 bos_new。
idx_buttock_off = Fz_buttock_f < 50;
Fx_buttock_f(idx_buttock_off) = 0;
Fy_buttock_f(idx_buttock_off) = 0;

GRF.plantar_left = struct('x',Fx_plantar_left_f,'y',Fy_plantar_left_f,'z',Fz_plantar_left_f);
GRF.plantar_right = struct('x',Fx_plantar_right_f,'y',Fy_plantar_right_f,'z',Fz_plantar_right_f);
GRF.buttock = struct('x',Fx_buttock_f,'y',Fy_buttock_f,'z',Fz_buttock_f);
GRF.sum = struct('x',Fx_plantar_left_f + Fx_plantar_right_f + Fx_buttock_f, ...
                 'y',Fy_plantar_left_f + Fy_plantar_right_f + Fy_buttock_f, ...
                 'z',Fz_sum_f);
