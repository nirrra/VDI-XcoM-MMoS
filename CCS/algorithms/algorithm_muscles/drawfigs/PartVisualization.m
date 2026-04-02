function PartVisualization()
%% 交互式肌肉力和姿态可视化界面
% 需要从主脚本的工作空间获取变量

try
    % 获取工作空间变量
    streamInter = evalin('base', 'streamInter');
    muscles_new = evalin('base', 'muscles_new');
    segments_RM = evalin('base', 'segments_RM');
    segments_origin = evalin('base', 'segments_origin');
    segments_length = evalin('base', 'segments_length');
    muscle_names = evalin('base', 'muscle_names');
    muscle_activations = evalin('base', 'muscle_activations');
    muscle_forces = evalin('base', 'muscle_forces');
    f_ls = evalin('base', 'f_ls');
    f_vs = evalin('base', 'f_vs');
    f_pes = evalin('base', 'f_pes');
    times = evalin('base', 'times');
catch ME
    error('无法从工作空间获取必要变量。请确保已运行主脚本并计算了所有必要数据。\n错误信息: %s', ME.message);
end

% 获取数据长度
n_frames = length(times.union);
current_frame = round(n_frames/2); % 初始帧设为中间帧

% 设置支持中文的字体
if ispc
    % Windows系统
    chinese_font = 'Microsoft YaHei'; % 微软雅黑
    backup_font = 'SimHei'; % 黑体作为备选
elseif ismac
    % Mac系统
    chinese_font = 'PingFang SC'; % 苹方
    backup_font = 'STHeiti'; % 华文黑体作为备选
else
    % Linux系统
    chinese_font = 'WenQuanYi Micro Hei'; % 文泉驿微米黑
    backup_font = 'DejaVu Sans'; % DejaVu Sans作为备选
end

% 测试字体是否可用
try
    test_fig = figure('Visible', 'off');
    test_text = text(0.5, 0.5, '测试', 'FontName', chinese_font);
    if strcmp(get(test_text, 'FontName'), chinese_font)
        font_name = chinese_font;
    else
        font_name = backup_font;
    end
    close(test_fig);
catch
    font_name = backup_font;
end

% 创建主窗口 - 设置浅灰色背景
fig = figure('Position', [100, 100, 1800, 1000], 'Name', '肌肉力和姿态交互式可视化', ...
    'NumberTitle', 'off', 'Resize', 'on', 'Color', [0.94, 0.94, 0.94]); % 浅灰色背景

% 为整个Figure创建大边框
annotation(fig, 'rectangle', [0.01, 0.01, 0.98, 0.98], ...
    'LineWidth', 4, 'EdgeColor', [0.2, 0.2, 0.2], 'FaceColor', 'none');

% 调整布局：增加右侧四个图之间的垂直间距，避免文本重叠
% 左侧大图：姿态和肌肉状态
ax_pose = axes('Parent', fig, 'Position', [0.05, 0.15, 0.55, 0.75]);

% 右侧四个图，显著增加间距以避免xlabel和title重叠
% 肌肉激活度 - 最上方
ax_activation = axes('Parent', fig, 'Position', [0.63, 0.80, 0.34, 0.15]);

% 力-长度关系 (fl) - 第二个
ax_fl = axes('Parent', fig, 'Position', [0.63, 0.60, 0.34, 0.14]);

% 力-速度关系 (fv) - 第三个
ax_fv = axes('Parent', fig, 'Position', [0.63, 0.40, 0.34, 0.14]);

% 被动力关系 (fpe) - 最下方
ax_fpe = axes('Parent', fig, 'Position', [0.63, 0.20, 0.34, 0.14]);

% 设置所有子图的边框样式，使其更加清晰
all_axes = [ax_pose, ax_activation, ax_fl, ax_fv, ax_fpe];
for i = 1:length(all_axes)
    set(all_axes(i), 'Box', 'on', 'LineWidth', 2, ...
        'XColor', [0.15, 0.15, 0.15], 'YColor', [0.15, 0.15, 0.15], ...
        'Color', 'white'); % 子图背景设为白色
end

% 创建滑动条
slider = uicontrol('Parent', fig, 'Style', 'slider', 'Min', 1, 'Max', n_frames, 'Value', current_frame, ...
    'Position', [50, 50, 800, 30], 'Callback', @updateVisualization);

