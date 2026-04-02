% 在Vicon+测力台数据中验证XcoM
close all; clear; clc
cd('..'); % 将路径移到上一层
addpath(genpath('../../data/dataSTS2'));
addpath(genpath('../../data/dataSTS2P'));
addpath(genpath('../../data/dataKinect2'));
addpath('../../correctionValue');
addpath(genpath('../../mat_data'));
addpath(genpath('../algorithms'));
addpath(genpath('./algorithm_STS2'));

%% 初始化

flag_select_paras = false;
flag_draw_bos = false;
flag_show_figs = false;
flag_bw = true;

PartInitialization;

height_sit = 0.52;
plantar_buttock_displacement = 0.45;

%% 读取数据

cellData = ReadAndSortDataKinect2();

%% 所有被试
if false
    cellSegs = {};
    for idxFile = 1:length(cellData)
        close all;
        
        disp([num2str(idxFile),' / ',num2str(length(cellData))]);
        if ismember(idxFile,[2,8]), continue; end

        data = cellData{idxFile};
        disp([num2str(data.idxSub,'%03d'),num2str(data.idxSTS,'%02d'),num2str(data.idxSTSTest,'%02d'),' 右脚：',num2str(data.isRight)]);
        
        dataPlantar = data.plantar; dataHip = data.hip; 
        masterAll = data.kinect.master; [stream,stream2] = SelectSubjectLongest(masterAll);
        groupStream2 = [12,13,27,28,29];
        if ismember(idxFile,groupStream2)
            stream = stream2;
        end
        % vicon+测力台
        grf = data.grf;
        ik = data.ik;
        id = data.id;
        analysisGround = data.analysis.analysisGround;
        analysisParent = data.analysis.analysisParent;
        analysis = analysisGround;
        % kinect+预测grf
        grfP = data.grfP;
        grfPX = grfP; grfPY = grfP;
        ikP = data.ikP;
        okP = data.okP;
        idP = data.idP;
        analysisGroundP = data.analysisP.analysisGround;
        analysisParentP = data.analysisP.analysisParent;
        
        %% 预处理
        PartPreprocessing_com_cmp;

        %% 划分站起周期
        PartSegmentsSTS;

        %% 计算CoM/XcoM/CoM_CMP
        PartCalCoMs;

        %% 移动阵列到Vicon坐标系
        PartFS2Vicon;

        %% ======== BoS =======
        % PartCalculateBoS_original;
        % PartCalculateBoS;
        PartCalculateBoS_left_right_buttock;

        %% 计算MoS
        % xcom_hof到bos_plantar；xcom_hof到bos_new；xcom_cmp_h到bos_new
        mos_com_plantar = calc_mos_signed_distance(com, bos_plantar, times);
        mos_com_plantar_fixed = calc_mos_signed_distance(com, bos_plantar_fixed, times);
        mos_com_total_fixed = calc_mos_signed_distance(com, bos_total_fixed, times);
        mos_com_new = calc_mos_signed_distance(com, bos_new, times);

        mos_hof_plantar = calc_mos_signed_distance(xcom_hof, bos_plantar, times);
        mos_hof_plantar_fixed = calc_mos_signed_distance(xcom_hof, bos_plantar_fixed, times);
        mos_hof_total_fixed = calc_mos_signed_distance(xcom_hof, bos_total_fixed, times);
        mos_hof_new = calc_mos_signed_distance(xcom_hof, bos_new, times);
        
        mos_cmp_h_plantar = calc_mos_signed_distance(xcom_cmp_h, bos_plantar, times);
        mos_cmp_h_plantar_fixed = calc_mos_signed_distance(xcom_cmp_h, bos_plantar_fixed, times);
        mos_cmp_h_total_fixed = calc_mos_signed_distance(xcom_cmp_h, bos_total_fixed, times);
        mos_cmp_h_new = calc_mos_signed_distance(xcom_cmp_h, bos_new, times);
        mos_cmp_h_nom = calc_mos_signed_distance(xcom_cmp_h, bos_nom, times);
        mos_cmp_h_adm = calc_mos_signed_distance(xcom_cmp_h, bos_adm, times);
        mos_cmp_h_rob = calc_mos_signed_distance(xcom_cmp_h, bos_rob, times);
        
        %% 记录所有站起段
        for idx_seg = 1:length(times_sts)
            time_start = times_sts(idx_seg,1);
            time_end = times_sts(idx_seg,4);
            idx_start_union = GetIdxTime(times.union,time_start);
            idx_end_union = GetIdxTime(times.union,time_end);
            range_union = idx_start_union:idx_end_union;
            idx_start_vicon = GetIdxTime(times.vicon,time_start);
            idx_end_vicon = GetIdxTime(times.vicon,time_end);
            range_vicon = idx_start_vicon:idx_end_vicon;

            seg = struct();

            % 基本信息
            seg.info.idx_sub = data.idxSub;
            seg.info.idx_sts = data.idxSTS;
            seg.info.idx_test = data.idxSTSTest;
            seg.info.idx_seg = idx_seg;
            seg.info.weight = weight;
            seg.info.height = height;

            % 分段
            seg.time_sts.time_start = times_sts(idx_seg,1);
            seg.time_sts.time_seat_off = times_sts(idx_seg,2);
            seg.time_sts.time_min_grf_plantar = times_sts(idx_seg,3);
            seg.time_sts.time_end = times_sts(idx_seg,4);

            % 时间
            seg.times.union = times.union(range_union);
            seg.times.vicon = times.vicon(range_vicon);
            
            % CoM, XcoM_hof, CoM_CMP
            seg.com.x = com.x(range_vicon);
            seg.com.y = com.y(range_vicon);
            seg.com.z = com.z(range_vicon);
            seg.xcom_hof.x = xcom_hof.x(range_vicon);
            seg.xcom_hof.y = xcom_hof.y(range_vicon);
            seg.xcom_cmp.x = xcom_cmp.x(range_vicon);
            seg.xcom_cmp.y = xcom_cmp.y(range_vicon);
            seg.xcom_cmp_h.x = xcom_cmp_h.x(range_vicon);
            seg.xcom_cmp_h.y = xcom_cmp_h.y(range_vicon);
            seg.com.vx = com.vx(range_vicon);
            seg.com.vy = com.vy(range_vicon);
            seg.com.vz = com.vz(range_vicon);
            seg.com.ax = com.ax(range_vicon);
            seg.com.ay = com.ay(range_vicon);
            seg.com.az = com.az(range_vicon);

            seg.omega_hof = omega_hof(range_vicon);
            seg.omega_cmp = omega_cmp(range_vicon);
                
            % BoS
            seg.bos.plantar_left = struct('x', bos_plantar_left.x(range_union), 'y', bos_plantar_left.y(range_union));
            seg.bos.plantar_right = struct('x', bos_plantar_right.x(range_union), 'y', bos_plantar_right.y(range_union));
            seg.bos.plantar = struct('x', bos_plantar.x(range_union), 'y', bos_plantar.y(range_union));
            seg.bos.buttock = struct('x', bos_buttock.x(range_union), 'y', bos_buttock.y(range_union));
            seg.bos.new = struct('x', bos_new.x(range_union), 'y', bos_new.y(range_union));
            seg.bos.nom = struct('x', bos_nom.x(range_union), 'y', bos_nom.y(range_union));
            seg.bos.adm = struct('x', bos_adm.x(range_union), 'y', bos_adm.y(range_union));
            seg.bos.rob = struct('x', bos_rob.x(range_union), 'y', bos_rob.y(range_union));

            seg.bos.alpha_left = Fz_plantar_left_f ./ Fz_sum_f;
            seg.bos.alpha_right = Fz_plantar_right_f ./ Fz_sum_f;
            seg.bos.alpha_buttock = Fz_buttock_f ./ Fz_sum_f;

            % MoS
            % 定义一个快速函数用于赋值
            func_assign_mos = @(mos, range_union) struct(...
                'sum', mos.sum(range_union), ...
                'front', mos.front(range_union), ...
                'back', mos.back(range_union), ...
                'left', mos.left(range_union), ...
                'right', mos.right(range_union));

            seg.mos.com_plantar = func_assign_mos(mos_com_plantar, range_union);
            seg.mos.com_plantar_fixed = func_assign_mos(mos_com_plantar_fixed, range_union);
            seg.mos.com_total_fixed = func_assign_mos(mos_com_total_fixed, range_union);
            seg.mos.com_new = func_assign_mos(mos_com_new, range_union);
            seg.mos.hof_plantar = func_assign_mos(mos_hof_plantar, range_union);
            seg.mos.hof_plantar_fixed = func_assign_mos(mos_hof_plantar_fixed, range_union);
            seg.mos.hof_total_fixed = func_assign_mos(mos_hof_total_fixed, range_union);
            seg.mos.hof_new = func_assign_mos(mos_hof_new, range_union);
            seg.mos.cmp_h_plantar = func_assign_mos(mos_cmp_h_plantar, range_union);
            seg.mos.cmp_h_plantar_fixed = func_assign_mos(mos_cmp_h_plantar_fixed, range_union);
            seg.mos.cmp_h_total_fixed = func_assign_mos(mos_cmp_h_total_fixed, range_union);
            seg.mos.cmp_h_new = func_assign_mos(mos_cmp_h_new, range_union);
            seg.mos.cmp_h_nom = func_assign_mos(mos_cmp_h_nom, range_union);
            seg.mos.cmp_h_adm = func_assign_mos(mos_cmp_h_adm, range_union);
            seg.mos.cmp_h_rob = func_assign_mos(mos_cmp_h_rob, range_union);

            % 关节角
            seg.ja.hip_flexion_l = ik.hip_flexion_l(range_vicon);
            seg.ja.hip_flexion_r = ik.hip_flexion_r(range_vicon);
            seg.ja.knee_angle_l = ik.knee_angle_l(range_vicon);
            seg.ja.knee_angle_r = ik.knee_angle_r(range_vicon);
            seg.ja.ankle_angle_l = ik.ankle_angle_l(range_vicon);
            seg.ja.ankle_angle_r = ik.ankle_angle_r(range_vicon);
            seg.ja.lumbar_extension = ik.lumbar_extension(range_vicon);

            % grf
            seg.grf.plantar_left_x = Fx_plantar_left(range_vicon);
            seg.grf.plantar_left_y = Fy_plantar_left(range_vicon);
            seg.grf.plantar_left_z = Fz_plantar_left(range_vicon);
            seg.grf.plantar_right_x = Fx_plantar_right(range_vicon);
            seg.grf.plantar_right_y = Fy_plantar_right(range_vicon);
            seg.grf.plantar_right_z = Fz_plantar_right(range_vicon);
            seg.grf.plantar_x = Fx_plantar(range_vicon);
            seg.grf.plantar_y = Fy_plantar(range_vicon);
            seg.grf.plantar_z = Fz_plantar(range_vicon);
            seg.grf.hip_x = Fx_buttock(range_vicon);
            seg.grf.hip_y = Fy_buttock(range_vicon);
            seg.grf.hip_z = Fz_buttock(range_vicon);

            cellSegs = [cellSegs;seg];
        end
        
    end
    save('../../mat_data/com_cmp_all.mat','cellSegs');
