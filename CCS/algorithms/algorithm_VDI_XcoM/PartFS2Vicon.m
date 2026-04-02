% 根据静止站立时的cop和com，确定阵列在Vicon坐标系位置
[copPlantar_inter.x, copPlantar_inter.y] = calCOP(pressurePlantar2DInter,1); copPlantar_inter.x = copPlantar_inter.x*0.001; copPlantar_inter.y = -copPlantar_inter.y*0.001;
[copPlantar.x,copPlantar.y] = calCOP(pressurePlantar2D,1); copPlantar.x = copPlantar.x*0.001; copPlantar.y = -copPlantar.y*0.001;
[copHip_inter.x, copHip_inter.y] = calCOP(pressureHip2DInter,1); copHip_inter.x = copHip_inter.x*0.001; copHip_inter.y = -copHip_inter.y*0.001;

% 确定静站段
com_f.x = com.x;
com_f.y = com.y;
com_f.z = com.z;
com_f.x = interp1(times.vicon,com_f.x,times.union,'pchip');
com_f.y = interp1(times.vicon,com_f.y,times.union,'pchip');
com_f.z = interp1(times.vicon,com_f.z,times.union,'pchip');

idxs_stable_standing = GetIdxTime(times.union,times_end);
for i = 1:length(idxs_stable_standing)
    if abs(copPlantar_inter.x(idxs_stable_standing(i))) < 0.01 || abs(copPlantar_inter.y(idxs_stable_standing(i))) < 0.01 
        idxs_stable_standing(i) = [];
    end
end

transform_plantar2vicon = [median(com_f.x(idxs_stable_standing)),median(com_f.y(idxs_stable_standing))] -...
    [median(copPlantar_inter.x),median(copPlantar_inter.y)];
transform_plantar2vicon = [transform_plantar2vicon,0];
transform_buttock2vicon = transform_plantar2vicon+[0,-plantar_buttock_displacement,height_sit];

figVisible = 'off';
if flag_show_figs
    figVisible = 'on';
end
fig_fs2vicon = figure('Visible', figVisible);
subplot(3,1,1); hold on;
plot(copPlantar_inter.y);
plot(idxs_stable_standing,copPlantar_inter.y(idxs_stable_standing),'ro');
hold off; legend('com.y'); title('选择静站段');
subplot(3,1,2); hold on;
plot(com_f.y);
plot(com_f.z);
plot(idxs_stable_standing,com_f.y(idxs_stable_standing),'ro');
hold off; legend('com.y','com.z'); title('选择静站段');
subplot(3,1,3); hold on;
plot(com_f.x,com_f.y); 
plot(copPlantar_inter.x+transform_plantar2vicon(1),copPlantar_inter.y+transform_plantar2vicon(2));
plot(copHip_inter.x+transform_buttock2vicon(1),copHip_inter.y+transform_buttock2vicon(2));
hold off; axis equal; legend('com','cop plantar','cop buttock');
title('查看对齐效果');

outputDir = fullfile('outputs', 'images com cmp', 'fs2vicon');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
outputName = sprintf('fs2vicon_%d.png', idxFile);
saveas(fig_fs2vicon, fullfile(outputDir, outputName));
if ~flag_show_figs
    close(fig_fs2vicon);
end