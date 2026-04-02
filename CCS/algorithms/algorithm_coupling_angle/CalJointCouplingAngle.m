function [jc] = CalJointCouplingAngle(ja_proximal, ja_distal)

% 计算耦合角（从点i到点i+1）
n = length(ja_proximal);

jc = [];

for i = 1:n-1
    dx = ja_proximal(i+1) - ja_proximal(i);
    dy = ja_distal(i+1) - ja_distal(i);
    
    if dx > 0
        jc(end+1) = atand(dy/dx);
    else
        jc(end+1) = atand(dy/dx) + 180;
    end
end

% 将角度调整到[0, 360]区间
jc(jc < 0) = jc(jc < 0) + 360;

% % 求平均耦合角（使用圆统计学）
% mean_x = mean(cosd(jc));
% mean_y = mean(sind(jc));
% 
% % 使用atan2进行四象限修正
% mean_jc = atan2d(mean_y, mean_x);
% if mean_jc < 0
%     mean_jc = mean_jc + 360;
% end

% %% 协调模式分类（依据Hamill等, 2000; Needham等, 2015）
% % 根据平均耦合角进行四象限分类
% if (mean_jc >= 22.5 && mean_jc < 67.5) || (mean_jc >= 202.5 && mean_jc < 247.5)
%     coordination_pattern = '同向（In-phase）';
%     quadrant = 1;
% elseif (mean_jc >= 112.5 && mean_jc < 157.5) || (mean_jc >= 292.5 && mean_jc < 337.5)
%     coordination_pattern = '反向（Anti-phase）';
%     quadrant = 2;
% elseif (mean_jc >= 67.5 && mean_jc < 112.5) || (mean_jc >= 247.5 && mean_jc < 292.5)
%     coordination_pattern = '远端主导（Distal）';
%     quadrant = 3;
% elseif (mean_jc >= 157.5 && mean_jc < 202.5) || (mean_jc >= 337.5 && mean_jc <= 360) || (mean_jc >= 0 && mean_jc < 22.5)
%     coordination_pattern = '近端主导（Proximal）';
%     quadrant = 4;
% else
%     coordination_pattern = '未知';
%     quadrant = 0;
% end

% %% 显示
% if flagShow
%     %% 显示结果
%     fprintf('\n========== 耦合角分析结果 ==========\n');
%     fprintf('平均耦合角: %.2f°\n', mean_jc);
%     fprintf('协调模式: %s\n', coordination_pattern);
%     fprintf('所在象限: %d\n', quadrant);
%     fprintf('=====================================\n');
% 
%     %% 可视化：角-角图 (Angle-Angle Plot)
%     figure('Name', '关节协调分析', 'Position', [100, 100, 1200, 500]);
%     
%     % 子图1: 角-角图
%     subplot(1, 2, 1);
%     plot(ja_proximal, ja_distal, 'b-', 'LineWidth', 1.5);
%     hold on;
%     plot(ja_proximal(1), ja_distal(1), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'DisplayName', '起点');
%     plot(ja_proximal(end), ja_distal(end), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'DisplayName', '终点');
%     xlabel('近端关节角度[°]');
%     ylabel('远端关节角度[°]');
%     title('角-角图 (Angle-Angle Plot)');
%     grid on;
%     legend('运动轨迹', '起点', '终点', 'Location', 'best');
%     axis equal;
%     
%     % 子图2: 耦合角极坐标图
%     subplot(1, 2, 2);
%     polarhistogram(deg2rad(jc), 36, 'FaceColor', [0.3, 0.5, 0.8], 'FaceAlpha', 0.6);
%     hold on;
%     
%     % 绘制平均耦合角方向
%     mean_jc_rad = deg2rad(mean_jc);
%     polarplot([0, mean_jc_rad], [0, max(histcounts(jc, 36))], 'r-', 'LineWidth', 3);
%     
%     % 添加象限分界线
%     max_radius = max(histcounts(jc, 36)) * 1.1;
%     polarplot([0, deg2rad(45)], [0, max_radius], 'k--', 'LineWidth', 0.5);
%     polarplot([0, deg2rad(135)], [0, max_radius], 'k--', 'LineWidth', 0.5);
%     polarplot([0, deg2rad(225)], [0, max_radius], 'k--', 'LineWidth', 0.5);
%     polarplot([0, deg2rad(315)], [0, max_radius], 'k--', 'LineWidth', 0.5);
%     
%     title(sprintf('耦合角分布 (平均: %.1f°)\n%s', mean_jc, coordination_pattern));
%     thetaticks([0, 90, 180, 270]);
%     thetaticklabels({'近端 (0°)', '远端 (90°)', '近端 (180°)', '远端 (270°)'});
%     
%     % 子图3：耦合角变化
%     subplot(1, 3, 3);
% 
%     sgtitle('关节协调分析', 'FontWeight', 'bold');
% 
% end