f = figure; 
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');

subplot(4,1,1);
hold on; grid on;
p1 = plot(times.vicon,id.hip_flexion_l_moment,'Color', colors(1,:), 'LineWidth', 1.5, 'DisplayName', 'hip flexion moment');
p2 = plot(times.vicon,id.hip_adduction_l_moment,'Color', colors(2,:), 'LineWidth', 1.5, 'DisplayName', 'hip adduction moment');
p3 = plot(times.vicon,id.hip_rotation_l_moment,'Color', colors(3,:), 'LineWidth', 1.5, 'DisplayName', 'hip rotation moment');

xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 0.5, 'Alpha', 0.7);
hold off; 
legend([p1, p2, p3], 'Location', 'eastoutside', 'FontSize', 9);
title('髋关节'); xlabel('time / s'); ylabel('Moment / N*m');

subplot(4,1,2);
hold on; grid on;
p1 = plot(times.vicon,id.knee_angle_l_moment,'Color', colors(1,:), 'LineWidth', 1.5, 'DisplayName', 'left knee moment');
p2 = plot(times.vicon,id.knee_angle_r_moment,'Color', colors(2,:), 'LineWidth', 1.5, 'DisplayName', 'right knee moment');

xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 0.5, 'Alpha', 0.7);
hold off; 
legend([p1, p2], 'Location', 'eastoutside', 'FontSize', 9);
title('膝关节'); xlabel('time / s'); ylabel('Moment / N*m');

subplot(4,1,3);
hold on; grid on;
p1 = plot(times.vicon,id.ankle_angle_l_moment,'Color', colors(1,:), 'LineWidth', 1.5, 'DisplayName', 'left ankle moment');
p2 = plot(times.vicon,id.ankle_angle_r_moment,'Color', colors(2,:), 'LineWidth', 1.5, 'DisplayName', 'right ankle moment');

xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 0.5, 'Alpha', 0.7);
hold off; 
legend([p1, p2], 'Location', 'eastoutside', 'FontSize', 9);
title('踝关节'); xlabel('time / s'); ylabel('Moment / N*m');

subplot(4,1,4);
hold on; grid on;
p1 = plot(times.vicon,id.lumbar_extension_moment,'Color', colors(1,:), 'LineWidth', 1.5, 'DisplayName', 'lumbar extension moment');
p2 = plot(times.vicon,id.lumbar_bending_moment,'Color', colors(2,:), 'LineWidth', 1.5, 'DisplayName', 'lumbar bending moment');
p3 = plot(times.vicon,id.lumbar_rotation_moment,'Color', colors(3,:), 'LineWidth', 1.5, 'DisplayName', 'lumbar rotation moment');

xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 0.5, 'Alpha', 0.7);
hold off; 
legend([p1, p2, p3], 'Location', 'eastoutside', 'FontSize', 9);
title('腰椎'); xlabel('time / s'); ylabel('Moment / N*m');



sgtitle('图.10 关节矩', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

print(f, ['./outputs/images jms/',filename,'_jms.png'],'-dpng','-r300');
