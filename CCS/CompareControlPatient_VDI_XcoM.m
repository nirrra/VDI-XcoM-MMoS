% Compare control and patient groups for VDI-XcoM analysis.
% Lite version: Experiment B only, summarized with a single primary valley.
close all; clear; clc
addpath(genpath('./algorithms'));
addpath(genpath('./data'));
addpath(genpath('./data_control'));

%% Output folders
output_root = fullfile('outputs', 'experiment_b_lite');
output_table_dir = fullfile(output_root, 'tables');
output_figure_dir = fullfile(output_root, 'figures');
flag_bw = true;
ensure_folder(output_root);
ensure_folder(output_table_dir);
ensure_folder(output_figure_dir);

%% Initialization
PartInitialization_patient;
idx_analyze_absorb_patient = idx_analyze_absorb;
info_patient = struct();
info_patient.genders = genders;
info_patient.weights = weights;
info_patient.heights = heights;
info_patient.ages = ages;
info_patient.sts_methods = sts_methods;
info_patient.FCA_transfer = FCA_transfer;
info_patient.FM_sum = FM_sum;

PartInitialization_control;
idx_analyze_absorb_control = idx_data_absorb;
info_control = struct();
info_control.genders = genders;
info_control.weights = weights;
info_control.heights = heights;
info_control.ages = ages;
info_control.sts_methods = sts_methods;

%% Load data
cellSegs_patient = load('./data/sts_segs_patient.mat', 'cellSegs');
cellSegs_control = load('./data_control/sts_segs_control.mat', 'cellSegs');
cellSegs_patient = cellSegs_patient.cellSegs;
cellSegs_control = cellSegs_control.cellSegs;

%% Keep analyzed STS segments only
cellSegs_patient = filter_group_segments(cellSegs_patient, idx_analyze_absorb_patient, 3);
cellSegs_control = filter_group_segments(cellSegs_control, idx_analyze_absorb_control, 2);

if isempty(cellSegs_control) || isempty(cellSegs_patient)
    error('Control or patient segments are empty after filtering.');
end

disp(['Control segments: ', num2str(numel(cellSegs_control))]);
disp(['Patient segments: ', num2str(numel(cellSegs_patient))]);

%% Add derived fields used by Experiment B analysis
cellSegs_control = add_ap_boundary_metrics(cellSegs_control);
cellSegs_patient = add_ap_boundary_metrics(cellSegs_patient);

cellSegs_control = add_derived_plot_fields(cellSegs_control);
cellSegs_patient = add_derived_plot_fields(cellSegs_patient);

cellSegs_control = annotate_mmos_main_valley(cellSegs_control);
cellSegs_patient = annotate_mmos_main_valley(cellSegs_patient);

%% Table 1: subject characteristics
table1 = build_table1_subject_characteristics(cellSegs_control, info_control, cellSegs_patient, info_patient);
write_output_table(table1, fullfile(output_table_dir, 'Table1_SubjectCharacteristics.csv'));
disp('Table 1 written: subject characteristics');
disp(table1);

%% Table 3: traditional STS metrics
table3 = build_table3_traditional_metrics(cellSegs_control, cellSegs_patient);
write_output_table(table3, fullfile(output_table_dir, 'Table3_TraditionalSTSGroupComparison.csv'));
disp('Table 3 written: traditional STS metrics');
disp(table3);

%% Figure 3: stability metric time courses
plot_figure_xcom_comparison_by_group(cellSegs_control, cellSegs_patient, output_figure_dir, flag_bw);
disp('Figure XcoM comparison written: XcoM / VDI-XcoM by group');

%% Figure 3: stability metric time courses
plot_figure3_stability_curves(cellSegs_control, cellSegs_patient, output_figure_dir, flag_bw);
disp('Figure 3 written: stability metric time courses');

%% Table 4: stability summary features at seat-off
table4 = build_table4_stability_features(cellSegs_control, cellSegs_patient);
write_output_table(table4, fullfile(output_table_dir, 'Table4_StabilitySummaryFeatures.csv'));
disp('Table 4 written: stability summary features');
disp(table4);

%% Figure 4 and Table 5: single primary valley risk-window features
table5 = build_table5_main_valley_features(cellSegs_control, cellSegs_patient);
write_output_table(table5, fullfile(output_table_dir, 'Table5_MainValleyFeatures.csv'));
disp('Table 5 written: single primary valley features');
disp(table5);

plot_figure4_main_valley_features(cellSegs_control, cellSegs_patient, output_figure_dir, flag_bw);
disp('Figure 4 written: single primary valley features');

%% Figure 5: VDI-XcoM decomposition terms
plot_figure5_vdi_xcom_decomposition(cellSegs_control, cellSegs_patient, output_figure_dir, flag_bw);
disp('Figure 5 written: VDI-XcoM decomposition terms');

disp(['Experiment B lite outputs saved under ', output_root]);

%% Local functions
function ensure_folder(folder_path)
    if ~exist(folder_path, 'dir')
        mkdir(folder_path);
    end
end

function write_output_table(table_data, file_path)
    writetable(table_data, file_path);
end

function cellSegs = filter_group_segments(cellSegs, idx_absorb, sts_method)
    aux = {};
    for idxSeg = 1:length(cellSegs)
        seg = cellSegs{idxSeg};
        if ismember(seg.info.idx_file, idx_absorb)
            continue;
        end
        if seg.info.sts_method ~= sts_method
            continue;
        end
        aux{end+1,1} = seg; %#ok<AGROW>
    end
    cellSegs = aux;
end

function table_out = build_table1_subject_characteristics(cellSegs_control, info_control, cellSegs_patient, info_patient)
    control_ids = get_group_subject_ids(cellSegs_control);
    patient_ids = get_group_subject_ids(cellSegs_patient);

    control_ages = pick_numeric_values(info_control.ages, control_ids);
    patient_ages = pick_numeric_values(info_patient.ages, patient_ids);
    control_heights = pick_numeric_values(info_control.heights, control_ids);
    patient_heights = pick_numeric_values(info_patient.heights, patient_ids);
    control_weights = pick_numeric_values(info_control.weights, control_ids);
    patient_weights = pick_numeric_values(info_patient.weights, patient_ids);

    control_gender = pick_gender_values(info_control.genders, control_ids);
    patient_gender = pick_gender_values(info_patient.genders, patient_ids);
    [control_male, control_female] = count_male_female(control_gender);
    [patient_male, patient_female] = count_male_female(patient_gender);

    patient_fca_transfer = pick_numeric_values(info_patient.FCA_transfer, patient_ids);
    patient_fm_sum = pick_numeric_values(info_patient.FM_sum, patient_ids);

    row_names = { ...
        'Sample size, n'; ...
        'Age, years'; ...
        'Sex, male/female'; ...
        'Height, m'; ...
        'Weight, kg'; ...
        'FCA transfer'; ...
        'FMA total'};

    control_text = { ...
        num2str(numel(control_ids)); ...
        format_mean_sd(control_ages, 1); ...
        [num2str(control_male), '/', num2str(control_female)]; ...
        format_mean_sd(control_heights, 3); ...
        format_mean_sd(control_weights, 1); ...
        '-'; ...
        '-'};

    patient_text = { ...
        num2str(numel(patient_ids)); ...
        format_mean_sd(patient_ages, 1); ...
        [num2str(patient_male), '/', num2str(patient_female)]; ...
        format_mean_sd(patient_heights, 3); ...
        format_mean_sd(patient_weights, 1); ...
        format_mean_sd(patient_fca_transfer, 1); ...
        format_mean_sd(patient_fm_sum, 1)};

    p_values = { ...
        '-'; ...
        format_p_value(compare_continuous_groups(control_ages, patient_ages)); ...
        format_p_value(compare_sex_distribution(control_male, control_female, patient_male, patient_female)); ...
        format_p_value(compare_continuous_groups(control_heights, patient_heights)); ...
        format_p_value(compare_continuous_groups(control_weights, patient_weights)); ...
        '-'; ...
        '-'};

    table_out = table(row_names, control_text, patient_text, p_values, ...
        'VariableNames', {'Variable', 'Control', 'Patient', 'PValue'});
