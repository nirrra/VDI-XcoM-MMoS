%% 绘制肌肉fpe值（被动张力-长度关系）变化曲线
figure('Position', [50, 50, 1600, 1000]);
sgtitle('前12块肌肉fpe值（被动张力-长度关系）变化曲线', 'FontSize', 16, 'FontWeight', 'bold');

for i = 1:12
    subplot(3, 4, i);
    
    name_muscle = left_muscle_names{i};
    
    % 获取数据
    fpe_value = f_pes.(name_muscle);
    
    % 绘制曲线
    plot(time_matlab, fpe_value, 'b-', 'LineWidth', 2);
    
    title([name_muscle, ' f_{pe}'], 'FontSize', 10, 'Interpreter', 'none');
    xlabel('Time (s)', 'FontSize', 8);
    ylabel('f_{pe} (normalized)', 'FontSize', 8);
    
    % 设置网格
    grid on;
    
    % 设置坐标轴范围
    xlim([min(time_matlab), max(time_matlab)]);
    
    % 计算y轴范围
    max_fpe = max(fpe_value);
    if max_fpe > 0
        ylim([0, max_fpe * 1.1]);
    else
        ylim([0, 0.1]);
    end
end 