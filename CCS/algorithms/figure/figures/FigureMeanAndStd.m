function FigureMeanAndStd(time_curves, mean_curves, std_curves, time_stages, str_paras, idxParas, colors, fig_options)

if nargin<8
    figure_name = [];
    for i = idxParas
        figure_name = [figure_name, str_paras{i}, '; '];
    end
    figure_name(end-1:end) = [];
    figure_name = strrep(figure_name,'seg.','');
    figure_name = upper(figure_name);


    legend_names = str_paras(idxParas);
    for j = 1:length(legend_names)
        legend_names{j} = strrep(legend_names{j},'seg.','');
    end
    
    y_name = 'Signal Amplitude';
else
    figure_name = fig_options.figure_name;
    legend_names = fig_options.legend_names;
    y_name = fig_options.y_name;
end

% Create figure with white background and appropriate size
f = figure('Color', 'white', 'Position', [100, 100, 1280, 960]);

% Create 3 subplots with equal size
subplot_handles = [];
h_mean_all = []; % Store all line handles for the shared legend

% Define number of subplots
num_plots = 3;

% Dividing the parameters into groups for each subplot
% If the number of parameters is less than 3, adjust accordingly
total_params = length(idxParas);
params_per_plot = ceil(total_params / num_plots);

for plot_idx = 1:num_plots
    % Calculate parameter indices for this subplot
    start_idx = (plot_idx-1) * params_per_plot + 1;
    end_idx = min(plot_idx * params_per_plot, total_params);
    
    % If we've run out of parameters, break
    if start_idx > total_params
        break;
    end
    
    % Create subplot
    ax = subplot(num_plots, 1, plot_idx);
    subplot_handles(plot_idx) = ax;
    
    hold(ax, 'on');
    
    h_mean = []; % Store line handles for this subplot
    y_min = []; y_max = [];
    
    % Loop through parameters for this subplot
    for k = start_idx:end_idx
        param_idx = k - start_idx + 1; % Index relative to this subplot
        idxPara = idxParas(k);
        time = time_curves{idxPara};
        signal_mean = mean_curves{idxPara};
        signal_std = std_curves{idxPara};
        time_stage = time_stages{idxPara};
        
        % Draw standard deviation area (light shaded area)
        fill(ax, [time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
            colors(param_idx+1,:) * 0.7 + 0.3, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        
        % Draw stage marker lines and label x-coordinate values
        for j = 1:length(time_stage)
            xline(ax, time_stage(j), 'LineWidth', 1.5, 'LineStyle', '-.', ...
                'Color', [0.80 0.40 0.40], ...
                'Label', sprintf('%.1f', time_stage(j)), ...
                'LabelOrientation', 'horizontal', ...
                'LabelHorizontalAlignment', 'left', ...
                'LabelVerticalAlignment', 'bottom');
        end
        
        % Draw mean line (dark solid line)
        h = plot(ax, time, signal_mean, 'LineWidth', 2.5, 'Color', colors(k+1,:));
        h_mean = [h_mean, h];
        h_mean_all = [h_mean_all, h]; % Store for shared legend
        
        y_min(end+1) = min(mean_curves{idxPara}(1,:)-std_curves{idxPara}(1,:))-range(mean_curves{idxPara}(1,:))./3;
        y_max(end+1) = max(mean_curves{idxPara}(1,:)+std_curves{idxPara}(1,:))+range(mean_curves{idxPara}(1,:))./3;
    end
    
    % Set subplot properties
    grid(ax, 'on');
    box(ax, 'on');
    set(ax, 'FontSize', 12, 'FontName', 'Arial', 'LineWidth', 1.5, ...
        'XMinorTick', 'on', 'YMinorTick', 'on');
    
    % Only add x-label to the bottom subplot
    if plot_idx == num_plots
        xlabel(ax, 'Time / s', 'FontSize', 10);
    end
    
    ylabel(ax, y_name, 'FontSize', 10, 'Interpreter', 'latex');
    xlim(ax, [0 2.5]);
    
    % Add title to the top subplot
    if plot_idx == 1
        title(ax, figure_name, 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');
    end
end

% Create shared legend below the middle subplot
if num_plots > 1
    % Create a new axis for legend only
    leg_pos = get(subplot_handles(ceil(num_plots/2)), 'Position');
    leg_width = leg_pos(3);
    leg_height = 0.05; % Height of legend area
    leg_x = leg_pos(1);
    leg_y = leg_pos(2) - leg_height - 0.05; % Position below the middle subplot
    
    legend_ax = axes('Position', [leg_x, leg_y, leg_width, leg_height]);
    legend_ax.Visible = 'off'; % Hide the axes, show only the legend
    
    % Create a dummy plot with the same line styles and colors
    dummy_h = zeros(size(h_mean_all));
    for i = 1:length(h_mean_all)
        dummy_h(i) = plot(legend_ax, [0, 1], [0, 0], 'LineWidth', 2.5, 'Color', get(h_mean_all(i), 'Color'));
        set(dummy_h(i), 'Visible', 'off'); % Hide the lines
    end
    
    % Create the legend on this axes
    legend(legend_ax, dummy_h, legend_names, 'Orientation', 'horizontal', 'FontSize', 10, 'Interpreter', 'latex');
else
    % If there's only one subplot, create legend within it
    legend(subplot_handles(1), h_mean_all, legend_names, 'Location', 'southoutside', 'FontSize', 10, 'Interpreter', 'latex');
end

% Save the figure
print(f, ['./outputs/images mean std/',figure_name,'.png'],'-dpng','-r300');

