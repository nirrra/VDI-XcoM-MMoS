function FigureMeanAndStd_compare_Chinese(cellSegs_patient, cellSegs_control, str_paras, colors, fig_options)

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
    
    x_name = 'Time / s';
    y_name = 'Signal Amplitude';
    group_names = {'Stroke','Control'};
    out_dir = './outputs/images_compare/';
    show_p2 = false;
    plot_bw = true;
    with_title = false;
else
    figure_name = fig_options.figure_name;
    legend_names = fig_options.legend_names;
    if isfield(fig_options, 'x_name')
        x_name = fig_options.x_name;
    else
        x_name = 'Time / s';
    end
    if isfield(fig_options, 'y_name')
        y_name = fig_options.y_name;
    else
        y_name = 'Signal Amplitude';
    end
    if isfield(fig_options, 'group_names')
        group_names = fig_options.group_names;
    else
        group_names = {'卒中组','对照组'};
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
    if isfield(fig_options, 'with_title')
        with_title = fig_options.with_title;
    else
        with_title = false;
    end
end

time_p2 = zeros(2,1);
time_p2(1) = GetAverageTime_p2(cellSegs_patient);
time_p2(2) = GetAverageTime_p2(cellSegs_control);

% 定义黑白线型样式：1. 黑+实线；2. 灰+实线；3. 黑+虚线；4. 灰+虚线；5. 黑+另一种虚线；6. 灰+另一种虚线
line_styles = {'-', '-', '--', '--', '-.', '-.'};  % 实线、实线、虚线、虚线、点划线、点划线
line_colors = {'k', [0.5 0.5 0.5], 'k', [0.5 0.5 0.5], 'k', [0.5 0.5 0.5]}; % 黑色、灰色、黑色、灰色、黑色、灰色
line_widths = [2.5, 2.5, 2.5, 2.5, 2.5, 2.5];   % 线宽
marker_styles = {'none', 'none', 'none', 'none', 'none', 'none'}; % 无标记
marker_sizes = [6, 6, 6, 6, 6, 6]; % 标记大小

f = figure('Color', 'white', 'Position', [100, 100, 1280, 480]);
all_y_min = [];
all_y_max = [];
h_mean_all = cell(1,2);

% 定义子图位置参数
pos = [0.08 0.25 0.4 0.6]; % [left, bottom, width, height]
w = 0.48; % 子图间距

% 计算两个组所有参数的最大时间点
max_time_patient = -inf;
max_time_control = -inf;
for idxPara = 1:length(str_paras)
    t1 = curves_patient.time_curves{idxPara};
    t2 = curves_control.time_curves{idxPara};
    if ~isempty(t1)
        max_time_patient = max(max_time_patient, max(t1));
    end
    if ~isempty(t2)
        max_time_control = max(max_time_control, max(t2));
    end
end
x_min = -0.2;
x_max = max(max_time_patient, max_time_control) + 0.2;

