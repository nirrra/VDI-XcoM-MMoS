f = figure('Color', 'white', 'Position', [100, 100, 1280, 960]); % 白色背景，适当大小

idxs_para = {[49,52:54], [57,60:62]};
y_names = {'% BW','% BW'};

i_names = {'JP','JW'};
j_names = {'MT','ETF','DVR'};
legend_names = {'Hip Flexion','Knee Flexion','Ankle Dorsiflexion','Lumbar Extension'};

for i = 1:2
    for j = 2:4
        subplot(3,2,2*(j-2)+i);
        idxParas = idxs_para{i};
        hold on;
        h_mean = []; % 存储均值线句柄
    
        for k = 1:length(idxParas)
            idxPara = idxParas(k);
            time = time_curves{idxPara}(j,:);
            signal_mean = mean_curves{idxPara}(j,:);
            signal_std = std_curves{idxPara}(j,:);
            time_stage = time_stages{idxPara}(j,:);
    
            % 绘制标准差区域（浅色阴影）
            fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
                colors(k+1,:) * 0.7 + 0.3, 'EdgeColor', 'none', 'FaceAlpha', 0.3); % 浅色半透明区域
    
            %     xline(time_stage, 'LineWidth', 1.5, 'LineStyle', '-.' , 'Color', [0.80 0.40 0.40]);
            % 绘制阶段标记线并标注横坐标值
            for m = 1:length(time_stage)
                xline(time_stage(m), 'LineWidth', 1.5, 'LineStyle', '-.', ...
                      'Color', [0.80 0.40 0.40], ...
                      'Label', sprintf('%.1f', time_stage(m)), ...
                      'LabelOrientation', 'horizontal', ...
                      'LabelHorizontalAlignment', 'left', ...  
                      'LabelVerticalAlignment', 'bottom');     
            end
            
            % 绘制均值线（深色实线）
            h = plot(time, signal_mean, 'LineWidth', 2.5, 'Color', colors(k+1,:)); % 深色实线
            h_mean = [h_mean, h];
    
        end
           
        % 设置图形属性
        grid on;
        box on;
        set(gca, 'FontSize', 12, 'FontName', 'Arial', 'LineWidth', 1.5, ...
            'XMinorTick', 'on', 'YMinorTick', 'on');
        xlabel('Time / s', 'FontSize', 10);
        ylabel(y_names{i}, 'FontSize', 10);
    
        xlim([0 2.5]);
    %     ylim([min(y_min),max(y_max)]);
    
        title([i_names{i},': ',j_names{j-1}]);
    
    %     legend(h_mean, legend_names, 'Location', 'southoutside', 'FontSize', 10, 'Interpreter', 'none');
        legend(h_mean, legend_names, 'Location', 'southoutside', 'FontSize', 10, 'Interpreter', 'latex');
    end

    % 获取所有子图的y轴范围并统一设置
    all_ylim = [];
    for j = 2:4
        subplot(3,length(idxs_para),length(idxs_para)*(j-2)+i);
        ylim_current = ylim;
        all_ylim = [all_ylim; ylim_current];
    end

    % 计算最大最小范围
    y_min = min(all_ylim(:,1));
    y_max = max(all_ylim(:,2));

    % 统一设置y轴范围
    for j = 2:4
        subplot(3,length(idxs_para),length(idxs_para)*(j-2)+i);
        ylim([y_min y_max]);
    end
end

sgtitle('The Average Trends of Components of P-XcoM', 'FontSize', 16, 'FontWeight', 'bold');

print(f, './outputs/components.png','-dpng','-r300');