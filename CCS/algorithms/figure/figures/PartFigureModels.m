%% 肌肉骨骼模型作图
f = figure;
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');

% 设置显示帧
idxFrame = 300;

% 调用DrawKinectFrame_WithMuscles绘制模型
DrawKinectFrame_WithMuscles(streamInter, idxFrame, muscles_new, segments_RM, segments_origin, segments_length, muscle_names, false);

% 设置图形属性
set(gca, 'FontName', 'Arial', 'FontSize', 12, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], 'ZColor', [.3 .3 .3]);
set(gca, 'Box', 'off', 'TickDir', 'out');

% 设置视角和轴属性
% view([45 15]); % 调整视角使模型更清晰
view([1 1 0.5]);
axis equal;
grid on;
set(gca, 'GridAlpha', 0.3);

% 添加标题
title(sprintf('Musculoskeletal Model at Frame %d (Time: %.2f s)', idxFrame, times.union(idxFrame)), ...
    'FontSize', 14, 'FontWeight', 'bold', 'Color', [.1 .1 .1]);

% 添加图例
legend_entries = {};
legend_handles = [];

% 寻找现有的绘图对象来创建图例
ax_children = get(gca, 'Children');
for i = 1:length(ax_children)
    if strcmp(get(ax_children(i), 'Type'), 'line')
        color = get(ax_children(i), 'Color');
        linewidth = get(ax_children(i), 'LineWidth');
        marker = get(ax_children(i), 'Marker');
        
        if isequal(color, [0 1 0]) && strcmp(marker, '.')
            legend_handles = [legend_handles, ax_children(i)];
            legend_entries{end+1} = 'Joints';
        elseif isequal(color, [0.8500 0.3250 0.0980]) && linewidth == 1
            legend_handles = [legend_handles, ax_children(i)];
            legend_entries{end+1} = 'Bones';
        elseif isequal(color, [0.3 0.3 1]) && linewidth > 5
            legend_handles = [legend_handles, ax_children(i)];
            legend_entries{end+1} = 'Body Segments';
        elseif isequal(color, [174,82,76]./256) && linewidth == 6
            legend_handles = [legend_handles, ax_children(i)];
            legend_entries{end+1} = 'Muscles';
        elseif strcmp(marker, '*') && isequal(color, [1 0 0])
            legend_handles = [legend_handles, ax_children(i)];
            legend_entries{end+1} = 'Center of Mass';
        end
    end
end

% 只显示前几个图例项避免重复
if ~isempty(legend_handles)
    [~, unique_idx] = unique(legend_entries, 'stable');
    legend(legend_handles(unique_idx), legend_entries(unique_idx), ...
        'Location', 'northeast', 'FontSize', 10, 'Box', 'off');
end

% 添加信息文本
info_text = {
    sprintf('Subject: %s', filename(1:3));
    sprintf('Frame: %d / %d', idxFrame, length(times.union));
    sprintf('Time: %.2f s', times.union(idxFrame));
    sprintf('Muscles: %d', length(muscle_names));
};

text(0.02, 0.98, info_text, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
    'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black', ...
    'Margin', 5, 'Interpreter', 'none');

% 调整坐标轴标签
xlabel('X (m)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Y (m)', 'FontSize', 12, 'FontWeight', 'bold');
zlabel('Z (m)', 'FontSize', 12, 'FontWeight', 'bold');

% 确保输出目录存在
if ~exist('./outputs/images models', 'dir')
    mkdir('./outputs/images models');
end

% 保存图像
print(f, ['./outputs/images models/',filename,'_model_frame',num2str(idxFrame),'.png'], '-dpng', '-r300');

% 显示完成信息
fprintf('肌肉骨骼模型图已保存: %s\n', ['./outputs/images models/',filename,'_model_frame',num2str(idxFrame),'.png']); 