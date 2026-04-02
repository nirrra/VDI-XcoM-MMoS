function FigureMeanAndStd_VCI_and_omega_Chinese(cellSegs_patient, cellSegs_control, colors, fig_options)
% FigureMeanAndStd_omega - 绘制VCI（Velocity Contribution Index）的ML和AP方向对比图
%
% 输入参数:
%   cellSegs_patient - 患者组数据cell数组
%   cellSegs_control - 对照组数据cell数组  
%   colors - 颜色数组
%   fig_options - 图形选项结构体
%
% 功能:
%   创建两个子图，分别显示VCI和omega
%   每个子图内同时显示患者组和对照组，两个子图共用图例
%   信号乘以100转换为百分比，纵坐标固定在0-100%之间

str_paras_omega = {'seg.items.w_eff'};
str_paras_VCI = {'seg.vci'};

% 计算ML方向的数据
curves_patient_omega = struct();
curves_patient_omega.mean_curves = cell(1,1); 
curves_patient_omega.std_curves = cell(1,1); 
curves_patient_omega.time_curves = cell(1,1); 
curves_patient_omega.time_stage = [];
curves_control_omega = curves_patient_omega;

[curves_patient_omega.mean_curves{1}, curves_patient_omega.std_curves{1}, ...
    curves_patient_omega.time_curves{1}, curves_patient_omega.time_stage] = GetAverageCurves_All(cellSegs_patient, str_paras_omega{1});
[curves_control_omega.mean_curves{1}, curves_control_omega.std_curves{1}, ...
    curves_control_omega.time_curves{1}, curves_control_omega.time_stage] = GetAverageCurves_All(cellSegs_control, str_paras_omega{1});

% 计算AP方向的数据
curves_patient_VCI = struct();
curves_patient_VCI.mean_curves = cell(1,1); 
curves_patient_VCI.std_curves = cell(1,1); 
curves_patient_VCI.time_curves = cell(1,1); 
curves_patient_VCI.time_stage = [];
curves_control_VCI = curves_patient_VCI;

[curves_patient_VCI.mean_curves{1}, curves_patient_VCI.std_curves{1}, ...
    curves_patient_VCI.time_curves{1}, curves_patient_VCI.time_stage] = GetAverageCurves_All(cellSegs_patient, str_paras_VCI{1});
[curves_control_VCI.mean_curves{1}, curves_control_VCI.std_curves{1}, ...
    curves_control_VCI.time_curves{1}, curves_control_VCI.time_stage] = GetAverageCurves_All(cellSegs_control, str_paras_VCI{1});


% 设置默认选项
if nargin < 4
    figure_name = 'VCI and omega Comparison';
    group_names = {'卒中组','对照组'};
    out_dir = './outputs/images_compare/';
    show_p2 = false;
    plot_bw = true;
else
    if isfield(fig_options, 'figure_name')
        figure_name = fig_options.figure_name;
    else
        figure_name = 'VCI and omega Comparison';
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
end

% 获取seat-off时间
time_p2 = zeros(2,1);
time_p2(1) = GetAverageTime_p2(cellSegs_patient);
time_p2(2) = GetAverageTime_p2(cellSegs_control);

% 定义线型样式和颜色
if plot_bw
    % 黑白模式：患者组黑色实线，对照组灰色虚线
    patient_line_style = '-';  % 患者组：实线
    control_line_style = '--'; % 对照组：虚线
    patient_color = 'k';
    control_color = [0.5 0.5 0.5];
else
    % 彩色模式：患者组实线，对照组虚线
    patient_line_style = '-';  % 患者组：实线
    control_line_style = '--'; % 对照组：虚线
    patient_color = colors(2,:);
    control_color = colors(3,:);
end
line_width = 2.5;

% 计算时间范围
max_time_patient_omega = -inf;
max_time_control_omega = -inf;
max_time_patient_omgea = -inf;
max_time_control_VCI = -inf;

if ~isempty(curves_patient_omega.time_curves{1})
    max_time_patient_omega = max(curves_patient_omega.time_curves{1});
end
if ~isempty(curves_control_omega.time_curves{1})
    max_time_control_omega = max(curves_control_omega.time_curves{1});
end
if ~isempty(curves_patient_VCI.time_curves{1})
    max_time_patient_omgea = max(curves_patient_VCI.time_curves{1});
end
if ~isempty(curves_control_VCI.time_curves{1})
    max_time_control_VCI = max(curves_control_VCI.time_curves{1});
end

x_min = -0.2;
x_max_ML = max(max_time_patient_omega, max_time_control_omega) + 0.2;
x_max_AP = max(max_time_patient_omgea, max_time_control_VCI) + 0.2;

% 创建图形窗口
f = figure('Color', 'white', 'Position', [100, 100, 1280, 480]);

% 定义子图位置参数
pos = [0.08 0.25 0.4 0.6]; % [left, bottom, width, height]
w = 0.48; % 子图间距

% 存储图例句柄（用于共用图例）
h_legend_all = [];
legend_labels_all = {};

% 为ML和AP方向分别创建子图
directions = {'$\omega_{eff}$','VCI'};
curves_patient_dirs = {curves_patient_omega, curves_patient_VCI};
curves_control_dirs = {curves_control_omega, curves_control_VCI};
x_max_dirs = [x_max_ML, x_max_AP];

y_names = {'','VCI (\%)'};

