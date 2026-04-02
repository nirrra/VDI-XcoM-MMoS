%% 创建专业布局图形
figure;
set(gcf, 'position', [100, 100, 900, 700], 'color', 'w');

% 上部左右并列的子图 (使用更精确的subplot定位)
ax1 = subplot(3,4,[1 2 5 6]); % 左图 3行4列中占据左上4格
hold on; grid on;
set(gca, 'FontSize', 10, 'GridAlpha', 0.2, ...
         'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], 'Box', 'off');
plot(copPlantar.x(seg_plantar), copPlantar.y(seg_plantar), ...
     'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'COP轨迹');
scatter(copPlantar.x(seg_plantar(1)), copPlantar.y(seg_plantar(1)), 80, ...
        'MarkerEdgeColor', colors(1,:), 'MarkerFaceColor', 'w', 'LineWidth', 1.5);
scatter(copPlantar.x(seg_plantar(end)), copPlantar.y(seg_plantar(end)), 80, ...
        'MarkerEdgeColor', colors(1,:), 'MarkerFaceColor', colors(1,:), 'LineWidth', 1.5);
title('足底压力中心(COP)轨迹', 'FontWeight', 'normal', 'FontSize', 11);
axis equal; 
% legend('Location', 'northeast');

% 右图
ax2 = subplot(3,4,[3 4 7 8]); % 右图 3行4列中占据右上4格
hold on; grid on;
set(gca, 'FontSize', 10, 'GridAlpha', 0.2, ...
         'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], 'Box', 'off');
plot(posCOMSegments.Trunk.x(seg_union), posCOMSegments.Trunk.y(seg_union), ...
     'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'COM轨迹');
scatter(posCOMSegments.Trunk.x(seg_union(1)), posCOMSegments.Trunk.y(seg_union(1)), 80, ...
        'MarkerEdgeColor', colors(2,:), 'MarkerFaceColor', 'w', 'LineWidth', 1.5);
scatter(posCOMSegments.Trunk.x(seg_union(end)), posCOMSegments.Trunk.y(seg_union(end)), 80, ...
        'MarkerEdgeColor', colors(2,:), 'MarkerFaceColor', colors(2,:), 'LineWidth', 1.5);
title('身体质心(COM)轨迹', 'FontWeight', 'normal', 'FontSize', 11);
axis equal;
% legend('Location', 'northeast');

% 下部全宽的时间序列图 (占据最下面两行)
ax3 = subplot(3,1,3); % 单独一行
hold on; grid on;
set(gca, 'FontSize', 10, 'GridAlpha', 0.2, ...
         'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], 'Box', 'off');
p1 = plot(times.plantar, copPlantar.y, ...
          'Color', colors(1,:), 'LineWidth', 2.5, 'DisplayName', 'COP竖直位置');
p2 = plot(times.union, posCOMSegments.Trunk.y, ...
          'Color', colors(2,:), 'LineWidth', 2.5, 'DisplayName', 'COM竖直位置');
xlabel('时间 (s)', 'FontSize', 10);
ylabel('竖直位置 (mm)', 'FontSize', 10);
legend([p1, p2], 'Location', 'northeast', 'FontSize', 9);

% 手动调整子图位置 (归一化坐标)
set(ax1, 'Position', [0.08 0.56 0.40 0.30]); % [left bottom width height]
set(ax2, 'Position', [0.56 0.56 0.40 0.30]);
set(ax3, 'Position', [0.10 0.10 0.85 0.40]);

% 添加总标题
sgtitle('图3. 压力中心(COP)与身体质心(COM)对比分析', ...
        'FontSize', 14, 'FontWeight', 'bold', 'Color', [.2 .2 .2]);