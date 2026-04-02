f = figure; 
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');

subplot(3,1,1);
hold on; grid on;
p1 = plot(times.vicon,analysisGround.jrl_hip_l_on_femur_l_in_ground_fz,'Color', colors(1,:), 'LineWidth', 1.5, 'DisplayName', 'x');
p2 = plot(times.vicon,analysisGround.jrl_hip_l_on_femur_l_in_ground_fx,'Color', colors(2,:), 'LineWidth', 1.5, 'DisplayName', 'y');
p3 = plot(times.vicon,analysisGround.jrl_hip_l_on_femur_l_in_ground_fy,'Color', colors(3,:), 'LineWidth', 1.5, 'DisplayName', 'z');
p4 = plot(times.vicon,funcSumXYZ(analysisGround.jrl_hip_l_on_femur_l_in_ground_fx,...
    analysisGround.jrl_hip_l_on_femur_l_in_ground_fy,...
    analysisGround.jrl_hip_l_on_femur_l_in_ground_fz),...
    'Color', colors(4,:), 'LineWidth', 1.5, 'DisplayName', 'sum');

xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 0.5, 'Alpha', 0.7);
hold off; 
legend([p1, p2, p3, p4], 'Location', 'eastoutside', 'FontSize', 9);
title('髋关节'); xlabel('time / s'); ylabel('Force / N');

subplot(3,1,2);
hold on; grid on;
p1 = plot(times.vicon,analysisGround.jrl_knee_l_on_tibia_l_in_ground_fz,'Color', colors(1,:), 'LineWidth', 1.5, 'DisplayName', 'x');
p2 = plot(times.vicon,analysisGround.jrl_knee_l_on_tibia_l_in_ground_fx,'Color', colors(2,:), 'LineWidth', 1.5, 'DisplayName', 'y');
p3 = plot(times.vicon,analysisGround.jrl_knee_l_on_tibia_l_in_ground_fy,'Color', colors(3,:), 'LineWidth', 1.5, 'DisplayName', 'z');
p4 = plot(times.vicon,funcSumXYZ(analysisGround.jrl_knee_l_on_tibia_l_in_ground_fx,...
    analysisGround.jrl_knee_l_on_tibia_l_in_ground_fy,...
    analysisGround.jrl_knee_l_on_tibia_l_in_ground_fz),...
    'Color', colors(4,:), 'LineWidth', 1.5, 'DisplayName', 'sum');

xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 0.5, 'Alpha', 0.7);
hold off; 
legend([p1, p2, p3, p4], 'Location', 'eastoutside', 'FontSize', 9);
title('膝关节'); xlabel('time / s'); ylabel('Force / N');

subplot(3,1,3);
hold on; grid on;
p1 = plot(times.vicon,analysisGround.jrl_ankle_l_on_talus_l_in_ground_fz,'Color', colors(1,:), 'LineWidth', 1.5, 'DisplayName', 'x');
p2 = plot(times.vicon,analysisGround.jrl_ankle_l_on_talus_l_in_ground_fx,'Color', colors(2,:), 'LineWidth', 1.5, 'DisplayName', 'y');
p3 = plot(times.vicon,analysisGround.jrl_ankle_l_on_talus_l_in_ground_fy,'Color', colors(3,:), 'LineWidth', 1.5, 'DisplayName', 'z');
p4 = plot(times.vicon,funcSumXYZ(analysisGround.jrl_ankle_l_on_talus_l_in_ground_fx,...
    analysisGround.jrl_ankle_l_on_talus_l_in_ground_fy,...
    analysisGround.jrl_ankle_l_on_talus_l_in_ground_fz),...
    'Color', colors(4,:), 'LineWidth', 1.5, 'DisplayName', 'sum');

xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 0.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 0.5, 'Alpha', 0.7);
hold off; 
legend([p1, p2, p3, p4], 'Location', 'eastoutside', 'FontSize', 9);
title('踝关节'); xlabel('time / s'); ylabel('Force / N');



sgtitle('图.9 关节力', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);

print(f, ['./outputs/images jrfs/',filename,'_jrfs.png'],'-dpng','-r300');