else
    load('../../mat_data/com_cmp_all.mat','cellSegs');
end

%% ========= 结果 ==========
cellSegs_MT = cellSegs(cellfun(@(x) x.info.idx_sts == 1, cellSegs));
cellSegs_ETF = cellSegs(cellfun(@(x) x.info.idx_sts == 2, cellSegs));
cellSegs_DVR = cellSegs(cellfun(@(x) x.info.idx_sts == 3, cellSegs));

output_dir = fullfile('outputs', 'experiment_a');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% Table 2: 实验A描述性指标
table_exp_a = build_experiment_a_table(cellSegs_MT, cellSegs_ETF, cellSegs_DVR);
disp('Table 2. Experiment A descriptive metrics:');
disp(table_exp_a);
writetable(table_exp_a, fullfile(output_dir, 'Table2_ExperimentA.csv'));

%% Figure 2: 实验A核心图
plot_experiment_a_figure2(cellSegs_MT, cellSegs_ETF, cellSegs_DVR, ...
    flag_bw, output_dir);

%% Figure 2: Experiment A core figure
plot_experiment_a_figure2(cellSegs_MT, cellSegs_ETF, cellSegs_DVR, ...
    flag_bw, output_dir);

%% Figure 3: cmp_h_new vs cmp_h_nom
plot_experiment_a_cmp_h_new_vs_nom(cellSegs_MT, cellSegs_ETF, cellSegs_DVR, ...
    flag_bw, output_dir);


