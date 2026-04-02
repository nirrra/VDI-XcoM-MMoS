idx_sts = 3;
flag_xlim = false;

% 查看各分量(x,y,vx,vy,z,az,I)趋势
f = figure;
set(gcf, 'position', [100, 100, 1280, 720], 'color', 'w');
subplot(4,1,1); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, com.x, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'CoM_x');
p2 = plot(times.union, xcom.x, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'XcoM_x');
p3 = plot(times.union, vcom.x, 'Color', colors(3,:), 'LineWidth', 2.5, 'LineStyle', '-', 'DisplayName', 'V_x');
% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(2,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(3,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(4,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1, p2, p3], 'Location', 'eastoutside', 'FontSize', 9);
title('COM X-component', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('Front ← m → Back');

if flag_xlim, xlim([sts_segments.time_start(idx_sts)-1,sts_segments.time_end(idx_sts)+1]); end

subplot(4,1,2); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, com.y, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'CoM_y');
p2 = plot(times.union, xcom.y, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'XcoM_y');
p3 = plot(times.union, vcom.y, 'Color', colors(3,:), 'LineWidth', 2.5, 'LineStyle', '-', 'DisplayName', 'V_y');
% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(2,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(3,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(4,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1, p2, p3], 'Location', 'eastoutside', 'FontSize', 9);
title('COM Y-component', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('Front ← m → Back');

if flag_xlim, xlim([sts_segments.time_start(idx_sts)-1,sts_segments.time_end(idx_sts)+1]); end

subplot(4,1,3); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, com.z, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'CoM_z');
p2 = plot(times.union, acom.z, 'Color', colors(3,:), 'LineWidth', 2.5, 'LineStyle', '-', 'DisplayName', 'A_z');
% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(2,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(3,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(4,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1, p2], 'Location', 'eastoutside', 'FontSize', 9);
title('COM Z-component', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('Front ← m → Back');

if flag_xlim, xlim([sts_segments.time_start(idx_sts)-1,sts_segments.time_end(idx_sts)+1]); end

subplot(4,1,4); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union, inertia_rotary, 'Color', colors(4,:), 'LineWidth', 2.5);
% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(2,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(3,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(4,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
title('Inertia Rotary', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

xlabel('time / s'); ylabel('Front ← m → Back');

if flag_xlim, xlim([sts_segments.time_start(idx_sts)-1,sts_segments.time_end(idx_sts)+1]); end

% 添加总标题
sgtitle('Fig.7 XcoM = x + v/√(m(g - a_z)z/I) Component Trends', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Color', [.1 .1 .1]);

% 调整子图间距
h = findobj(gcf, 'type', 'axes');
set(h, 'Box', 'off', 'TickDir', 'out');
set(h(1:3), 'XTickLabel', []);

print(f, ['./outputs/images xcom/',filename_plantar(1:end-5),'xcom.png'],'-dpng','-r300');