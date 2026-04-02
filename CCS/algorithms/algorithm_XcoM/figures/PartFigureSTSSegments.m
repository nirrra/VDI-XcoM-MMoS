f = figure; 
hold on; grid on;
set(gca, 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
p1 = plot(times.union,jointAngles.ankleAngleL,'Color', colors(1,:), 'LineWidth', 1.5, 'DisplayName', 'Left Ankle');
p2 = plot(times.union,jointAngles.ankleAngleR,'Color', colors(1,:), 'LineWidth', 1.5,'LineStyle','--', 'DisplayName', 'Right Ankle');
p3 = plot(times.union,jointAngles.hipFlexionL,'Color', colors(2,:), 'LineWidth', 1.5, 'DisplayName', 'Left Hip');
p4 = plot(times.union,jointAngles.hipFlexionR,'Color', colors(2,:), 'LineWidth', 1.5,'LineStyle','--', 'DisplayName', 'Left Hip');
p5 = plot(times.union,ScaleData(streamInter.PELVIS.z,jointAngles.ankleAngleL),'Color', colors(3,:), 'LineWidth', 1.5, 'DisplayName', 'Pelvis Height');
plot(times.union,ScaleData(streamInter.HIP_LEFT.z,jointAngles.ankleAngleL),'Color', colors(3,:), 'LineWidth', 1);
plot(times.union,ScaleData(streamInter.HIP_RIGHT.z,jointAngles.ankleAngleL),'Color', colors(3,:), 'LineWidth', 1);
p6 = plot(times.union,ScaleData(sum(sum(pressureHip2DInter,2),3)./100,jointAngles.ankleAngleL),'Color', colors(4,:), 'LineWidth', 1.5, 'DisplayName', 'Buttock Pressure');

xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1, 'Alpha', 0.7);

aux = ScaleData(streamInter.HIP_LEFT.z,jointAngles.ankleAngleL);
plot(times.union(sts_segments.idx_p1),aux(sts_segments.idx_p1),'Color', colors(3,:),...
    'LineStyle', 'none', 'Marker','o', 'MarkerFaceColor', colors(3,:), 'MarkerSize', 8);
plot(times.union(sts_segments.idx_p3),jointAngles.ankleAngleL(sts_segments.idx_p3),'Color', colors(1,:),...
    'LineStyle', 'none', 'Marker','o', 'MarkerFaceColor', colors(1,:), 'MarkerSize', 8);
plot(times.union(sts_segments.idx_p4),jointAngles.hipFlexionL(sts_segments.idx_p4),'Color', colors(2,:),...
    'LineStyle', 'none', 'Marker','o', 'MarkerFaceColor', colors(2,:), 'MarkerSize', 8);
aux = ScaleData(sum(sum(pressureHip2DInter,2),3)./100,jointAngles.ankleAngleL);
plot(times.union(sts_segments.idx_p2),aux(sts_segments.idx_p2),'Color', colors(4,:),...
    'LineStyle', 'none', 'Marker','o', 'MarkerFaceColor', colors(4,:), 'MarkerSize', 8);

hold off; 
legend([p1, p2, p3, p4, p5, p6], 'Location', 'eastoutside', 'FontSize', 9);
title('图.6 站起分期（开始→臀部离开坐垫→踝关节角最小→髋关节角最大）', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlim([0,times.union(end)]);
set(gcf,'position',[100,100,1280,720]);

print(f, ['./outputs/images segments/',filename,'_jas.png'],'-dpng','-r300');