function table_exp_a = build_experiment_a_table(cellSegs_MT, cellSegs_ETF, cellSegs_DVR)
    stats_MT = calc_strategy_stats_from_seg(cellSegs_MT);
    stats_ETF = calc_strategy_stats_from_seg(cellSegs_ETF);
    stats_DVR = calc_strategy_stats_from_seg(cellSegs_DVR);

    metric_names = { ...
        'Duration (s)'; ...
        'Seat-off timing (s)'; ...
        'Maximum trunk flexion angle (deg)'; ...
        'Peak plantar vertical GRF (N)' ...
    };

    table_exp_a = table( ...
        metric_names, ...
        {format_mean_std(stats_MT.duration_mean, stats_MT.duration_std, '%.2f'); ...
         format_mean_std(stats_MT.seat_off_mean, stats_MT.seat_off_std, '%.2f'); ...
         format_mean_std(stats_MT.trunk_flex_mean, stats_MT.trunk_flex_std, '%.1f'); ...
         format_mean_std(stats_MT.max_grf_mean, stats_MT.max_grf_std, '%.1f')}, ...
        {format_mean_std(stats_ETF.duration_mean, stats_ETF.duration_std, '%.2f'); ...
         format_mean_std(stats_ETF.seat_off_mean, stats_ETF.seat_off_std, '%.2f'); ...
         format_mean_std(stats_ETF.trunk_flex_mean, stats_ETF.trunk_flex_std, '%.1f'); ...
         format_mean_std(stats_ETF.max_grf_mean, stats_ETF.max_grf_std, '%.1f')}, ...
        {format_mean_std(stats_DVR.duration_mean, stats_DVR.duration_std, '%.2f'); ...
         format_mean_std(stats_DVR.seat_off_mean, stats_DVR.seat_off_std, '%.2f'); ...
         format_mean_std(stats_DVR.trunk_flex_mean, stats_DVR.trunk_flex_std, '%.1f'); ...
         format_mean_std(stats_DVR.max_grf_mean, stats_DVR.max_grf_std, '%.1f')}, ...
        'VariableNames', {'Metric', 'MT', 'ETF', 'DVR'});
