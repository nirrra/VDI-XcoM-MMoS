function FigureMeanAndStd_compare_3groups(cellSegs_patient_1, cellSegs_patient_2, cellSegs_patient_3, str_paras, colors, fig_options)

curves_patient_1 = struct();
curves_patient_1.mean_curves = cell(length(str_paras),1); 
curves_patient_1.std_curves = cell(length(str_paras),1); 
curves_patient_1.time_curves = cell(length(str_paras),1); 
curves_patient_1.time_stage = [];
curves_patient_2 = curves_patient_1;
curves_patient_3 = curves_patient_1;

for i = 1:length(str_paras)
    str_para = str_paras{i};
    [curves_patient_1.mean_curves{i}, curves_patient_1.std_curves{i}, ...
        curves_patient_1.time_curves{i}, curves_patient_1.time_stage] = GetAverageCurves_All(cellSegs_patient_1, str_para);
    [curves_patient_2.mean_curves{i}, curves_patient_2.std_curves{i}, ...
        curves_patient_2.time_curves{i}, curves_patient_2.time_stage] = GetAverageCurves_All(cellSegs_patient_2, str_para);
    [curves_patient_3.mean_curves{i}, curves_patient_3.std_curves{i}, ...
        curves_patient_3.time_curves{i}, curves_patient_3.time_stage] = GetAverageCurves_All(cellSegs_patient_3, str_para);
end

if nargin<6
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
    group_names = {'Patient Group 1','Patient Group 2','Patient Group 3'};
    out_dir = './outputs/images_compare_3groups/';
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
        group_names = {'Patient Group 1','Patient Group 2','Patient Group 3'};
    end
    if isfield(fig_options, 'out_dir')
        out_dir = fig_options.out_dir;
    else
        out_dir = './outputs/images_compare_3groups/';
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

time_p2 = zeros(3,1);
time_p2(1) = GetAverageTime_p2(cellSegs_patient_1);
time_p2(2) = GetAverageTime_p2(cellSegs_patient_2);
time_p2(3) = GetAverageTime_p2(cellSegs_patient_3);

% 定义黑白线型样式：1. 黑+实线；2. 灰+实线；3. 黑+虚线；4. 灰+虚线；5. 黑+另一种虚线；6. 灰+另一种虚线
line_styles = {'-', '-', '--', '--', '-.', '-.'};  % 实线、实线、虚线、虚线、点划线、点划线
line_colors = {'k', [0.5 0.5 0.5], 'k', [0.5 0.5 0.5], 'k', [0.5 0.5 0.5]}; % 黑色、灰色、黑色、灰色、黑色、灰色
line_widths = [2.5, 2.5, 2.5, 2.5, 2.5, 2.5];   % 线宽
marker_styles = {'none', 'none', 'none', 'none', 'none', 'none'}; % 无标记
marker_sizes = [6, 6, 6, 6, 6, 6]; % 标记大小

f = figure('Color', 'white', 'Position', [100, 100, 1920, 480]);
all_y_min = [];
all_y_max = [];
h_mean_all = cell(1,3);

% 计算三个组所有参数的最大时间点
curves_all = {curves_patient_1, curves_patient_2, curves_patient_3};
max_time_1 = -inf;
max_time_2 = -inf;
max_time_3 = -inf;
for idxPara = 1:length(str_paras)
    t1 = curves_patient_1.time_curves{idxPara};
    t2 = curves_patient_2.time_curves{idxPara};
    t3 = curves_patient_3.time_curves{idxPara};
    if ~isempty(t1)
        max_time_1 = max(max_time_1, max(t1));
    end
    if ~isempty(t2)
        max_time_2 = max(max_time_2, max(t2));
    end
    if ~isempty(t3)
        max_time_3 = max(max_time_3, max(t3));
    end
end
x_min = -0.2;
x_max = max([max_time_1, max_time_2, max_time_3]) + 0.2;

for group = 1:3
    subplot(1,3,group);
    curves = curves_all{group};
    hold on;
    y_min = [];
    y_max = [];
    h_mean = [];
    for idxPara = 1:length(str_paras)
        time = curves.time_curves{idxPara};
        signal_mean = curves.mean_curves{idxPara};
        signal_std = curves.std_curves{idxPara};
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
    xlabel('Time / s', 'FontSize', 14, 'Interpreter', 'latex');
    ylabel(y_name, 'FontSize', 14, 'Interpreter', 'latex');
    xlim([x_min x_max]);
    title(group_names{group}, 'Interpreter', 'latex');
    set(gca, 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 1.5, ...
        'XMinorTick', 'on', 'YMinorTick', 'on');
    grid on;
    box on;
end

% 统一y轴范围
if ~isempty(all_y_min) && ~isempty(all_y_max)
    global_y_min = min(all_y_min) - 0.05 * range([min(all_y_min), max(all_y_max)]);
    global_y_max = max(all_y_max) + 0.05 * range([min(all_y_min), max(all_y_max)]);
    for group = 1:3
        subplot(1,3,group);
        ylim([global_y_min, global_y_max]);
    end
end

% 图例
if plot_bw
    % 黑白模式：创建图例项（用于显示不同线型）
    for group = 1:3
        subplot(1,3,group);
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
            'FontSize', 12, 'Interpreter', 'latex', 'Orientation', 'horizontal', 'Box', 'on');
    end
else
    % 彩色模式：使用原图例
    for group = 1:3
        subplot(1,3,group);
        legend(h_mean_all{group}, legend_names, 'Location','southoutside', ...
            'FontSize', 12, 'Interpreter', 'latex', 'Orientation', 'horizontal', 'Box', 'on');
    end
end

sgtitle(figure_name, 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');

% 确保输出目录存在
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

print(f, [out_dir, figure_name, '.png'], '-dpng', '-r600');

end

function [time_mean] = GetAverageTime_p2(cellSegs)
time_mean = [];

for idxSeg = 1:length(cellSegs)
    seg = cellSegs{idxSeg};

    period = 1:seg.idx.idx_p2;

    if length(1:seg.idx.idx_p1)<2 ...
            || length(seg.idx.idx_p1:seg.idx.idx_p3)<2 ...
            || length(seg.idx.idx_p3:seg.idx.idx_p4)<2 ...
            || length(seg.idx.idx_p4:seg.idx.idx_end)<2 ...
            || length(period)<2
        continue;
    end

    time = seg.time(period);

    time_mean(end+1) = range(time);
end

time_mean = mean(time_mean);
end
