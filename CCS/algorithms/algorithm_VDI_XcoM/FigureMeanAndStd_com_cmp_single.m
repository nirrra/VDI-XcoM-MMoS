function FigureMeanAndStd_com_cmp_single(cellSegs_control, cellSegs_patient, fig_options)
% Plot segmented mean curves of two groups on a single axis.

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

    output_dir = fullfile('outputs', 'images mean std');
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    curves_control = build_group_curves(cellSegs_control, str_paras, idxParas);
    curves_patient = build_group_curves(cellSegs_patient, str_paras, idxParas);
    draw_single_axis_compare(curves_control, curves_patient, idxParas, fig_options);
end

function curves = build_group_curves(cellSegs, str_paras, idxParas)
    curves.mean_curves = cell(length(str_paras), 1);
    curves.std_curves = cell(length(str_paras), 1);
    curves.stage_durations = get_group_stage_durations(cellSegs);
    curves.time_curve = build_time_curve(curves.stage_durations);
    curves.time_stage = [0, cumsum(curves.stage_durations)];

    for i = idxParas
        [curves.mean_curves{i}, curves.std_curves{i}] = get_group_average_curve(cellSegs, str_paras{i});
    end
end

function [mean_curve, std_curve] = get_group_average_curve(cellSegs, str_para)
    mean_curve = [];
    std_curve = [];

    for idxStage = 1:3
        datas_interp = get_average_curve_segment(cellSegs, str_para, idxStage);
        if isempty(datas_interp)
            mean_data = nan(1, 101);
            std_data = nan(1, 101);
        else
            mean_data = mean_omitnan(datas_interp, 1);
            std_data = std_omitnan(datas_interp, 1);
        end
        mean_curve = [mean_curve, mean_data]; %#ok<AGROW>
        std_curve = [std_curve, std_data]; %#ok<AGROW>
    end
end

function datas_interp = get_average_curve_segment(cellSegs, str_para, idxStage)
    time_interp = 0:0.01:1;
    datas_interp = zeros(0, length(time_interp));

    for idxSeg = 1:length(cellSegs)
        seg = cellSegs{idxSeg};
        if ~isfield(seg, 'time_sts')
            continue;
        end

        [t1, t2] = get_stage_times(seg, idxStage);
        data = get_nested_field(seg, str_para);
        if isempty(data)
            continue;
        end
        data = data(:);

        time = get_matching_time(seg, numel(data));
        if isempty(time)
            continue;
        end
        time = time(:);

        aux = GetIdxTime(time, [t1, t2]);
        if isempty(aux) || numel(aux) < 2
            continue;
        end
        period = aux(1):aux(2);
        if numel(period) < 2
            continue;
        end

        time_seg = time(period);
        data_seg = data(period);
        denom = range(time_seg);
        if denom <= 0
            continue;
        end

        time_norm = (time_seg - time_seg(1)) ./ denom;
        data_interp = interp1(time_norm, data_seg, time_interp, 'linear', 'extrap');
        datas_interp(end+1, :) = data_interp; %#ok<AGROW>
    end
end

function [t1, t2] = get_stage_times(seg, idxStage)
    t_start = seg.time_sts.time_start;
    t_seat_off = seg.time_sts.time_seat_off;
    t_min = seg.time_sts.time_min_grf_plantar;
    t_end = seg.time_sts.time_end;

    if idxStage == 1
        t1 = t_start;
        t2 = t_seat_off;
    elseif idxStage == 2
        t1 = t_seat_off;
        t2 = t_min;
    else
        t1 = t_min;
        t2 = t_end;
    end
end

function time = get_matching_time(seg, nData)
    time = [];
    if ~isfield(seg, 'times')
        return;
    end

    if isfield(seg.times, 'vicon') && numel(seg.times.vicon) == nData
        time = seg.times.vicon;
    elseif isfield(seg.times, 'union') && numel(seg.times.union) == nData
        time = seg.times.union;
    elseif isfield(seg.times, 'union')
        time = seg.times.union;
    elseif isfield(seg.times, 'vicon')
        time = seg.times.vicon;
    end
end