end

function plot_experiment_a_figure2(cellSegs_MT, cellSegs_ETF, cellSegs_DVR, flag_bw, output_dir)
    strategy_cells = {cellSegs_MT, cellSegs_ETF, cellSegs_DVR};
    strategy_names = {'MT', 'ETF', 'DVR'};

    top_spec = struct();
    top_spec.str_paras = {'seg.xcom_hof.y', 'seg.xcom_cmp_h.y'};
    top_spec.legend_names = {'XcoM', 'VDI-XcoM'};
    top_spec.y_name = 'Position / m';
    top_spec.colors = make_plot_colors(2, flag_bw);
    top_spec.line_styles = make_line_styles(2, flag_bw);

    bottom_spec = struct();
    bottom_spec.str_paras = {'seg.mos.cmp_h_plantar_fixed.sum', 'seg.mos.hof_new.sum', 'seg.mos.cmp_h_new.sum'};
    bottom_spec.legend_names = {'MoS_{plantar}', 'MoS_{XcoM}', 'MMoS'};
    bottom_spec.y_name = 'Distance / m';
    bottom_spec.colors = make_plot_colors(3, flag_bw);
    bottom_spec.line_styles = make_line_styles(3, flag_bw);

    top_curves = cell(1, 3);
    bottom_curves = cell(1, 3);
    top_x_max = 0;
    bottom_x_max = 0;
    top_y_min = inf;
    top_y_max = -inf;
    bottom_y_min = inf;
    bottom_y_max = -inf;

    for idx_strategy = 1:3
        top_curves{idx_strategy} = collect_average_curves(strategy_cells{idx_strategy}, top_spec.str_paras);
        bottom_curves{idx_strategy} = collect_average_curves(strategy_cells{idx_strategy}, bottom_spec.str_paras);

        top_x_max = max(top_x_max, top_curves{idx_strategy}.time_max);
        bottom_x_max = max(bottom_x_max, bottom_curves{idx_strategy}.time_max);

        [top_y_min, top_y_max] = update_axis_limits(top_curves{idx_strategy}, top_y_min, top_y_max);
        [bottom_y_min, bottom_y_max] = update_axis_limits(bottom_curves{idx_strategy}, bottom_y_min, bottom_y_max);
    end

    top_ylim = expand_axis_limits(top_y_min, top_y_max);
    bottom_ylim = expand_axis_limits(bottom_y_min, bottom_y_max);
    top_x_max = max(2.5, top_x_max);
    bottom_x_max = max(2.5, bottom_x_max);

    fig = figure('Color', 'white', 'Position', [100, 100, 1500, 760]);
    tl = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

    for idx_strategy = 1:3
        ax = nexttile(tl, idx_strategy);
        line_handles = plot_strategy_panel(ax, top_curves{idx_strategy}, top_spec, ...
            strategy_names{idx_strategy}, 'XcoM vs VDI-XcoM', top_ylim, top_x_max);
        if idx_strategy == 1
            ylabel(ax, top_spec.y_name, 'FontName', 'Times New Roman', 'FontSize', 15);
        end
        if idx_strategy == 3
            legend(ax, line_handles, top_spec.legend_names, 'Location', 'southeast', ...
                'FontName', 'Times New Roman', 'FontSize', 13, 'Box', 'off');
        end
    end

    for idx_strategy = 1:3
        ax = nexttile(tl, idx_strategy + 3);
        line_handles = plot_strategy_panel(ax, bottom_curves{idx_strategy}, bottom_spec, ...
            strategy_names{idx_strategy}, 'MoS Comparison', bottom_ylim, bottom_x_max);
        xlabel(ax, 'Time / s', 'FontName', 'Times New Roman', 'FontSize', 15);
        if idx_strategy == 1
            ylabel(ax, bottom_spec.y_name, 'FontName', 'Times New Roman', 'FontSize', 15);
        end
        if idx_strategy == 3
            legend(ax, line_handles, bottom_spec.legend_names, 'Location', 'southeast', ...
                'FontName', 'Times New Roman', 'FontSize', 13, 'Box', 'off');
        end
    end

    print(fig, fullfile(output_dir, 'Figure2_ExperimentA.png'), '-dpng', '-r600');
