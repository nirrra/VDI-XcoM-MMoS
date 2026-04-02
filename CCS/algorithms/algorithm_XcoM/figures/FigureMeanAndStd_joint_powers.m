function FigureMeanAndStd_joint_powers(cellSegs_patient, cellSegs_control, colors, fig_options)
% FigureMeanAndStd_joint_powers - 绘制四个关节功率的2x2子图比较
%
% 输入参数:
%   cellSegs_patient - 患者组数据cell数组
%   cellSegs_control - 对照组数据cell数组  
%   colors - 颜色数组
%   fig_options - 图形选项结构体（可选）
%
% 功能:
%   创建2x2子图布局，分别显示踝关节、膝关节、髋关节和腰椎的功率对比
%   每个子图显示患者组和对照组的均值和标准差曲线

% 定义四个关节的参数
joint_params = {
    {'(seg.jp.left_ankle.x+seg.jp.right_ankle.x)./2'}, ...    % 踝关节
    {'(seg.jp.left_knee.x+seg.jp.right_knee.x)./2'}, ...      % 膝关节
    {'(seg.jp.left_hip.x+seg.jp.right_hip.x)./2'}, ... % 髋关节
    {'seg.jp.lumbar.x'} ...                       % 腰椎
};

joint_names = {'Ankle Joint Power', 'Knee Joint Power', 'Hip Joint Power', 'Lumbar Joint Power'};
joint_legends = {'JP Ankle', 'JP Knee', 'JP Hip', 'JP Lumbar'};

% 设置默认选项
if nargin < 4
    fig_options = struct();
end

if ~isfield(fig_options, 'figure_name')
    fig_options.figure_name = 'Joint Powers Comparison';
end
if ~isfield(fig_options, 'y_name')
    fig_options.y_name = 'Joint Power (W)';
end
if ~isfield(fig_options, 'group_names')
    fig_options.group_names = {'Patient','Control'};
end
if ~isfield(fig_options, 'out_dir')
    fig_options.out_dir = './outputs/images_compare/';
end
if ~isfield(fig_options, 'show_p2')
    fig_options.show_p2 = false;
end
if ~isfield(fig_options, 'plot_bw')
    fig_options.plot_bw = true;
end

% 预处理数据 - 为每个关节计算曲线
curves_patient = cell(4, 1);
curves_control = cell(4, 1);
time_p2 = zeros(2, 1);
time_p2(1) = GetAverageTime_p2(cellSegs_patient);
time_p2(2) = GetAverageTime_p2(cellSegs_control);

for i = 1:4
    curves_patient{i} = struct();
    curves_patient{i}.mean_curves = cell(1, 1);
    curves_patient{i}.std_curves = cell(1, 1);
    curves_patient{i}.time_curves = cell(1, 1);
    curves_patient{i}.time_stage = [];
    
    curves_control{i} = curves_patient{i};
    
    % 计算患者组数据
    [curves_patient{i}.mean_curves{1}, curves_patient{i}.std_curves{1}, ...
        curves_patient{i}.time_curves{1}, curves_patient{i}.time_stage] = ...
        GetAverageCurves_All(cellSegs_patient, joint_params{i}{1});
    
    % 计算对照组数据
    [curves_control{i}.mean_curves{1}, curves_control{i}.std_curves{1}, ...
        curves_control{i}.time_curves{1}, curves_control{i}.time_stage] = ...
        GetAverageCurves_All(cellSegs_control, joint_params{i}{1});
end

% 定义线型样式
if fig_options.plot_bw
    patient_line_styles = {'-', '-', '-', '-'};
    control_line_styles = {'--', '--', '--', '--'};
    patient_colors = {'k', 'k', 'k', 'k'};
    control_colors = {[0.5 0.5 0.5], [0.5 0.5 0.5], [0.5 0.5 0.5], [0.5 0.5 0.5]};
else
    patient_line_styles = {'-', '-', '-', '-'};
    control_line_styles = {'--', '--', '--', '--'};
end
line_widths = [2.5, 2.5, 2.5, 2.5];

% 创建2x2子图
f = figure('Color', 'white', 'Position', [100, 100, 1200, 900]);

% 计算全局时间范围和y轴范围
max_time_patient = -inf;
max_time_control = -inf;
all_y_min = [];
all_y_max = [];

