function FigurePointsCoMsDifference(cellTableP, idxs_sts, colors)
    % 检查输入是否为 cell 数组且包含 4 个 table
    if ~iscell(cellTableP) || numel(cellTableP) ~= 4
        error('输入 cellTableP 必须是包含 4 个 table 的 cell 数组');
    end
    
    % 设置图形风格
    set(0, 'DefaultAxesFontName', 'Arial');
    set(0, 'DefaultAxesFontSize', 10);
    
    % 创建大图
    f = figure('Position', [100, 100, 1200, 800], 'Color', 'w');
    
    % 为每组创建颜色
    group_colors = colors; % 直接使用输入的颜色
    
    % 定义子图标题
    subplot_titles = {'P1', 'P2', 'P3', 'P4'};
    
    % 对每个 table 创建子图
    for tabIdx = 1:4
        tableP2 = cellTableP{tabIdx};
        
        % 如果是 double 数组，转换为 table
        if isa(tableP2, 'double')
            tableP2 = array2table(tableP2);
        end
        
        % 准备数据 - 计算差值
        data = [];
        groups = {};
        groupColors = [];
        
        for i = 1:length(idxs_sts)
            % 计算差值: 列2 - 列1
            diff_data = tableP2{idxs_sts{i}, 2} - tableP2{idxs_sts{i}, 1};
            data = [data; diff_data];
            
            % 创建组标签
            switch i
                case 1
                    group_name = 'All';
                case 2
                    group_name = 'MT';
                case 3
                    group_name = 'ETF';
                case 4
                    group_name = 'DVR';
            end
            groups = [groups; repmat({group_name}, length(diff_data), 1)];
            groupColors = [groupColors; repmat(group_colors(i,:), length(diff_data), 1)];
        end
        
        % 创建子图
        subplot(2, 2, tabIdx);
        
        % 创建箱形图
        boxplot(data, groups, 'Color', 'k', 'Widths', 0.6, 'Symbol', 'k+');
        
        % 设置颜色 - 确保每个箱型图有独特颜色
        h = findobj(gca, 'Tag', 'Box');
        for j = 1:length(h)
            patch(get(h(j), 'XData'), get(h(j), 'YData'), group_colors(j,:), 'FaceAlpha', 0.8);
        end
        
        % 美化子图
        title(subplot_titles{tabIdx}, 'FontSize', 11, 'FontWeight', 'bold');
        ylabel('XcoM - CoM (%)', 'FontSize', 10); % 修改y轴标签
        grid on;
        set(gca, 'GridAlpha', 0.2, 'TickLength', [0.01 0.01]);
        
        % 添加水平参考线y=0
        ylims = ylim;
        line(xlim, [0 0], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.5);
        ylim(ylims); % 保持原有y轴范围
        
        % 如果是第一个子图，添加图例
        if tabIdx == 1
            legend_handles = [];
            legend_labels = {'All', 'MT', 'ETF', 'DVR'};
            for m = 1:length(idxs_sts)
                legend_handles(end+1) = patch(NaN, NaN, group_colors(m,:), 'FaceAlpha', 0.8);
            end
            legend_handles = legend_handles(end:-1:1);
            legend(legend_handles, legend_labels, 'Location', 'northeast', 'FontSize', 8);
        end
    end
    
    % 添加大标题
    sgtitle('Differences between XcoM and CoM at Different Points', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 调整整体布局
    set(gcf, 'Color', 'w');
    ha = findobj(gcf, 'type', 'axes');
    for i = 1:length(ha)
        set(ha(i), 'Position', get(ha(i), 'Position') .* [1 0.9 1.1 1.1]);
    end

    print(f, './outputs/PointsDiffs.png', '-dpng', '-r300');

end