function stage_durations = get_group_stage_durations(cellSegs)
    durations = nan(length(cellSegs), 3);
    for idxSeg = 1:length(cellSegs)
        seg = cellSegs{idxSeg};
        if ~isfield(seg, 'time_sts')
            continue;
        end
        durations(idxSeg, 1) = seg.time_sts.time_seat_off - seg.time_sts.time_start;
        durations(idxSeg, 2) = seg.time_sts.time_min_grf_plantar - seg.time_sts.time_seat_off;
        durations(idxSeg, 3) = seg.time_sts.time_end - seg.time_sts.time_min_grf_plantar;
    end
    stage_durations = mean(durations, 1, 'omitnan');
    stage_durations(~isfinite(stage_durations)) = 0;
end

function time_curve = build_time_curve(stage_durations)
    time_curve = 0;
    for idxStage = 1:numel(stage_durations)
        time_curve = [time_curve, time_curve(end) + linspace(0, stage_durations(idxStage), 101)]; %#ok<AGROW>
    end
    time_curve(1) = [];
end

function draw_single_axis_compare(curves_control, curves_patient, idxParas, fig_options)
    figure_name = fig_options.figure_name;
    legend_names = fig_options.legend_names;
    legend_names = legend_names(idxParas);
    y_name = fig_options.y_name;
    group_names = get_or_default(fig_options, 'group_names', {'Control','Patient'});

    font_name = get_or_default(fig_options, 'font_name', 'Times New Roman');
    font_size = get_or_default(fig_options, 'font_size', 15);
    axis_line_width = get_or_default(fig_options, 'axis_line_width', 1.2);
    line_width = get_or_default(fig_options, 'line_width', 2.0);
    stage_line_width = get_or_default(fig_options, 'stage_line_width', 1.6);
    fill_alpha = get_or_default(fig_options, 'fill_alpha', 0.14);
    flag_bw = get_or_default(fig_options, 'flag_bw', false);
    flag_std = get_or_default(fig_options, 'flag_std', true);

    colors = fig_options.colors;
    if flag_bw
        colors = bw_color_palette(length(idxParas));
    end

    control_style = '-';
    patient_style = '--';
    f = figure('Color', 'white', 'Position', [100, 100, 640, 480]);
    axes('Parent', f, 'Position', [0.12, 0.20, 0.78, 0.70]);
    hold on;
    grid on;
    box on;
    set(gca, 'FontSize', font_size, 'FontName', font_name, 'LineWidth', axis_line_width, ...
        'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');

    for j = 1:length(curves_control.time_stage)
        xline(curves_control.time_stage(j), ':', 'LineWidth', stage_line_width, 'Color', [0.45 0.45 0.45]);
    end
    for j = 1:length(curves_patient.time_stage)
        xline(curves_patient.time_stage(j), '-.', 'LineWidth', stage_line_width, 'Color', [0.72 0.72 0.72]);
    end

    h_legend = gobjects(1, 2 * length(idxParas));
    legend_labels = cell(1, 2 * length(idxParas));
    y_min = [];
    y_max = [];

    for k = 1:length(idxParas)
        idxPara = idxParas(k);
        time_control = curves_control.time_curve;
        time_patient = curves_patient.time_curve;
        mean_control = curves_control.mean_curves{idxPara};
        mean_patient = curves_patient.mean_curves{idxPara};
        std_control = curves_control.std_curves{idxPara};
        std_patient = curves_patient.std_curves{idxPara};

        if flag_std
            fill_group_std(time_control, mean_control, std_control, colors(k, :), fill_alpha);
            fill_group_std(time_patient, mean_patient, std_patient, colors(k, :), fill_alpha * 0.75);
        end

        h_legend(2 * k - 1) = plot(time_control, mean_control, 'LineWidth', line_width, ...
            'Color', colors(k, :), 'LineStyle', control_style);
        h_legend(2 * k) = plot(time_patient, mean_patient, 'LineWidth', line_width, ...
            'Color', colors(k, :), 'LineStyle', patient_style);

        legend_labels{2 * k - 1} = [legend_names{k}, ' (', group_names{1}, ')'];
        legend_labels{2 * k} = [legend_names{k}, ' (', group_names{2}, ')'];

        [curve_y_min, curve_y_max] = get_curve_bounds(mean_control, std_control, flag_std);
        if ~isempty(curve_y_min)
            y_min(end+1) = curve_y_min; %#ok<AGROW>
            y_max(end+1) = curve_y_max; %#ok<AGROW>
        end

        [curve_y_min, curve_y_max] = get_curve_bounds(mean_patient, std_patient, flag_std);
        if ~isempty(curve_y_min)
            y_min(end+1) = curve_y_min; %#ok<AGROW>
            y_max(end+1) = curve_y_max; %#ok<AGROW>
        end
    end

    xlabel('Time / s', 'FontSize', font_size, 'FontName', font_name);
    ylabel(y_name, 'FontSize', font_size, 'FontName', font_name);
    xlim([0, max([curves_control.time_curve, curves_patient.time_curve])]);

    if ~isempty(y_min)
        y_span = max(y_max) - min(y_min);
        if y_span <= 0
            y_span = max(abs(y_max));
        end
        ylim([min(y_min) - 0.05 * y_span, max(y_max) + 0.05 * y_span]);
    end

    legend(h_legend, legend_labels, 'Location', 'eastoutside', ...
        'Orientation', 'vertical', 'Box', 'off', ...
        'FontSize', font_size, 'FontName', font_name);

    print(f, fullfile('outputs', 'images mean std', [figure_name, '.png']), '-dpng', '-r600');