end

function table_out = build_table3_traditional_metrics(cellSegs_control, cellSegs_patient)
    metric_names = {'duration','seat_off','trunk_flex_min','max_grf'};
    table_control = collect_subject_metric_means(cellSegs_control, metric_names, @extract_traditional_metrics);
    table_patient = collect_subject_metric_means(cellSegs_patient, metric_names, @extract_traditional_metrics);

    specs = { ...
        'STS duration', 'duration', 2; ...
        'Seat-off timing', 'seat_off', 2; ...
        'Minimum trunk flexion angle', 'trunk_flex_min', 1; ...
        'Peak plantar vertical GRF', 'max_grf', 1};

    table_out = summarize_metric_table(table_control, table_patient, specs);
end

function table_out = build_table4_stability_features(cellSegs_control, cellSegs_patient)
    metric_names = {'mos_plantar_seatoff','mos_xcom_seatoff','mmos_seatoff'};
    table_control = collect_subject_metric_means(cellSegs_control, metric_names, @extract_stability_summary_metrics);
    table_patient = collect_subject_metric_means(cellSegs_patient, metric_names, @extract_stability_summary_metrics);

    feature_used = repmat({'Value at seat-off'}, 3, 1);
    metric_labels = {'MoS_{plantar}'; 'MoS_{XcoM}'; 'MMoS'};
    field_names = {'mos_plantar_seatoff'; 'mos_xcom_seatoff'; 'mmos_seatoff'};

    control_text = cell(3, 1);
    patient_text = cell(3, 1);
    p_values = cell(3, 1);
    for i = 1:3
        control_vals = table_control.(field_names{i});
        patient_vals = table_patient.(field_names{i});
        control_text{i} = format_mean_sd(control_vals, 4);
        patient_text{i} = format_mean_sd(patient_vals, 4);
        p_values{i} = format_p_value(compare_continuous_groups(control_vals, patient_vals));
    end

    table_out = table(metric_labels, feature_used, control_text, patient_text, p_values, ...
        'VariableNames', {'Metric', 'FeatureUsed', 'Control', 'Patient', 'PValue'});
end

function table_out = build_table5_main_valley_features(cellSegs_control, cellSegs_patient)
    metric_names = {'main_valley_time','main_valley_value','main_valley_front_exceed','seatoff_front_exceed'};
    table_control = collect_subject_metric_means(cellSegs_control, metric_names, @extract_main_valley_metrics);
    table_patient = collect_subject_metric_means(cellSegs_patient, metric_names, @extract_main_valley_metrics);

    specs = { ...
        'Primary valley time relative to seat-off', 'main_valley_time', 3; ...
        'Primary valley value (MMoS)', 'main_valley_value', 4; ...
        'Anterior exceedance probability at primary valley', 'main_valley_front_exceed', 3; ...
        'Anterior exceedance probability at seat-off', 'seatoff_front_exceed', 3};

    table_out = summarize_metric_table(table_control, table_patient, specs);
end

function table_out = summarize_metric_table(table_control, table_patient, specs)
    nRows = size(specs, 1);
    variable = cell(nRows, 1);
    control_text = cell(nRows, 1);
    patient_text = cell(nRows, 1);
    p_values = cell(nRows, 1);

    for iRow = 1:nRows
        variable{iRow} = specs{iRow, 1};
        field_name = specs{iRow, 2};
        precision = specs{iRow, 3};

        control_vals = table_control.(field_name);
        patient_vals = table_patient.(field_name);
        control_text{iRow} = format_mean_sd(control_vals, precision);
        patient_text{iRow} = format_mean_sd(patient_vals, precision);
        p_values{iRow} = format_p_value(compare_continuous_groups(control_vals, patient_vals));
    end

    table_out = table(variable, control_text, patient_text, p_values, ...
        'VariableNames', {'Variable', 'Control', 'Patient', 'PValue'});
end

function plot_figure3_stability_curves(cellSegs_control, cellSegs_patient, output_dir, flag_bw)
    [control_color, patient_color, ~] = get_plot_palette(flag_bw);
    metric_defs = { ...
        'seg.mos.cmp_h_plantar_fixed.sum', 'MoS_{plantar}'; ...
        'seg.mos.hof_new.sum', 'MoS_{XcoM}'; ...
        'seg.mos.cmp_h_new.sum', 'MMoS'};

    curves_control = cell(size(metric_defs, 1), 1);
    curves_patient = cell(size(metric_defs, 1), 1);
    y_min = [];
    y_max = [];
    x_max = 0;

    for iMetric = 1:size(metric_defs, 1)
        curves_control{iMetric} = build_metric_curve(cellSegs_control, metric_defs{iMetric, 1});
        curves_patient{iMetric} = build_metric_curve(cellSegs_patient, metric_defs{iMetric, 1});
        x_max = max([x_max, curves_control{iMetric}.time_curve(end), curves_patient{iMetric}.time_curve(end)]);

        [y1_min, y1_max] = get_curve_bounds(curves_control{iMetric}.mean_curve, curves_control{iMetric}.std_curve, true);
        [y2_min, y2_max] = get_curve_bounds(curves_patient{iMetric}.mean_curve, curves_patient{iMetric}.std_curve, true);
        y_min = [y_min, y1_min, y2_min]; %#ok<AGROW>
        y_max = [y_max, y1_max, y2_max]; %#ok<AGROW>
    end

    y_lim = expand_ylim(y_min, y_max);
    f = figure('Color', 'white', 'Position', [100, 100, 1350, 430]);
    [axes_handles, legend_position] = create_three_panel_axes(f);
    legend_handles = gobjects(1, 2);

    for iMetric = 1:size(metric_defs, 1)
        ax = axes_handles(iMetric);
        hold(ax, 'on');
        box(ax, 'on');
        grid(ax, 'on');
        set(ax, 'FontName', 'Times New Roman', 'FontSize', 13, 'LineWidth', 1.1, ...
            'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');

        yline(ax, 0, ':', 'Color', [0.55, 0.55, 0.55], 'LineWidth', 1.0);

        fill_std_band(ax, curves_control{iMetric}.time_curve, curves_control{iMetric}.mean_curve, ...
            curves_control{iMetric}.std_curve, control_color, 0.16);
        fill_std_band(ax, curves_patient{iMetric}.time_curve, curves_patient{iMetric}.mean_curve, ...
            curves_patient{iMetric}.std_curve, patient_color, 0.14);

        h1 = plot(ax, curves_control{iMetric}.time_curve, curves_control{iMetric}.mean_curve, ...
            'Color', control_color, 'LineWidth', 2.0, 'LineStyle', '-');
        h2 = plot(ax, curves_patient{iMetric}.time_curve, curves_patient{iMetric}.mean_curve, ...
            'Color', patient_color, 'LineWidth', 2.0, 'LineStyle', '--');

        title(ax, metric_defs{iMetric, 2}, 'FontWeight', 'normal');
        xlabel(ax, 'Time / s');
        if iMetric == 1
            ylabel(ax, 'Distance / m');
        end
        xlim(ax, [0, x_max]);
        ylim(ax, y_lim);
        plot_seatoff_marker(ax, mean_finite([curves_control{iMetric}.time_stage(2), curves_patient{iMetric}.time_stage(2)]));

        if iMetric == 2
            legend_handles = [h1, h2];
        end
    end

    place_axes_legend(axes_handles(2), legend_handles, {'Control', 'Patient'}, legend_position);

    print(f, fullfile(output_dir, 'Figure3_StabilityMetricTimeCourses.png'), '-dpng', '-r600');
