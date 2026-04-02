[pressurePlantar,pressurePlantar2D] = SortOriginalData(dataPlantar.dataAllOri);
rotK = 2; pressurePlantar2D = rotDataAll(pressurePlantar2D, rotK);
[pressureHip,pressureHip2D] = SortOriginalData(dataHip.dataAllOri);

fsInter = 30; order_N = 3;
stream = Kinectstream_Rmoutliers_Filter_And_Interp_STS2(stream,fsInter,order_N);

weight = weights(data.idxSub); height = heights(data.idxSub); gender = genders(data.idxSub);

% 时间对齐
PartTimeProcessing;
% 坐标转换
PartFrameProcessing;
% 压力校准
PartPressureCalibration;
% 信号插值到streamInter
PartSignalInter_com_cmp;
% OpenSim输出滤波
PartFilterOpenSim_Kinect2;

idxsKinect = intersect(find(streamInter.wtime>=timeStart),find(streamInter.wtime<=timeEnd));
times.grfP = streamInter.wtime(idxsKinect);
times.viconP = streamInter.wtime;

times.union = streamInter.wtime;

filename = [num2str(data.idxSub,'%03d'),num2str(data.idxSTS,'%02d'),num2str(data.idxSTSTest,'%02d')];

%% 定义压力
Fz_plantar = grf.left_force_vy+grf.right_force_vy;
Fz_plantar_left = grf.left_force_vy;
Fz_plantar_right = grf.right_force_vy;
Fz_buttock = grf.hip_force_vy;
Fz_sum = Fz_plantar+Fz_buttock;
Fx_plantar = grf.left_force_vz+grf.right_force_vz;
Fx_plantar_left = grf.left_force_vz;
Fx_plantar_right = grf.right_force_vz;
Fy_plantar = grf.left_force_vx+grf.right_force_vx;
Fy_plantar_left = grf.left_force_vx;
Fy_plantar_right = grf.right_force_vx;
Fx_buttock = grf.hip_force_vz;
Fy_buttock = grf.hip_force_vx;
aux = 1:10:size(grf,1);
Fz_plantar = Fz_plantar(aux);
Fz_plantar_left = Fz_plantar_left(aux);
Fz_plantar_right = Fz_plantar_right(aux);
Fz_buttock = Fz_buttock(aux);
Fz_sum = Fz_sum(aux);
Fx_plantar = Fx_plantar(aux);
Fx_plantar_left = Fx_plantar_left(aux);
Fx_plantar_right = Fx_plantar_right(aux);
Fy_plantar = Fy_plantar(aux);
Fy_plantar_left = Fy_plantar_left(aux);
Fy_plantar_right = Fy_plantar_right(aux);
Fx_buttock = Fx_buttock(aux);
Fy_buttock = Fy_buttock(aux);
Fz_plantar(Fz_plantar<0) = 0;
Fz_plantar_left(Fz_plantar_left<0) = 0;
Fz_plantar_right(Fz_plantar_right<0) = 0;
Fz_buttock(Fz_buttock<0) = 0;

%% 定义后续times.union时间轴的压力
Fz_plantar_left_f = interp1(times.vicon,Fz_plantar_left,times.union,'pchip');
Fz_plantar_right_f = interp1(times.vicon,Fz_plantar_right,times.union,'pchip');
Fz_plantar_f = interp1(times.vicon,Fz_plantar,times.union,'pchip');
Fz_buttock_f = interp1(times.vicon,Fz_buttock,times.union,'pchip');
Fz_sum_f = Fz_plantar_left_f+Fz_plantar_right_f+Fz_buttock_f;
Fx_plantar_left_f = interp1(times.vicon,Fx_plantar_left,times.union,'pchip');
Fx_plantar_right_f = interp1(times.vicon,Fx_plantar_right,times.union,'pchip');
Fy_plantar_f = interp1(times.vicon,Fy_plantar,times.union,'pchip');
Fy_plantar_left_f = interp1(times.vicon,Fy_plantar_left,times.union,'pchip');
Fy_plantar_right_f = interp1(times.vicon,Fy_plantar_right,times.union,'pchip');
Fx_buttock_f = interp1(times.vicon,Fx_buttock,times.union,'pchip');
Fy_buttock_f = interp1(times.vicon,Fy_buttock,times.union,'pchip');

% 使用阵列的GRF
% Fz_plantar_f = grfPlantar_F.z;
% Fz_buttock_f = grfHip_F.z;
% Fz_sum_f = Fz_plantar_f+Fz_buttock_f;