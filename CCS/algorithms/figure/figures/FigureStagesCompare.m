function FigureStagesCompare(cellTableStages, idxs_sts, colors)
    num_stage = 4;
    % 检查输入是否为 cell 数组且包含 4 个 table
    if ~iscell(cellTableStages) || numel(cellTableStages) ~= num_stage
        error('输入 cellTableStages 必须是包含 4 个 table 的 cell 数组');
    end
    
    % 设置图形风格
    set(0, 'DefaultAxesFontName', 'Arial');
    set(0, 'DefaultAxesFontSize', 10);
    
    % 创建大图
    f = figure('Position', [100, 100, 1600, 900], 'Color', 'w');
    
    % 获取列数 (应该是7)
    num_columns = size(cellTableStages{1}, 2);
    
    % 定义子图标题 (可以根据需要修改)
    subplot_titles = {'CoM', 'XcoM', 'XcoM-CoM', 'v CoM', 'acc CoM', 'z', 'acc z', 'Inertia'};
    % 对每个变量列创建子图
    for colIdx = 1:num_columns
        subplot(4, 2, colIdx); % 3x3布局，可以显示7个子图(第8,9个位置空着)
        
        % 准备所有数据用于箱型图
        all_data = [];
        group_labels = {};
        group_colors = [];
        
        % 对每个stage (共5个)
        for stageIdx = 1:num_stage
            current_table = cellTableStages{stageIdx};
            
            % 对每个统计组 (共4个)
            for statIdx = 1:length(idxs_sts)
                % 获取当前组的数据
                current_data = current_table{idxs_sts{statIdx}, colIdx};
                
                % 添加到总数据
                all_data = [all_data; current_data];
                
                % 创建组标签 (格式: StageX-GroupY)
                group_labels = [group_labels; repmat({sprintf('S%d-G%d', stageIdx, statIdx)}, length(current_data), 1)];
                
                % 分配颜色 (使用提供的colors矩阵)
                group_colors = [group_colors; repmat(colors(statIdx,:), length(current_data), 1)];
            end
            
        end
        
        % 创建箱型图
        bp = boxplot(all_data, group_labels, 'Color', 'k', 'Widths', 0.6, 'Symbol', 'k+', 'Positions', getBoxPositions(num_stage, 4));
        
        % 设置箱型图颜色
        h = findobj(gca, 'Tag', 'Box');
        for j = 1:length(h)
            % 计算对应的stage和group
            group_num = ceil(j/(num_stage-1)); % 1-num_stage (stages)
            stat_num = mod(j-1,4)+1; % 1-4 (stat groups)
            
            % 设置颜色
            patch(get(h(j), 'XData'), get(h(j), 'YData'), colors(stat_num,:), 'FaceAlpha', 0.7);
        end
        
        % 美化子图
        title(subplot_titles{colIdx}, 'FontSize', 11, 'FontWeight', 'bold');
        ylabel('Value', 'FontSize', 10);
        grid on;
        set(gca, 'GridAlpha', 0.2, 'TickLength', [0.01 0.01]);
        
        % 调整X轴标签 (只显示stage分隔)
        xtick_positions = 2.5:4:(num_stage*4);
        set(gca, 'XTick', xtick_positions, 'XTickLabel', {'Stage1', 'Stage2', 'Stage3', 'Stage4'});
        
        % 添加垂直线分隔stage
        ylims = ylim;
        for k = 4.5:4:(5*4)
            line([k k], ylims, 'Color', [0.7 0.7 0.7], 'LineStyle', '--', 'LineWidth', 0.5);
        end
        
        % 如果是第一个子图，添加图例
        if colIdx == 1
            legend_handles = [];
            legend_labels = {'All','MT','ETF','DVR'};
            for m = 1:length(idxs_sts)
                legend_handles(end+1) = patch(NaN, NaN, colors(m,:), 'FaceAlpha', 0.7);
            end
            legend_handles = legend_handles(end:-1:1);
            legend(legend_handles, legend_labels, 'Location', 'southeast', 'FontSize', 8);
        end
    end
    
    % 添加大标题
    sgtitle('Comparison of Variables Across Stages and Groups', 'FontSize', 14, 'FontWeight', 'bold');
    
    % 调整整体布局
    set(gcf, 'Color', 'w');
    ha = findobj(gcf, 'type', 'axes');
    for i = 1:length(ha)
        set(ha(i), 'Position', get(ha(i), 'Position') .* [1 0.95 1.1 1]);
    end

    % 保存图形
    print(f, './outputs/StagesComparison.png', '-dpng', '-r300');
end

% 辅助函数: 计算箱型图位置 (5 stages, 4 groups per stage)
function positions = getBoxPositions(num_stages, num_groups)
    positions = [];
    for stage = 1:num_stages
        base_pos = (stage-1)*num_groups;
        for group = 1:num_groups
            positions = [positions, base_pos + group];
        end
    end
end