for i = 1:4
    t1 = curves_patient{i}.time_curves{1};
    t2 = curves_control{i}.time_curves{1};
    if ~isempty(t1)
        max_time_patient = max(max_time_patient, max(t1));
    end
    if ~isempty(t2)
        max_time_control = max(max_time_control, max(t2));
    end
    
    % 计算y轴范围
    if ~isempty(curves_patient{i}.mean_curves{1}) && ~isempty(curves_patient{i}.std_curves{1})
        patient_y_min = min(curves_patient{i}.mean_curves{1} - curves_patient{i}.std_curves{1});
        patient_y_max = max(curves_patient{i}.mean_curves{1} + curves_patient{i}.std_curves{1});
        all_y_min = [all_y_min, patient_y_min];
        all_y_max = [all_y_max, patient_y_max];
    end
    
    if ~isempty(curves_control{i}.mean_curves{1}) && ~isempty(curves_control{i}.std_curves{1})
        control_y_min = min(curves_control{i}.mean_curves{1} - curves_control{i}.std_curves{1});
        control_y_max = max(curves_control{i}.mean_curves{1} + curves_control{i}.std_curves{1});
        all_y_min = [all_y_min, control_y_min];
        all_y_max = [all_y_max, control_y_max];
    end
end

x_min = -0.2;
x_max = max(max_time_patient, max_time_control) + 0.2;

% 子图位置定义
subplot_positions = [1, 2, 3, 4]; % 左上、右上、左下、右下

