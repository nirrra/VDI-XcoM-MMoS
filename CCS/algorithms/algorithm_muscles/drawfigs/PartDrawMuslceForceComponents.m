%% 绘制肌肉力分量对比图（总力、CE力、PE力）
figure('Position', [50, 50, 1600, 1000]);
sgtitle('前12块肌肉力分量对比 (总力 vs CE力 vs PE力)', 'FontSize', 16, 'FontWeight', 'bold');

for i = 1:12
    subplot(3, 4, i);
    
    name_muscle = left_muscle_names{i};
    
    % 获取数据
    f_total = muscle_forces.(name_muscle);
    f_ce = muscle_forces_ce.(name_muscle);
    f_pe = muscle_forces_pe.(name_muscle);
    
    % 绘制曲线
    plot(time_matlab, f_total, 'b-', 'LineWidth', 2, 'DisplayName', '总力');
    hold on;
    plot(time_matlab, f_ce, 'g-', 'LineWidth', 2, 'DisplayName', 'CE力');
    plot(time_matlab, f_pe, 'm-', 'LineWidth', 2, 'DisplayName', 'PE力');
    
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
    max_force = max([max(f_total), max(f_ce), max(f_pe)]);
    if max_force > 0
        ylim([0, max_force * 1.1]);
    end
    
    hold off;
end 