end

function plot_figure_xcom_comparison_by_group(cellSegs_control, cellSegs_patient, output_dir, flag_bw)
    metric_defs = { ...
        'seg.xcom_hof.y', 'XcoM'; ...
        'seg.xcom_cmp_h.y', 'VDI-XcoM'};
    [metric_colors, metric_styles] = get_metric_style_palette(flag_bw, size(metric_defs, 1));

    curves_control = cell(size(metric_defs, 1), 1);
    curves_patient = cell(size(metric_defs, 1), 1);
    all_y_min = [];
    all_y_max = [];
    x_max = 0;

    for iMetric = 1:size(metric_defs, 1)
        curves_control{iMetric} = build_metric_curve(cellSegs_control, metric_defs{iMetric, 1});
        curves_patient{iMetric} = build_metric_curve(cellSegs_patient, metric_defs{iMetric, 1});
        x_max = max([x_max, curves_control{iMetric}.time_curve(end), curves_patient{iMetric}.time_curve(end)]);

        [control_min, control_max] = get_curve_bounds(curves_control{iMetric}.mean_curve, curves_control{iMetric}.std_curve, true);
        [patient_min, patient_max] = get_curve_bounds(curves_patient{iMetric}.mean_curve, curves_patient{iMetric}.std_curve, true);
        all_y_min = [all_y_min, control_min, patient_min]; %#ok<AGROW>
        all_y_max = [all_y_max, control_max, patient_max]; %#ok<AGROW>
    end

    y_lim = expand_ylim(all_y_min, all_y_max);
    f = figure('Color', 'white', 'Position', [100, 100, 1080, 430]);
    [axes_handles, ~] = create_two_panel_axes(f);
    legend_position = [0.39, 0.07, 0.22, 0.07];
    group_curves = {curves_control, curves_patient};
    group_names = {'Control', 'Patient'};
    legend_handles = gobjects(1, size(metric_defs, 1));

    for iGroup = 1:2
        ax = axes_handles(iGroup);
        hold(ax, 'on');
        box(ax, 'on');
        grid(ax, 'on');
        set(ax, 'FontName', 'Times New Roman', 'FontSize', 13, 'LineWidth', 1.1, ...
            'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');

        for iMetric = 1:size(metric_defs, 1)
            curve = group_curves{iGroup}{iMetric};
            fill_std_band(ax, curve.time_curve, curve.mean_curve, curve.std_curve, metric_colors(iMetric, :), 0.14);
            legend_handles(iMetric) = plot(ax, curve.time_curve, curve.mean_curve, ...
                'Color', metric_colors(iMetric, :), 'LineWidth', 2.0, 'LineStyle', metric_styles{iMetric});
        end

        title(ax, group_names{iGroup}, 'FontWeight', 'normal');
        xlabel(ax, 'Time / s');
        if iGroup == 1
            ylabel(ax, 'Position / m');
        end
        xlim(ax, [0, x_max]);
        ylim(ax, y_lim);
        plot_seatoff_marker(ax, group_curves{iGroup}{1}.time_stage(2));
    end

    place_axes_legend(axes_handles(2), legend_handles, metric_defs(:, 2)', legend_position);
    print(f, fullfile(output_dir, 'Figure_XcoM_VDIXcoM_ByGroup.png'), '-dpng', '-r600');
end

function plot_figure4_main_valley_features(cellSegs_control, cellSegs_patient, output_dir, flag_bw)
    metric_names = {'main_valley_time','main_valley_value','main_valley_front_exceed','seatoff_front_exceed'};
    table_control = collect_subject_metric_means(cellSegs_control, metric_names, @extract_main_valley_metrics);
    table_patient = collect_subject_metric_means(cellSegs_patient, metric_names, @extract_main_valley_metrics);

    control_time = table_control.main_valley_time;
    patient_time = table_patient.main_valley_time;
    control_value = table_control.main_valley_value;
    patient_value = table_patient.main_valley_value;
    control_prob = [mean(table_control.main_valley_front_exceed, 'omitnan'), mean(table_control.seatoff_front_exceed, 'omitnan')];
    patient_prob = [mean(table_patient.main_valley_front_exceed, 'omitnan'), mean(table_patient.seatoff_front_exceed, 'omitnan')];
    control_prob_std = [std(table_control.main_valley_front_exceed, 'omitnan'), std(table_control.seatoff_front_exceed, 'omitnan')];
    patient_prob_std = [std(table_patient.main_valley_front_exceed, 'omitnan'), std(table_patient.seatoff_front_exceed, 'omitnan')];

    [control_color, patient_color, ~] = get_plot_palette(flag_bw);
    f = figure('Color', 'white', 'Position', [100, 100, 1350, 430]);
    [axes_handles, ~, axes_positions] = create_three_panel_axes(f);
    legend_positions = get_subplot_legend_positions(axes_positions, 0.07, 0.08);

    ax1 = axes_handles(1);
    [h_control_1, h_patient_1] = plot_group_scatter_with_mean(ax1, control_time, patient_time, ...
        'Time relative to seat-off / s', 'Primary Valley Time', 0, flag_bw);

    ax2 = axes_handles(2);
    [h_control, h_patient] = plot_group_scatter_with_mean(ax2, control_value, patient_value, ...
        'MMoS / m', 'Primary Valley Value', 0, flag_bw);

    ax3 = axes_handles(3);
    hold(ax3, 'on');
    box(ax3, 'on');
    grid(ax3, 'on');
    set(ax3, 'FontName', 'Times New Roman', 'FontSize', 13, 'LineWidth', 1.1, ...
        'XMinorTick', 'off', 'YMinorTick', 'on', 'TickDir', 'out');

    prob_mat = [control_prob(1), patient_prob(1); control_prob(2), patient_prob(2)];
    prob_std_mat = [control_prob_std(1), patient_prob_std(1); control_prob_std(2), patient_prob_std(2)];
    bar_handles = bar(ax3, prob_mat, 'grouped');
    bar_handles(1).FaceColor = control_color;
    bar_handles(2).FaceColor = patient_color;

    for iBar = 1:numel(bar_handles)
        errorbar(ax3, bar_handles(iBar).XEndPoints, prob_mat(:, iBar), prob_std_mat(:, iBar), ...
            'k.', 'LineWidth', 1.1, 'CapSize', 10);
    end

    yline(ax3, 0, ':', 'Color', [0.55, 0.55, 0.55], 'LineWidth', 1.0);
    ylim(ax3, [0, 1]);
    xticks(ax3, [1, 2]);
    xticklabels(ax3, {'Primary valley', 'Seat-off'});
    ylabel(ax3, 'Probability');
    title(ax3, 'Anterior Exceedance Probability', 'FontWeight', 'normal');

    place_axes_legend(ax1, [h_control_1, h_patient_1], {'Control', 'Patient'}, legend_positions(1, :), 2, 11);
    place_axes_legend(ax2, [h_control, h_patient], {'Control', 'Patient'}, legend_positions(2, :), 2, 11);
    place_axes_legend(ax3, bar_handles, {'Control', 'Patient'}, legend_positions(3, :), 2, 11);

    print(f, fullfile(output_dir, 'Figure4_PrimaryValleyRiskWindowFeatures.png'), '-dpng', '-r600');
end

function [h_control, h_patient] = plot_group_scatter_with_mean(ax, control_vals, patient_vals, y_label_text, title_text, y_ref, flag_bw)
    control_vals = control_vals(~isnan(control_vals));
    patient_vals = patient_vals(~isnan(patient_vals));
    [control_color, patient_color, ~] = get_plot_palette(flag_bw);
    hold(ax, 'on');
    box(ax, 'on');
    grid(ax, 'on');
    set(ax, 'FontName', 'Times New Roman', 'FontSize', 13, 'LineWidth', 1.1, ...
        'XMinorTick', 'off', 'YMinorTick', 'on', 'TickDir', 'out');

    h_control = scatter(ax, 1 + 0.10 * randn(size(control_vals)), control_vals, 34, ...
        'MarkerFaceColor', control_color, 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.60);
    h_patient = scatter(ax, 2 + 0.10 * randn(size(patient_vals)), patient_vals, 34, ...
        'MarkerFaceColor', patient_color, 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.60);

    draw_mean_sd(ax, 1, control_vals, control_color);
    draw_mean_sd(ax, 2, patient_vals, patient_color);

    if ~isempty(y_ref) && ~isnan(y_ref)
        yline(ax, y_ref, ':', 'Color', [0.55, 0.55, 0.55], 'LineWidth', 1.0);
    end

    xlim(ax, [0.5, 2.5]);
    xticks(ax, [1, 2]);
    xticklabels(ax, {'Control', 'Patient'});
    ylabel(ax, y_label_text);
    title(ax, title_text, 'FontWeight', 'normal');
end

function draw_mean_sd(ax, x_pos, values, color_value)
    if isempty(values)
        return;
    end
    mu = mean(values, 'omitnan');
    sigma = std(values, 'omitnan');
    errorbar(ax, x_pos, mu, sigma, 'Color', color_value, 'LineWidth', 1.6, 'CapSize', 10);
    plot(ax, x_pos, mu, 'o', 'MarkerFaceColor', color_value, 'MarkerEdgeColor', color_value, 'MarkerSize', 7);
end

function plot_figure5_vdi_xcom_decomposition(cellSegs_control, cellSegs_patient, output_dir, flag_bw)
    [~, ~, component_colors] = get_plot_palette(flag_bw);
    raw_defs = { ...
        'seg.com.y', 'Displacement term'; ...
        'seg.item.vel_cmp', 'Velocity term'; ...
        'seg.item.h', 'Angular-momentum term'};
    contrib_defs = { ...
        'seg.vdi_xcom_contrib.com_y', 'Displacement term'; ...
        'seg.vdi_xcom_contrib.vel_cmp_y', 'Velocity term'; ...
        'seg.vdi_xcom_contrib.h_y', 'Angular-momentum term'};

    raw_control = cell(size(raw_defs, 1), 1);
    raw_patient = cell(size(raw_defs, 1), 1);
    contrib_control = cell(size(contrib_defs, 1), 1);
    contrib_patient = cell(size(contrib_defs, 1), 1);
    raw_y_min = [];
    raw_y_max = [];
    contrib_y_min = [];
    contrib_y_max = [];
    x_max = 0;

    for iMetric = 1:size(raw_defs, 1)
        raw_control{iMetric} = build_metric_curve(cellSegs_control, raw_defs{iMetric, 1});
        raw_patient{iMetric} = build_metric_curve(cellSegs_patient, raw_defs{iMetric, 1});
        contrib_control{iMetric} = build_metric_curve(cellSegs_control, contrib_defs{iMetric, 1});
        contrib_patient{iMetric} = build_metric_curve(cellSegs_patient, contrib_defs{iMetric, 1});

        x_max = max([x_max, raw_control{iMetric}.time_curve(end), raw_patient{iMetric}.time_curve(end), ...
            contrib_control{iMetric}.time_curve(end), contrib_patient{iMetric}.time_curve(end)]);

        [raw_control_min, raw_control_max] = get_curve_bounds(raw_control{iMetric}.mean_curve, raw_control{iMetric}.std_curve, true);
        [raw_patient_min, raw_patient_max] = get_curve_bounds(raw_patient{iMetric}.mean_curve, raw_patient{iMetric}.std_curve, true);
        raw_y_min = [raw_y_min, raw_control_min, raw_patient_min]; %#ok<AGROW>
        raw_y_max = [raw_y_max, raw_control_max, raw_patient_max]; %#ok<AGROW>

        [contrib_control_min, contrib_control_max] = get_curve_bounds(contrib_control{iMetric}.mean_curve, contrib_control{iMetric}.std_curve, true);
        [contrib_patient_min, contrib_patient_max] = get_curve_bounds(contrib_patient{iMetric}.mean_curve, contrib_patient{iMetric}.std_curve, true);
        contrib_y_min = [contrib_y_min, contrib_control_min, contrib_patient_min]; %#ok<AGROW>
        contrib_y_max = [contrib_y_max, contrib_control_max, contrib_patient_max]; %#ok<AGROW>
    end

    raw_y_lim = expand_ylim(raw_y_min, raw_y_max);
    contrib_y_lim = expand_ylim(contrib_y_min, contrib_y_max);

    f = figure('Color', 'white', 'Position', [100, 100, 1350, 460]);
    [axes_handles, ~, axes_positions] = create_three_panel_axes(f);
    legend_positions = [ ...
        axes_positions(1, 1) - 0.01, 0.01, axes_positions(1, 3) + 0.04, 0.12; ...
        axes_positions(2, 1) + 0.00, 0.01, axes_positions(2, 3), 0.12; ...
        axes_positions(3, 1) + 0.00, 0.01, axes_positions(3, 3), 0.12];
    legend_handles = gobjects(1, 3);
    raw_legend_handles = gobjects(1, 6);
    raw_legend_labels = {'Disp (C)', 'Disp (P)', 'Vel (C)', 'Vel (P)', 'AngMom (C)', 'AngMom (P)'};
    contrib_legend_labels = {'Displacement', 'Velocity', 'AngMom'};

    ax1 = axes_handles(1);
    hold(ax1, 'on');
    box(ax1, 'on');
    grid(ax1, 'on');
    set(ax1, 'FontName', 'Times New Roman', 'FontSize', 13, 'LineWidth', 1.1, ...
        'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');

    yline(ax1, 0, ':', 'Color', [0.55, 0.55, 0.55], 'LineWidth', 1.0);
    for iMetric = 1:size(raw_defs, 1)
        fill_std_band(ax1, raw_control{iMetric}.time_curve, raw_control{iMetric}.mean_curve, ...
            raw_control{iMetric}.std_curve, component_colors(iMetric, :), 0.12);
        fill_std_band(ax1, raw_patient{iMetric}.time_curve, raw_patient{iMetric}.mean_curve, ...
            raw_patient{iMetric}.std_curve, component_colors(iMetric, :), 0.08);

        raw_legend_handles(2 * iMetric - 1) = plot(ax1, raw_control{iMetric}.time_curve, raw_control{iMetric}.mean_curve, ...
            'Color', component_colors(iMetric, :), 'LineWidth', 2.0, 'LineStyle', '-');
        raw_legend_handles(2 * iMetric) = plot(ax1, raw_patient{iMetric}.time_curve, raw_patient{iMetric}.mean_curve, ...
            'Color', component_colors(iMetric, :), 'LineWidth', 2.0, 'LineStyle', '--');
    end
    title(ax1, 'VDI-XcoM Terms', 'FontWeight', 'normal');
    xlabel(ax1, 'Time / s');
    ylabel(ax1, 'Position / m');
    xlim(ax1, [0, x_max]);
    ylim(ax1, raw_y_lim);
    plot_seatoff_marker(ax1, mean_finite([raw_control{1}.time_stage(2), raw_patient{1}.time_stage(2)]));

    for iGroup = 1:2
        ax = axes_handles(iGroup + 1);
        hold(ax, 'on');
        box(ax, 'on');
        grid(ax, 'on');
        set(ax, 'FontName', 'Times New Roman', 'FontSize', 13, 'LineWidth', 1.1, ...
            'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');

        if iGroup == 1
            group_curves = contrib_control;
            stage_time = contrib_control{1}.time_stage(2);
            title_text = 'Control Contribution';
        else
            group_curves = contrib_patient;
            stage_time = contrib_patient{1}.time_stage(2);
            title_text = 'Patient Contribution';
        end

        for iMetric = 1:size(contrib_defs, 1)
            fill_std_band(ax, group_curves{iMetric}.time_curve, group_curves{iMetric}.mean_curve, ...
                group_curves{iMetric}.std_curve, component_colors(iMetric, :), 0.14);
            legend_handles(iMetric) = plot(ax, group_curves{iMetric}.time_curve, group_curves{iMetric}.mean_curve, ...
                'Color', component_colors(iMetric, :), 'LineWidth', 2.0, 'LineStyle', '-');
        end

        title(ax, title_text, 'FontWeight', 'normal');
        xlabel(ax, 'Time / s');
        ylabel(ax, 'Contribution / %');
        xlim(ax, [0, x_max]);
        ylim(ax, contrib_y_lim);
        plot_seatoff_marker(ax, stage_time);
    end

    place_axes_legend(ax1, raw_legend_handles, raw_legend_labels, legend_positions(1, :), 2, 10);
    place_axes_legend(axes_handles(2), legend_handles, contrib_legend_labels, legend_positions(2, :), 1, 10);
    place_axes_legend(axes_handles(3), legend_handles, contrib_legend_labels, legend_positions(3, :), 1, 10);

    print(f, fullfile(output_dir, 'Figure5_VDIXcoMDecompositionTerms.png'), '-dpng', '-r600');
end

function plot_seatoff_marker(ax, seat_off_time)
    if ~isfinite(seat_off_time)
        return;
    end
    xline(ax, seat_off_time, '--', 'Seat-off', ...
        'LineWidth', 1.2, ...
        'Color', [0.45, 0.45, 0.45], ...
        'LabelOrientation', 'horizontal', ...
        'LabelHorizontalAlignment', 'left', ...
        'LabelVerticalAlignment', 'bottom', ...
        'FontName', 'Times New Roman', ...
        'FontSize', 11);
end

function value = mean_finite(values)
    values = values(isfinite(values));
    if isempty(values)
        value = nan;
        return;
    end
    value = mean(values);
end

function [axes_handles, legend_position, axes_positions] = create_three_panel_axes(fig_handle)
    axes_positions = [ ...
        0.07, 0.24, 0.24, 0.62; ...
        0.38, 0.24, 0.24, 0.62; ...
        0.69, 0.24, 0.24, 0.62];
    axes_handles = gobjects(1, 3);
    for iAxes = 1:3
        axes_handles(iAxes) = axes('Parent', fig_handle, 'Position', axes_positions(iAxes, :));
    end
    legend_position = [axes_positions(2, 1) + 0.01, 0.07, axes_positions(2, 3) - 0.02, 0.07];
end

function [axes_handles, legend_position] = create_two_panel_axes(fig_handle)
    axes_positions = [ ...
        0.08, 0.24, 0.36, 0.62; ...
        0.54, 0.24, 0.36, 0.62];
    axes_handles = gobjects(1, 2);
    for iAxes = 1:2
        axes_handles(iAxes) = axes('Parent', fig_handle, 'Position', axes_positions(iAxes, :));
    end
    legend_position = [axes_positions(2, 1) + 0.03, 0.07, axes_positions(2, 3) - 0.06, 0.07];
end

function legend_handle = place_axes_legend(anchor_axes, legend_handles, legend_labels, legend_position, num_columns, font_size)
    if nargin < 5 || isempty(num_columns)
        num_columns = numel(legend_labels);
    end
    if nargin < 6 || isempty(font_size)
        font_size = 12;
    end

    legend_handle = legend(anchor_axes, legend_handles, legend_labels, ...
        'Location', 'southoutside', ...
        'Position', legend_position, ...
        'Orientation', 'horizontal', ...
        'Box', 'off', ...
        'NumColumns', num_columns, ...
        'FontSize', font_size, ...
        'FontName', 'Times New Roman');
end

function legend_positions = get_subplot_legend_positions(axes_positions, y_pos, height_value)
    legend_positions = zeros(size(axes_positions, 1), 4);
    for iAxes = 1:size(axes_positions, 1)
        legend_positions(iAxes, :) = [ ...
            axes_positions(iAxes, 1) + 0.01, ...
            y_pos, ...
            axes_positions(iAxes, 3) - 0.02, ...
            height_value];
    end
end

function [metric_colors, metric_styles] = get_metric_style_palette(flag_bw, nMetric)
    if nargin < 2 || isempty(nMetric)
        nMetric = 3;
    end

    if flag_bw
        base_colors = [ ...
            0.00, 0.00, 0.00; ...
            0.35, 0.35, 0.35; ...
            0.65, 0.65, 0.65];
        base_styles = {'-','--','-.'};
    else
        base_colors = [ ...
            0.00, 0.45, 0.74; ...
            0.85, 0.33, 0.10; ...
            0.47, 0.67, 0.19];
        base_styles = {'-','-','-'};
    end

    metric_colors = zeros(nMetric, 3);
    metric_styles = cell(1, nMetric);
    for iMetric = 1:nMetric
        idx = mod(iMetric - 1, size(base_colors, 1)) + 1;
        metric_colors(iMetric, :) = base_colors(idx, :);
        metric_styles{iMetric} = base_styles{idx};
    end
end

function [control_color, patient_color, component_colors] = get_plot_palette(flag_bw)
    if nargin < 1 || isempty(flag_bw)
        flag_bw = true;
    end

    if flag_bw
        control_color = [0.00, 0.00, 0.00];
        patient_color = [0.45, 0.45, 0.45];
        component_colors = [ ...
            0.00, 0.00, 0.00; ...
            0.35, 0.35, 0.35; ...
            0.65, 0.65, 0.65];
    else
        control_color = [0.00, 0.45, 0.74];
        patient_color = [0.85, 0.33, 0.10];
        component_colors = [ ...
            0.00, 0.45, 0.74; ...
            0.47, 0.67, 0.19; ...
            0.85, 0.33, 0.10];
    end
end

function fill_std_band(ax, time, signal_mean, signal_std, color_value, alpha_value)
    valid = isfinite(time) & isfinite(signal_mean) & isfinite(signal_std);
    if ~any(valid)
        return;
    end
    fill(ax, [time(valid), fliplr(time(valid))], ...
        [signal_mean(valid) + signal_std(valid), fliplr(signal_mean(valid) - signal_std(valid))], ...
        0.70 * color_value + 0.30 * [1, 1, 1], 'EdgeColor', 'none', 'FaceAlpha', alpha_value);
end

function curve = build_metric_curve(cellSegs, str_para)
    curve.mean_curve = get_group_average_curve(cellSegs, str_para);
    curve.std_curve = get_group_std_curve(cellSegs, str_para);
    curve.stage_durations = get_group_stage_durations(cellSegs);
    curve.time_curve = build_time_curve(curve.stage_durations);
    curve.time_stage = [0, cumsum(curve.stage_durations)];
end

function mean_curve = get_group_average_curve(cellSegs, str_para)
    mean_curve = [];
    for idxStage = 1:3
        datas_interp = get_average_curve_segment(cellSegs, str_para, idxStage);
        if isempty(datas_interp)
            mean_data = nan(1, 101);
        else
            mean_data = mean_omitnan(datas_interp, 1);
        end
        mean_curve = [mean_curve, mean_data]; %#ok<AGROW>
    end
end

function std_curve = get_group_std_curve(cellSegs, str_para)
    std_curve = [];
    for idxStage = 1:3
        datas_interp = get_average_curve_segment(cellSegs, str_para, idxStage);
        if isempty(datas_interp)
            std_data = nan(1, 101);
        else
            std_data = std_omitnan(datas_interp, 1);
        end
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
        datas_interp(end+1, :) = interp1(time_norm, data_seg, time_interp, 'linear', 'extrap'); %#ok<AGROW>
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
        curve_y_min = nan;
        curve_y_max = nan;
        return;
    end
    curve_y_min = min(signal_low(valid));
    curve_y_max = max(signal_high(valid));
end

function y_lim = expand_ylim(y_min, y_max)
    valid = isfinite(y_min) & isfinite(y_max);
    if ~any(valid)
        y_lim = [-1, 1];
        return;
    end
    y_min = min(y_min(valid));
    y_max = max(y_max(valid));
    y_span = y_max - y_min;
    if y_span <= 0
        y_span = max(abs([y_min, y_max]));
        if y_span <= 0
            y_span = 1;
        end
    end
    y_lim = [y_min - 0.05 * y_span, y_max + 0.05 * y_span];
end

function cellSegs = add_ap_boundary_metrics(cellSegs)
    for idxSeg = 1:length(cellSegs)
        seg = cellSegs{idxSeg};
        [seg.diff_front, seg.diff_back, seg.prob_front, seg.prob_back] = calc_ap_boundary_metrics(seg);
        cellSegs{idxSeg} = seg;
    end
end

function [diff_front, diff_back, prob_front, prob_back] = calc_ap_boundary_metrics(seg)
    diff_front = [];
    diff_back = [];
    prob_front = [];
    prob_back = [];

    if ~isfield(seg, 'times') || ~isfield(seg.times, 'union') || ...
            ~isfield(seg, 'bos') || ~isfield(seg.bos, 'new') || ~isfield(seg.bos.new, 'y') || ...
            ~isfield(seg, 'xcom_cmp_h') || ~isfield(seg.xcom_cmp_h, 'y')
        return;
    end

    time_union = seg.times.union(:);
    xcom_y = seg.xcom_cmp_h.y(:);
    time_xcom = resolve_signal_time(seg, numel(xcom_y));
    boundary_frames = seg.bos.new.y;

    if isempty(time_union) || isempty(time_xcom) || isempty(xcom_y) || isempty(boundary_frames)
        return;
    end

    n_frame = min(numel(time_union), count_boundary_frames(boundary_frames));
    diff_front = nan(n_frame, 1);
    diff_back = nan(n_frame, 1);

    for idxFrame = 1:n_frame
        idx_xcom = GetIdxTime(time_xcom, time_union(idxFrame));
        if isempty(idx_xcom) || idx_xcom < 1 || idx_xcom > numel(xcom_y)
            continue;
        end

        y_boundary = extract_boundary_frame(boundary_frames, idxFrame);
        y_boundary = y_boundary(:);
        y_boundary = y_boundary(isfinite(y_boundary));
        if isempty(y_boundary)
            continue;
        end

        y_front = max(y_boundary);
        y_back = min(y_boundary);
        y_cmp_h = xcom_y(idx_xcom);

        diff_front(idxFrame) = y_front - y_cmp_h;
        diff_back(idxFrame) = y_cmp_h - y_back;
    end

    prob_front = nan(size(diff_front));
    prob_back = nan(size(diff_back));
    idx_valid_front = ~isnan(diff_front);
    idx_valid_back = ~isnan(diff_back);
    prob_front(idx_valid_front) = double(diff_front(idx_valid_front) < 0);
    prob_back(idx_valid_back) = double(diff_back(idx_valid_back) < 0);
end

function time_signal = resolve_signal_time(seg, n_data)
    time_signal = [];
    if ~isfield(seg, 'times')
        return;
    end

    if isfield(seg.times, 'vicon') && numel(seg.times.vicon) == n_data
        time_signal = seg.times.vicon(:);
    elseif isfield(seg.times, 'union') && numel(seg.times.union) == n_data
        time_signal = seg.times.union(:);
    elseif isfield(seg.times, 'vicon') && ~isempty(seg.times.vicon)
        time_signal = seg.times.vicon(:);
    elseif isfield(seg.times, 'union') && ~isempty(seg.times.union)
        time_signal = seg.times.union(:);
    end
end

function boundary_frame = extract_boundary_frame(boundary_frames, idx_frame)
    boundary_frame = [];
    if iscell(boundary_frames)
        if idx_frame <= numel(boundary_frames)
            boundary_frame = boundary_frames{idx_frame};
        end
    elseif isnumeric(boundary_frames)
        if isvector(boundary_frames)
            if idx_frame <= numel(boundary_frames)
                boundary_frame = boundary_frames(idx_frame);
            end
        elseif idx_frame <= size(boundary_frames, 1)
            boundary_frame = boundary_frames(idx_frame, :);
        end
    elseif isstruct(boundary_frames) && idx_frame <= numel(boundary_frames) && isfield(boundary_frames, 'y')
        boundary_frame = boundary_frames(idx_frame).y;
    end
end

function n_frame = count_boundary_frames(boundary_frames)
    n_frame = 0;
    if iscell(boundary_frames)
        n_frame = numel(boundary_frames);
    elseif isnumeric(boundary_frames)
        if isvector(boundary_frames)
            n_frame = numel(boundary_frames);
        else
            n_frame = size(boundary_frames, 1);
        end
    elseif isstruct(boundary_frames)
        n_frame = numel(boundary_frames);
    end
end

function cellSegs = add_derived_plot_fields(cellSegs)
    for idxSeg = 1:length(cellSegs)
        seg = cellSegs{idxSeg};

        if isfield(seg, 'xcom_cmp_h') && isfield(seg.xcom_cmp_h, 'y') && ...
                isfield(seg, 'xcom_hof') && isfield(seg.xcom_hof, 'y')
            seg.xcom.diff = seg.xcom_cmp_h.y - seg.xcom_hof.y;
        else
            seg.xcom.diff = [];
        end

        if isfield(seg, 'com') && isfield(seg.com, 'y') && ...
                isfield(seg, 'xcom_hof') && isfield(seg.xcom_hof, 'y')
            seg.item.vel_hof = seg.xcom_hof.y - seg.com.y;
        else
            seg.item.vel_hof = [];
        end

        if isfield(seg, 'com') && isfield(seg.com, 'y') && ...
                isfield(seg, 'xcom_cmp') && isfield(seg.xcom_cmp, 'y')
            seg.item.vel_cmp = seg.xcom_cmp.y - seg.com.y;
        else
            seg.item.vel_cmp = [];
        end

        if isfield(seg, 'xcom_cmp_h') && isfield(seg.xcom_cmp_h, 'y') && ...
                isfield(seg, 'xcom_cmp') && isfield(seg.xcom_cmp, 'y')
            seg.item.h = seg.xcom_cmp_h.y - seg.xcom_cmp.y;
        else
            seg.item.h = [];
        end

        if ~isempty(seg.item.vel_cmp) && ~isempty(seg.item.h) && isfield(seg, 'com') && isfield(seg.com, 'y')
            [seg.vdi_xcom_contrib.com_y, ...
             seg.vdi_xcom_contrib.vel_cmp_y, ...
             seg.vdi_xcom_contrib.h_y] = calc_vdi_xcom_component_contribution_y( ...
                seg.com.y, seg.item.vel_cmp, seg.item.h);
        else
            seg.vdi_xcom_contrib.com_y = [];
            seg.vdi_xcom_contrib.vel_cmp_y = [];
            seg.vdi_xcom_contrib.h_y = [];
        end

        cellSegs{idxSeg} = seg;
    end
end

function [contrib_com_y, contrib_vel_cmp_y, contrib_h_y] = calc_vdi_xcom_component_contribution_y(com_y, vel_cmp_y, h_y)
    com_y = com_y(:);
    vel_cmp_y = vel_cmp_y(:);
    h_y = h_y(:);

    d_com = com_y - com_y(1);
    d_vel = vel_cmp_y - vel_cmp_y(1);
    d_h = h_y - h_y(1);

    denom = abs(d_com) + abs(d_vel) + abs(d_h);
    thr = max(1e-2 * max(denom), eps);
    denom(denom < thr) = NaN;

    contrib_com_y = 100 * abs(d_com) ./ denom;
    contrib_vel_cmp_y = 100 * abs(d_vel) ./ denom;
    contrib_h_y = 100 * abs(d_h) ./ denom;
end

function cellSegs = annotate_mmos_main_valley(cellSegs)
    for idxSeg = 1:length(cellSegs)
        seg = cellSegs{idxSeg};
        seg.main_valley = struct( ...
            'idx', -1, ...
            'time', nan, ...
            'value', nan, ...
            'front_exceed', nan, ...
            'seat_off_front_exceed', nan);

        if ~isfield(seg, 'mos') || ~isfield(seg.mos, 'cmp_h_new') || ~isfield(seg.mos.cmp_h_new, 'sum')
            cellSegs{idxSeg} = seg;
            continue;
        end
        if ~isfield(seg, 'time_sts')
            cellSegs{idxSeg} = seg;
            continue;
        end

        signal = seg.mos.cmp_h_new.sum(:);
        time = resolve_signal_time(seg, numel(signal));
        if isempty(time)
            cellSegs{idxSeg} = seg;
            continue;
        end

        n = min(numel(signal), numel(time));
        signal = signal(1:n);
        time = time(1:n);

        idx_start = GetIdxTime(time, seg.time_sts.time_start);
        idx_seat_off = GetIdxTime(time, seg.time_sts.time_seat_off);
        if isempty(idx_start) || isempty(idx_seat_off) || idx_seat_off <= idx_start
            cellSegs{idxSeg} = seg;
            continue;
        end

        search_idx = idx_start:max(idx_start, idx_seat_off - 1);
        signal_search = signal(search_idx);
        signal_search(~isfinite(signal_search)) = inf;
        [min_value, idx_rel] = min(signal_search);
        if ~isfinite(min_value)
            cellSegs{idxSeg} = seg;
            continue;
        end

        idx_main = search_idx(idx_rel);
        seg.main_valley.idx = idx_main;
        seg.main_valley.time = time(idx_main) - seg.time_sts.time_seat_off;
        seg.main_valley.value = signal(idx_main);

        if isfield(seg, 'diff_front') && idx_main <= numel(seg.diff_front) && isfinite(seg.diff_front(idx_main))
            seg.main_valley.front_exceed = double(seg.diff_front(idx_main) < 0);
        end
        if isfield(seg, 'times') && isfield(seg.times, 'union') && isfield(seg, 'diff_front')
            idx_seat_front = GetIdxTime(seg.times.union(:), seg.time_sts.time_seat_off);
            if ~isempty(idx_seat_front) && idx_seat_front <= numel(seg.diff_front) && isfinite(seg.diff_front(idx_seat_front))
                seg.main_valley.seat_off_front_exceed = double(seg.diff_front(idx_seat_front) < 0);
            end
        end

        cellSegs{idxSeg} = seg;
    end
end

function table_subject = collect_subject_metric_means(cellSegs, metric_names, extractor_func)
    subs_list = get_group_subject_ids(cellSegs);
    nSubs = numel(subs_list);
    metric_mat = nan(nSubs, numel(metric_names));

    for iSub = 1:nSubs
        idx_sub = subs_list(iSub);
        values_by_metric = nan(numel(cellSegs), numel(metric_names));
        row_count = 0;

        for idxSeg = 1:numel(cellSegs)
            seg = cellSegs{idxSeg};
            if seg.info.idx_sub ~= idx_sub
                continue;
            end
            row_count = row_count + 1;
            metrics = extractor_func(seg);
            for iMetric = 1:numel(metric_names)
                values_by_metric(row_count, iMetric) = metrics.(metric_names{iMetric});
            end
        end

        if row_count > 0
            metric_mat(iSub, :) = mean(values_by_metric(1:row_count, :), 1, 'omitnan');
        end
    end

    table_subject = array2table(metric_mat, 'VariableNames', metric_names);
    table_subject = addvars(table_subject, subs_list, 'Before', 1, 'NewVariableNames', 'idx_sub');
end

function subject_ids = get_group_subject_ids(cellSegs)
    idx_subs = nan(numel(cellSegs), 1);
    for idxSeg = 1:numel(cellSegs)
        idx_subs(idxSeg) = cellSegs{idxSeg}.info.idx_sub;
    end
    subject_ids = unique(idx_subs(~isnan(idx_subs)));
    subject_ids = subject_ids(:);
end

function metrics = extract_traditional_metrics(seg)
    metrics.duration = nan;
    metrics.seat_off = nan;
    metrics.trunk_flex_min = nan;
    metrics.max_grf = nan;

    if isfield(seg, 'time_sts')
        metrics.duration = seg.time_sts.time_end - seg.time_sts.time_start;
        metrics.seat_off = seg.time_sts.time_seat_off - seg.time_sts.time_start;
    end

    if isfield(seg, 'ja') && isfield(seg.ja, 'lumbar') && isfield(seg.ja.lumbar, 'x')
        metrics.trunk_flex_min = min(seg.ja.lumbar.x);
    elseif isfield(seg, 'ja') && isfield(seg.ja, 'lumbar_extension')
        metrics.trunk_flex_min = min(seg.ja.lumbar_extension);
    end

    if isfield(seg, 'grf') && isfield(seg.grf, 'plantar_z')
        metrics.max_grf = max(seg.grf.plantar_z);
    end
end

function metrics = extract_stability_summary_metrics(seg)
    metrics.mos_plantar_seatoff = nan;
    metrics.mos_xcom_seatoff = nan;
    metrics.mmos_seatoff = nan;

    if ~isfield(seg, 'time_sts') || ~isfield(seg.time_sts, 'time_seat_off')
        return;
    end

    metrics.mos_plantar_seatoff = extract_signal_value_at_event(seg, 'seg.mos.cmp_h_plantar_fixed.sum', seg.time_sts.time_seat_off);
    metrics.mos_xcom_seatoff = extract_signal_value_at_event(seg, 'seg.mos.hof_new.sum', seg.time_sts.time_seat_off);
    metrics.mmos_seatoff = extract_signal_value_at_event(seg, 'seg.mos.cmp_h_new.sum', seg.time_sts.time_seat_off);
end

function metrics = extract_main_valley_metrics(seg)
    metrics.main_valley_time = nan;
    metrics.main_valley_value = nan;
    metrics.main_valley_front_exceed = nan;
    metrics.seatoff_front_exceed = nan;

    if isfield(seg, 'main_valley')
        metrics.main_valley_time = seg.main_valley.time;
        metrics.main_valley_value = seg.main_valley.value;
        metrics.main_valley_front_exceed = seg.main_valley.front_exceed;
        metrics.seatoff_front_exceed = seg.main_valley.seat_off_front_exceed;
    end
end

function value = extract_signal_value_at_event(seg, str_para, event_time)
    value = nan;
    data = get_nested_field(seg, str_para);
    if isempty(data)
        return;
    end
    data = data(:);
    time = get_matching_time(seg, numel(data));
    if isempty(time)
        return;
    end
    idx = GetIdxTime(time(:), event_time);
    if isempty(idx) || idx < 1 || idx > numel(data)
        return;
    end
    value = data(idx);
end

function p_value = compare_continuous_groups(control_vals, patient_vals)
    control_vals = control_vals(:);
    patient_vals = patient_vals(:);
    control_vals = control_vals(~isnan(control_vals));
    patient_vals = patient_vals(~isnan(patient_vals));

    p_value = nan;
    if numel(control_vals) < 2 || numel(patient_vals) < 2
        return;
    end
    [~, p_value] = ttest2(control_vals, patient_vals, 'Vartype', 'unequal');
end

function p_value = compare_sex_distribution(control_male, control_female, patient_male, patient_female)
    counts = [control_male, control_female; patient_male, patient_female];
    if any(counts(:) < 0) || sum(counts(:)) == 0
        p_value = nan;
        return;
    end

    row_sum = sum(counts, 2);
    col_sum = sum(counts, 1);
    expected = row_sum * col_sum / sum(counts(:));
    if any(expected(:) == 0)
        p_value = nan;
        return;
    end

    chi2 = sum((counts - expected).^2 ./ expected, 'all');
    p_value = gammainc(chi2 / 2, 0.5, 'upper');
end

function values = pick_numeric_values(source, indices)
    values = nan(numel(indices), 1);
    if isempty(source)
        return;
    end
    source = source(:);
    for i = 1:numel(indices)
        idx = indices(i);
        if idx >= 1 && idx <= numel(source)
            values(i) = source(idx);
        end
    end
end

function genders = pick_gender_values(source, indices)
    genders = repmat('U', numel(indices), 1);
    if isempty(source)
        return;
    end
    source = source(:);
    for i = 1:numel(indices)
        idx = indices(i);
        if idx >= 1 && idx <= numel(source)
            genders(i) = source(idx);
        end
    end
end

function [n_male, n_female] = count_male_female(genders)
    n_male = sum(genders == 'M');
    n_female = sum(genders == 'F');
end

function out = format_mean_sd(values, precision)
    values = values(:);
    values = values(~isnan(values));
    if isempty(values)
        out = '-';
        return;
    end
    fmt = ['%0.', num2str(precision), 'f'];
    out = [num2str(mean(values, 'omitnan'), fmt), ' +/- ', num2str(std(values, 'omitnan'), fmt)];
end

function out = format_p_value(p_value)
    if isnan(p_value)
        out = '-';
    elseif p_value < 0.001
        out = '<0.001';
    else
        out = num2str(p_value, '%.3f');
    end
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