end

function plot_experiment_a_cmp_h_new_vs_nom(cellSegs_MT, cellSegs_ETF, cellSegs_DVR, flag_bw, output_dir)
    strategy_cells = {cellSegs_MT, cellSegs_ETF, cellSegs_DVR};
    strategy_names = {'MT', 'ETF', 'DVR'};

    spec = struct();
    spec.str_paras = {'seg.mos.cmp_h_new.sum', 'seg.mos.cmp_h_nom.sum'};
    spec.legend_names = {'MMoS_{new}', 'MMoS_{nom}'};
    spec.y_name = 'Distance / m';
    spec.colors = make_plot_colors(2, flag_bw);
    spec.line_styles = make_line_styles(2, flag_bw);

    curves = cell(1, 3);
    x_max = 0;
    y_min = inf;
    y_max = -inf;

    for idx_strategy = 1:3
        curves{idx_strategy} = collect_average_curves(strategy_cells{idx_strategy}, spec.str_paras);
        x_max = max(x_max, curves{idx_strategy}.time_max);
        [y_min, y_max] = update_axis_limits(curves{idx_strategy}, y_min, y_max);
    end

    y_limits = expand_axis_limits(y_min, y_max);
    x_max = max(2.5, x_max);

    fig = figure('Color', 'white', 'Position', [120, 120, 1500, 440]);
    tl = tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

    for idx_strategy = 1:3
        ax = nexttile(tl, idx_strategy);
        line_handles = plot_strategy_panel(ax, curves{idx_strategy}, spec, ...
            strategy_names{idx_strategy}, 'MMoS_{new} vs MMoS_{nom}', y_limits, x_max);
        xlabel(ax, 'Time / s', 'FontName', 'Times New Roman', 'FontSize', 15);
        if idx_strategy == 1
            ylabel(ax, spec.y_name, 'FontName', 'Times New Roman', 'FontSize', 15);
        end
        if idx_strategy == 3
            legend(ax, line_handles, spec.legend_names, 'Location', 'southeast', ...
                'FontName', 'Times New Roman', 'FontSize', 13, 'Box', 'off');
        end
    end

    print(fig, fullfile(output_dir, 'Figure3_cmp_h_new_vs_nom_ExperimentA.png'), '-dpng', '-r600');
end

