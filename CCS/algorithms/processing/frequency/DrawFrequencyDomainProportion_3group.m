function [] = DrawFrequencyDomainProportion_3group(cellSegs_before, cellSegs_after, cellSegs_control, fs_inter)

% 计算治疗前组频域占比
table_com_frequency_before = zeros(length(cellSegs_before),12);
for idx_seg = 1:length(cellSegs_before)
    seg = cellSegs_before{idx_seg};
    com.x = seg.com.x;
    com.y = seg.com.y;
    com.z = seg.com.z;
    com.sum = (com.x.^2+com.y.^2+com.z.^2).^0.5;
    x_05Hz = FrequencyDomainProportion(com.x,fs_inter,0,0.5);
    x_05Hz_2Hz = FrequencyDomainProportion(com.x,fs_inter,0.5,2);
    x_2Hz = FrequencyDomainProportion(com.x,fs_inter,2,fs_inter/2);
    y_05Hz = FrequencyDomainProportion(com.y,fs_inter,0,0.5);
    y_05Hz_2Hz = FrequencyDomainProportion(com.y,fs_inter,0.5,2);
    y_2Hz = FrequencyDomainProportion(com.y,fs_inter,2,fs_inter/2);
    z_05Hz = FrequencyDomainProportion(com.z,fs_inter,0,0.5);
    z_05Hz_2Hz = FrequencyDomainProportion(com.z,fs_inter,0.5,2);
    z_2Hz = FrequencyDomainProportion(com.z,fs_inter,2,fs_inter/2);
    sum_05Hz = FrequencyDomainProportion(com.sum,fs_inter,0,0.5);
    sum_05Hz_2Hz = FrequencyDomainProportion(com.sum,fs_inter,0.5,2);
    sum_2Hz = FrequencyDomainProportion(com.sum,fs_inter,2,fs_inter/2);
    table_com_frequency_before(idx_seg,:) = [x_05Hz, x_05Hz_2Hz, x_2Hz, ...
                                      y_05Hz, y_05Hz_2Hz, y_2Hz, ...
                                      z_05Hz, z_05Hz_2Hz, z_2Hz, ...
                                      sum_05Hz, sum_05Hz_2Hz, sum_2Hz];
end
table_com_frequency_before = array2table(table_com_frequency_before, 'VariableNames', ...
    {'x_05Hz','x_05Hz_2Hz','x_2Hz','y_05Hz','y_05Hz_2Hz','y_2Hz',...
    'z_05Hz','z_05Hz_2Hz','z_2Hz','sum_05Hz','sum_05Hz_2Hz','sum_2Hz'});

% 计算治疗后组频域占比    
table_com_frequency_after = zeros(length(cellSegs_after),12);
for idx_seg = 1:length(cellSegs_after)
    seg = cellSegs_after{idx_seg};
    com.x = seg.com.x;
    com.y = seg.com.y;
    com.z = seg.com.z;
    com.sum = (com.x.^2+com.y.^2+com.z.^2).^0.5;
    x_05Hz = FrequencyDomainProportion(com.x,fs_inter,0,0.5);
    x_05Hz_2Hz = FrequencyDomainProportion(com.x,fs_inter,0.5,2);
    x_2Hz = FrequencyDomainProportion(com.x,fs_inter,2,fs_inter/2);
    y_05Hz = FrequencyDomainProportion(com.y,fs_inter,0,0.5);
    y_05Hz_2Hz = FrequencyDomainProportion(com.y,fs_inter,0.5,2);
    y_2Hz = FrequencyDomainProportion(com.y,fs_inter,2,fs_inter/2);
    z_05Hz = FrequencyDomainProportion(com.z,fs_inter,0,0.5);
    z_05Hz_2Hz = FrequencyDomainProportion(com.z,fs_inter,0.5,2);
    z_2Hz = FrequencyDomainProportion(com.z,fs_inter,2,fs_inter/2);
    sum_05Hz = FrequencyDomainProportion(com.sum,fs_inter,0,0.5);
    sum_05Hz_2Hz = FrequencyDomainProportion(com.sum,fs_inter,0.5,2);
    sum_2Hz = FrequencyDomainProportion(com.sum,fs_inter,2,fs_inter/2);
    table_com_frequency_after(idx_seg,:) = [x_05Hz, x_05Hz_2Hz, x_2Hz, ...
                                      y_05Hz, y_05Hz_2Hz, y_2Hz, ...
                                      z_05Hz, z_05Hz_2Hz, z_2Hz, ...
                                      sum_05Hz, sum_05Hz_2Hz, sum_2Hz];
