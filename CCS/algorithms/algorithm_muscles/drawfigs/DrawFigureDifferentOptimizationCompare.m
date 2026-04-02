%% 绘制肌肉激活对比图

% 创建英文肌肉名称到中文名称的映射
muscle_name_map = containers.Map();
muscle_name_map('hamstrings_l') = '腘绳肌';
muscle_name_map('bifemsh_l') = '股二头肌短头';
muscle_name_map('glut_max_l') = '臀大肌';
muscle_name_map('iliopsoas_l') = '髂腰肌';
muscle_name_map('rect_fem_l') = '股直肌';
muscle_name_map('vasti_l') = '股外侧肌';
muscle_name_map('gastroc_l') = '腓肠肌';
muscle_name_map('soleus_l') = '比目鱼肌';
muscle_name_map('tib_ant_l') = '胫骨前肌';
muscle_name_map('ercspn_l') = '竖脊肌';
muscle_name_map('intobl_l') = '腹内斜肌';
muscle_name_map('extobl_l') = '腹外斜肌';

figure('Position', [50, 50, 1600, 1000]);
% sgtitle('前12块肌肉激活对比 (Matlab vs OpenSim)', 'FontSize', 16, 'FontWeight', 'bold');

for i = 1:12
    subplot(3, 4, i);
    
    name_muscle = left_muscle_names{i};
    
    % 获取数据
    a_matlab = muscle_activations.(name_muscle);
    b_matlab = muscle_activations2.(name_muscle);
%     a_opensim = ma_v.(name_muscle);
    
    % 绘制曲线
    plot(time_matlab, a_matlab, 'b-', 'LineWidth', 2, 'DisplayName', '无平滑项的优化');
    hold on;
    plot(time_matlab, b_matlab, 'r-', 'LineWidth', 2, 'DisplayName', '带平滑项的优化');
    
    % 使用中文标题
    if muscle_name_map.isKey(name_muscle)
        chinese_name = muscle_name_map(name_muscle);
    else
        chinese_name = name_muscle; % 如果没有找到对应的中文名称，使用原名称
    end
    
    title(chinese_name, 'FontSize', 18, 'FontName', 'SimHei');
    xlabel('时间 / 秒', 'FontSize', 16, 'FontName', 'SimHei');
    ylabel('肌肉激活', 'FontSize', 16, 'FontName', 'SimHei');
    
    % 设置图例
    if i == 1
        legend('Location', 'best', 'FontSize', 12, 'FontName', 'SimHei');
    end
    
    % 设置网格
    grid on;
    
    % 设置坐标轴范围
    xlim([min(time_matlab), max(time_matlab)]);
    ylim([0, 1]); % 激活度范围0-1
    
    % 设置坐标轴字体
    set(gca, 'FontSize', 14, 'FontName', 'SimHei');
    
    hold off;
end
