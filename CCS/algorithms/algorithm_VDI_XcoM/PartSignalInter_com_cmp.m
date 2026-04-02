%% stream滤波插值
fsInter = 50; % 插值后的频率
order_N = 21; % hamming
order_N = 3; % butter
streamInter = Kinectstream_Rmoutliers_Filter_And_Interp(stream,fsInter,order_N); % kinect关节点与时间插值

%% 阵列插值到streamInter
pressurePlantar2DInter = zeros(length(streamInter.wtime),32,32);
pressureHip2DInter = zeros(length(streamInter.wtime),32,32);
framelen = 11; order = 5;
for i = 1:32
    for j = 1:32
        aux = pressurePlantar2D(:,i,j);
        aux = sgolayfilt(aux,order,framelen); 
        aux = interp1(timeP,aux(pPS1:pPE1),streamInter.wtime,'pchip');
        aux(aux<0) = 0;
        pressurePlantar2DInter(:,i,j) = aux;

        aux = pressureHip2D(:,i,j);
        aux = sgolayfilt(aux,order,framelen); 
        aux = interp1(timeH,aux(pHS1:pHE1),streamInter.wtime,'pchip');
        aux(aux<0) = 0;
        pressureHip2DInter(:,i,j) = aux;
    end
end

grfPlantar_F.z = interp1(timeP,sum(pressurePlantar2D(pPS1:pPE1,:,:),[2,3]),streamInter.wtime,'pchip');
grfPlantar_F.x = zeros(size(grfPlantar_F.z)); grfPlantar_F.y = zeros(size(grfPlantar_F.z));
grfPlantarLeft_F.z = interp1(timeP,sum(pressurePlantar2D(pPS1:pPE1,:,1:16),[2,3]),streamInter.wtime,'pchip');
grfPlantarLeft_F.x = zeros(size(grfPlantarLeft_F.z)); grfPlantarLeft_F.y = zeros(size(grfPlantarLeft_F.z));
grfPlantarRight_F.z = interp1(timeP,sum(pressurePlantar2D(pPS1:pPE1,:,17:32),[2,3]),streamInter.wtime,'pchip');
grfPlantarRight_F.x = zeros(size(grfPlantarRight_F.z)); grfPlantarRight_F.y = zeros(size(grfPlantarRight_F.z));
[p_listPlantarInter,ptsPartsAnotomy] = CalPlantarPressures(pressurePlantar2DInter);

% [mid,ischialLeft,ischialRight,idxSitStable,ptsHipLeft,ptsHipRight,grfHipLeft_F,grfHipRight_F] = ...
%     GetHipMidAndPressureLR(pressureHip2DInter,streamInter,grfPlantar_F,height);
% grfHip_F.z = grfHipLeft_F.z+grfHipRight_F.z;
% grfHip_F.x = grfHipLeft_F.x+grfHipRight_F.x;
% grfHip_F.y = grfHipLeft_F.y+grfHipRight_F.y;

grfHip_F.z = interp1(timeH,sum(pressureHip2D(pHS1:pHE1,:,:),[2,3]),streamInter.wtime,'pchip');
grfHip_F.x = zeros(size(grfHip_F.z)); grfHip_F.y = zeros(size(grfHip_F.z));
grfHipLeft_F.z = interp1(timeH,sum(pressureHip2D(pHS1:pHE1,:,1:16),[2,3]),streamInter.wtime,'pchip');
grfHipLeft_F.x = zeros(size(grfHipLeft_F.z)); grfHipLeft_F.y = zeros(size(grfHipLeft_F.z));
grfHipRight_F.z = interp1(timeH,sum(pressureHip2D(pHS1:pHE1,:,17:32),[2,3]),streamInter.wtime,'pchip');
grfHipRight_F.x = zeros(size(grfHipRight_F.z)); grfHipRight_F.y = zeros(size(grfHipRight_F.z));

%% GRF插值到streamInter
grfHip.x = grf.hip_force_vz; grfHip.y = grf.hip_force_vx; grfHip.z = grf.hip_force_vy;
grmHip.x = grf.hip_moment_mz; grmHip.y = grf.hip_moment_mx; grmHip.z = grf.hip_moment_my;
grfPlantarLeft.x = grf.left_force_vz; grfPlantarLeft.y = grf.left_force_vx; grfPlantarLeft.z = grf.left_force_vy;
grmPlantarLeft.x = grf.left_moment_mz; grmPlantarLeft.y = grf.left_moment_mx; grmPlantarLeft.z = grf.left_moment_my;
grfPlantarRight.x = grf.right_force_vz; grfPlantarRight.y = grf.right_force_vx; grfPlantarRight.z = grf.right_force_vy;
grmPlantarRight.x = grf.right_moment_mz; grmPlantarRight.y = grf.right_moment_mx; grmPlantarRight.z = grf.right_moment_my;

% 将grf信号插值到kinect时间
% 测力台
grfHip = FilterXYZAndInter(grfHip,timeG,pGS1,pGE1,streamInter);
grmHip = FilterXYZAndInter(grmHip,timeG,pGS1,pGE1,streamInter);
grfHipLeft.x = grfHip.x/2; grfHipLeft.y = grfHip.y/2; grfHipLeft.z = grfHip.z/2;
grfHipRight.x = grfHip.x/2; grfHipRight.y = grfHip.y/2; grfHipRight.z = grfHip.z/2;

grfPlantarLeft = FilterXYZAndInter(grfPlantarLeft,timeG,pGS1,pGE1,streamInter);
grfPlantarRight = FilterXYZAndInter(grfPlantarRight,timeG,pGS1,pGE1,streamInter);
grmPlantarLeft = FilterXYZAndInter(grmPlantarLeft,timeG,pGS1,pGE1,streamInter);
grmPlantarRight = FilterXYZAndInter(grmPlantarRight,timeG,pGS1,pGE1,streamInter);

grfPlantar.x = grfPlantarLeft.x+grfPlantarRight.x;
grfPlantar.y = grfPlantarLeft.y+grfPlantarRight.y;
grfPlantar.z = grfPlantarLeft.z+grfPlantarRight.z;

grmPlantar.x = grmPlantarLeft.x+grmPlantarRight.x;
grmPlantar.y = grmPlantarLeft.y+grmPlantarRight.y;
grmPlantar.z = grmPlantarLeft.z+grmPlantarRight.z;

posHip.x = grf.hip_force_pz; posHip.y = grf.hip_force_px; posHip.z = grf.hip_force_py; 
posPlantarLeft.x = grf.left_force_pz; posPlantarLeft.y = grf.left_force_px; posPlantarLeft.z = grf.left_force_py;
posPlantarRight.x = grf.right_force_pz; posPlantarRight.y = grf.right_force_px; posPlantarRight.z = grf.right_force_py;
posHip = FilterXYZAndInter(posHip,timeG,pGS1,pGE1,streamInter);
posPlantarLeft = FilterXYZAndInter(posPlantarLeft,timeG,pGS1,pGE1,streamInter);
posPlantarRight = FilterXYZAndInter(posPlantarRight,timeG,pGS1,pGE1,streamInter);