% 创建帧数显示标签
frame_label = uicontrol('Parent', fig, 'Style', 'text', 'Position', [50, 20, 200, 20], ...
    'String', sprintf('当前帧: %d/%d (时间: %.2fs)', current_frame, n_frames, times.union(current_frame)), ...
    'FontSize', 12, 'BackgroundColor', [0.94, 0.94, 0.94], 'FontName', font_name, 'FontWeight', 'bold');

% 选择要显示的肌肉（默认选择前几个重要肌肉）
selected_muscles = {'glut_max_l', 'vasti_l', 'gastroc_l', 'bifemsh_l', 'soleus_l', 'tib_ant_l'};
% 检查肌肉是否存在，如果不存在则选择前6个
valid_muscles = {};
for i = 1:length(selected_muscles)
    if isfield(muscle_activations, selected_muscles{i})
        valid_muscles{end+1} = selected_muscles{i};
    end
end
if isempty(valid_muscles)
    % 如果默认肌肉都不存在，选择前6个肌肉
    all_muscle_names = fieldnames(muscle_activations);
    valid_muscles = all_muscle_names(1:min(6, length(all_muscle_names)));
end
selected_muscles = valid_muscles;

% 初始化绘图
updateVisualization();

    function updateVisualization(~, ~)
        % 检查坐标轴是否仍然有效
        if ~isvalid(ax_pose) || ~isvalid(ax_activation) || ~isvalid(ax_fl) || ~isvalid(ax_fv) || ~isvalid(ax_fpe)
            fprintf('坐标轴句柄无效，停止更新\n');
            return;
        end
        
        % 获取当前帧
        current_frame = round(get(slider, 'Value'));
        
        % 更新帧数显示
        if isvalid(frame_label)
            set(frame_label, 'String', sprintf('当前帧: %d/%d (时间: %.2fs)', ...
                current_frame, n_frames, times.union(current_frame)));
        end
        
        % 更新姿态和肌肉显示
        updatePoseAndMuscles();
        
        % 更新肌肉激活度显示
        updateActivationDisplay();
        
        % 更新肌肉特性曲线（只需要绘制一次，与时间无关）
        updateMuscleCharacteristicCurves();
    end

    function updatePoseAndMuscles()
        % 检查坐标轴是否有效
        if ~isvalid(ax_pose)
            return;
        end
        
        % 清除当前姿态图
        cla(ax_pose);
        hold(ax_pose, 'on');
        
        % 绘制人体姿态（基于DrawKinectFrame_WithMuscles）
        drawHumanPose();
        
        % 绘制肌肉，根据激活度设置颜色
        drawMusclesWithActivation();
        
        % 设置坐标轴 - 使用支持中文的字体
        xlabel(ax_pose, 'X (m)', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
        ylabel(ax_pose, 'Y (m)', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
        zlabel(ax_pose, 'Z (m)', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
        title(ax_pose, sprintf('人体姿态和肌肉状态 - 帧 %d', current_frame), ...
            'FontName', font_name, 'FontSize', 14, 'FontWeight', 'bold');
        
        % 设置坐标轴属性，增强边框
        set(ax_pose, 'FontName', font_name, 'FontSize', 10, ...
            'Box', 'on', 'LineWidth', 2, ...
            'XColor', [0.15, 0.15, 0.15], 'YColor', [0.15, 0.15, 0.15], 'ZColor', [0.15, 0.15, 0.15]);
        axis(ax_pose, 'equal');
        view(ax_pose, [1 1 0.5]);
        grid(ax_pose, 'on');
        
        % 添加颜色条说明 - 调整范围为0-0.5
        try
            colormap(ax_pose, 'hot');
            c = colorbar(ax_pose);
            c.Label.String = '肌肉激活度';
            c.Label.FontName = font_name;
            c.Label.FontSize = 12;
            c.Label.FontWeight = 'bold';
            caxis(ax_pose, [0, 0.5]); % 修改范围为0-0.5
        catch
            % 如果colorbar创建失败，忽略
        end
        
        hold(ax_pose, 'off');
    end

    function drawHumanPose()
        try
            % 坐标系转换
            matrixT = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
            streamTransform = Transform_Azure(matrixT, streamInter);
            jointArrayCell = KinectAzureStructToArray(streamTransform);
            
            % 获取当前帧的关节位置
            joints = jointArrayCell{current_frame}.joints;
            
            % 定义连接关系（关节索引）
            connections = [
                2, 19;    % 头-颈
                1, 19;    % 躯干-颈
                4, 3;     % 左上臂
                8, 7;     % 右上臂
                5, 4;     % 左前臂
                9, 8;     % 右前臂
                12, 11;   % 左大腿
                16, 15;   % 右大腿
                13, 12;   % 左小腿
                17, 16;   % 右小腿
                6, 5;     % 左手
                10, 9;    % 右手
                14, 13;   % 左脚
                18, 17;   % 右脚
                19, 3;    % 左肩
                19, 7;    % 右肩
                1, 11;    % 左髋
                1, 15;    % 右髋
            ];
            
            % 绘制骨骼连接
            for i = 1:size(connections, 1)
                joint1 = joints(connections(i, 1), :);
                joint2 = joints(connections(i, 2), :);
                plot3(ax_pose, [joint1(1), joint2(1)], [joint1(2), joint2(2)], ...
                    [joint1(3), joint2(3)], 'b-', 'LineWidth', 2);
            end
            
            % 绘制关节点
            plot3(ax_pose, joints(:, 1), joints(:, 2), joints(:, 3), 'ro', ...
                'MarkerSize', 6, 'MarkerFaceColor', 'r');
            
            % 绘制质心
            [comX, comY, comZ] = GravityKinectArray(joints, 'M');
            plot3(ax_pose, comX, comY, comZ, '*g', 'MarkerSize', 15, 'LineWidth', 3);
            
        catch ME
            % 如果绘制人体姿态失败，显示简单的文本提示
            text(ax_pose, 0, 0, 0, sprintf('无法绘制人体姿态\n错误: %s', ME.message), ...
                'HorizontalAlignment', 'center', 'FontSize', 12, 'FontName', font_name);
        end
    end

    function drawMusclesWithActivation()
        try
            % 为每个肌肉绘制线条，颜色表示激活度
            for idx_name = 1:length(muscle_names)
                muscle_name = muscle_names{idx_name};
                
                % 检查肌肉激活数据是否存在
                if ~isfield(muscle_activations, muscle_name)
                    continue;
                end
                
                % 获取肌肉激活度
                activation = muscle_activations.(muscle_name)(current_frame);
                
                % 限制激活度范围为0-0.5，0.5以上都显示为0.5的颜色
                activation_clamped = min(activation, 0.5);
                
                % 根据激活度设置颜色（热色图：黑-红-黄）
                % 将0-0.5映射到0-1的颜色范围
                color_intensity = activation_clamped / 0.5;
                muscle_color = [color_intensity, color_intensity*0.5, 0]; % 红色系
                muscle_color = min(muscle_color, 1); % 确保不超过1
                
                % 计算肌肉几何位置
                px = []; py = []; pz = [];
                linex = []; liney = []; linez = [];
                
                if ~isfield(muscles_new, muscle_name) || ~isfield(muscles_new.(muscle_name), 'geometry')
                    continue;
                end
                
                muscle_pts = muscles_new.(muscle_name).geometry;
                
                for idx_pt = 1:length(muscle_pts)
                    muscle_pt = muscle_pts{idx_pt};
                    
                    % 检查必要字段是否存在
                    if ~isfield(muscle_pt, 'frame') || ~isfield(muscle_pt, 'location')
                        continue;
                    end
                    
                    if ~isfield(segments_RM, muscle_pt.frame) || ...
                       ~isfield(segments_length, muscle_pt.frame) || ...
                       ~isfield(segments_origin, muscle_pt.frame)
                        continue;
                    end
                    
                    r = segments_RM.(muscle_pt.frame){current_frame};
                    l = segments_length.(muscle_pt.frame)(current_frame);
                    origin = segments_origin.(muscle_pt.frame)(current_frame, :);
                    aux = l * muscle_pt.location * r' + origin;
                    px(end+1) = aux(1); py(end+1) = aux(2); pz(end+1) = aux(3);
                    
                    if idx_pt > 1
                        linex = [linex, [px(end-1), px(end)]];
                        liney = [liney, [py(end-1), py(end)]];
                        linez = [linez, [pz(end-1), pz(end)]];
                    end
                end
                
                % 绘制肌肉线条
                if ~isempty(linex)
                    line_width = 3 + activation_clamped * 10; % 线宽随激活度变化
                    plot3(ax_pose, linex, liney, linez, 'Color', muscle_color, ...
                        'LineWidth', line_width);
                end
                
                % 绘制肌肉节点
                if ~isempty(px)
                    plot3(ax_pose, px, py, pz, 'o', 'Color', muscle_color, ...
                        'MarkerSize', 4, 'MarkerFaceColor', muscle_color);
                end
            end
        catch ME
            % 如果绘制肌肉失败，显示警告
            fprintf('绘制肌肉时发生错误: %s\n', ME.message);
        end
    end

    function updateActivationDisplay()
        if ~isvalid(ax_activation)
            return;
        end
        
        cla(ax_activation);
        
        % 显示当前帧选定肌肉的激活度柱状图
        activation_values = [];
        muscle_labels = {};
        
        for i = 1:length(selected_muscles)
            muscle_name = selected_muscles{i};
            if isfield(muscle_activations, muscle_name)
                activation_values(end+1) = muscle_activations.(muscle_name)(current_frame);
                muscle_labels{end+1} = muscle_name;
            end
        end
        
        if ~isempty(activation_values)
            % 生成足够大的颜色映射表
            color_map = hot(256); % 使用256个颜色级别
            
            for i = 1:length(activation_values)
                % 根据激活度值选择颜色，确保索引在有效范围内
                color_idx = max(1, min(256, round(activation_values(i) * 255) + 1));
                bar(ax_activation, i, activation_values(i), 'FaceColor', color_map(color_idx, :), ...
                    'EdgeColor', 'black', 'LineWidth', 1.5);
                hold(ax_activation, 'on');
            end
            
            set(ax_activation, 'XTick', 1:length(muscle_labels), 'XTickLabel', muscle_labels, ...
                'XTickLabelRotation', 45, 'FontName', font_name, 'FontSize', 9, ...
                'Box', 'on', 'LineWidth', 2, ...
                'XColor', [0.15, 0.15, 0.15], 'YColor', [0.15, 0.15, 0.15]);
            ylabel(ax_activation, '激活度', 'FontName', font_name, 'FontSize', 11, 'FontWeight', 'bold');
            title(ax_activation, sprintf('当前帧肌肉激活度 (帧 %d)', current_frame), ...
                'FontName', font_name, 'FontSize', 11, 'FontWeight', 'bold');
            ylim(ax_activation, [0, 1]);
            grid(ax_activation, 'on');
            hold(ax_activation, 'off');
        end
    end

    function updateMuscleCharacteristicCurves()
        % 绘制力-长度关系曲线 (fl)
        updateForceLengthCurve();
        
        % 绘制力-速度关系曲线 (fv)
        updateForceVelocityCurve();
        
        % 绘制被动力关系曲线 (fpe)
        updatePassiveForceCurve();
    end

    function updateForceLengthCurve()
        if ~isvalid(ax_fl)
            return;
        end
        
        cla(ax_fl);
        hold(ax_fl, 'on');
        
        % 归一化纤维长度范围
        l_normal = 0:0.01:2.5;
        
        % 力-长度关系方程 (Hill-type模型的典型fl曲线)
        % 使用高斯函数形式: fl = exp(-((l_normal - 1)^2) / (2 * width^2))
        width = 0.45; % 控制曲线宽度
        fl_curve = exp(-((l_normal - 1).^2) / (2 * width^2));
        
        plot(ax_fl, l_normal, fl_curve, 'b-', 'LineWidth', 3);
        
        % 使用支持中文的字体，减小字体大小，增强边框
        xlabel(ax_fl, '归一化纤维长度', 'FontName', font_name, 'FontSize', 10, 'FontWeight', 'bold');
        ylabel(ax_fl, 'f_l 值', 'FontName', font_name, 'FontSize', 10, 'FontWeight', 'bold');
        title(ax_fl, '力-长度关系曲线', 'FontName', font_name, 'FontSize', 11, 'FontWeight', 'bold');
        set(ax_fl, 'FontName', font_name, 'FontSize', 9, ...
            'Box', 'on', 'LineWidth', 2, ...
            'XColor', [0.15, 0.15, 0.15], 'YColor', [0.15, 0.15, 0.15]);
        grid(ax_fl, 'on');
        xlim(ax_fl, [0, 2.5]);
        ylim(ax_fl, [0, 1.2]);
        
        hold(ax_fl, 'off');
    end

    function updateForceVelocityCurve()
        if ~isvalid(ax_fv)
            return;
        end
        
        cla(ax_fv);
        hold(ax_fv, 'on');
        
        % 归一化纤维速度范围
        v_normal = -1:0.01:1;
        
        % 力-速度关系方程 (Hill方程)
        % fv = (v_max - v_normal) / (v_max + k * v_normal) for v_normal >= 0 (向心收缩)
        % fv = (1 + a * v_normal) for v_normal < 0 (离心收缩)
        
        v_max = 10; % 最大收缩速度参数
        k = 0.25;   % 形状参数
        a = 0.25;   % 离心收缩参数
        
        fv_curve = zeros(size(v_normal));
        
        % 离心收缩 (v_normal < 0)
        idx_eccentric = v_normal < 0;
        fv_curve(idx_eccentric) = 1 + a * abs(v_normal(idx_eccentric));
        
        % 向心收缩 (v_normal >= 0)
        idx_concentric = v_normal >= 0;
        fv_curve(idx_concentric) = (v_max - v_normal(idx_concentric)) ./ (v_max + k * v_normal(idx_concentric));
        
        plot(ax_fv, v_normal, fv_curve, 'r-', 'LineWidth', 3);
        
        % 使用支持中文的字体，减小字体大小，增强边框
        xlabel(ax_fv, '归一化纤维速度', 'FontName', font_name, 'FontSize', 10, 'FontWeight', 'bold');
        ylabel(ax_fv, 'f_v 值', 'FontName', font_name, 'FontSize', 10, 'FontWeight', 'bold');
        title(ax_fv, '力-速度关系曲线', 'FontName', font_name, 'FontSize', 11, 'FontWeight', 'bold');
        set(ax_fv, 'FontName', font_name, 'FontSize', 9, ...
            'Box', 'on', 'LineWidth', 2, ...
            'XColor', [0.15, 0.15, 0.15], 'YColor', [0.15, 0.15, 0.15]);
        grid(ax_fv, 'on');
        xlim(ax_fv, [-1, 1]);
        ylim(ax_fv, [0, 2]);
        
        hold(ax_fv, 'off');
    end

    function updatePassiveForceCurve()
        if ~isvalid(ax_fpe)
            return;
        end
        
        cla(ax_fpe);
        hold(ax_fpe, 'on');
        
        % 归一化纤维长度范围
        l_normal = 0:0.01:2.5;
        
        % 被动力关系方程 (指数函数形式)
        % fpe = k * (exp(c * (l_normal - l0)) - 1) for l_normal > l0, else 0
        
        l0 = 1.0;   % 松弛长度
        k = 0.5;    % 刚度参数
        c = 3.0;    % 指数参数
        
        fpe_curve = zeros(size(l_normal));
        idx_stretch = l_normal > l0;
        fpe_curve(idx_stretch) = k * (exp(c * (l_normal(idx_stretch) - l0)) - 1);
        
        plot(ax_fpe, l_normal, fpe_curve, 'g-', 'LineWidth', 3);
        
        % 使用支持中文的字体，减小字体大小，增强边框
        xlabel(ax_fpe, '归一化纤维长度', 'FontName', font_name, 'FontSize', 10, 'FontWeight', 'bold');
        ylabel(ax_fpe, 'f_{pe} 值', 'FontName', font_name, 'FontSize', 10, 'FontWeight', 'bold');
        title(ax_fpe, '被动力-长度关系曲线', 'FontName', font_name, 'FontSize', 11, 'FontWeight', 'bold');
        set(ax_fpe, 'FontName', font_name, 'FontSize', 9, ...
            'Box', 'on', 'LineWidth', 2, ...
            'XColor', [0.15, 0.15, 0.15], 'YColor', [0.15, 0.15, 0.15]);
        grid(ax_fpe, 'on');
        xlim(ax_fpe, [0, 2.5]);
        ylim(ax_fpe, [0, 5]);
        
        hold(ax_fpe, 'off');
    end

end