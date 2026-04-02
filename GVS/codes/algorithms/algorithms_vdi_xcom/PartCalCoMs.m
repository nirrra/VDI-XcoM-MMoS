time = times.vicon;
com.x = analysisGround.pos_center_of_mass_Z;
com.y = analysisGround.pos_center_of_mass_X;
com.z = analysisGround.pos_center_of_mass_Y;

com.vx = analysisGround.vel_center_of_mass_Z;
com.vy = analysisGround.vel_center_of_mass_X;
com.vz = analysisGround.vel_center_of_mass_Y;

com.ax = analysisGround.acc_center_of_mass_Z;
com.ay = analysisGround.acc_center_of_mass_X;
com.az = analysisGround.acc_center_of_mass_Y;

l = ((com.x-(analysisGround.pos_calcn_l_Z+analysisGround.pos_calcn_r_Z)./2).^2 +...
    (com.y-(analysisGround.pos_calcn_l_X+analysisGround.pos_calcn_r_X)./2).^2 +...
    (com.z-(analysisGround.pos_calcn_l_Y+analysisGround.pos_calcn_r_Y)./2).^2).^0.5;

omega_hof = (9.78./com.z).^0.5;
xcom_hof.x = com.x + com.vx./omega_hof;
xcom_hof.y = com.y + com.vy./omega_hof;

% Compute \dot{h_z}
[dot_hx, dot_hy, dot_hz] = CalDotH(analysisGround);

omega_cmp = (Fz_sum./(weight.*com.z)).^0.5;
xcom_cmp.x = com.x + com.vx./omega_cmp;
xcom_cmp.y = com.y + com.vy./omega_cmp;

xcom_cmp_h.x = com.x + com.vx./omega_cmp - dot_hy./Fz_sum;
xcom_cmp_h.y = com.y + com.vy./omega_cmp + dot_hx./Fz_sum;

if flag_show_figs
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
    sgtitle('Compare CoM / XcoM / CoM CMP')
end