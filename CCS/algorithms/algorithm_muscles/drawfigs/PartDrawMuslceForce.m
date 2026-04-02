%% 绘制肌肉力对比图
figure('Position', [50, 50, 1600, 1000]);
sgtitle('前12块肌肉力对比 (Matlab vs OpenSim)', 'FontSize', 16, 'FontWeight', 'bold');

for i = 1:12
    subplot(3, 4, i);
    
    name_muscle = left_muscle_names{i};
    
    % 获取数据
    f_matlab = muscle_forces.(name_muscle);
    f_opensim = mf_v.(name_muscle);
    
    % 绘制曲线
    plot(time_matlab, f_matlab, 'b-', 'LineWidth', 2, 'DisplayName', 'Matlab');
    hold on;
    plot(time_opensim, f_opensim, 'r-', 'LineWidth', 2, 'DisplayName', 'OpenSim');
    
    title(name_muscle, 'FontSize', 10, 'Interpreter', 'none');
    xlabel('Time (s)', 'FontSize', 8);
    ylabel('Force (N)', 'FontSize', 8);
    
    % 设置图例
    if i == 1
        legend('Location', 'best', 'FontSize', 8);
    end
    
    % 设置网格
    grid on;
    
    % 设置坐标轴范围
    xlim([min(time_matlab), max(time_matlab)]);
    
    % 计算y轴范围
    max_force = max([max(f_matlab), max(f_opensim)]);
    if max_force > 0
        ylim([0, max_force * 1.1]);
    end
    
    hold off;
end 