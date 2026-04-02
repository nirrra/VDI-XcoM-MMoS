function FigureMeanAndStd_compare_one_figure(cellSegs_patient, cellSegs_control, str_paras, colors, fig_options)
% FigureMeanAndStd_compare_one_figure - 在一个图中比较患者组和对照组的均值和标准差曲线
%
% 输入参数:
%   cellSegs_patient - 患者组数据cell数组
%   cellSegs_control - 对照组数据cell数组  
%   str_paras - 参数字符串数组
%   colors - 颜色数组
%   fig_options - 图形选项结构体
%
% 功能:
%   将原来分别显示在两个子图中的患者组和对照组数据合并到一个图中显示，
%   患者组和对照组的每个参数使用不同的线型和颜色进行区分

curves_patient = struct();
curves_patient.mean_curves = cell(length(str_paras),1); 
curves_patient.std_curves = cell(length(str_paras),1); 
curves_patient.time_curves = cell(length(str_paras),1); 
curves_patient.time_stage = [];
curves_control = curves_patient;

for i = 1:length(str_paras)
    str_para = str_paras{i};
    [curves_patient.mean_curves{i}, curves_patient.std_curves{i}, ...
        curves_patient.time_curves{i}, curves_patient.time_stage] = GetAverageCurves_All(cellSegs_patient, str_para);
    [curves_control.mean_curves{i}, curves_control.std_curves{i}, ...
        curves_control.time_curves{i}, curves_control.time_stage] = GetAverageCurves_All(cellSegs_control, str_para);
end

if nargin<5
    figure_name = [];
    for i = 1:length(str_paras)
        figure_name = [figure_name, str_paras{i}, '; '];
    end
    figure_name(end-1:end) = [];
    figure_name = strrep(figure_name,'seg.','');
    figure_name = upper(figure_name);

    legend_names = str_paras;
    for j = 1:length(legend_names)
        legend_names{j} = strrep(legend_names{j},'seg.','');
    end
    
    y_name = 'Signal Amplitude';
    group_names = {'Stroke','Control'};
    out_dir = './outputs/images_compare/';
    show_p2 = false;
    plot_bw = true;
else
    figure_name = fig_options.figure_name;
    legend_names = fig_options.legend_names;
    if isfield(fig_options, 'y_name')
        y_name = fig_options.y_name;
    else
        y_name = 'Signal Amplitude';
    end
    if isfield(fig_options, 'group_names')
        group_names = fig_options.group_names;
    else
        group_names = {'Stroke','Control'};
    end
    if isfield(fig_options, 'out_dir')
        out_dir = fig_options.out_dir;
    else
        out_dir = './outputs/images_compare/';
    end
    if isfield(fig_options, 'show_p2')
        show_p2 = fig_options.show_p2;
    else
        show_p2 = false;
    end
    if isfield(fig_options, 'plot_bw')
        plot_bw = fig_options.plot_bw;
    else
        plot_bw = true;
    end
end

time_p2 = zeros(2,1);
time_p2(1) = GetAverageTime_p2(cellSegs_patient);
time_p2(2) = GetAverageTime_p2(cellSegs_control);

% 定义线型样式：患者组使用实线，对照组使用虚线
% 每个参数使用不同的颜色，但保持患者组实线、对照组虚线的区分
if plot_bw
    % 黑白模式：使用不同灰度和线型
    patient_line_styles = {'-', '-', '-', '-', '-', '-'};  % 患者组：实线
    control_line_styles = {'--', '--', '--', '--', '--', '--'};  % 对照组：虚线
    patient_colors = {'k', [0.3 0.3 0.3], [0.6 0.6 0.6], 'k', [0.3 0.3 0.3], [0.6 0.6 0.6]}; 
    control_colors = {'k', [0.3 0.3 0.3], [0.6 0.6 0.6], 'k', [0.3 0.3 0.3], [0.6 0.6 0.6]};
else
    % 彩色模式：患者组实线，对照组虚线，颜色相同
    patient_line_styles = {'-', '-', '-', '-', '-', '-'};  % 患者组：实线
    control_line_styles = {'--', '--', '--', '--', '--', '--'};  % 对照组：虚线
end
line_widths = [2.5, 2.5, 2.5, 2.5, 2.5, 2.5];   % 线宽

% 创建单一图形
f = figure('Color', 'white', 'Position', [100, 100, 800, 600]);
hold on;

% 计算所有数据的时间范围和y轴范围
max_time_patient = -inf;
max_time_control = -inf;
all_y_min = [];
all_y_max = [];