end

function fill_group_std(time, signal_mean, signal_std, color_value, fill_alpha)
    valid = isfinite(time) & isfinite(signal_mean) & isfinite(signal_std);
    if ~any(valid)
        return;
    end
    fill([time(valid), fliplr(time(valid))], ...
         [signal_mean(valid) + signal_std(valid), fliplr(signal_mean(valid) - signal_std(valid))], ...
         color_value * 0.65 + 0.35, 'EdgeColor', 'none', 'FaceAlpha', fill_alpha);
end

function [curve_y_min, curve_y_max] = get_curve_bounds(signal_mean, signal_std, flag_std)
    if flag_std
        signal_low = signal_mean - signal_std;
        signal_high = signal_mean + signal_std;
    else
        signal_low = signal_mean;
        signal_high = signal_mean;
    end
    valid = isfinite(signal_low) & isfinite(signal_high);
    if ~any(valid)
        curve_y_min = [];
        curve_y_max = [];
        return;
    end
    curve_y_min = min(signal_low(valid));
    curve_y_max = max(signal_high(valid));
end

function y = mean_omitnan(x, dim)
    if nargin < 2
        dim = 1;
    end
    mask = ~isnan(x);
    count = sum(mask, dim);
    x(~mask) = 0;
    y = sum(x, dim) ./ max(count, 1);
    y(count == 0) = nan;
end

function y = std_omitnan(x, dim)
    if nargin < 2
        dim = 1;
    end
    mu = mean_omitnan(x, dim);
    mu_rep = repmat_to_match(mu, size(x), dim);
    mask = ~isnan(x);
    diff_sq = (x - mu_rep).^2;
    diff_sq(~mask) = 0;
    count = sum(mask, dim);
    denom = max(count - 1, 1);
    y = sqrt(sum(diff_sq, dim) ./ denom);
    y(count <= 1) = 0;
    y(count == 0) = nan;
end

function out = repmat_to_match(x, target_size, dim)
    reps = ones(1, numel(target_size));
    reps(dim) = target_size(dim);
    out = repmat(x, reps);
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
    if n <= size(base, 1)
        colors = base(1:n, :);
    else
        colors = lines(n);
    end
end

function colors = bw_color_palette(n)
    base = [ ...
        0.00, 0.00, 0.00; ...
        0.35, 0.35, 0.35; ...
        0.65, 0.65, 0.65; ...
        0.20, 0.20, 0.20 ...
    ];
    colors = zeros(n, 3);
    for i = 1:n
        idx = mod(i - 1, size(base, 1)) + 1;
        colors(i, :) = base(idx, :);
    end
end
