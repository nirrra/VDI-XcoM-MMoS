
f = figure;
set(gcf, 'units', 'normalized', 'position', [0 0 800 960], 'color', 'w');

%% CoM
subplot(5,1,1); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(seg.time, seg.com.y, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'CoM_y');
p2 = plot(seg.time, seg.xcom.y, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'XcoM_y');
p3 = plot(seg.time, seg.xcom.y-seg.com.y, 'Color', colors(3,:), 'LineWidth', 2.5, 'DisplayName', 'XcoM_y-CoM_y');
p4 = plot(seg.time, seg.com.vy./2, 'Color', colors(4,:), 'LineWidth', 2.5, 'LineStyle', '-', 'DisplayName', 'V_y/2');
p5 = plot(seg.time, seg.com.az./5, 'Color', colors(5,:), 'LineWidth', 2.5, 'LineStyle', '-', 'DisplayName', 'Acc_z/5');

p6 = plot(seg.time, seg.bos.plantar_front, 'Color', colors(12,:), 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', 'Plantar front');
p7 = plot(seg.time, seg.bos.plantar_back, 'Color', colors(11,:), 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', 'Plantar back');
p8 = plot(seg.time, seg.bos.back, 'Color', colors(10,:), 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', 'All back');

plot(seg.time(seg.idx.idx_com_stable), seg.com.y(seg.idx.idx_com_stable), 'Color', colors(1,:), ...
    'LineStyle', 'none', 'Marker','o', 'MarkerFaceColor', colors(1,:), 'MarkerSize', 8);
plot(seg.time(seg.idx.idx_xcom_stable), seg.xcom.y(seg.idx.idx_xcom_stable), 'Color', colors(2,:), ...
    'LineStyle', 'none', 'Marker','o', 'MarkerFaceColor', colors(2,:), 'MarkerSize', 8);

% 添加垂直线
xline(seg.time(1), '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p1), '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p2), '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p3), '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p4), '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_end), '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1, p2, p3, p4, p5, p6, p7, p8], 'Location', 'northeast', 'FontSize', 9);
title('CoM & XcoM', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('Back ← m → Front');

xlim([seg.time(1)-0.2,seg.time(end)+0.3]);

%% 转动惯量
subplot(5,1,2);
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(seg.time, seg.inertia, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'Inertia');

% 添加垂直线
xline(seg.time(1), '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p1), '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p2), '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p3), '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p4), '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_end), '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1], 'Location', 'northeast', 'FontSize', 9);
title('Inertia', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('kg.m^2');

xlim([seg.time(1)-0.2,seg.time(end)+0.3]);

%% 关节角
subplot(5,1,3);
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(seg.time, seg.ja.left_hip, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'Hip');
p2 = plot(seg.time, seg.ja.left_knee, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'Knee');
p3 = plot(seg.time, seg.ja.left_ankle, 'Color', colors(3,:), 'LineWidth', 2.5, 'DisplayName', 'Ankle');
p4 = plot(seg.time, seg.ja.lumbar, 'Color', colors(4,:), 'LineWidth', 2.5, 'DisplayName', 'Lumbar');

% 添加垂直线
xline(seg.time(1), '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p1), '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p2), '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p3), '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p4), '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_end), '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

aux = seg.ja.left_hip;
plot(seg.time(seg.idx.idx_p4),aux(seg.idx.idx_p4),'Color', colors(1,:),...
    'LineStyle', 'none', 'Marker','o', 'MarkerFaceColor', colors(1,:), 'MarkerSize', 8);
aux = seg.ja.left_ankle;
plot(seg.time(seg.idx.idx_p3),aux(seg.idx.idx_p3),'Color', colors(3,:),...
    'LineStyle', 'none', 'Marker','o', 'MarkerFaceColor', colors(3,:), 'MarkerSize', 8);

legend([p1, p2, p3, p4], 'Location', 'northeast', 'FontSize', 9);
title('Joint Angles', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('degree');

xlim([seg.time(1)-0.2,seg.time(end)+0.3]);

%% 关节力
subplot(5,1,4);
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(seg.time_vicon, seg.jrf.left_hip_y, 'Color', colors(1,:), 'LineWidth', 1.5, 'DisplayName', 'Hip y');
p2 = plot(seg.time_vicon, seg.jrf.left_hip_z, 'Color', colors(1,:), 'LineWidth', 1.5, 'LineStyle', '-.', 'DisplayName', 'Hip z');
p3 = plot(seg.time_vicon, seg.jrf.left_knee_y, 'Color', colors(2,:), 'LineWidth', 1.5, 'DisplayName', 'Knee y');
p4 = plot(seg.time_vicon, seg.jrf.left_knee_z, 'Color', colors(2,:), 'LineWidth', 1.5, 'LineStyle', '-.', 'DisplayName', 'Knee z');
p5 = plot(seg.time_vicon, seg.jrf.left_ankle_y, 'Color', colors(3,:), 'LineWidth', 1.5, 'DisplayName', 'Ankle y');
p6 = plot(seg.time_vicon, seg.jrf.left_ankle_z, 'Color', colors(3,:), 'LineWidth', 1.5, 'LineStyle', '-.', 'DisplayName', 'Ankle z');

% 添加垂直线
xline(seg.time(1), '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p1), '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p2), '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p3), '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p4), '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_end), '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1, p2, p3, p4, p5, p6], 'Location', 'northeast', 'FontSize', 9);
title('Joint Reaction Forces', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('Force / N');

xlim([seg.time(1)-0.2,seg.time(end)+0.3]);

%% 关节矩
subplot(5,1,5);
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(seg.time_vicon, seg.jm.left_hip_flexion, 'Color', colors(1,:), 'LineWidth', 1.5, 'DisplayName', 'Hip flexion');
p2 = plot(seg.time_vicon, seg.jm.left_hip_rotation, 'Color', colors(5,:), 'LineWidth', 1.5, 'DisplayName', 'Hip rotation');
p3 = plot(seg.time_vicon, seg.jm.left_hip_adduction, 'Color', colors(12,:), 'LineWidth', 1.5, 'DisplayName', 'Hip adduction');
p4 = plot(seg.time_vicon, seg.jm.left_knee, 'Color', colors(2,:), 'LineWidth', 1.5, 'DisplayName', 'Knee');
p5 = plot(seg.time_vicon, seg.jm.left_ankle, 'Color', colors(3,:), 'LineWidth', 1.5, 'DisplayName', 'Ankle');
p6 = plot(seg.time_vicon, seg.jm.lumbar_bending, 'Color', colors(4,:), 'LineWidth', 1.5, 'DisplayName', 'Lumbar bending');
p7 = plot(seg.time_vicon, seg.jm.lumbar_extension, 'Color', colors(8,:), 'LineWidth', 1.5, 'DisplayName', 'Lumbar extension');
% p8 = plot(seg.time_vicon, seg.jm.lumbar_rotation, 'Color', colors(13,:), 'LineWidth', 1.5, 'DisplayName', 'Lumbar rotation');

% 添加垂直线
xline(seg.time(1), '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p1), '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p2), '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p3), '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p4), '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_end), '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1, p2, p3, p4, p5, p6, p7], 'Location', 'northeast', 'FontSize', 9);
title('Joint Moments', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('Moment / N*m');

xlim([seg.time(1)-0.2,seg.time(end)+0.3]);

%% 保存

sgtitle(strrep(filename_seg,'_',' '), 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
print(f, ['./outputs/images segs/',filename_seg,'_segs.png'],'-dpng','-r300');