for idxPara = 1:length(str_paras)
    t1 = curves_patient.time_curves{idxPara};
    t2 = curves_control.time_curves{idxPara};
    if ~isempty(t1)
        max_time_patient = max(max_time_patient, max(t1));
    end
    if ~isempty(t2)
        max_time_control = max(max_time_control, max(t2));
    end
    
    % 计算y轴范围
    if ~isempty(curves_patient.mean_curves{idxPara}) && ~isempty(curves_patient.std_curves{idxPara})
        patient_y_min = min(curves_patient.mean_curves{idxPara} - curves_patient.std_curves{idxPara});
        patient_y_max = max(curves_patient.mean_curves{idxPara} + curves_patient.std_curves{idxPara});
        all_y_min = [all_y_min, patient_y_min];
        all_y_max = [all_y_max, patient_y_max];
    end
    
    if ~isempty(curves_control.mean_curves{idxPara}) && ~isempty(curves_control.std_curves{idxPara})
        control_y_min = min(curves_control.mean_curves{idxPara} - curves_control.std_curves{idxPara});
        control_y_max = max(curves_control.mean_curves{idxPara} + curves_control.std_curves{idxPara});
        all_y_min = [all_y_min, control_y_min];
        all_y_max = [all_y_max, control_y_max];
    end
end

x_min = -0.2;
x_max = max(max_time_patient, max_time_control) + 0.2;

% 绘制阶段标记线（同时显示患者组和对照组的时间）
time_stage_patient = curves_patient.time_stage;
time_stage_control = curves_control.time_stage;
aux = {'right','right','right','left','left'};

% 绘制患者组的阶段标记线
for j = 1:length(time_stage_patient)
    if plot_bw
        xline(time_stage_patient(j), 'LineWidth', 1.5, 'LineStyle', '-.', ...
              'Color', [0.7 0.7 0.7], ...
              'Label', sprintf('P%.1f', time_stage_patient(j)), ...
              'LabelOrientation', 'horizontal', ...
              'LabelHorizontalAlignment', aux{j}, ...  
              'LabelVerticalAlignment', 'bottom');     
    else
        xline(time_stage_patient(j), 'LineWidth', 1.5, 'LineStyle', '-.', ...
              'Color', [0.80 0.40 0.40], ...
              'Label', sprintf('P%.1f', time_stage_patient(j)), ...
              'LabelOrientation', 'horizontal', ...
              'LabelHorizontalAlignment', aux{j}, ...  
              'LabelVerticalAlignment', 'bottom');     
    end
end

% 绘制对照组的阶段标记线
for j = 1:length(time_stage_control)
    if plot_bw
        xline(time_stage_control(j), 'LineWidth', 1.5, 'LineStyle', ':', ...
              'Color', [0.5 0.5 0.5], ...
              'Label', sprintf('C%.1f', time_stage_control(j)), ...
              'LabelOrientation', 'horizontal', ...
              'LabelHorizontalAlignment', aux{j}, ...  
              'LabelVerticalAlignment', 'top');     
    else
        xline(time_stage_control(j), 'LineWidth', 1.5, 'LineStyle', ':', ...
              'Color', [0.40 0.80 0.40], ...
              'Label', sprintf('C%.1f', time_stage_control(j)), ...
              'LabelOrientation', 'horizontal', ...
              'LabelHorizontalAlignment', aux{j}, ...  
              'LabelVerticalAlignment', 'top');     
    end
end

if show_p2
    % 绘制患者组的seat-off线
    if plot_bw
        xline(time_stage_patient(1)+time_p2(1), 'LineWidth', 2.0, 'LineStyle', '-', ...
              'Color', [0.2 0.2 0.2], ...
              'Label', sprintf('P-SO%.1f', time_stage_patient(1)+time_p2(1)), ...
              'LabelOrientation', 'horizontal', ...
              'LabelHorizontalAlignment', 'left', ...  
              'LabelVerticalAlignment', 'bottom');   
    else
        xline(time_stage_patient(1)+time_p2(1), 'LineWidth', 1.5, 'LineStyle', '-', ...
              'Color', [0.40 0.40 0.80], ...
              'Label', sprintf('P-SO%.1f', time_stage_patient(1)+time_p2(1)), ...
              'LabelOrientation', 'horizontal', ...
              'LabelHorizontalAlignment', 'left', ...  
              'LabelVerticalAlignment', 'bottom');   
    end
    
    % 绘制对照组的seat-off线
    if plot_bw
        xline(time_stage_control(1)+time_p2(2), 'LineWidth', 2.0, 'LineStyle', '--', ...
              'Color', [0.4 0.4 0.4], ...
              'Label', sprintf('C-SO%.1f', time_stage_control(1)+time_p2(2)), ...
              'LabelOrientation', 'horizontal', ...
              'LabelHorizontalAlignment', 'right', ...  
              'LabelVerticalAlignment', 'bottom');   
    else
        xline(time_stage_control(1)+time_p2(2), 'LineWidth', 1.5, 'LineStyle', '--', ...
              'Color', [0.80 0.40 0.80], ...
              'Label', sprintf('C-SO%.1f', time_stage_control(1)+time_p2(2)), ...
              'LabelOrientation', 'horizontal', ...
              'LabelHorizontalAlignment', 'right', ...  
              'LabelVerticalAlignment', 'bottom');   
    end
end

