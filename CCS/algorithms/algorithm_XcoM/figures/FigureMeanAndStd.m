function FigureMeanAndStd(cellSegs, str_paras, colors, fig_options)
% FigureMeanAndStd_compare - 绘制单组数据的均值和标准差曲线
%
% 输入参数:
%   cellSegs - 数据cell数组
%   str_paras - 参数字符串数组
%   colors - 颜色数组
%   fig_options - 图形选项结构体
%
% 功能:
%   绘制单组数据的均值和标准差曲线，支持多个参数在同一图中显示

curves = struct();
curves.mean_curves = cell(length(str_paras),1); 
curves.std_curves = cell(length(str_paras),1); 
curves.time_curves = cell(length(str_paras),1); 
curves.time_stage = [];

for i = 1:length(str_paras)
    str_para = str_paras{i};
    [curves.mean_curves{i}, curves.std_curves{i}, ...
        curves.time_curves{i}, curves.time_stage] = GetAverageCurves_All(cellSegs, str_para);
end

if nargin<4
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

time_p2 = GetAverageTime_p2(cellSegs);

% 定义黑白线型样式：1. 黑+实线；2. 灰+实线；3. 黑+虚线；4. 灰+虚线；5. 黑+另一种虚线；6. 灰+另一种虚线
line_styles = {'-', '-', '--', '--', '-.', '-.'};  % 实线、实线、虚线、虚线、点划线、点划线
line_colors = {'k', [0.5 0.5 0.5], 'k', [0.5 0.5 0.5], 'k', [0.5 0.5 0.5]}; % 黑色、灰色、黑色、灰色、黑色、灰色
line_widths = [2.5, 2.5, 2.5, 2.5, 2.5, 2.5];   % 线宽
marker_styles = {'none', 'none', 'none', 'none', 'none', 'none'}; % 无标记
marker_sizes = [6, 6, 6, 6, 6, 6]; % 标记大小

f = figure('Color', 'white', 'Position', [100, 100, 960, 720]);

% 计算所有参数的最大时间点
max_time = -inf;
for idxPara = 1:length(str_paras)
    t = curves.time_curves{idxPara};
    if ~isempty(t)
        max_time = max(max_time, max(t));
    end
end
x_min = -0.2;
x_max = max_time + 0.2;

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
    
%     % 绘制阶段标记线
%     aux = {'right','right','right','left','left'};
%     for j = 1:length(time_stage)
%         if plot_bw
%             % 黑白模式：使用灰色
%             xline(time_stage(j), 'LineWidth', 1.5, 'LineStyle', '-.', ...
%                   'Color', [0.5 0.5 0.5], ...
%                   'Label', sprintf('%.1f', time_stage(j)), ...
%                   'LabelOrientation', 'horizontal', ...
%                   'LabelHorizontalAlignment', aux{j}, ...  
%                   'LabelVerticalAlignment', 'bottom');
%         else
%             % 彩色模式：使用原色
%             xline(time_stage(j), 'LineWidth', 1.5, 'LineStyle', '-.', ...
%                   'Color', [0.80 0.40 0.40], ...
%                   'Label', sprintf('%.1f', time_stage(j)), ...
%                   'LabelOrientation', 'horizontal', ...
%                   'LabelHorizontalAlignment', aux{j}, ...  
%                   'LabelVerticalAlignment', 'bottom');     
%         end
%     end
    
    if show_p2
        % 绘制seat-off线
        if plot_bw
            % 黑白模式：使用深灰色，实线线型以区别于其他阶段标记线
            xline(time_stage(1)+time_p2, 'LineWidth', 2.0, 'LineStyle', '-', ...
                  'Color', [0.2 0.2 0.2], ...
                  'Label', sprintf('%.1f', time_stage(1)+time_p2), ...
                  'LabelOrientation', 'horizontal', ...
                  'LabelHorizontalAlignment', 'left', ...  
                  'LabelVerticalAlignment', 'bottom');   
        else
            % 彩色模式：使用原色
            xline(time_stage(1)+time_p2, 'LineWidth', 1.5, 'LineStyle', '-.', ...
                  'Color', [0.40 0.40 0.80], ...
                  'Label', sprintf('%.1f', time_stage(1)+time_p2), ...
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

h_mean_all = h_mean;
global_y_min = min(y_min);
global_y_max = max(y_max);

xlabel(x_name, 'FontSize', 14, 'Interpreter', 'latex');
ylabel(y_name, 'FontSize', 14, 'Interpreter', 'latex');
xlim([x_min x_max]);
set(gca, 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 1.5, ...
    'XMinorTick', 'on', 'YMinorTick', 'on');
grid on;
box on;

% 设置y轴范围
if ~isempty(global_y_min) && ~isempty(global_y_max)
    y_min_final = global_y_min - 0.05 * range([global_y_min, global_y_max]);
    y_max_final = global_y_max + 0.05 * range([global_y_min, global_y_max]);
    ylim([y_min_final, y_max_final]);
end

% 图例
if plot_bw
    % 黑白模式：创建图例项（用于显示不同线型）
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
        'FontSize', 16, 'Interpreter', 'latex', 'Orientation', 'horizontal', 'Box', 'on');
else
    % 彩色模式：使用原图例
    legend(h_mean_all, legend_names, 'Location','southoutside', ...
        'FontSize', 16, 'Interpreter', 'latex', 'Orientation', 'horizontal', 'Box', 'on');
end

if with_title
    title(figure_name, 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');
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