% 绘制每个关节的子图
for i = 1:4
    subplot(2, 2, subplot_positions(i));
    hold on;
    
    curves_p = curves_patient{i};
    curves_c = curves_control{i};
    
    % 绘制阶段标记线
    time_stage_patient = curves_p.time_stage;
    time_stage_control = curves_c.time_stage;
    aux = {'right','right','right','left','left'};
    
    % 绘制患者组的阶段标记线
    for j = 1:length(time_stage_patient)
        if fig_options.plot_bw
            xline(time_stage_patient(j), 'LineWidth', 1.2, 'LineStyle', '-.', ...
                  'Color', [0.7 0.7 0.7], ...
                  'Label', sprintf('P%.1f', time_stage_patient(j)), ...
                  'LabelOrientation', 'horizontal', ...
                  'LabelHorizontalAlignment', aux{j}, ...  
                  'LabelVerticalAlignment', 'bottom', ...
                  'FontSize', 8);     
        else
            xline(time_stage_patient(j), 'LineWidth', 1.2, 'LineStyle', '-.', ...
                  'Color', [0.80 0.40 0.40], ...
                  'Label', sprintf('P%.1f', time_stage_patient(j)), ...
                  'LabelOrientation', 'horizontal', ...
                  'LabelHorizontalAlignment', aux{j}, ...  
                  'LabelVerticalAlignment', 'bottom', ...
                  'FontSize', 8);     
        end
    end
    
    % 绘制对照组的阶段标记线
    for j = 1:length(time_stage_control)
        if fig_options.plot_bw
            xline(time_stage_control(j), 'LineWidth', 1.2, 'LineStyle', ':', ...
                  'Color', [0.5 0.5 0.5], ...
                  'Label', sprintf('C%.1f', time_stage_control(j)), ...
                  'LabelOrientation', 'horizontal', ...
                  'LabelHorizontalAlignment', aux{j}, ...  
                  'LabelVerticalAlignment', 'top', ...
                  'FontSize', 8);     
        else
            xline(time_stage_control(j), 'LineWidth', 1.2, 'LineStyle', ':', ...
                  'Color', [0.40 0.80 0.40], ...
                  'Label', sprintf('C%.1f', time_stage_control(j)), ...
                  'LabelOrientation', 'horizontal', ...
                  'LabelHorizontalAlignment', aux{j}, ...  
                  'LabelVerticalAlignment', 'top', ...
                  'FontSize', 8);     
        end
    end
    
    if fig_options.show_p2
        % 绘制seat-off线
        if fig_options.plot_bw
            xline(time_stage_patient(1)+time_p2(1), 'LineWidth', 1.5, 'LineStyle', '-', ...
                  'Color', [0.2 0.2 0.2], ...
                  'Label', sprintf('P-SO%.1f', time_stage_patient(1)+time_p2(1)), ...
                  'FontSize', 8);
            xline(time_stage_control(1)+time_p2(2), 'LineWidth', 1.5, 'LineStyle', '--', ...
                  'Color', [0.4 0.4 0.4], ...
                  'Label', sprintf('C-SO%.1f', time_stage_control(1)+time_p2(2)), ...
                  'FontSize', 8);
        else
            xline(time_stage_patient(1)+time_p2(1), 'LineWidth', 1.5, 'LineStyle', '-', ...
                  'Color', [0.40 0.40 0.80], ...
                  'Label', sprintf('P-SO%.1f', time_stage_patient(1)+time_p2(1)), ...
                  'FontSize', 8);
            xline(time_stage_control(1)+time_p2(2), 'LineWidth', 1.5, 'LineStyle', '--', ...
                  'Color', [0.80 0.40 0.80], ...
                  'Label', sprintf('C-SO%.1f', time_stage_control(1)+time_p2(2)), ...
                  'FontSize', 8);
        end
    end
    
    % 绘制患者组数据
    time_p = curves_p.time_curves{1};
    signal_mean_p = curves_p.mean_curves{1};
    signal_std_p = curves_p.std_curves{1};
    
    if ~isempty(time_p) && ~isempty(signal_mean_p) && ~isempty(signal_std_p)
        % 绘制标准差阴影
        if fig_options.plot_bw
            fill([time_p, fliplr(time_p)], [signal_mean_p + signal_std_p, fliplr(signal_mean_p - signal_std_p)], ...
                [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.2);
        else
            fill([time_p, fliplr(time_p)], [signal_mean_p + signal_std_p, fliplr(signal_mean_p - signal_std_p)], ...
                colors(i+1,:) * 0.7 + 0.3, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
        end
        
        % 绘制均值曲线
        if fig_options.plot_bw
            h_p = plot(time_p, signal_mean_p, 'LineWidth', line_widths(i), ...
                    'Color', patient_colors{i}, 'LineStyle', patient_line_styles{i});
        else
            h_p = plot(time_p, signal_mean_p, 'LineWidth', line_widths(i), ...
                    'Color', colors(i+1,:), 'LineStyle', patient_line_styles{i});
        end
    else
        h_p = [];
    end
    
    % 绘制对照组数据
    time_c = curves_c.time_curves{1};
    signal_mean_c = curves_c.mean_curves{1};
    signal_std_c = curves_c.std_curves{1};
    
    if ~isempty(time_c) && ~isempty(signal_mean_c) && ~isempty(signal_std_c)
        % 绘制标准差阴影
        if fig_options.plot_bw
            fill([time_c, fliplr(time_c)], [signal_mean_c + signal_std_c, fliplr(signal_mean_c - signal_std_c)], ...
                [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.15);
        else
            fill([time_c, fliplr(time_c)], [signal_mean_c + signal_std_c, fliplr(signal_mean_c - signal_std_c)], ...
                colors(i+1,:) * 0.7 + 0.3, 'EdgeColor', 'none', 'FaceAlpha', 0.15);
        end
        
        % 绘制均值曲线
        if fig_options.plot_bw
            h_c = plot(time_c, signal_mean_c, 'LineWidth', line_widths(i), ...
                    'Color', control_colors{i}, 'LineStyle', control_line_styles{i});
        else
            h_c = plot(time_c, signal_mean_c, 'LineWidth', line_widths(i), ...
                    'Color', colors(i+1,:), 'LineStyle', control_line_styles{i});
        end
    else
        h_c = [];
    end
    
    % 设置子图属性
    xlim([x_min x_max]);
    if ~isempty(all_y_min) && ~isempty(all_y_max)
        global_y_min = min(all_y_min) - 0.05 * range([min(all_y_min), max(all_y_max)]);
        global_y_max = max(all_y_max) + 0.05 * range([min(all_y_min), max(all_y_max)]);
        ylim([global_y_min, global_y_max]);
    end
    
    set(gca, 'FontSize', 12, 'FontName', 'Arial', 'LineWidth', 1.5, ...
        'XMinorTick', 'on', 'YMinorTick', 'on');
    grid on;
    set(gca, 'XGrid', 'off'); % 关闭垂直网格线
    box on;
    
    % 设置标签和标题
    if i == 3 || i == 4  % 下方子图显示x轴标签
        xlabel('Time / s', 'FontSize', 12, 'Interpreter', 'latex');
    end
    if i == 1 || i == 3  % 左侧子图显示y轴标签
        ylabel(fig_options.y_name, 'FontSize', 12, 'Interpreter', 'latex');
    end
    
    title(joint_names{i}, 'FontSize', 13, 'FontWeight', 'bold', 'Interpreter', 'latex');
    
    % 添加图例（只在第一个子图添加）
    if i == 1 && (~isempty(h_p) || ~isempty(h_c))
        legend_handles = [];
        legend_labels = {};
        if ~isempty(h_p)
            legend_handles = [legend_handles, h_p];
            legend_labels{end+1} = [joint_legends{i}, ' (', fig_options.group_names{1}, ')'];
        end
        if ~isempty(h_c)
            legend_handles = [legend_handles, h_c];
            legend_labels{end+1} = [joint_legends{i}, ' (', fig_options.group_names{2}, ')'];
        end
        legend(legend_handles, legend_labels, 'Location', 'southeast', ...
               'FontSize', 10, 'Interpreter', 'latex', 'Box', 'on');
    end
end

% 添加总标题
sgtitle(fig_options.figure_name, 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');

% 保存图片
print(f, [fig_options.out_dir, fig_options.figure_name, '_joint_powers.png'], '-dpng', '-r600');

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