for group = 1:2
    % 使用axes直接指定位置
    axes('Position', [pos(1)+w*(group-1), pos(2), pos(3), pos(4)]);
    if group == 1
        curves = curves_patient;
    else
        curves = curves_control;
    end
    hold on;
    y_min = [];
    y_max = [];
    h_mean = [];
    for idxPara = 1:length(str_paras)
        time = curves.time_curves{idxPara};
        signal_mean = curves.mean_curves{idxPara};
        signal_std = curves.std_curves{idxPara}; % 0.5倍标准差
        time_stage = curves.time_stage;
        % 绘制标准差阴影
        if plot_bw
            % 黑白模式：使用不同灰度级别
            gray_level = 0.7 + 0.05 * (idxPara-1); % 不同的灰度级别
            if gray_level > 0.9, gray_level = 0.9; end
            fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
                [gray_level gray_level gray_level], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        else
            % 彩色模式：使用原色
            fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
                colors(idxPara+1,:) * 0.7 + 0.3, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
        % 绘制阶段标记线
        aux = {'right','right','right','left','left'};
        for j = 1:length(time_stage)
            if plot_bw
                % 黑白模式：使用灰色
                xline(time_stage(j), 'LineWidth', 1.5, 'LineStyle', '-.', ...
                      'Color', [0.5 0.5 0.5], ...
                      'Label', sprintf('%.1f', time_stage(j)), ...
                      'LabelOrientation', 'horizontal', ...
                      'LabelHorizontalAlignment', aux{j}, ...  
                      'LabelVerticalAlignment', 'bottom');     
            else
                % 彩色模式：使用原色
                xline(time_stage(j), 'LineWidth', 1.5, 'LineStyle', '-.', ...
                      'Color', [0.80 0.40 0.40], ...
                      'Label', sprintf('%.1f', time_stage(j)), ...
                      'LabelOrientation', 'horizontal', ...
                      'LabelHorizontalAlignment', aux{j}, ...  
                      'LabelVerticalAlignment', 'bottom');     
            end
        end
        if show_p2
            % 绘制seat-off线
            if plot_bw
                % 黑白模式：使用深灰色，实线线型以区别于其他阶段标记线
                xline(time_stage(1)+time_p2(group), 'LineWidth', 2.0, 'LineStyle', '-', ...
                      'Color', [0.2 0.2 0.2], ...
                      'Label', sprintf('%.1f', time_stage(1)+time_p2(group)), ...
                      'LabelOrientation', 'horizontal', ...
                      'LabelHorizontalAlignment', 'left', ...  
                      'LabelVerticalAlignment', 'bottom');   
            else
                % 彩色模式：使用原色
                xline(time_stage(1)+time_p2(group), 'LineWidth', 1.5, 'LineStyle', '-.', ...
                      'Color', [0.40 0.40 0.80], ...
                      'Label', sprintf('%.1f', time_stage(1)+time_p2(group)), ...
                      'LabelOrientation', 'horizontal', ...
                      'LabelHorizontalAlignment', 'left', ...  
                      'LabelVerticalAlignment', 'bottom');   
            end
        end
    end

    for idxPara = 1:length(str_paras)
        time = curves.time_curves{idxPara};
        signal_mean = curves.mean_curves{idxPara};
        signal_std = curves.std_curves{idxPara};
        time_stage = curves.time_stage;
        % 绘制均值曲线
        if plot_bw
            % 黑白模式：使用预定义的颜色和线型
            if strcmp(marker_styles{idxPara}, 'none')
                h = plot(time, signal_mean, 'LineWidth', line_widths(idxPara), 'Color', line_colors{idxPara}, ...
                        'LineStyle', line_styles{idxPara});
            else
                h = plot(time, signal_mean, 'LineWidth', line_widths(idxPara), 'Color', line_colors{idxPara}, ...
                        'LineStyle', line_styles{idxPara}, 'Marker', marker_styles{idxPara}, ...
                        'MarkerSize', marker_sizes(idxPara), 'MarkerFaceColor', line_colors{idxPara}, ...
                        'MarkerEdgeColor', line_colors{idxPara}, 'MarkerIndices', 1:10:length(time)); % 每10个点显示一个标记
            end
        else
            % 彩色模式：使用原色
            h = plot(time, signal_mean, 'LineWidth', 2.5, 'Color', colors(idxPara+1,:));
        end
        h_mean = [h_mean, h];
        % 计算y范围
        current_y_min = min(signal_mean - signal_std);
        current_y_max = max(signal_mean + signal_std);
        y_min(end+1) = current_y_min;
        y_max(end+1) = current_y_max;
    end

    h_mean_all{group} = h_mean;
    all_y_min = [all_y_min, min(y_min)];
    all_y_max = [all_y_max, max(y_max)];
    % 设置图形属性
    grid on;
    box on;
    set(gca, 'FontSize', 14, 'FontName', 'SimHei', 'LineWidth', 1.5, ...
        'XMinorTick', 'on', 'YMinorTick', 'on');
    
    % 判断是否包含中文字符
    has_chinese_x = any(x_name >= char(hex2dec('4E00')) & x_name <= char(hex2dec('9FFF')));
    has_chinese_y = any(y_name >= char(hex2dec('4E00')) & y_name <= char(hex2dec('9FFF')));
    has_chinese_group = any(group_names{group} >= char(hex2dec('4E00')) & group_names{group} <= char(hex2dec('9FFF')));
    
    % 根据是否含中文选择不同的解释器
    if has_chinese_x
        xlabel(x_name, 'FontSize', 14, 'Interpreter', 'none');
    else
        xlabel(x_name, 'FontSize', 14, 'Interpreter', 'latex');
    end
    
    if has_chinese_y
        ylabel(y_name, 'FontSize', 14, 'Interpreter', 'none');
    else
        ylabel(y_name, 'FontSize', 14, 'Interpreter', 'latex');
    end
    
    xlim([x_min x_max]);
    
    if has_chinese_group
        title(group_names{group}, 'Interpreter', 'none', 'FontName', 'SimHei');
    else
        title(group_names{group}, 'Interpreter', 'latex');
    end
