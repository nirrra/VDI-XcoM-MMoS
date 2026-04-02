[posCOMSegments,vCOMSegments,accCOMSegments] = Segments_Velocity_Acceleration_WithPelvis(streamInter,gender,fsInter);

time = times.union;
com.x = posCOMSegments.human.x;
com.y = posCOMSegments.human.y;
com.z = posCOMSegments.human.z;

com.vx = vCOMSegments.human.x;
com.vy = vCOMSegments.human.y;
com.vz = vCOMSegments.human.z;

com.ax = accCOMSegments.human.x;
com.ay = accCOMSegments.human.y;
com.az = accCOMSegments.human.z;

omega_hof = (9.78./com.z).^0.5;
xcom_hof.x = com.x + com.vx./omega_hof;
xcom_hof.y = com.y + com.vy./omega_hof;

%% 旋转矩阵（体段坐标系到全局坐标系）
[segments_RM, segments_origin] = Segments_Rotation_WithPelvis(streamInter);
%% 角速度和角加速度
[segments_W_G,segments_W_L,segments_W_G_xyz,segments_W_L_xyz] = Segments_Rotation_Angular_velocity(segments_RM,fsInter);
[segments_Alpha_G,segments_Alpha_L,segments_Alpha_G_xyz,segments_Alpha_L_xyz] = Segments_Rotation_Angular_Acceleration(segments_W_G,segments_W_L,fsInter);

% 计算绕全身CoM的角动量率
[dot_hx, dot_hy, dot_hz] = CalDotHCoM3D(weight, gender, streamInter, ...
    posCOMSegments, segments_RM, segments_W_L, segments_Alpha_L, ...
    vCOMSegments, accCOMSegments, fsInter);

omega_cmp = (Fz_sum_f./(weight.*com.z)).^0.5;
xcom_cmp.x = com.x + com.vx./omega_cmp;
xcom_cmp.y = com.y + com.vy./omega_cmp;

xcom_cmp_h.x = com.x + com.vx./omega_cmp - dot_hy./Fz_sum_f;
xcom_cmp_h.y = com.y + com.vy./omega_cmp + dot_hx./Fz_sum_f;

if flag_show_fig
    figure;
    set(gcf, 'Position', [100, 100, 1280, 960], 'color', 'w');
    subplot(2,1,1); hold on;
    p1 = plot(time,com.x,'DisplayName','CoM X');
    p2 = plot(time,xcom_hof.x,'DisplayName','XcoM hof X');
    p3 = plot(time,xcom_cmp.x,'DisplayName','XcoM cmp X');
    p4 = plot(time,xcom_cmp_h.x,'DisplayName','XcoM cmp hz X');
    xline(times_start,'r--');
    xline(times_end,'b--');
    xlim([20,60]);
    legend([p1,p2,p3,p4]);
    hold off;
    subplot(2,1,2); hold on;
    p1 = plot(time,com.y,'DisplayName','CoM Y');
    p2 = plot(time,xcom_hof.y,'DisplayName','XcoM hof Y');
    p3 = plot(time,xcom_cmp.y,'DisplayName','XcoM cmp Y');
    p4 = plot(time,xcom_cmp_h.y,'DisplayName','XcoM cmp hz Y');
    xline(times_start,'r--');
    xline(times_end,'b--');
    xlim([20,60]);
    legend([p1,p2,p3,p4]);
    hold off;
    sgtitle('比较CoM/XcoM/CoM CMP')
end