end
table_com_frequency_after = array2table(table_com_frequency_after, 'VariableNames', ...
    {'x_05Hz','x_05Hz_2Hz','x_2Hz','y_05Hz','y_05Hz_2Hz','y_2Hz',...
    'z_05Hz','z_05Hz_2Hz','z_2Hz','sum_05Hz','sum_05Hz_2Hz','sum_2Hz'});

% 计算对照组频域占比
table_com_frequency_control = zeros(length(cellSegs_control),12);
for idx_seg = 1:length(cellSegs_control)
    seg = cellSegs_control{idx_seg};
    com.x = seg.com.x;
    com.y = seg.com.y;
    com.z = seg.com.z;
    com.sum = (com.x.^2+com.y.^2+com.z.^2).^0.5;
    x_05Hz = FrequencyDomainProportion(com.x,fs_inter,0,0.5);
    x_05Hz_2Hz = FrequencyDomainProportion(com.x,fs_inter,0.5,2);
    x_2Hz = FrequencyDomainProportion(com.x,fs_inter,2,fs_inter/2);
    y_05Hz = FrequencyDomainProportion(com.y,fs_inter,0,0.5);
    y_05Hz_2Hz = FrequencyDomainProportion(com.y,fs_inter,0.5,2);
    y_2Hz = FrequencyDomainProportion(com.y,fs_inter,2,fs_inter/2);
    z_05Hz = FrequencyDomainProportion(com.z,fs_inter,0,0.5);
    z_05Hz_2Hz = FrequencyDomainProportion(com.z,fs_inter,0.5,2);
    z_2Hz = FrequencyDomainProportion(com.z,fs_inter,2,fs_inter/2);
    sum_05Hz = FrequencyDomainProportion(com.sum,fs_inter,0,0.5);
    sum_05Hz_2Hz = FrequencyDomainProportion(com.sum,fs_inter,0.5,2);
    sum_2Hz = FrequencyDomainProportion(com.sum,fs_inter,2,fs_inter/2);
    table_com_frequency_control(idx_seg,:) = [x_05Hz, x_05Hz_2Hz, x_2Hz, ...
                                      y_05Hz, y_05Hz_2Hz, y_2Hz, ...
                                      z_05Hz, z_05Hz_2Hz, z_2Hz, ...
                                      sum_05Hz, sum_05Hz_2Hz, sum_2Hz];
end
table_com_frequency_control = array2table(table_com_frequency_control, 'VariableNames', ...
    {'x_05Hz','x_05Hz_2Hz','x_2Hz','y_05Hz','y_05Hz_2Hz','y_2Hz',...
    'z_05Hz','z_05Hz_2Hz','z_2Hz','sum_05Hz','sum_05Hz_2Hz','sum_2Hz'});

% 频域变量名
freq_var_names = {'x_05Hz','x_05Hz_2Hz','x_2Hz','y_05Hz','y_05Hz_2Hz','y_2Hz',...
    'z_05Hz','z_05Hz_2Hz','z_2Hz','sum_05Hz','sum_05Hz_2Hz','sum_2Hz'};

% 创建图形
figure('Name','频域能量占比对比（三组对比）','Position',[100 100 1600 800]);

% 统计检验结果存储
p_values_BA = zeros(1, numel(freq_var_names));  % Before vs After
p_values_BC = zeros(1, numel(freq_var_names));  % Before vs Control  
p_values_AC = zeros(1, numel(freq_var_names));  % After vs Control

