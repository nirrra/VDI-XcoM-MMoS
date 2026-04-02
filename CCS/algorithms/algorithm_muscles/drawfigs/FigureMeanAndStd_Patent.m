function FigureMeanAndStd_Patent(time_curves, mean_curves, std_curves, time_stages, str_paras, idxParas, colors, fig_options)

if nargin<8
    legend_names = str_paras(idxParas);
    for j = 1:length(legend_names)
        legend_names{j} = strrep(legend_names{j},'seg.','');
    end
    
    y_name = '信号幅值';
else
    legend_names = fig_options.legend_names;
    y_name = fig_options.y_name;
end

f = figure('Color', 'white', 'Position', [100, 100, 1280, 480]); % 白色背景，适当大小
title_names = {'全部','MT','ETF','DVR'};

pos = [0.06 0.25 0.26 0.6]; w = 0.325;

% 初始化存储所有 y 轴范围
all_y_min = [];
all_y_max = [];

for i = 2:4 % 四组STS策略
    axes('Position',[pos(1)+w*(i-2),pos(2),pos(3),pos(4)]);

    % 设置图形属性
    grid on;
    box on;
    set(gca, 'FontSize', 14, 'FontName', 'SimHei', 'LineWidth', 1.5, ...
        'XMinorTick', 'on', 'YMinorTick', 'on');

    hold on;

    h_mean = []; % 存储均值线句柄

    y_min = []; y_max = [];

    for k = 1:length(idxParas)
        idxPara = idxParas(k);
        time = time_curves{idxPara}(i,:);
        signal_mean = mean_curves{idxPara}(i,:);
        signal_std = std_curves{idxPara}(i,:);
        time_stage = time_stages{idxPara}(i,:);

        % 绘制标准差区域（浅色阴影）
        fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
            colors(k+1,:) * 0.7 + 0.3, 'EdgeColor', 'none', 'FaceAlpha', 0.3); % 浅色半透明区域

        % 绘制阶段标记线并标注横坐标值
        for j = 1:length(time_stage)
            xline(time_stage(j), 'LineWidth', 1.5, 'LineStyle', '-.', ...
                  'Color', [0.80 0.40 0.40], ...
                  'Label', sprintf('%.1f', time_stage(j)), ...
                  'LabelOrientation', 'horizontal', ...
                  'LabelHorizontalAlignment', 'left', ...  
                  'LabelVerticalAlignment', 'bottom');     
        end
        
        % 绘制均值线（深色实线）
        h = plot(time, signal_mean, 'LineWidth', 2.5, 'Color', colors(k+1,:)); % 深色实线
        h_mean = [h_mean, h];

        % 计算当前曲线的 y 范围
        current_y_min = min(signal_mean - signal_std);
        current_y_max = max(signal_mean + signal_std);
        
        y_min(end+1) = current_y_min;
        y_max(end+1) = current_y_max;
    end
   
    % 更新全局 y 范围
    all_y_min = [all_y_min, min(y_min)];
    all_y_max = [all_y_max, max(y_max)];

    xlabel('时间 / 秒', 'FontSize', 14, 'FontName', 'SimHei');
    ylabel(y_name, 'FontSize', 14, 'FontName', 'SimHei');

    xlim([0 2.5]);
    title(title_names{i}, 'FontSize', 14, 'FontName', 'SimHei');
end

% 计算全局 y 范围（可额外增加 5% 的边距）
global_y_min = min(all_y_min) - 0.05 * range([min(all_y_min), max(all_y_max)]);
global_y_max = max(all_y_max) + 0.05 * range([min(all_y_min), max(all_y_max)]);

% 统一设置所有子图的 y 轴范围
for i = 1:3
    ax = findobj(f, 'Type', 'axes', 'Position', [pos(1)+w*(i-1), pos(2), pos(3), pos(4)]);
    ylim(ax, [global_y_min, global_y_max]);
end

% 添加图例（无总标题）
legend(h_mean, legend_names, 'Location','southoutside', ...
    'Position',[pos(1)+1.25*w, pos(2)-0.23, 0.1, 0.1], ...
    'FontSize', 14, 'FontName', 'SimHei', 'Orientation', 'horizontal', 'Box', 'on');

% 注意：专利图不添加总标题，所以移除了 sgtitle 行

% print(f, ['./outputs/images mean std/', figure_name, '.png'], '-dpng', '-r600'); 