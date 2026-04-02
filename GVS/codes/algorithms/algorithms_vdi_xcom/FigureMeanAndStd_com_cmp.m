function FigureMeanAndStd_com_cmp(cellSegs_MT, cellSegs_ETF, cellSegs_DVR, fig_options)
% 基于分段平均趋势作图（MT/ETF/DVR）

    if ~isfield(fig_options, 'str_paras') || isempty(fig_options.str_paras)
        error('fig_options.str_paras is required.');
    end
    str_paras = fig_options.str_paras;

    if ~isfield(fig_options, 'idxParas') || isempty(fig_options.idxParas)
        idxParas = 1:length(str_paras);
    else
        idxParas = fig_options.idxParas;
    end

    if ~isfield(fig_options, 'colors') || isempty(fig_options.colors)
        fig_options.colors = default_color_palette(length(idxParas));
    end

    cellSegs_all = [cellSegs_MT; cellSegs_ETF; cellSegs_DVR];
    n_mt = length(cellSegs_MT);
    n_etf = length(cellSegs_ETF);
    n_dvr = length(cellSegs_DVR);
    idxs_sts = { ...
        1:length(cellSegs_all), ...
        1:n_mt, ...
        n_mt + (1:n_etf), ...
        n_mt + n_etf + (1:n_dvr) ...
    };

    mean_curves = cell(length(str_paras), 1);
    std_curves = cell(length(str_paras), 1);
    time_curves = cell(length(str_paras), 1);
    time_stages = cell(length(str_paras), 1);
    for i = 1:length(str_paras)
        str_para = str_paras{i};
        [mean_curves{i}, std_curves{i}, time_curves{i}, time_stages{i}] = ...
            GetAverageCurves_ComCmp(cellSegs_all, idxs_sts, str_para);
    end

    output_dir = fullfile('outputs', 'images mean std');
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    FigureMeanAndStd_Color(time_curves, mean_curves, std_curves, time_stages, ...
        str_paras, idxParas, fig_options);
end

function [mean_curves, std_curves, time_curves, time_stages] = GetAverageCurves_ComCmp(cellSegs, idxs_sts, str_para)
    mean_curves = [];
    std_curves = [];
    time_curves = [];
    time_stages = [];

    for idxSTS = 1:4
        mean_curve = [];
        std_curve = [];
        time_curve = [0];
        time_stage = [0];

        for idxStage = 1:3
            [datas_interp, time_mean] = GetAverageCurve_Segment_ComCmp(cellSegs(idxs_sts{idxSTS}), str_para, idxStage);
            if isempty(datas_interp)
                mean_data = nan(1, 101);
                std_data = nan(1, 101);
                time_mean = 0;
            else
                mean_data = mean(datas_interp, 1);
                std_data = std(datas_interp, 0, 1);
                if isempty(time_mean) || ~isfinite(time_mean)
                    time_mean = 0;
                end
            end

            mean_curve = [mean_curve, mean_data];
            std_curve = [std_curve, std_data];
            time_curve = [time_curve, time_curve(end) + linspace(0, time_mean, numel(mean_data))];
            time_stage(end+1) = time_stage(end) + time_mean;
        end

        time_curve(1) = [];
        mean_curves = [mean_curves; mean_curve];
        std_curves = [std_curves; std_curve];
        time_curves = [time_curves; time_curve];
        time_stages = [time_stages; time_stage];
    end
end

