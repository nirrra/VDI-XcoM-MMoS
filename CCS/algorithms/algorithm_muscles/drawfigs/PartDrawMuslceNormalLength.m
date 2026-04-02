%% 绘制归一化纤维长度变化曲线
figure('Position', [50, 50, 1600, 1000]);
sgtitle('前12块肌肉归一化纤维长度变化曲线', 'FontSize', 16, 'FontWeight', 'bold');

for i = 1:12
    subplot(3, 4, i);
    
    name_muscle = left_muscle_names{i};
    
    % 获取数据
    normal_length = normal_fiber_lengths.(name_muscle);
    
    % 绘制曲线
    plot(time_matlab, normal_length, 'b-', 'LineWidth', 2);
    
    title([name_muscle, ' Normalized Length'], 'FontSize', 10, 'Interpreter', 'none');
    xlabel('Time (s)', 'FontSize', 8);
    ylabel('Normalized Length', 'FontSize', 8);
    
    % 设置网格
    grid on;
    
    % 设置坐标轴范围
    xlim([min(time_matlab), max(time_matlab)]);
    
    % 计算y轴范围
    min_length = min(normal_length);
    max_length = max(normal_length);
    ylim([min_length * 0.9, max_length * 1.1]);
    
    % 添加参考线（最优长度 = 1.0）
    hold on;
    yline(1.0, '--', 'Optimal Length', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
    hold off;
end 