function FigureMeanAndStd_compare_treatment(curves_before, curves_after, curves_control, str_paras, idxParas, colors, fig_options)

if nargin<7
    figure_name = [];
    for i = idxParas
        figure_name = [figure_name, str_paras{i}, '; '];
    end
    figure_name(end-1:end) = [];
    figure_name = strrep(figure_name,'seg.','');
    figure_name = upper(figure_name);

    legend_names = str_paras(idxParas);
    for j = 1:length(legend_names)
        legend_names{j} = strrep(legend_names{j},'seg.','');
    end
    
    y_name = 'Signal Amplitude';
    group_names = {'Before','After','Control'};
    out_dir = './outputs/images_after_treatment/';
    filename_prefix = '';
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
        group_names = {'Before','After','Control'};
    end
    if isfield(fig_options, 'out_dir')
        out_dir = fig_options.out_dir;
    else
        out_dir = './outputs/images_after_treatment/';
    end
    if isfield(fig_options, 'filename_prefix')
        filename_prefix = fig_options.filename_prefix;
    else
        filename_prefix = '';
    end
end

f = figure('Color', 'white', 'Position', [100, 100, 1920, 480]);
all_y_min = [];
all_y_max = [];
h_mean_all = cell(1,3);

% 计算三个组所有参数的最大时间点
curves_all = {curves_before, curves_after, curves_control};
max_time_before = -inf;
max_time_after = -inf;
max_time_control = -inf;
for k = 1:length(idxParas)
    idxPara = idxParas(k);
    t1 = curves_before.time_curves{idxPara};
    t2 = curves_after.time_curves{idxPara};
    t3 = curves_control.time_curves{idxPara};
    if ~isempty(t1)
        max_time_before = max(max_time_before, max(t1));
    end
    if ~isempty(t2)
        max_time_after = max(max_time_after, max(t2));
    end
    if ~isempty(t3)
        max_time_control = max(max_time_control, max(t3));
    end
end
x_min = -0.2;
x_max = max(max(max_time_before, max_time_after), max_time_control) + 0.2;

for group = 1:3
    subplot(1,3,group);
    curves = curves_all{group};
    hold on;
    y_min = [];
    y_max = [];
    h_mean = [];
    for k = 1:length(idxParas)
        idxPara = idxParas(k);
        time = curves.time_curves{idxPara};
        signal_mean = curves.mean_curves{idxPara};
        signal_std = curves.std_curves{idxPara};
        time_stage = curves.time_stage;
        % 绘制标准差阴影
        fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
            colors(k+1,:) * 0.7 + 0.3, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        % 绘制阶段标记线
        for j = 1:length(time_stage)
            xline(time_stage(j), 'LineWidth', 1.5, 'LineStyle', '-.', ...
                  'Color', [0.80 0.40 0.40], ...
                  'Label', sprintf('%.1f', time_stage(j)), ...
                  'LabelOrientation', 'horizontal', ...
                  'LabelHorizontalAlignment', 'left', ...  
                  'LabelVerticalAlignment', 'bottom');     
        end
        % 绘制均值曲线
        h = plot(time, signal_mean, 'LineWidth', 2.5, 'Color', colors(k+1,:));
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
for group = 1:3
    subplot(1,3,group);
    legend(h_mean_all{group}, legend_names, 'Location','southoutside', ...
        'FontSize', 12, 'Interpreter', 'latex', 'Orientation', 'horizontal', 'Box', 'on');
end

sgtitle(figure_name, 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');

print(f, [out_dir, '/', filename_prefix, figure_name, '.png'], '-dpng', '-r600');









