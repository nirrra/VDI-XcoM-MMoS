%% 肌肉力作图
f = figure;
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');

% 髋关节相关肌肉力
subplot(2,2,1); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);

% 髋关节相关肌肉（左侧）
hip_muscles = {'glut_max_l', 'hamstrings_l', 'rect_fem_l', 'iliopsoas_l', 'ercspn_l'};
hip_muscle_names = {'Glut Max', 'Hamstrings', 'Rect Fem', 'Iliopsoas', 'Erector Spinae'};
plot_handles = [];
for i = 1:length(hip_muscles)
    if isfield(muscle_forces, hip_muscles{i})
        p = plot(times.union, muscle_forces.(hip_muscles{i}), 'Color', colors(i,:), 'LineWidth', 2, 'DisplayName', hip_muscle_names{i});
        plot_handles = [plot_handles, p];
    end
end

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

if ~isempty(plot_handles)
    legend(plot_handles, 'Location', 'best', 'FontSize', 8);
end
title('Hip-related Muscle Forces (Left)', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlabel('time / s'); ylabel('Force / N');

% 膝关节相关肌肉力
subplot(2,2,2); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);

% 膝关节相关肌肉（左侧）
knee_muscles = {'vasti_l', 'rect_fem_l', 'hamstrings_l', 'bifemsh_l', 'gastroc_l'};
knee_muscle_names = {'Vasti', 'Rect Fem', 'Hamstrings', 'Biceps Femoris', 'Gastrocnemius'};
plot_handles = [];
for i = 1:length(knee_muscles)
    if isfield(muscle_forces, knee_muscles{i})
        p = plot(times.union, muscle_forces.(knee_muscles{i}), 'Color', colors(i,:), 'LineWidth', 2, 'DisplayName', knee_muscle_names{i});
        plot_handles = [plot_handles, p];
    end
end

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

if ~isempty(plot_handles)
    legend(plot_handles, 'Location', 'best', 'FontSize', 8);
end
title('Knee-related Muscle Forces (Left)', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlabel('time / s'); ylabel('Force / N');

% 踝关节相关肌肉力
subplot(2,2,3); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);

% 踝关节相关肌肉（左侧）
ankle_muscles = {'soleus_l', 'gastroc_l', 'tib_ant_l'};
ankle_muscle_names = {'Soleus', 'Gastrocnemius', 'Tibialis Anterior'};
plot_handles = [];
for i = 1:length(ankle_muscles)
    if isfield(muscle_forces, ankle_muscles{i})
        p = plot(times.union, muscle_forces.(ankle_muscles{i}), 'Color', colors(i,:), 'LineWidth', 2, 'DisplayName', ankle_muscle_names{i});
        plot_handles = [plot_handles, p];
    end
end

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

if ~isempty(plot_handles)
    legend(plot_handles, 'Location', 'best', 'FontSize', 8);
end
title('Ankle-related Muscle Forces (Left)', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlabel('time / s'); ylabel('Force / N');

% 腰椎相关肌肉力
subplot(2,2,4); 
hold on; grid on;
set(gca, 'FontName', 'Arial', 'FontSize', 10, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);

% 腰椎相关肌肉（左侧）
lumbar_muscles = {'ercspn_l', 'extobl_l', 'intobl_l'};
lumbar_muscle_names = {'Erector Spinae', 'External Oblique', 'Internal Oblique'};
plot_handles = [];
for i = 1:length(lumbar_muscles)
    if isfield(muscle_forces, lumbar_muscles{i})
        p = plot(times.union, muscle_forces.(lumbar_muscles{i}), 'Color', colors(i,:), 'LineWidth', 2, 'DisplayName', lumbar_muscle_names{i});
        plot_handles = [plot_handles, p];
    end
end

% 添加垂直线
xline(sts_segments.time_start, '--', 'Color', line_colors(1,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p1, '--', 'Color', line_colors(6,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p2, '--', 'Color', line_colors(7,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p3, '--', 'Color', line_colors(8,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_p4, '--', 'Color', line_colors(9,:), 'LineWidth', 1.5, 'Alpha', 0.7);
xline(sts_segments.time_end, '--', 'Color', line_colors(5,:), 'LineWidth', 1.5, 'Alpha', 0.7);

if ~isempty(plot_handles)
    legend(plot_handles, 'Location', 'best', 'FontSize', 8);
end
title('Lumbar-related Muscle Forces (Left)', 'FontWeight', 'normal', 'FontSize', 11, 'Color', [.2 .2 .2]);
xlabel('time / s'); ylabel('Force / N');

% 添加总标题
sgtitle('Muscle Forces by Joint', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Color', [.1 .1 .1]);

% 调整子图间距
h = findobj(gcf, 'type', 'axes');
set(h, 'Box', 'off', 'TickDir', 'out');

print(f, ['./outputs/images muscle forces/',filename,'_muscle_forces.png'],'-dpng','-r300'); 