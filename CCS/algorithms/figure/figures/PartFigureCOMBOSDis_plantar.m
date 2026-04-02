figure; 
set(gcf, 'position', [100, 100, 1280, 720], 'color', 'w');
subplot(3,1,1);
hold on; grid on;
p1 = plot(times.union,dis_com_bos_plantar.dis,'Color', colors(1,:), 'LineWidth', 1, 'DisplayName', 'com-bos');
p2 = plot(times.union,dis_xcom_bos_plantar.dis,'Color', colors(2,:), 'LineWidth', 1, 'DisplayName', 'xcom-bos');
% p3 = plot(times.union,dis_xcom_xbos.dis,'Color', colors(4,:), 'LineWidth', 1, 'DisplayName', 'xcom-xbos');

xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(2,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(3,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(4,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 0.5, 'Alpha', 0.7);

hold off; 
legend([p1, p2], 'Location', 'eastoutside', 'FontSize', 9);
title('到BoS距离（负值表示在BoS之外）'); xlabel('time/s'); ylabel('distance/m');

subplot(3,1,2);
hold on; grid on;
p1 = plot(times.union,dis_com_bos_plantar.y_front,'Color', colors(1,:), 'LineWidth', 1, 'DisplayName', 'com-bos');
p2 = plot(times.union,dis_xcom_bos_plantar.y_front,'Color', colors(2,:), 'LineWidth', 1, 'DisplayName', 'xcom-bos');
% p3 = plot(times.union,dis_xcom_xbos.y_front,'Color', colors(4,:), 'LineWidth', 1, 'DisplayName', 'xcom-xbos');

xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(2,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(3,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(4,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 0.5, 'Alpha', 0.7);

hold off;
legend([p1, p2], 'Location', 'eastoutside', 'FontSize', 9);
title('到BoS前边界距离（正值表示位于BoS前边界前方）'); xlabel('time/s'); ylabel('后 ← distance/m → 前');

subplot(3,1,3);
hold on; grid on;
p1 = plot(times.union,dis_com_bos_plantar.y_back,'Color', colors(1,:), 'LineWidth', 1, 'DisplayName', 'com-bos');
p2 = plot(times.union,dis_xcom_bos_plantar.y_back,'Color', colors(2,:), 'LineWidth', 1, 'DisplayName', 'xcom-bos');
% p3 = plot(times.union,dis_xcom_xbos.y_back,'Color', colors(4,:), 'LineWidth', 1, 'DisplayName', 'xcom-xbos');

xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(2,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(3,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(4,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 0.5, 'Alpha', 0.7);

hold off;
legend([p1, p2], 'Location', 'eastoutside', 'FontSize', 9);
title('到BoS后边界距离（正值表示位于BoS后边界前方）'); xlabel('time/s'); ylabel('后 ← distance/m → 前');

sgtitle('图.8 com-足部bos距离', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);