function line_handles = plot_strategy_panel(ax, curve_bundle, spec, strategy_name, panel_label, y_limits, x_max)
    hold(ax, 'on');
    grid(ax, 'on');
    box(ax, 'on');
    set(ax, 'FontName', 'Times New Roman', 'FontSize', 14, 'LineWidth', 1.1, ...
        'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');

    seat_off_time = curve_bundle.time_stages{1}(2);
    min_grf_time = curve_bundle.time_stages{1}(3);
    h_seat_off = xline(ax, seat_off_time, ':', 't_{SO}', 'Color', [0.15 0.15 0.15], ...
        'LineWidth', 1.6, 'FontName', 'Times New Roman', 'FontSize', 14, ...
        'LabelHorizontalAlignment', 'left');
    h_min_grf = xline(ax, min_grf_time, ':', 'Color', [0.55 0.55 0.55], 'LineWidth', 1.2);
    h_seat_off.Annotation.LegendInformation.IconDisplayStyle = 'off';
    h_min_grf.Annotation.LegendInformation.IconDisplayStyle = 'off';

    line_handles = gobjects(1, numel(spec.str_paras));
    for idx_para = 1:numel(spec.str_paras)
        line_handles(idx_para) = plot(ax, curve_bundle.time_curves{idx_para}, curve_bundle.mean_curves{idx_para}, ...
            'Color', spec.colors(idx_para, :), ...
            'LineStyle', spec.line_styles{idx_para}, ...
            'LineWidth', 2.0);
    end

    xlim(ax, [0, x_max]);
    ylim(ax, y_limits);
    title(ax, {strategy_name, panel_label}, 'FontName', 'Times New Roman', 'FontSize', 16);
end

function curve_bundle = collect_average_curves(cellSegs, str_paras)
    n_para = numel(str_paras);
    curve_bundle.mean_curves = cell(1, n_para);
    curve_bundle.std_curves = cell(1, n_para);
    curve_bundle.time_curves = cell(1, n_para);
    curve_bundle.time_stages = cell(1, n_para);
    curve_bundle.time_max = 0;

    for idx_para = 1:n_para
        [mean_curve, std_curve, time_curve, time_stage] = get_average_curve_single(cellSegs, str_paras{idx_para});
        curve_bundle.mean_curves{idx_para} = mean_curve;
        curve_bundle.std_curves{idx_para} = std_curve;
        curve_bundle.time_curves{idx_para} = time_curve;
        curve_bundle.time_stages{idx_para} = time_stage;
        curve_bundle.time_max = max(curve_bundle.time_max, time_curve(end));
    end
end

function [mean_curve, std_curve, time_curve, time_stage] = get_average_curve_single(cellSegs, str_para)
    mean_curve = [];
    std_curve = [];
    time_curve = 0;
    time_stage = 0;

    for idx_stage = 1:3
        [datas_interp, time_mean] = get_average_curve_segment(cellSegs, str_para, idx_stage);
        if isempty(datas_interp)
            mean_data = nan(1, 101);
            std_data = nan(1, 101);
            time_mean = 0;
        else
            mean_data = mean(datas_interp, 1);
            std_data = std(datas_interp, 0, 1);
        end

        mean_curve = [mean_curve, mean_data]; %#ok<AGROW>
        std_curve = [std_curve, std_data]; %#ok<AGROW>
        time_curve = [time_curve, time_curve(end) + linspace(0, time_mean, numel(mean_data))]; %#ok<AGROW>
        time_stage(end+1) = time_stage(end) + time_mean; %#ok<AGROW>
    end

    time_curve(1) = [];
end

function [datas_interp, time_mean] = get_average_curve_segment(cellSegs, str_para, idx_stage)
    time_interp = 0:0.01:1;
    datas_interp = zeros(0, numel(time_interp));
    time_mean = [];

    for idx_seg = 1:length(cellSegs)
        seg = cellSegs{idx_seg};
        if ~isfield(seg, 'time_sts')
            continue;
        end

        t_start = seg.time_sts.time_start;
        t_seat_off = seg.time_sts.time_seat_off;
        t_min = seg.time_sts.time_min_grf_plantar;
        t_end = seg.time_sts.time_end;

        if idx_stage == 1
            t1 = t_start;
            t2 = t_seat_off;
        elseif idx_stage == 2
            t1 = t_seat_off;
            t2 = t_min;
        else
            t1 = t_min;
            t2 = t_end;
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
            continue;
        end

        idxs = GetIdxTime(time, [t1, t2]);
        if isempty(idxs) || numel(idxs) < 2
            continue;
        end
        period = idxs(1):idxs(2);
        if numel(period) < 2
            continue;
        end

        time_seg = time(period);
        time_mean(end+1) = range(time_seg); %#ok<AGROW>
        time_norm = (time_seg - time_seg(1)) ./ max(eps, range(time_seg));
        data_seg = data(period);
        datas_interp(end+1, :) = interp1(time_norm, data_seg, time_interp, 'linear', 'extrap'); %#ok<AGROW>
    end

    if ~isempty(time_mean)
        time_mean = mean(time_mean);
    end
