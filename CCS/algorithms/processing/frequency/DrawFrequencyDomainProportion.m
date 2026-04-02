function [] = DrawFrequencyDomainProportion(cellSegs_patient, cellSegs_control, fs_inter, type_com)
if nargin<4, type_com = 'com'; end

table_com_frequency_patient = zeros(length(cellSegs_patient),12);
% 患者组
for idx_seg = 1:length(cellSegs_patient)
    seg = cellSegs_patient{idx_seg};
    com.x = seg.(type_com).x;
    com.y = seg.(type_com).y;
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
    table_com_frequency_patient(idx_seg,:) = [x_05Hz, x_05Hz_2Hz, x_2Hz, ...
                                      y_05Hz, y_05Hz_2Hz, y_2Hz, ...
                                      z_05Hz, z_05Hz_2Hz, z_2Hz, ...
                                      sum_05Hz, sum_05Hz_2Hz, sum_2Hz];
end
table_com_frequency_patient = array2table(table_com_frequency_patient, 'VariableNames', ...
    {'x_05Hz','x_05Hz_2Hz','x_2Hz','y_05Hz','y_05Hz_2Hz','y_2Hz',...
    'z_05Hz','z_05Hz_2Hz','z_2Hz','sum_05Hz','sum_05Hz_2Hz','sum_2Hz'});
    
table_com_frequency_control = zeros(length(cellSegs_control),12);
% 对照组
for idx_seg = 1:length(cellSegs_control)
    seg = cellSegs_control{idx_seg};
    com.x = seg.(type_com).x;
    com.y = seg.(type_com).y;
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

% 统计分析
% 统计分析
% 比较患者组和对照组间不同频域占比的差异，并作箱型图展示

% 频域变量名
freq_var_names = {'x_05Hz','x_05Hz_2Hz','x_2Hz','y_05Hz','y_05Hz_2Hz','y_2Hz',...
    'z_05Hz','z_05Hz_2Hz','z_2Hz','sum_05Hz','sum_05Hz_2Hz','sum_2Hz'};

% 统计检验和可视化
p_values = zeros(1, numel(freq_var_names));
figure('Name','Comparison of Frequency Domain Energy Proportion (Patient Group vs Control Group)',...
    'Position',[100 100 1600 800]);
for i = 1:numel(freq_var_names)
    data_patient = table_com_frequency_patient.(freq_var_names{i});
    data_control = table_com_frequency_control.(freq_var_names{i});
    % 正态性检验
    if length(data_patient) > 3 && length(data_control) > 3
        [h1,~] = kstest((data_patient-mean(data_patient))/std(data_patient));
        [h2,~] = kstest((data_control-mean(data_control))/std(data_control));
    else
        h1 = 1; h2 = 1; % 样本太小，直接用非参数
    end
    % 组间检验
    if h1==0 && h2==0
        [~,p] = ttest2(data_patient, data_control);
        test_name = 't-test';
    else
        p = ranksum(data_patient, data_control);
        test_name = 'ranksum';
    end
    p_values(i) = p;

    % 箱型图
    subplot(2,6,i);
    boxplot([data_patient; data_control], ...
        [repmat({'Patient'},length(data_patient),1); repmat({'Control'},length(data_control),1)]);
    ylabel('Proportion');
    
    % 添加显著性标记
    if p < 0.01
        sig_mark = '***';
    elseif p < 0.05
        sig_mark = '**';
    elseif p < 0.1
        sig_mark = '*';
    else
        sig_mark = 'ns';
    end
    
    % 处理标题中的下划线，避免下标显示问题
    title_str = strrep(freq_var_names{i}, '_', '-');
    title({title_str, sprintf('p=%.3f (%s) %s', p, test_name, sig_mark)}, 'FontSize', 10);
    grid on;
    
    % 调整子图间距，避免标题与y轴标签重叠
    ax = gca;
    ax.TitleHorizontalAlignment = 'left';
    ax.TitleFontSizeMultiplier = 0.9;
    
    % 如果y轴有科学计数法标记，调整标题位置
    if contains(ax.YLabel.String, '×10')
        ax.Title.Position(2) = ax.Title.Position(2) * 1.1; % 向上移动标题
    end
end

% 保存图片
set(gcf, 'Position', [100, 100, 1600, 600]); % 设置图片大小
saveas(gcf, 'outputs/CoM_FrequencyDomainProportion.png');