for dir = 1:2
    % 使用axes直接指定位置
    axes('Position', [pos(1)+w*(dir-1), pos(2), pos(3), pos(4)]);
    hold on;
    
    curves_patient_dir = curves_patient_dirs{dir};
    curves_control_dir = curves_control_dirs{dir};
    
    % 绘制阶段标记线
    time_stage_patient = curves_patient_dir.time_stage;
    time_stage_control = curves_control_dir.time_stage;
    aux = {'right','right','right','right','right'};
    
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
    
    % 绘制患者组数据
    if ~isempty(curves_patient_dir.time_curves{1}) && ~isempty(curves_patient_dir.mean_curves{1})
        time = curves_patient_dir.time_curves{1};
        signal_mean = curves_patient_dir.mean_curves{1};
        signal_std = curves_patient_dir.std_curves{1};
        
        % 绘制标准差阴影
        if plot_bw
            fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
                [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        else
            fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
                patient_color * 0.7 + 0.3, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
        
        % 绘制均值曲线
        h = plot(time, signal_mean, 'LineWidth', line_width, ...
                'Color', patient_color, 'LineStyle', patient_line_style);
        
        % 只在第一个子图时添加到图例
        if dir == 1
            h_legend_all = [h_legend_all, h];
            legend_labels_all{end+1} = group_names{1};
        end
    end
    
    % 绘制对照组数据
    if ~isempty(curves_control_dir.time_curves{1}) && ~isempty(curves_control_dir.mean_curves{1})
        time = curves_control_dir.time_curves{1};
        signal_mean = curves_control_dir.mean_curves{1};
        signal_std = curves_control_dir.std_curves{1};
        
        % 绘制标准差阴影
        if plot_bw
            fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
                [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        else
            fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
                control_color * 0.7 + 0.3, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
        
        % 绘制均值曲线
        h = plot(time, signal_mean, 'LineWidth', line_width, ...
                'Color', control_color, 'LineStyle', control_line_style);
        
        % 只在第一个子图时添加到图例
        if dir == 1
            h_legend_all = [h_legend_all, h];
            legend_labels_all{end+1} = group_names{2};
        end
    end
    
    % 设置子图属性
    % 判断是否包含中文字符
    x_label = '时间 (s)';
    has_chinese_x = any(x_label >= char(hex2dec('4E00')) & x_label <= char(hex2dec('9FFF')));
    has_chinese_y = any(y_names{dir} >= char(hex2dec('4E00')) & y_names{dir} <= char(hex2dec('9FFF')));
    has_chinese_title = any(directions{dir} >= char(hex2dec('4E00')) & directions{dir} <= char(hex2dec('9FFF')));
    
    if has_chinese_x
        xlabel(x_label, 'FontSize', 14, 'Interpreter', 'none');
    else
        xlabel(x_label, 'FontSize', 14, 'Interpreter', 'latex');
    end
    
    if has_chinese_y
        ylabel(y_names{dir}, 'FontSize', 14, 'Interpreter', 'none');
    else
        ylabel(y_names{dir}, 'FontSize', 14, 'Interpreter', 'latex');
    end
    
    xlim([x_min x_max_dirs(dir)+0.2]);
    
    if has_chinese_title
        title([directions{dir}], 'FontSize', 14, 'Interpreter', 'none', 'FontName', 'SimHei');
    else
        title([directions{dir}], 'FontSize', 14, 'Interpreter', 'latex');
    end
    
    set(gca, 'FontSize', 14, 'FontName', 'SimHei', 'LineWidth', 1.5, ...
        'XMinorTick', 'on', 'YMinorTick', 'on');
    grid on;
    set(gca, 'XGrid', 'off'); % 关闭垂直网格线，只保留水平网格线
    box on;
end

% 添加共用图例 - 参考FigureMeanAndStd_compare的方式
if plot_bw
    % 黑白模式：创建图例项
    ax_last = findobj(f, 'Type', 'axes', 'Position', [pos(1)+w*(2-1), pos(2), pos(3), pos(4)]);
    axes(ax_last);
    legend_handles = [];
    h_legend_patient = plot(NaN, NaN, 'LineWidth', line_width, 'Color', patient_color, ...
                           'LineStyle', patient_line_style);
    h_legend_control = plot(NaN, NaN, 'LineWidth', line_width, 'Color', control_color, ...
                           'LineStyle', control_line_style);
    legend_handles = [h_legend_patient, h_legend_control];
    legend(legend_handles, legend_labels_all, 'Location','southoutside', ...
        'Position',[pos(1)+0.8*w, pos(2)-0.23, 0.1, 0.1], ...
        'FontSize', 12, 'Interpreter', 'latex', 'Orientation', 'horizontal', 'Box', 'on', 'FontName', 'SimHei');
else
    % 彩色模式：使用原图例
    ax_last = findobj(f, 'Type', 'axes', 'Position', [pos(1)+w*(2-1), pos(2), pos(3), pos(4)]);
    axes(ax_last);
    if ~isempty(h_legend_all)
        legend(h_legend_all, legend_labels_all, 'Location','southoutside', ...
            'Position',[pos(1)+0.8*w, pos(2)-0.23, 0.1, 0.1], ...
            'FontSize', 12, 'Interpreter', 'latex', 'Orientation', 'horizontal', 'Box', 'on', 'FontName', 'SimHei');
    end
end

% 保存图片
print(f, [out_dir, figure_name, '_omega.png'], '-dpng', '-r600');

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