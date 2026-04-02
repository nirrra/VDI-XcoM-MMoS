%% X和Y共同显示

f = figure('Color', 'white', 'Position', [100, 100, 1280, 600]); % 白色背景，适当大小
% subplot(1,2,1);
axes('Position',[0.08 0.32 0.38 0.55]);
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 12, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);

p3 = plot(seg.time, seg.bos.left, 'Color', line_colors(3,:), 'LineWidth', 1.5, 'LineStyle', ':', 'DisplayName', 'Left Edge of BoS');
p4 = plot(seg.time, seg.bos.right, 'Color', line_colors(4,:), 'LineWidth', 1.5, 'LineStyle', ':', 'DisplayName', 'Right Edge of BoS');

p1 = plot(seg.time, seg.com.x, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'CoM');
p2 = plot(seg.time, seg.xcom.x, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'XcoM');

% 添加垂直线
xline(seg.time(1), '-.', 'Color', [0.80 0.40 0.40], 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p1), '-.', 'Color', [0.80 0.40 0.40], 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p2), '-.', 'Color', [0.80 0.40 0.40], 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p3), '-.', 'Color', [0.80 0.40 0.40], 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p4), '-.', 'Color', [0.80 0.40 0.40], 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_end), '-.', 'Color', [0.80 0.40 0.40], 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1, p2, p3, p4], 'Location', 'southoutside', 'FontSize', 12, 'Position', [0.2 0.07 0.1 0.1]);
title('Mediolateral', 'FontWeight', 'normal', 'FontSize', 14, 'Color', [.2 .2 .2]);

xlabel('Time / s'); ylabel('Position / m');
xlim([seg.time(1)-0.2,seg.time(end)+0.3]);
hold off;

% subplot(1,2,2);
axes('Position',[0.56 0.32 0.38 0.55]);
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 12, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);

p3 = plot(seg.time, seg.bos.plantar_front, 'Color', line_colors(3,:), 'LineWidth', 1.5, 'LineStyle', ':', 'DisplayName', 'Front Edge of BoS');
p4 = plot(seg.time, seg.bos.back, 'Color', line_colors(4,:), 'LineWidth', 1.5, 'LineStyle', ':', 'DisplayName', 'Back Edge of BoS');
p5 = plot(seg.time, seg.bos.plantar_back, 'Color', line_colors(8,:), 'LineWidth', 1.5, 'LineStyle', ':', 'DisplayName', 'Back Edge of Plantar BoS');

p1 = plot(seg.time, seg.com.y, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'CoM');
p2 = plot(seg.time, seg.xcom.y, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'XcoM');

% 添加垂直线
xline(seg.time(1), '-.', 'Color', [0.80 0.40 0.40], 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p1), '-.', 'Color', [0.80 0.40 0.40], 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p2), '-.', 'Color', [0.80 0.40 0.40], 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p3), '-.', 'Color', [0.80 0.40 0.40], 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_p4), '-.', 'Color', [0.80 0.40 0.40], 'LineWidth', 1.5, 'Alpha', 0.7);
xline(seg.time(seg.idx.idx_end), '-.', 'Color', [0.80 0.40 0.40], 'LineWidth', 1.5, 'Alpha', 0.7);
legend([p1, p2, p3, p4, p5], 'Location', 'southoutside', 'FontSize', 12, 'Position', [0.7 0.07 0.1 0.1]);
title('Anteroposterior ', 'FontWeight', 'normal', 'FontSize', 14, 'Color', [.2 .2 .2]);

xlabel('Time / s'); ylabel('Position / m');

xlim([seg.time(1)-0.2,seg.time(end)+0.3]);
hold off;

sgtitle('Typical displacements of CoM and P-XcoM', 'FontSize', 16, 'FontWeight', 'bold');

print(f, ['./outputs/Typical displacements of CoM and P-XcoM.png'],'-dpng','-r300');


% %% X
% 
% figure; 
% set(gcf, 'units', 'normalized', 'position', [0 0 800 960], 'color', 'w');
% hold on; grid on;
% set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
% p1 = plot(seg.time, seg.com.x, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'CoM_x');
% p2 = plot(seg.time, seg.xcom.x, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'XcoM_x');
% 
% p3 = plot(seg.time, seg.bos.plantar_left, 'Color', colors(12,:), 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', 'BoS Left');
% p4 = plot(seg.time, seg.bos.plantar_right, 'Color', colors(11,:), 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', 'BoS Right');
% 
% % 添加垂直线
% xline(seg.time(1), '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
% xline(seg.time(seg.idx.idx_p1), '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
% xline(seg.time(seg.idx.idx_p2), '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
% xline(seg.time(seg.idx.idx_p3), '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
% xline(seg.time(seg.idx.idx_p4), '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
% xline(seg.time(seg.idx.idx_end), '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
% legend([p1, p2, p3, p4], 'Location', 'northeast', 'FontSize', 9);
% title('CoM & XcoM', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
% 
% xlabel('time / s'); ylabel('Position / m');
% xlim([seg.time(1)-0.2,seg.time(end)+0.3]);
% 
% %% Y
% 
% figure; 
% set(gcf, 'units', 'normalized', 'position', [0 0 800 960], 'color', 'w');
% hold on; grid on;
% set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
% p1 = plot(seg.time, seg.com.y, 'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'CoM_y');
% p2 = plot(seg.time, seg.xcom.y, 'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'XcoM_y');
% 
% p3 = plot(seg.time, seg.bos.plantar_front, 'Color', colors(12,:), 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', 'Plantar front');
% p4 = plot(seg.time, seg.bos.plantar_back, 'Color', colors(11,:), 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', 'Plantar back');
% p5 = plot(seg.time, seg.bos.back, 'Color', colors(10,:), 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', 'All back');
% 
% % 添加垂直线
% xline(seg.time(1), '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
% xline(seg.time(seg.idx.idx_p1), '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
% xline(seg.time(seg.idx.idx_p2), '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
% xline(seg.time(seg.idx.idx_p3), '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
% xline(seg.time(seg.idx.idx_p4), '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
% xline(seg.time(seg.idx.idx_end), '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);
% legend([p1, p2, p3, p4, p5], 'Location', 'northeast', 'FontSize', 9);
% title('CoM & XcoM', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
% 
% xlabel('time / s'); ylabel('Position / m');
% 
% xlim([seg.time(1)-0.2,seg.time(end)+0.3]);