function FigureMeanAndStd_Color(time_curves, mean_curves, std_curves, time_stages, ~, idxParas, fig_options)
    figure_name = fig_options.figure_name;
    legend_names = fig_options.legend_names;
    y_name = fig_options.y_name;

    line_styles = {'-','--','-.',':'};
    font_name = get_or_default(fig_options, 'font_name', 'Times New Roman');
    font_size = get_or_default(fig_options, 'font_size', 15);
    axis_line_width = get_or_default(fig_options, 'axis_line_width', 1.2);
    line_width = get_or_default(fig_options, 'line_width', 1.8);
    stage_line_width = get_or_default(fig_options, 'stage_line_width', 2.0);
    fill_alpha = get_or_default(fig_options, 'fill_alpha', 0.18);

    flag_bw = get_or_default(fig_options, 'flag_bw', false);
    flag_std = get_or_default(fig_options, 'flag_std', true);
    colors = fig_options.colors;
    if flag_bw
        [colors, line_styles] = bw_line_palette(length(idxParas));
        fill_alpha = min(fill_alpha, 0.12);
    end
    f = figure('Color', 'white', 'Position', [100, 100, 1280, 480]);
    title_names = {'All','MT','ETF','DVR'};

    pos = [0.06 0.25 0.26 0.6]; w = 0.325;
    all_y_min = [];
    all_y_max = [];

    for i = 2:4
        axes('Position',[pos(1)+w*(i-2),pos(2),pos(3),pos(4)]);
        grid on;
        box on;
        set(gca, 'FontSize', font_size, 'FontName', font_name, 'LineWidth', axis_line_width, ...
            'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');
        hold on;

        h_mean = [];
        y_min = []; y_max = [];

        for k = 1:length(idxParas)
            idxPara = idxParas(k);
            time = time_curves{idxPara}(i,:);
            signal_mean = mean_curves{idxPara}(i,:);
            signal_std = std_curves{idxPara}(i,:);
            time_stage = time_stages{idxPara}(i,:);

            if flag_std
                fill([time, fliplr(time)], [signal_mean + signal_std, fliplr(signal_mean - signal_std)], ...
                    colors(k,:) * 0.6 + 0.4, 'EdgeColor', 'none', 'FaceAlpha', fill_alpha);
            end

            for j = 1:length(time_stage)
                xline(time_stage(j), 'LineWidth', stage_line_width, 'LineStyle', ':', ...
                    'Color', [0.5 0.5 0.5]);
            end

            style_idx = mod(k-1, length(line_styles)) + 1;
            h = plot(time, signal_mean, 'LineWidth', line_width, ...
                'Color', colors(k,:), 'LineStyle', line_styles{style_idx});
            h_mean = [h_mean, h];

            current_y_min = min(signal_mean - signal_std);
            current_y_max = max(signal_mean + signal_std);
            y_min(end+1) = current_y_min;
            y_max(end+1) = current_y_max;
        end

        all_y_min = [all_y_min, min(y_min)];
        all_y_max = [all_y_max, max(y_max)];

        xlabel('Time / s', 'FontSize', font_size, 'FontName', font_name);
        ylabel(y_name, 'FontSize', font_size, 'FontName', font_name);
        xlim([0 2.5]);
        title(title_names{i}, 'FontName', font_name);
    end

    global_y_min = min(all_y_min) - 0.05 * range([min(all_y_min), max(all_y_max)]);
    global_y_max = max(all_y_max) + 0.05 * range([min(all_y_min), max(all_y_max)]);
    for i = 1:3
        ax = findobj(f, 'Type', 'axes', 'Position', [pos(1)+w*(i-1), pos(2), pos(3), pos(4)]);
        ylim(ax, [global_y_min, global_y_max]);
    end

    legend(h_mean, legend_names, 'Location','southoutside', ...
        'Position',[pos(1)+1.25*w, pos(2)-0.23, 0.1, 0.1], ...
        'FontSize', font_size, 'FontName', font_name, 'Orientation', 'horizontal', 'Box', 'off');

    print(f, fullfile('outputs', 'images mean std', [figure_name, '.png']), '-dpng', '-r600');
end

function v = get_or_default(s, field, default_value)
    if isfield(s, field) && ~isempty(s.(field))
        v = s.(field);
    else
        v = default_value;
    end
end

