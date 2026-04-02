%% 作图
% 查看各分量(x,y,vx,vy,z,az,I)趋势
f = figure;
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');
subplot(4,1,1); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, com.x, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'CoM_x');
p2 = plot(times.union, xcom.x, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'XcoM_x');
p3 = plot(times.union, vcom.x, 'Color', colors(3,:), 'LineWidth', 2.5, 'LineStyle', '-', 'DisplayName', 'V_x');

p4 = plot(times.union, bos_plantar_left, 'Color', colors(12,:), 'LineWidth', 1.5, 'LineStyle', '--');
p5 = plot(times.union, bos_plantar_right, 'Color', colors(12,:), 'LineWidth', 1.5, 'LineStyle', '--');

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1, p2, p3, p4, p5], 'Location', 'northwest', 'FontSize', 9);
title('COM X-component', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('Left ← m → Right');

subplot(4,1,2); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, com.y, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'CoM_y');
p2 = plot(times.union, xcom.y, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'XcoM_y');
p3 = plot(times.union, vcom.y, 'Color', colors(3,:), 'LineWidth', 2.5, 'LineStyle', '-', 'DisplayName', 'V_y');

p4 = plot(times.union, bos_plantar_front, 'Color', colors(12,:), 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', 'Plantar front');
p5 = plot(times.union, bos_plantar_back, 'Color', colors(11,:), 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', 'Plantar back');
p6 = plot(times.union, bos_back, 'Color', colors(10,:), 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', 'All back');

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1, p2, p3, p4, p5, p6], 'Location', 'northwest', 'FontSize', 9);
title('COM Y-component', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('Back ← m → Front');

subplot(4,1,3); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, com.z, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'CoM_z');
p2 = plot(times.union, acom.z, 'Color', colors(3,:), 'LineWidth', 2.5, 'LineStyle', '-', 'DisplayName', 'A_z');
% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1, p2], 'Location', 'northwest', 'FontSize', 9);
title('COM Z-component', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('m');

subplot(4,1,4); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, inertia_rotary, 'Color', colors(4,:), 'LineWidth', 2.5, 'DisplayName', 'Inertia');
% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1], 'Location', 'northwest', 'FontSize', 9);
title('Inertia Rotary', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('kg*m*m');

% 添加总标题
sgtitle('P-XcoM Component Trends', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Color', [.1 .1 .1]);

% 调整子图间距
h = findobj(gcf, 'type', 'axes');
set(h, 'Box', 'off', 'TickDir', 'out');
set(h(1:3), 'XTickLabel', []);

print(f, ['./outputs/images p-xcom components/',filename,'_xcom.png'],'-dpng','-r300');