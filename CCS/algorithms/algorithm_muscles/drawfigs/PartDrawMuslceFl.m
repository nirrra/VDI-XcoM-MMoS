%% 绘制肌肉fl值（张力-长度关系）变化曲线
figure('Position', [50, 50, 1600, 1000]);
sgtitle('前12块肌肉fl值（张力-长度关系）变化曲线', 'FontSize', 16, 'FontWeight', 'bold');

for i = 1:12
    subplot(3, 4, i);
    
    name_muscle = left_muscle_names{i};
    
    % 获取数据
    fl_value = f_ls.(name_muscle);
    
    % 绘制曲线
    plot(time_matlab, fl_value, 'b-', 'LineWidth', 2);
    
    title([name_muscle, ' f_l'], 'FontSize', 10, 'Interpreter', 'none');
    xlabel('Time (s)', 'FontSize', 8);
    ylabel('f_l (normalized)', 'FontSize', 8);
    
    % 设置网格
    grid on;
    
    % 设置坐标轴范围
    xlim([min(time_matlab), max(time_matlab)]);
%     ylim([0, 1.2]); % fl值通常在0-1.2范围内
end 