function colors = default_color_palette(n)
    base = [ ...
        0.00, 0.45, 0.74; ...
        0.85, 0.33, 0.10; ...
        0.47, 0.67, 0.19; ...
        0.49, 0.18, 0.56; ...
        0.30, 0.75, 0.93; ...
        0.93, 0.69, 0.13 ...
    ];
    if n <= size(base,1)
        colors = base(1:n,:);
    else
        colors = lines(n);
    end
end

function [colors, line_styles] = bw_line_palette(n)
    if n <= 0
        colors = zeros(0, 3);
        line_styles = {};
        return;
    end

    if n == 1
        colors = [0.00, 0.00, 0.00];
        line_styles = {'-'};
        return;
    elseif n == 2
        colors = [ ...
            0.78, 0.78, 0.78; ...
            0.00, 0.00, 0.00 ...
        ];
        line_styles = {'-','--'};
        return;
    elseif n == 3
        colors = [ ...
            0.78, 0.78, 0.78; ...
            0.40, 0.40, 0.40; ...
            0.00, 0.00, 0.00 ...
        ];
        line_styles = {'-','-.','-'};
        return;
    end

    bw_colors = [ ...
        0.40, 0.40, 0.40; ...
        0.78, 0.78, 0.78; ...
        0.00, 0.00, 0.00; ...
        0.00, 0.00, 0.00 ...
    ];
    bw_styles = {'-','-','--','-'};
    colors = zeros(n, 3);
    line_styles = cell(1, n);
    for i = 1:n
        idx = mod(i-1, 4) + 1;
        colors(i, :) = bw_colors(idx, :);
        line_styles{i} = bw_styles{idx};
    end
end

function [datas_interp, time_mean] = GetAverageCurve_Segment_ComCmp(cellSegs, str_para, idxStage)
    time_interp = 0:0.01:1;
    datas_interp = zeros(0, length(time_interp));
    time_mean = [];

    for idxSeg = 1:length(cellSegs)
        seg = cellSegs{idxSeg};

        if ~isfield(seg, 'time_sts')
            continue;
        end
        t_start = seg.time_sts.time_start;
        t_seat_off = seg.time_sts.time_seat_off;
        t_min = seg.time_sts.time_min_grf_plantar;
        t_end = seg.time_sts.time_end;

        if idxStage == 1
            t1 = t_start; t2 = t_seat_off;
        elseif idxStage == 2
            t1 = t_seat_off; t2 = t_min;
        else
            t1 = t_min; t2 = t_end;
        end

        data = get_nested_field(seg, str_para);
        if isempty(data)
            continue;
        end
        data = data(:);

        time = [];
        if isfield(seg, 'times')
            if isfield(seg.times, 'vicon') && numel(seg.times.vicon) == numel(data)
                time = seg.times.vicon;
            elseif isfield(seg.times, 'union') && numel(seg.times.union) == numel(data)
                time = seg.times.union;
            end
        end
        if isempty(time)
            if isfield(seg, 'times') && isfield(seg.times, 'vicon')
                time = seg.times.vicon;
            elseif isfield(seg, 'times') && isfield(seg.times, 'union')
                time = seg.times.union;
            else
                continue;
            end
        end

        aux = GetIdxTime(time, [t1, t2]);
        if isempty(aux) || numel(aux) < 2
            continue;
        end
        period = aux(1):aux(2);
        if numel(period) < 2
            continue;
        end

        time_seg = time(period);
        time_mean(end+1) = range(time_seg);
        time_norm = (time_seg - time_seg(1)) ./ max(eps, range(time_seg));
        data_seg = data(period);
        data_interp = interp1(time_norm, data_seg, time_interp, 'linear', 'extrap');
        datas_interp(end+1, :) = data_interp;
    end

    if ~isempty(time_mean)
        time_mean = mean(time_mean);
    end
end

function data = get_nested_field(seg, str_para)
    field_path = strrep(str_para, 'seg.', '');
    parts = strsplit(field_path, '.');
    data = seg;
    for i = 1:length(parts)
        if isstruct(data) && isfield(data, parts{i})
            data = data.(parts{i});
        else
            data = [];
            return;
        end
    end
end
