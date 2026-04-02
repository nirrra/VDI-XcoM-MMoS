%% 绘制肌肉激活对比图
figure('Position', [50, 50, 1600, 1000]);
sgtitle('前12块肌肉激活对比 (Matlab vs OpenSim)', 'FontSize', 16, 'FontWeight', 'bold');

for i = 1:12
    subplot(3, 4, i);
    
    name_muscle = left_muscle_names{i};
    
    % 获取数据
    a_matlab = muscle_activations.(name_muscle);
    a_opensim = ma_v.(name_muscle);
    
    % 绘制曲线
    plot(time_matlab, a_matlab, 'b-', 'LineWidth', 2, 'DisplayName', 'Matlab');
    hold on;
%     plot(time_opensim, a_opensim, 'r-', 'LineWidth', 2, 'DisplayName', 'OpenSim');
    
    title(name_muscle, 'FontSize', 10, 'Interpreter', 'none');
    xlabel('Time (s)', 'FontSize', 8);
    ylabel('Activation', 'FontSize', 8);
    
    % 设置图例
    if i == 1
        legend('Location', 'best', 'FontSize', 8);
    end
    
    % 设置网格
    grid on;
    
    % 设置坐标轴范围
    xlim([min(time_matlab), max(time_matlab)]);
    ylim([0, 1]); % 激活度范围0-1
    
    hold off;
end
