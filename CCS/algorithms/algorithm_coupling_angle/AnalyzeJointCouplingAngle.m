function [ratios] = AnalyzeJointCouplingAngle(cellSegs,str_proximal,str_distal,name_proximal,name_distal,show_fig)
if nargin<6, show_fig = false; end

time_interp = 0:0.01:1;
n = length(time_interp);
jas_proximal = zeros(length(cellSegs),n);
jas_distal = zeros(length(cellSegs),n);
jcs_interp = zeros(length(cellSegs),n);
for idxSeg = 1:length(cellSegs)
    seg = cellSegs{idxSeg};
    eval(['ja_proximal = ',str_proximal,';']);
    eval(['ja_distal = ',str_distal,';']);
    jc = CalJointCouplingAngle(ja_proximal,ja_distal);
    time = seg.time(2:end);
    jc_interp = interp1((time-time(1))./range(time),jc,0:0.01:1);
    jcs_interp(idxSeg,:) = jc_interp;

    time = seg.time;
    ja_proximal = interp1((time-time(1))./range(time),ja_proximal,0:0.01:1);
    ja_distal = interp1((time-time(1))./range(time),ja_distal,0:0.01:1);
    jas_proximal(idxSeg,:) = ja_proximal;
    jas_distal(idxSeg,:) = ja_distal;
end

xi = cosd(jcs_interp);
yi = sind(jcs_interp);

xi_mean = mean(xi);
yi_mean = mean(yi);

jc_mean = zeros(n,1);
for i = 1:n
    xi = xi_mean(i); yi = yi_mean(i);
    if xi<0
        jc_mean(i) = atand(yi/xi)+180;
    elseif xi>0
        if yi>0
            jc_mean(i) = atand(yi/xi);
        else
            jc_mean(i) = atand(yi/xi)+360;
        end
    else
        if yi>0
            jc_mean(i) = 90;
        else
            jc_mean(i) = -90;
        end

    end
end

length_jc = (xi_mean.^2+yi_mean.^2).^0.5;
CAV = (2*(1-length_jc)).^0.5*180/pi;
ja_proximal = mean(jas_proximal);
ja_distal = mean(jas_distal);

%% 协调模式分类（依据Hamill等, 2000; Needham等, 2015）
% 根据平均耦合角进行四象限分类
quadrant = zeros(size(jc_mean));
for i = 1:length(jc_mean)
    jc = jc_mean(i);
    if (jc >= 22.5 && jc < 67.5) || (jc >= 202.5 && jc < 247.5)
        quadrant(i) = 1; % 同向
    elseif (jc >= 112.5 && jc < 157.5) || (jc >= 292.5 && jc < 337.5)
        quadrant(i) = 2; % 反向
    elseif (jc >= 67.5 && jc < 112.5) || (jc >= 247.5 && jc < 292.5)
        quadrant(i) = 3; % 远端主导
    elseif (jc >= 157.5 && jc < 202.5) || (jc >= 337.5 && jc <= 360) || (jc >= 0 && jc < 22.5)
        quadrant(i) = 4; % 近端主导
    else
        quadrant(i) = 0;
    end
end

% 统计每个类别的数量及比例
total = length(quadrant);
categories = [1 2 3 4];
category_names = {'In-phase', 'Anti-phase', 'Distal', 'Proximal'};
fprintf('\n各类别所占比例：\n');
ratios = zeros(4,1);
for idx = 1:length(categories)
    count = sum(quadrant == categories(idx));
    ratios(idx) = count / total;
    fprintf('%s: %.1f%% (%d/%d)\n', category_names{idx}, ratios(idx)*100, count, total);
end