end

% 统一y轴范围
if ~isempty(all_y_min) && ~isempty(all_y_max)
    global_y_min = min(all_y_min) - 0.05 * range([min(all_y_min), max(all_y_max)]);
    global_y_max = max(all_y_max) + 0.05 * range([min(all_y_min), max(all_y_max)]);
    % 统一设置所有子图的 y 轴范围
    for group = 1:2
        ax = findobj(f, 'Type', 'axes', 'Position', [pos(1)+w*(group-1), pos(2), pos(3), pos(4)]);
        ylim(ax, [global_y_min, global_y_max]);
    end
end

% 添加图例 - 使用统一的图例位置
if plot_bw
    % 黑白模式：创建图例项（用于显示不同线型）
    % 选择最后一个子图来添加图例
    ax_last = findobj(f, 'Type', 'axes', 'Position', [pos(1)+w*(2-1), pos(2), pos(3), pos(4)]);
    axes(ax_last);
    legend_handles = [];
    for idxPara = 1:length(str_paras)
        if strcmp(marker_styles{idxPara}, 'none')
            h_legend = plot(NaN, NaN, 'LineWidth', line_widths(idxPara), 'Color', line_colors{idxPara}, ...
                           'LineStyle', line_styles{idxPara});
        else
            h_legend = plot(NaN, NaN, 'LineWidth', line_widths(idxPara), 'Color', line_colors{idxPara}, ...
                           'LineStyle', line_styles{idxPara}, 'Marker', marker_styles{idxPara}, ...
                           'MarkerSize', marker_sizes(idxPara), 'MarkerFaceColor', line_colors{idxPara}, ...
                           'MarkerEdgeColor', line_colors{idxPara});
        end
        legend_handles = [legend_handles, h_legend];
    end
    legend(legend_handles, legend_names, 'Location','southoutside', ...
        'Position',[pos(1)+0.8*w, pos(2)-0.23, 0.1, 0.1], ...
        'FontSize', 12, 'Interpreter', 'latex', 'Orientation', 'horizontal', 'Box', 'on', 'FontName', 'SimHei');
else
    % 彩色模式：使用原图例
    % 选择最后一个子图来添加图例
    ax_last = findobj(f, 'Type', 'axes', 'Position', [pos(1)+w*(2-1), pos(2), pos(3), pos(4)]);
    axes(ax_last);
    legend(h_mean_all{2}, legend_names, 'Location','southoutside', ...
        'Position',[pos(1)+0.8*w, pos(2)-0.23, 0.1, 0.1], ...
        'FontSize', 12, 'Interpreter', 'latex', 'Orientation', 'horizontal', 'Box', 'on', 'FontName', 'SimHei');
end

% 判断标题是否包含中文
has_chinese_title = any(figure_name >= char(hex2dec('4E00')) & figure_name <= char(hex2dec('9FFF')));
if with_title
    if has_chinese_title
        sgtitle(figure_name, 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'none', 'FontName', 'SimHei');
    else
        sgtitle(figure_name, 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');
    end
end

print(f, [out_dir, figure_name, '.png'], '-dpng', '-r600');

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