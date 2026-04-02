function FigurePointsCompare(cellTableP, idxs_sts, colors)
    % 检查输入是否为 cell 数组且包含 4 个 table
    if ~iscell(cellTableP) || numel(cellTableP) ~= 4
        error('输入 cellTableP 必须是包含 4 个 table 的 cell 数组');
    end
    
    % 设置图形风格
    set(0, 'DefaultAxesFontName', 'Arial');
    set(0, 'DefaultAxesFontSize', 10);
    
    % 创建大图
    f = figure('Position', [100, 100, 1200, 800], 'Color', 'w');
    
    % 为每组的列2创建稍浅的版本
    column_colors = cell(4,2);
    for i = 1:4
        column_colors{i,1} = colors(i,:);  % 列1用主色
        column_colors{i,2} = colors(i,:) * 0.7 + 0.3;  % 列2用浅色版本
    end
    
    % 定义子图标题
    subplot_titles = {'P1', 'P2', 'P3', 'P4'};
    
    % 对每个 table 创建子图
    for tabIdx = 1:4
        tableP2 = cellTableP{tabIdx};
        
        % 如果是 double 数组，转换为 table
        if isa(tableP2, 'double')
            tableP2 = array2table(tableP2);
        end
        
        % 准备数据
        data = [];
        groups = {};
        groupColors = [];
        
        for i = 1:length(idxs_sts)
            % 第一列数据
            data = [data; tableP2{idxs_sts{i}, 1}];
            groups = [groups; repmat({sprintf('G%d-C1', i)}, length(idxs_sts{i}), 1)];
            groupColors = [groupColors; repmat(column_colors{i,1}, length(idxs_sts{i}), 1)];
            
            % 第二列数据
            data = [data; tableP2{idxs_sts{i}, 2}];
            groups = [groups; repmat({sprintf('G%d-C2', i)}, length(idxs_sts{i}), 1)];
            groupColors = [groupColors; repmat(column_colors{i,2}, length(idxs_sts{i}), 1)];
        end
        
        % 创建子图
        subplot(2, 2, tabIdx);
        
        % 创建箱形图
        boxplot(data, groups, 'Color', 'k', 'Widths', 0.6, 'Symbol', 'k+');
        
        % 设置颜色 - 确保每个箱型图有独特颜色
        h = findobj(gca, 'Tag', 'Box');
        for j = 1:length(h)
            % 计算对应的组和列
            if mod(j,2) == 1  % 奇数索引是列1
                group_idx = ceil(j/2);
                col_idx = 1;
            else              % 偶数索引是列2
                group_idx = j/2;
                col_idx = 2;
            end
            patch(get(h(j), 'XData'), get(h(j), 'YData'), column_colors{group_idx,col_idx}, 'FaceAlpha', 0.8);
        end
        
        % 美化子图
        title(subplot_titles{tabIdx}, 'FontSize', 11, 'FontWeight', 'bold');
        ylabel('Ratio (%)', 'FontSize', 10);
        grid on;
        set(gca, 'GridAlpha', 0.2, 'TickLength', [0.01 0.01]);
        
        % 调整X轴标签
        xticks = 1:length(groups)/length(idxs_sts);
        set(gca, 'XTick', xticks*2-0.5, 'XTickLabel', {'All','MT','ETF','DVR'});
        
        % 添加垂直线分隔组别
        ylims = ylim;
        for k = 2.5:2:(length(idxs_sts)*2)
            line([k k], ylims, 'Color', [0.7 0.7 0.7], 'LineStyle', '--', 'LineWidth', 0.5);
        end
        
        % 如果是第一个子图，添加图例
        if tabIdx == 1
            legend_handles = [];
            legend_labels = {'All CoM','All XcoM','MT CoM','MT XcoM','ETF CoM','ETF XcoM','DVR CoM','DVR XcoM'};
            for m = 1:length(idxs_sts)
                % 列1图例项
                legend_handles(end+1) = patch(NaN, NaN, column_colors{m,1}, 'FaceAlpha', 0.8);
                
                % 列2图例项
                legend_handles(end+1) = patch(NaN, NaN, column_colors{m,2}, 'FaceAlpha', 0.8);
            end
            legend_handles = legend_handles(end:-1:1);
            legend(legend_handles, legend_labels, 'Location', 'northeast', 'FontSize', 8);
        end
    end
    
    % 添加大标题
    sgtitle('Positions of CoM and XcoM at Different Points', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 调整整体布局
    set(gcf, 'Color', 'w');
    ha = findobj(gcf, 'type', 'axes');
    for i = 1:length(ha)
        set(ha(i), 'Position', get(ha(i), 'Position') .* [1 0.9 1.1 1.1]);
    end

    print(f, ['./outputs/','PointsComparison.png'],'-dpng','-r300');

end