% 存储图例句柄
h_legend = [];
legend_labels = {};

% 绘制患者组数据
for idxPara = 1:length(str_paras)
    time = curves_patient.time_curves{idxPara};
    signal_mean = curves_patient.mean_curves{idxPara};
    signal_std = curves_patient.std_curves{idxPara};
    
    if isempty(time) || isempty(signal_mean) || isempty(signal_std)
        continue;
    end
    
    % 绘制标准差阴影
    if plot_bw
        gray_level = 0.8 + 0.05 * (idxPara-1);
        if gray_level > 0.95, gray_level = 0.95; end
        fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
            [gray_level gray_level gray_level], 'EdgeColor', 'none', 'FaceAlpha', 0.2);
    else
        fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
            colors(idxPara+1,:) * 0.7 + 0.3, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
    end
    
    % 绘制均值曲线
    if plot_bw
        h = plot(time, signal_mean, 'LineWidth', line_widths(idxPara), ...
                'Color', patient_colors{idxPara}, 'LineStyle', patient_line_styles{idxPara});
    else
        h = plot(time, signal_mean, 'LineWidth', line_widths(idxPara), ...
                'Color', colors(idxPara+1,:), 'LineStyle', patient_line_styles{idxPara});
    end
    
    h_legend = [h_legend, h];
    legend_labels{end+1} = [legend_names{idxPara}, ' (', group_names{1}, ')'];
end

% 绘制对照组数据
for idxPara = 1:length(str_paras)
    time = curves_control.time_curves{idxPara};
    signal_mean = curves_control.mean_curves{idxPara};
    signal_std = curves_control.std_curves{idxPara};
    
    if isempty(time) || isempty(signal_mean) || isempty(signal_std)
        continue;
    end
    
    % 绘制标准差阴影（透明度更低以避免与患者组重叠时过于混乱）
    if plot_bw
        gray_level = 0.8 + 0.05 * (idxPara-1);
        if gray_level > 0.95, gray_level = 0.95; end
        fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
            [gray_level gray_level gray_level], 'EdgeColor', 'none', 'FaceAlpha', 0.15);
    else
        fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
            colors(idxPara+1,:) * 0.7 + 0.3, 'EdgeColor', 'none', 'FaceAlpha', 0.15);
    end
    
    % 绘制均值曲线
    if plot_bw
        h = plot(time, signal_mean, 'LineWidth', line_widths(idxPara), ...
                'Color', control_colors{idxPara}, 'LineStyle', control_line_styles{idxPara});
    else
        h = plot(time, signal_mean, 'LineWidth', line_widths(idxPara), ...
                'Color', colors(idxPara+1,:), 'LineStyle', control_line_styles{idxPara});
    end
    
    h_legend = [h_legend, h];
    legend_labels{end+1} = [legend_names{idxPara}, ' (', group_names{2}, ')'];
end

% 设置坐标轴和标签
xlabel('Time / s', 'FontSize', 14, 'Interpreter', 'latex');
ylabel(y_name, 'FontSize', 14, 'Interpreter', 'latex');
xlim([x_min x_max]);

% 设置y轴范围
if ~isempty(all_y_min) && ~isempty(all_y_max)
    global_y_min = min(all_y_min) - 0.05 * range([min(all_y_min), max(all_y_max)]);
    global_y_max = max(all_y_max) + 0.05 * range([min(all_y_min), max(all_y_max)]);
    ylim([global_y_min, global_y_max]);
end
ylim([0,100]);

% 设置图形属性
set(gca, 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 1.5, ...
    'XMinorTick', 'on', 'YMinorTick', 'on');
grid on;
set(gca, 'XGrid', 'off'); % 关闭垂直网格线，只保留水平网格线
box on;

% 添加图例
if ~isempty(h_legend)
    legend(h_legend, legend_labels, 'Location','southoutside', ...
        'FontSize', 11, 'Interpreter', 'latex', 'Orientation', 'horizontal', 'Box', 'on', ...
        'NumColumns', min(length(legend_labels), 4)); % 限制图例列数以避免过于拥挤
end

% 添加标题
% title([figure_name, ' - ', group_names{1}, ' vs ', group_names{2}], ...
%       'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');

% 保存图片
print(f, [out_dir, figure_name, '_combined.png'], '-dpng', '-r600');

end

function [time_mean] = GetAverageTime_p2(cellSegs)
time_mean = [];

for idxSeg = 1:length(cellSegs)
    seg = cellSegs{idxSeg};

    period = 1:seg.idx.idx_p2;

    if length(1:seg.idx.idx_p1)<2 ...
            || length(seg.idx.idx_p1:seg.idx.idx_p2)<2 ...
            || length(seg.idx.idx_p2:seg.idx.idx_p4)<2 ...
            || length(seg.idx.idx_p4:seg.idx.idx_end)<2 ...
            || length(period)<2
        continue;
    end

    time = seg.time(period);

    time_mean(end+1) = range(time);
end

time_mean = mean(time_mean);
end
