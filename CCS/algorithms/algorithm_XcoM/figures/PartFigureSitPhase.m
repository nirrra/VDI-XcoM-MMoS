figure; 
set(gcf, 'position', [100, 100, 1280, 720], 'color', 'w');

subplot(2,1,1); hold on; grid on;
set(gca, 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
plot(times.hip,sum(sum(pressureHip2D,2),3)./10000,'Color', colors(1,:), 'LineWidth', 2.5);
plot(times.union,streamInter.PELVIS.z,'Color', colors(2,:), 'LineWidth', 2.5);
xline(single_start_times, 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(single_end_times, 'Color', line_colors(2,:), 'LineWidth', 1.5, 'Alpha', 0.7);
hold off; title('臀底无接触段');
legend('臀底压力','PELVIS高度');
subplot(2,1,2); grid on;
set(gca, 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
histogram(streamInter.PELVIS.z(idx_segment_both),'EdgeColor',colors(1,:),'FaceColor',colors(2,:));
title('静坐段骨盆高度分布');
sgtitle('图.4 臀底无接触段');