end

function data = get_nested_field(seg, str_para)
    field_path = strrep(str_para, 'seg.', '');
    parts = strsplit(field_path, '.');
    data = seg;
    for idx_part = 1:numel(parts)
        if isstruct(data) && isfield(data, parts{idx_part})
            data = data.(parts{idx_part});
        else
            data = [];
            return;
        end
    end
end

function [y_min, y_max] = update_axis_limits(curve_bundle, y_min, y_max)
    for idx_para = 1:numel(curve_bundle.mean_curves)
        current_curve = curve_bundle.mean_curves{idx_para};
        if isempty(current_curve)
            continue;
        end
        y_min = min(y_min, min(current_curve, [], 'omitnan'));
        y_max = max(y_max, max(current_curve, [], 'omitnan'));
    end
end

function y_limits = expand_axis_limits(y_min, y_max)
    if ~isfinite(y_min) || ~isfinite(y_max)
        y_limits = [-1, 1];
        return;
    end

    if abs(y_max - y_min) < eps
        pad = max(abs(y_max) * 0.05, 0.05);
    else
        pad = 0.08 * (y_max - y_min);
    end
    y_limits = [y_min - pad, y_max + pad];
end

function stats = calc_strategy_stats_from_seg(cellSegs)
    n_seg = numel(cellSegs);
    durations = nan(n_seg, 1);
    seat_offs = nan(n_seg, 1);
    trunk_flex_peaks = nan(n_seg, 1);
    max_grf = nan(n_seg, 1);

    for idx_seg = 1:n_seg
        seg = cellSegs{idx_seg};
        durations(idx_seg) = seg.time_sts.time_end - seg.time_sts.time_start;
        seat_offs(idx_seg) = seg.time_sts.time_seat_off - seg.time_sts.time_start;

        if isfield(seg, 'ja') && isfield(seg.ja, 'lumbar_extension') && ~isempty(seg.ja.lumbar_extension)
            % 原始信号是 lumbar extension，因此取最小值并转成前屈幅值。
            trunk_flex_peaks(idx_seg) = -min(seg.ja.lumbar_extension);
        end
        if isfield(seg, 'grf') && isfield(seg.grf, 'plantar_z') && ~isempty(seg.grf.plantar_z)
            max_grf(idx_seg) = max(seg.grf.plantar_z);
        end
    end

    stats.duration_mean = mean(durations, 'omitnan');
    stats.duration_std = std(durations, 'omitnan');
    stats.seat_off_mean = mean(seat_offs, 'omitnan');
    stats.seat_off_std = std(seat_offs, 'omitnan');
    stats.trunk_flex_mean = mean(trunk_flex_peaks, 'omitnan');
    stats.trunk_flex_std = std(trunk_flex_peaks, 'omitnan');
    stats.max_grf_mean = mean(max_grf, 'omitnan');
    stats.max_grf_std = std(max_grf, 'omitnan');
end

function str_out = format_mean_std(mean_val, std_val, fmt)
    if nargin < 3 || isempty(fmt)
        fmt = '%.2f';
    end
    str_out = [num2str(mean_val, fmt), ' ± ', num2str(std_val, fmt)];
end

function colors = make_plot_colors(n, flag_bw)
    if flag_bw
        if n == 2
            colors = [0.65, 0.65, 0.65; 0.00, 0.00, 0.00];
        elseif n == 3
            colors = [0.78, 0.78, 0.78; 0.45, 0.45, 0.45; 0.00, 0.00, 0.00];
        else
            colors = repmat(linspace(0.2, 0.8, n).', 1, 3);
        end
        return;
    end

    base = [ ...
        0.00, 0.45, 0.74; ...
        0.85, 0.33, 0.10; ...
        0.47, 0.67, 0.19 ...
    ];
    colors = base(1:n, :);
end

function line_styles = make_line_styles(n, flag_bw)
    if flag_bw
        presets = {'-', '--', '-.'};
    else
        presets = {'-', '-', '-'};
    end

    line_styles = cell(1, n);
    for idx = 1:n
        line_styles{idx} = presets{min(idx, numel(presets))};
    end
end
