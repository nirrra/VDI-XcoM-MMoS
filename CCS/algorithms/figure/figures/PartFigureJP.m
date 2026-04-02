%% 关节功率作图
f = figure;
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');

% 髋关节功率
subplot(2,2,1); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, jointPower.hip_flexion_l, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'Left Hip');
p2 = plot(times.union, jointPower.hip_flexion_r, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'Right Hip');

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

legend([p1, p2], 'Location', 'best', 'FontSize', 9);
title('Hip Joint Power', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlabel('time / s'); ylabel('Power / W');

% 膝关节功率
subplot(2,2,2); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, jointPower.knee_angle_l, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'Left Knee');
p2 = plot(times.union, jointPower.knee_angle_r, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'Right Knee');

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

legend([p1, p2], 'Location', 'best', 'FontSize', 9);
title('Knee Joint Power', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlabel('time / s'); ylabel('Power / W');

% 踝关节功率
subplot(2,2,3); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, jointPower.ankle_angle_l, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'Left Ankle');
p2 = plot(times.union, jointPower.ankle_angle_r, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'Right Ankle');

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

legend([p1, p2], 'Location', 'best', 'FontSize', 9);
title('Ankle Joint Power', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlabel('time / s'); ylabel('Power / W');

% 腰椎关节功率
subplot(2,2,4); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, jointPower.lumbar_extension, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'Lumbar');

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

legend([p1], 'Location', 'best', 'FontSize', 9);
title('Lumbar Joint Power', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlabel('time / s'); ylabel('Power / W');

% 添加总标题
sgtitle('Joint Powers', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Color', [.1 .1 .1]);

% 调整子图间距
h = findobj(gcf, 'type', 'axes');
set(h, 'Box', 'off', 'TickDir', 'out');

print(f, ['./outputs/images jps/',filename,'_joint_powers.png'],'-dpng','-r300'); 