if show_fig
    %% 绘制学术风格的关节协调分析图
    figure('Position', [100, 100, 1400, 900], 'Color', 'w');
    
    % 设置学术论文风格的颜色方案
    color_proximal = [0.00, 0.45, 0.74];  % 蓝色 - 近端关节
    color_distal = [0.85, 0.33, 0.10];    % 橙红色 - 远端关节
    color_coupling = [
        0.47, 0.67, 0.19;   % In-phase: 绿色
        0.85, 0.33, 0.10;   % Anti-phase: 橙红色
        0.00, 0.45, 0.74;   % Distal: 蓝色
        0.93, 0.69, 0.13    % Proximal: 金色
    ];  % 四种象限不同色
    color_cav = [0.93, 0.69, 0.13];       % 金色 - CAV
    
    % 子图1: 关节角度变化
    subplot(3, 2, [1, 2]);
    hold on; grid on; box on;
    h1 = plot(time_interp*100, ja_proximal, '-', 'LineWidth', 2.5, 'Color', color_proximal);
    h2 = plot(time_interp*100, ja_distal, '-', 'LineWidth', 2.5, 'Color', color_distal);
    
    % 添加标准差阴影（如果有多个trial）
    if size(jas_proximal, 1) > 1
        std_proximal = std(jas_proximal, 0, 1);
        std_distal = std(jas_distal, 0, 1);
        fill([time_interp*100, fliplr(time_interp*100)], ...
             [ja_proximal+std_proximal, fliplr(ja_proximal-std_proximal)], ...
             color_proximal, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        fill([time_interp*100, fliplr(time_interp*100)], ...
             [ja_distal+std_distal, fliplr(ja_distal-std_distal)], ...
             color_distal, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    end
    
    xlabel('Normalized Time (% Cycle)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Joint Angle (deg)', 'FontSize', 12, 'FontWeight', 'bold');
    title('(A) Joint Angle Trajectories', 'FontSize', 13, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    legend([h1, h2], {['Proximal (',name_proximal,')'], ['Distal (',name_distal,')']}, 'Location', 'best', 'FontSize', 10);
    set(gca, 'FontSize', 11, 'LineWidth', 1.5);
    xlim([0, 100]);
    
    % 子图2: 耦合角变化
    subplot(3, 2, [3, 4]);
    hold on; grid on; box on;
    h3 = plot(time_interp(quadrant==1)*100, jc_mean(quadrant==1), 'o', 'LineWidth', 2.5, 'Color', color_coupling(1,:), 'DisplayName', 'In-phase');
    h4 = plot(time_interp(quadrant==2)*100, jc_mean(quadrant==2), 'o', 'LineWidth', 2.5, 'Color', color_coupling(2,:), 'DisplayName', 'Anti-phase');
    h5 = plot(time_interp(quadrant==3)*100, jc_mean(quadrant==3), 'o', 'LineWidth', 2.5, 'Color', color_coupling(3,:), 'DisplayName', 'Distal');
    h6 = plot(time_interp(quadrant==4)*100, jc_mean(quadrant==4), 'o', 'LineWidth', 2.5, 'Color', color_coupling(4,:), 'DisplayName', 'Proximal');
    
    % 添加四象限参考线
    yline(45, '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1, 'Alpha', 0.5);
    yline(135, '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1, 'Alpha', 0.5);
    yline(225, '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1, 'Alpha', 0.5);
    yline(315, '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1, 'Alpha', 0.5);
    
    % 添加象限标注
    text(5, 45, 'In-phase', 'FontSize', 8, 'Color', [0.5, 0.5, 0.5]);
    text(5, 135, 'Anti-phase', 'FontSize', 8, 'Color', [0.5, 0.5, 0.5]);
    text(5, 225, 'In-phase', 'FontSize', 8, 'Color', [0.5, 0.5, 0.5]);
    text(5, 315, 'Anti-phase', 'FontSize', 8, 'Color', [0.5, 0.5, 0.5]);
    
    xlabel('Normalized Time (% Cycle)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Coupling Angle (deg)', 'FontSize', 12, 'FontWeight', 'bold');
    title('(B) Coupling Angle Trajectory', 'FontSize', 13, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    set(gca, 'FontSize', 11, 'LineWidth', 1.5);
    xlim([0, 100]);
    ylim([0, 360]);
    yticks([0, 45, 90, 135, 180, 225, 270, 315, 360]);
    
    legend([h3, h4, h5, h6], 'Location', 'best', 'FontSize', 10);
    
    % 子图3: 耦合角变异性 (CAV)
    subplot(3, 2, [5, 6]);
    hold on; grid on; box on;
    h7 = plot(time_interp*100, CAV, '-', 'LineWidth', 2.5, 'Color', color_cav);
    
    % 添加高变异性参考线
    mean_cav = mean(CAV);
    yline(mean_cav, '--', sprintf('Mean = %.2f°', mean_cav), ...
          'Color', [0.5, 0.5, 0.5], 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');
    
    xlabel('Normalized Time (% Cycle)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('CAV (deg)', 'FontSize', 12, 'FontWeight', 'bold');
    title('(C) Coupling Angle Variability', 'FontSize', 13, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    set(gca, 'FontSize', 11, 'LineWidth', 1.5);
    xlim([0, 100]);
    ylim([0, max(CAV)*1.2]);
    
    % 添加总标题
    sgtitle(['Joint Coordination Analysis: ',name_proximal,'-',name_proximal,' Coupling'], ...
            'FontSize', 15, 'FontWeight', 'bold');
    
    % 调整子图间距
    set(gcf, 'PaperPositionMode', 'auto');
    
    hold off;
    
    %% 绘制每个类别占比的柱状图
    figure;
    hold on; grid on; box on;
    h8 = bar(1:length(categories), 100*ratios, 'FaceColor', [0.85 0.85 0.85]); % 浅灰色
    set(gca, 'XTick', 1:length(categories), 'XTickLabel', category_names);
    
    % 在每根柱子上方标注百分比
    for i = 1:length(categories)
        pct = 100 * ratios(i);
        text(categories(i), pct + 2, sprintf('%.1f%%', pct), ...
            'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
    end
    
    xlabel('Coordination Pattern', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Percentage (%)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Percentage of Each Category', 'FontSize', 13, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    set(gca, 'FontSize', 11, 'LineWidth', 1.5);
    xlim([0, 5]);
    ylim([0, 100]);
    hold off;

end