% 绘制每个频域变量的箱型图
row2_y_position = 0;  % 初始化第二行基准位置
for i = 1:numel(freq_var_names)
    subplot(2, 6, i);
    
    % 调整子图位置，确保行间高度统一
    pos = get(gca, 'Position');
    if i <= 6  % 第一行子图
        pos(2) = pos(2) - 0.05;  % 向下移动，避免与总标题重叠
    else  % 第二行子图 (i = 7-12)
        % 确保第二行所有子图使用相同的垂直位置
        if i == 7
            % 记录第二行第一个子图的位置作为基准
            row2_y_position = pos(2);
        else
            % 其他第二行子图使用相同的垂直位置
            pos(2) = row2_y_position;
        end
    end
    set(gca, 'Position', pos);
    
    var_name = freq_var_names{i};
    
    % 获取三组数据
    data_before = table_com_frequency_before.(var_name);
    data_after = table_com_frequency_after.(var_name);
    data_control = table_com_frequency_control.(var_name);
    
    % 移除NaN值
    data_before = data_before(~isnan(data_before));
    data_after = data_after(~isnan(data_after));
    data_control = data_control(~isnan(data_control));
    
    % 统计检验
    if ~isempty(data_before) && ~isempty(data_after)
        [p_BA, ~] = ranksum(data_before, data_after);
        p_values_BA(i) = p_BA;
    else
        p_values_BA(i) = NaN;
    end
    
    if ~isempty(data_before) && ~isempty(data_control)
        [p_BC, ~] = ranksum(data_before, data_control);
        p_values_BC(i) = p_BC;
    else
        p_values_BC(i) = NaN;
    end
    
    if ~isempty(data_after) && ~isempty(data_control)
        [p_AC, ~] = ranksum(data_after, data_control);
        p_values_AC(i) = p_AC;
    else
        p_values_AC(i) = NaN;
    end
    
    % 准备箱型图数据
    all_data = [];
    group_labels = [];
    
    if ~isempty(data_before)
        all_data = [all_data; data_before];
        group_labels = [group_labels; ones(length(data_before), 1)];
    end
    
    if ~isempty(data_after)
        all_data = [all_data; data_after];
        group_labels = [group_labels; 2*ones(length(data_after), 1)];
    end
    
    if ~isempty(data_control)
        all_data = [all_data; data_control];
        group_labels = [group_labels; 3*ones(length(data_control), 1)];
    end
    
    % 绘制箱型图
    if ~isempty(all_data)
        boxplot(all_data, group_labels, 'Labels', {'Before', 'After', 'Control'});
        
        % 设置颜色
        h = findobj(gca,'Tag','Box');
        colors = [0.8 0.2 0.2; 0.2 0.8 0.2; 0.2 0.2 0.8]; % 红、绿、蓝
        for j = 1:length(h)
            patch(get(h(j),'XData'), get(h(j),'YData'), colors(4-j,:), 'FaceAlpha', 0.7);
        end
    end
    
    % 添加显著性标记到标题中
    % 处理标题中的下划线，避免下标显示问题
    title_str = strrep(freq_var_names{i}, '_', '-');
    
    % 构建显著性标记字符串，分为三行显示
    sig_lines = {};
    
    % pBA (Before vs After)
    if ~isnan(p_values_BA(i))
        if p_values_BA(i) < 0.001
            sig_BA = '***';
        elseif p_values_BA(i) < 0.01
            sig_BA = '**';
        elseif p_values_BA(i) < 0.05
            sig_BA = '*';
        else
            sig_BA = 'ns';
        end
        sig_lines{end+1} = sprintf('pBA=%.3f(%s)', p_values_BA(i), sig_BA);
    end
    
    % pBC (Before vs Control)
    if ~isnan(p_values_BC(i))
        if p_values_BC(i) < 0.001
            sig_BC = '***';
        elseif p_values_BC(i) < 0.01
            sig_BC = '**';
        elseif p_values_BC(i) < 0.05
            sig_BC = '*';
        else
            sig_BC = 'ns';
        end
        sig_lines{end+1} = sprintf('pBC=%.3f(%s)', p_values_BC(i), sig_BC);
    end
    
    % pAC (After vs Control)
    if ~isnan(p_values_AC(i))
        if p_values_AC(i) < 0.001
            sig_AC = '***';
        elseif p_values_AC(i) < 0.01
            sig_AC = '**';
        elseif p_values_AC(i) < 0.05
            sig_AC = '*';
        else
            sig_AC = 'ns';
        end
        sig_lines{end+1} = sprintf('pAC=%.3f(%s)', p_values_AC(i), sig_AC);
    end
    
    % 设置标题，包含变量名和显著性信息（分多行显示）
    if ~isempty(sig_lines)
        title_cell = [{title_str}, sig_lines];
        title(title_cell, 'FontSize', 9);
    else
        title(title_str, 'FontSize', 9);
    end
    
    ylabel('能量占比', 'FontSize', 9);
    xlabel('Group', 'FontSize', 9);
    
    % 设置网格和样式
    grid on;
    set(gca, 'FontSize', 9);
end

% 设置整体标题
sgtitle('CoM Frequency Domain Proportion Comparison (Before vs After vs Control)', 'FontSize', 14, 'FontWeight', 'bold');

% 显示统计结果
fprintf('\n=== 频域占比统计分析结果 ===\n');
fprintf('变量名\t\t\tBefore vs After\tBefore vs Control\tAfter vs Control\n');
fprintf('--------------------------------------------------------------------\n');
for i = 1:length(freq_var_names)
    fprintf('%-15s\t%.4f\t\t%.4f\t\t\t%.4f\n', freq_var_names{i}, ...
        p_values_BA(i), p_values_BC(i), p_values_AC(i));
end
fprintf('--------------------------------------------------------------------\n');
fprintf('显著性水平: * p<0.05, ** p<0.01, *** p<0.001\n\n');

% 保存图片
set(gcf, 'Position', [100, 100, 1600, 800]);
saveas(gcf, 'outputs/images_after_treatment/CoM_FrequencyDomainProportion_3group.png');

end




























