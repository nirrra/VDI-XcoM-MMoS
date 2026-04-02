%% 绘制归一化纤维速度变化曲线
figure('Position', [50, 50, 1600, 1000]);
sgtitle('前12块肌肉归一化纤维速度变化曲线', 'FontSize', 16, 'FontWeight', 'bold');

for i = 1:12
    subplot(3, 4, i);
    
    name_muscle = left_muscle_names{i};
    
    % 获取数据
    normal_velocity = normal_fiber_velocities.(name_muscle);
    
    % 绘制曲线
    plot(time_matlab, normal_velocity, 'b-', 'LineWidth', 2);
    
    title([name_muscle, ' Normalized Velocity'], 'FontSize', 10, 'Interpreter', 'none');
    xlabel('Time (s)', 'FontSize', 8);
    ylabel('Normalized Velocity', 'FontSize', 8);
    
    % 设置网格
    grid on;
    
    % 设置坐标轴范围
    xlim([min(time_matlab), max(time_matlab)]);
    
    % 计算y轴范围
    min_velocity = min(normal_velocity);
    max_velocity = max(normal_velocity);
    y_range = max_velocity - min_velocity;
    ylim([min_velocity - 0.1*y_range, max_velocity + 0.1*y_range]);
    
    % 添加参考线（零速度）
    hold on;
    yline(0, '--', 'Zero Velocity', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
    hold off;
end 