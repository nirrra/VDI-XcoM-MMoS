%% 关节矩作图
f = figure;
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');

% 髋关节矩
subplot(2,2,1); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, jointMomentGlobal.Thigh_Left_proximal.x, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'Left Hip');
p2 = plot(times.union, jointMomentGlobal.Thigh_Right_proximal.x, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'Right Hip');

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

legend([p1, p2], 'Location', 'best', 'FontSize', 9);
title('Hip Joint Moment (+ Flexion, - Extension)', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlabel('time / s'); ylabel('Moment / N*m');

% 膝关节矩
subplot(2,2,2); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, jointMomentGlobal.Shank_Left_proximal.x, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'Left Knee');
p2 = plot(times.union, jointMomentGlobal.Shank_Right_proximal.x, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'Right Knee');

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

legend([p1, p2], 'Location', 'best', 'FontSize', 9);
title('Knee Joint Moment (+ Extension, - Flexion)', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlabel('time / s'); ylabel('Moment / N*m');

% 踝关节矩
subplot(2,2,3); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, jointMomentGlobal.Foot_Left_proximal.x, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'Left Ankle');
p2 = plot(times.union, jointMomentGlobal.Foot_Right_proximal.x, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'Right Ankle');

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

legend([p1, p2], 'Location', 'best', 'FontSize', 9);
title('Ankle Joint Moment (+ Dorsiflexion, - Plantarflexion)', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlabel('time / s'); ylabel('Moment / N*m');

% 腰椎关节矩
subplot(2,2,4); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, jointMomentGlobal.Trunk_Lower_proximal.x, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'Lumbar');

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

legend([p1], 'Location', 'best', 'FontSize', 9);
title('Lumbar Joint Moment (+ Extension, - Flexion)', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlabel('time / s'); ylabel('Moment / N*m');

% 添加总标题
sgtitle('Joint Moments', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Color', [.1 .1 .1]);

% 调整子图间距
h = findobj(gcf, 'type', 'axes');
set(h, 'Box', 'off', 'TickDir', 'out');

% set(gcf,'position',[100,100,1280,720]);

print(f, ['./outputs/images jms/',filename,'_joint_moments.png'],'-dpng','-r300'); 