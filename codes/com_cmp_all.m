% Validate XcoM using Vicon + force plate data
close all; clear; clc
addpath(genpath('./algorithms'));
addpath(genpath('../data'));

%% Initialization

flag_select_paras = false;
flag_draw_bos = false;
flag_show_figs = false;
flag_bw = true;

PartInitialization;

height_sit = 0.52;
plantar_buttock_displacement = 0.45;

%% Load data

cellData = ReadAndSortDataKinect2();

%% All subjects
if false
    cellSegs = {};
    for idxFile = 1:length(cellData)
        clc;close all;
        
        disp([num2str(idxFile),' / ',num2str(length(cellData))]);
        if ismember(idxFile,[2,8]), continue; end

        data = cellData{idxFile};
        disp([num2str(data.idxSub,'%03d'),num2str(data.idxSTS,'%02d'),num2str(data.idxSTSTest,'%02d'),' Right foot: ',num2str(data.isRight)]);
        
        dataPlantar = data.plantar; dataHip = data.hip; 
        masterAll = data.kinect.master; [stream,stream2] = SelectSubjectLongest(masterAll);
        groupStream2 = [12,13,27,28,29];
        if ismember(idxFile,groupStream2)
            stream = stream2;
        end
        % Vicon + force plate
        grf = data.grf;
        ik = data.ik;
        id = data.id;
        analysisGround = data.analysis.analysisGround;
        analysisParent = data.analysis.analysisParent;
        analysis = analysisGround;

        %% Preprocessing
        PartPreprocessing_com_cmp;

        %% Segment STS cycle
        PartSegmentsSTS;

        %% Compute CoM / XcoM / CoM_CMP
        PartCalCoMs;

        %% Transform arrays to Vicon coordinate system
        PartFS2Vicon;

        %% ======== BoS =======
        % PartCalculateBoS_original;
        % PartCalculateBoS;
        PartCalculateBoS_left_right_buttock;

        %% Compute MoS
        % XcoM_hof to BoS_plantar; XcoM_hof to BoS_new; XcoM_cmp_h to BoS_new
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
        
        %% Record all STS segments
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

            % Basic info
            seg.info.idx_sub = data.idxSub;
            seg.info.idx_sts = data.idxSTS;
            seg.info.idx_test = data.idxSTSTest;
            seg.info.idx_seg = idx_seg;
            seg.info.weight = weight;
            seg.info.height = height;

            % Segmentation events
            seg.time_sts.time_start = times_sts(idx_seg,1);
            seg.time_sts.time_seat_off = times_sts(idx_seg,2);
            seg.time_sts.time_min_grf_plantar = times_sts(idx_seg,3);
            seg.time_sts.time_end = times_sts(idx_seg,4);

            % Time vectors
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

            % MoS
            % Quick helper for assignment
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

            % Joint angles
            seg.ja.hip_flexion_l = ik.hip_flexion_l(range_vicon);
            seg.ja.hip_flexion_r = ik.hip_flexion_r(range_vicon);
            seg.ja.knee_angle_l = ik.knee_angle_l(range_vicon);
            seg.ja.knee_angle_r = ik.knee_angle_r(range_vicon);
            seg.ja.ankle_angle_l = ik.ankle_angle_l(range_vicon);
            seg.ja.ankle_angle_r = ik.ankle_angle_r(range_vicon);
            seg.ja.lumbar_extension = ik.lumbar_extension(range_vicon);

            % GRF
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
    save('./com_cmp_all.mat','cellSegs');
else
    load('./com_cmp_all.mat','cellSegs');
end

%% ========= Results ==========
close all;clc
%% Grouping
cellSegs_MT = cellSegs(cellfun(@(x) x.info.idx_sts == 1, cellSegs));
cellSegs_ETF = cellSegs(cellfun(@(x) x.info.idx_sts == 2, cellSegs)); %#ok<NASGU>
cellSegs_DVR = cellSegs(cellfun(@(x) x.info.idx_sts == 3, cellSegs)); %#ok<NASGU>

%% Plot: validate slow-varying condition
% Validate \left|\frac{\dot\omega(t)}{\omega^2(t)}\right| \ll 1
for idx_seg = 1:length(cellSegs)
    seg = cellSegs{idx_seg};
    if ~isfield(seg, 'omega_hof') || ~isfield(seg, 'omega_cmp')
        continue;
    end
    time_vicon = [];
    if isfield(seg, 'times') && isfield(seg.times, 'vicon')
        time_vicon = seg.times.vicon;
    end
    seg.slow_var.omega_hof = calc_slow_varying_ratio(seg.omega_hof, time_vicon);
    seg.slow_var.omega_cmp = calc_slow_varying_ratio(seg.omega_cmp, time_vicon);
    cellSegs{idx_seg} = seg;
end

cellSegs_MT = cellSegs(cellfun(@(x) x.info.idx_sts == 1, cellSegs));
cellSegs_ETF = cellSegs(cellfun(@(x) x.info.idx_sts == 2, cellSegs)); %#ok<NASGU>
cellSegs_DVR = cellSegs(cellfun(@(x) x.info.idx_sts == 3, cellSegs)); %#ok<NASGU>

str_paras = {'seg.slow_var.omega_hof','seg.slow_var.omega_cmp'};
fig_options = struct();
fig_options.str_paras = str_paras;
fig_options.figure_name = 'The Average Trends of Slow-Varying Condition';
fig_options.legend_names = {'|\dot{\omega}_{XcoM}/\omega_{XcoM}^2|','|\dot{\omega}_{P-XcoM}/\omega_{P-XcoM}^2|'};
fig_options.y_name = '|\dot{\omega}/\omega^2|';
FigureMeanAndStd_com_cmp(cellSegs_MT, cellSegs_ETF, cellSegs_DVR, fig_options);

%% Discriminability among three strategies
% Show the mean values of three strategies in a table:
% STS duration (time_sts.time_end - time_sts.time_start),
% seat-off time (time_sts.time_seat_off - time_sts.time_start),
% minimum trunk flexion angle (min(seg.ja.lumbar_extension)),
% maximum vertical plantar GRF (max(seg.grf.plantar_z)).
% Also print the results to the command window in plain language.
stats_MT = calc_strategy_stats_from_seg(cellSegs_MT);
stats_ETF = calc_strategy_stats_from_seg(cellSegs_ETF);
stats_DVR = calc_strategy_stats_from_seg(cellSegs_DVR);

strategy_names = {'MT','ETF','DVR'};
table_strategy = table(...
    [stats_MT.duration_mean; stats_ETF.duration_mean; stats_DVR.duration_mean], ...
    [stats_MT.duration_std; stats_ETF.duration_std; stats_DVR.duration_std], ...
    [stats_MT.seat_off_mean; stats_ETF.seat_off_mean; stats_DVR.seat_off_mean], ...
    [stats_MT.seat_off_std; stats_ETF.seat_off_std; stats_DVR.seat_off_std], ...
    [stats_MT.trunk_flex_mean; stats_ETF.trunk_flex_mean; stats_DVR.trunk_flex_mean], ...
    [stats_MT.trunk_flex_std; stats_ETF.trunk_flex_std; stats_DVR.trunk_flex_std], ...
    [stats_MT.max_grf_mean; stats_ETF.max_grf_mean; stats_DVR.max_grf_mean], ...
    [stats_MT.max_grf_std; stats_ETF.max_grf_std; stats_DVR.max_grf_std], ...
    'VariableNames', {'Duration_s','Duration_std','SeatOff_s','SeatOff_std', ...
                      'MinTrunkFlex_deg','MinTrunkFlex_std','MaxPlantarGRF_N','MaxPlantarGRF_std'}, ...
    'RowNames', strategy_names);

disp('Discriminability among three strategies (mean ± SD):');
disp(table_strategy);
disp(['MT mean STS duration ', num2str(stats_MT.duration_mean, '%.2f'), '±', num2str(stats_MT.duration_std, '%.2f'), ' s; ', ...
      'seat-off at ', num2str(stats_MT.seat_off_mean, '%.2f'), '±', num2str(stats_MT.seat_off_std, '%.2f'), ' s; ', ...
      'min trunk flexion ', num2str(stats_MT.trunk_flex_mean, '%.1f'), '±', num2str(stats_MT.trunk_flex_std, '%.1f'), ' deg; ', ...
      'max vertical plantar GRF ', num2str(stats_MT.max_grf_mean, '%.1f'), '±', num2str(stats_MT.max_grf_std, '%.1f'), ' N.']);
disp(['ETF mean STS duration ', num2str(stats_ETF.duration_mean, '%.2f'), '±', num2str(stats_ETF.duration_std, '%.2f'), ' s; ', ...
      'seat-off at ', num2str(stats_ETF.seat_off_mean, '%.2f'), '±', num2str(stats_ETF.seat_off_std, '%.2f'), ' s; ', ...
      'min trunk flexion ', num2str(stats_ETF.trunk_flex_mean, '%.1f'), '±', num2str(stats_ETF.trunk_flex_std, '%.1f'), ' deg; ', ...
      'max vertical plantar GRF ', num2str(stats_ETF.max_grf_mean, '%.1f'), '±', num2str(stats_ETF.max_grf_std, '%.1f'), ' N.']);
disp(['DVR mean STS duration ', num2str(stats_DVR.duration_mean, '%.2f'), '±', num2str(stats_DVR.duration_std, '%.2f'), ' s; ', ...
      'seat-off at ', num2str(stats_DVR.seat_off_mean, '%.2f'), '±', num2str(stats_DVR.seat_off_std, '%.2f'), ' s; ', ...
      'min trunk flexion ', num2str(stats_DVR.trunk_flex_mean, '%.1f'), '±', num2str(stats_DVR.trunk_flex_std, '%.1f'), ' deg; ', ...
      'max vertical plantar GRF ', num2str(stats_DVR.max_grf_mean, '%.1f'), '±', num2str(stats_DVR.max_grf_std, '%.1f'), ' N.']);

disp('Pairwise t-tests between groups (p<0.05 indicates significance):');
print_ttest_pair('STS duration', stats_MT.duration_vals, stats_ETF.duration_vals, 'MT', 'ETF');
print_ttest_pair('STS duration', stats_MT.duration_vals, stats_DVR.duration_vals, 'MT', 'DVR');
print_ttest_pair('STS duration', stats_ETF.duration_vals, stats_DVR.duration_vals, 'ETF', 'DVR');

print_ttest_pair('Seat-off time', stats_MT.seat_off_vals, stats_ETF.seat_off_vals, 'MT', 'ETF');
print_ttest_pair('Seat-off time', stats_MT.seat_off_vals, stats_DVR.seat_off_vals, 'MT', 'DVR');
print_ttest_pair('Seat-off time', stats_ETF.seat_off_vals, stats_DVR.seat_off_vals, 'ETF', 'DVR');

print_ttest_pair('Min trunk flexion angle', stats_MT.trunk_flex_vals, stats_ETF.trunk_flex_vals, 'MT', 'ETF');
print_ttest_pair('Min trunk flexion angle', stats_MT.trunk_flex_vals, stats_DVR.trunk_flex_vals, 'MT', 'DVR');
print_ttest_pair('Min trunk flexion angle', stats_ETF.trunk_flex_vals, stats_DVR.trunk_flex_vals, 'ETF', 'DVR');

print_ttest_pair('Max vertical plantar GRF', stats_MT.max_grf_vals, stats_ETF.max_grf_vals, 'MT', 'ETF');
print_ttest_pair('Max vertical plantar GRF', stats_MT.max_grf_vals, stats_DVR.max_grf_vals, 'MT', 'DVR');
print_ttest_pair('Max vertical plantar GRF', stats_ETF.max_grf_vals, stats_DVR.max_grf_vals, 'ETF', 'DVR');

%% Find two valleys of MMoS
output_dir = fullfile('outputs', 'mos_valley_plots');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
for idx_seg = 1:length(cellSegs)
    seg = cellSegs{idx_seg};
    signal = seg.mos.cmp_h_new.sum;
    idx_seat_off = GetIdxTime(seg.times.union, seg.time_sts.time_seat_off);
    [~,idx_v1] = min(signal);
    seg.valley.idx_v1 = -1;
    seg.valley.idx_v2 = -1;
    
    if idx_v1<5 || idx_v1>idx_seat_off
        cellSegs{idx_seg} = seg;
        continue; 
    end
    for aux = idx_v1:idx_seat_off
        if signal(aux) == max(signal(aux-1:aux+1)) ...
            && signal(aux)>0
            break;
        end
    end
    [~,idx_v2] = min(signal(aux:min([length(signal),idx_seat_off+5])));
    idx_v2 = idx_v2 + aux - 1;

    seg.valley.idx_v1 = idx_v1;
    seg.valley.idx_v2 = idx_v2;

    seg.valley.time_v1 = seg.times.union(idx_v1)-seg.time_sts.time_seat_off;
    seg.valley.time_v2 = seg.times.union(idx_v2)-seg.time_sts.time_seat_off;

    seg.valley.value_v1 = signal(idx_v1);
    seg.valley.value_v2 = signal(idx_v2);
    cellSegs{idx_seg} = seg;
end

%% Statistics: mean and std of value_v1 and value_v2 for three strategies
cellSegs_MT = cellSegs(cellfun(@(x) x.info.idx_sts == 1, cellSegs));
cellSegs_ETF = cellSegs(cellfun(@(x) x.info.idx_sts == 2, cellSegs)); 
cellSegs_DVR = cellSegs(cellfun(@(x) x.info.idx_sts == 3, cellSegs)); 

v1_MT = nan(length(cellSegs_MT),1);
v2_MT = nan(length(cellSegs_MT),1);
v1_ETF = nan(length(cellSegs_ETF),1);
v2_ETF = nan(length(cellSegs_ETF),1);
v1_DVR = nan(length(cellSegs_DVR),1);
v2_DVR = nan(length(cellSegs_DVR),1);
for idx_seg = 1:length(cellSegs_MT)
    seg = cellSegs_MT{idx_seg};
    if seg.valley.idx_v1<0, continue; end
    v1_MT(idx_seg) = seg.valley.value_v1;
    v2_MT(idx_seg) = seg.valley.value_v2;
end
for idx_seg = 1:length(cellSegs_ETF)
    seg = cellSegs_ETF{idx_seg};
    if seg.valley.idx_v1<0, continue; end
    v1_ETF(idx_seg) = seg.valley.value_v1;
    v2_ETF(idx_seg) = seg.valley.value_v2;
end
for idx_seg = 1:length(cellSegs_DVR)
    seg = cellSegs_DVR{idx_seg};
    if seg.valley.idx_v1<0, continue; end
    v1_DVR(idx_seg) = seg.valley.value_v1;
    v2_DVR(idx_seg) = seg.valley.value_v2;
end
v1_MT = v1_MT(~isnan(v1_MT));
v2_MT = v2_MT(~isnan(v2_MT));
v1_ETF = v1_ETF(~isnan(v1_ETF));
v2_ETF = v2_ETF(~isnan(v2_ETF));
v1_DVR = v1_DVR(~isnan(v1_DVR));
v2_DVR = v2_DVR(~isnan(v2_DVR));

%% Statistics: value_v1/value_v2/time_v1/time_v2 (mean and std) for three strategies
cellSegs_MT = cellSegs(cellfun(@(x) x.info.idx_sts == 1, cellSegs));
cellSegs_ETF = cellSegs(cellfun(@(x) x.info.idx_sts == 2, cellSegs)); 
cellSegs_DVR = cellSegs(cellfun(@(x) x.info.idx_sts == 3, cellSegs)); 

time_v1_MT = nan(length(cellSegs_MT),1);
time_v2_MT = nan(length(cellSegs_MT),1);
time_v1_ETF = nan(length(cellSegs_ETF),1);
time_v2_ETF = nan(length(cellSegs_ETF),1);
time_v1_DVR = nan(length(cellSegs_DVR),1);
time_v2_DVR = nan(length(cellSegs_DVR),1);
for idx_seg = 1:length(cellSegs_MT)
    seg = cellSegs_MT{idx_seg};
    if seg.valley.idx_v1<0, continue; end
    time_v1_MT(idx_seg) = seg.valley.time_v1;
    time_v2_MT(idx_seg) = seg.valley.time_v2;
end
for idx_seg = 1:length(cellSegs_ETF)
    seg = cellSegs_ETF{idx_seg};
    if seg.valley.idx_v1<0, continue; end
    time_v1_ETF(idx_seg) = seg.valley.time_v1;
    time_v2_ETF(idx_seg) = seg.valley.time_v2;
end
for idx_seg = 1:length(cellSegs_DVR)
    seg = cellSegs_DVR{idx_seg};
    if seg.valley.idx_v1<0, continue; end
    time_v1_DVR(idx_seg) = seg.valley.time_v1;
    time_v2_DVR(idx_seg) = seg.valley.time_v2;
end
time_v1_MT = time_v1_MT(~isnan(time_v1_MT));
time_v2_MT = time_v2_MT(~isnan(time_v2_MT));
time_v1_ETF = time_v1_ETF(~isnan(time_v1_ETF));
time_v2_ETF = time_v2_ETF(~isnan(time_v2_ETF));
time_v1_DVR = time_v1_DVR(~isnan(time_v1_DVR));
time_v2_DVR = time_v2_DVR(~isnan(time_v2_DVR));

valley_time_stats = table(...
    [mean(v1_MT,'omitnan'); mean(v1_ETF,'omitnan'); mean(v1_DVR,'omitnan')], ...
    [std(v1_MT,'omitnan');  std(v1_ETF,'omitnan');  std(v1_DVR,'omitnan')], ...
    [mean(v2_MT,'omitnan'); mean(v2_ETF,'omitnan'); mean(v2_DVR,'omitnan')], ...
    [std(v2_MT,'omitnan');  std(v2_ETF,'omitnan');  std(v2_DVR,'omitnan')], ...
    [mean(time_v1_MT,'omitnan'); mean(time_v1_ETF,'omitnan'); mean(time_v1_DVR,'omitnan')], ...
    [std(time_v1_MT,'omitnan');  std(time_v1_ETF,'omitnan');  std(time_v1_DVR,'omitnan')], ...
    [mean(time_v2_MT,'omitnan'); mean(time_v2_ETF,'omitnan'); mean(time_v2_DVR,'omitnan')], ...
    [std(time_v2_MT,'omitnan');  std(time_v2_ETF,'omitnan');  std(time_v2_DVR,'omitnan')], ...
    'VariableNames', {'ValueV1_mean','ValueV1_std','ValueV2_mean','ValueV2_std', ...
                      'TimeV1_mean','TimeV1_std','TimeV2_mean','TimeV2_std'}, ...
    'RowNames', {'MT','ETF','DVR'});

disp('Valleys and timing for three strategies (mean ± SD):');
disp(valley_time_stats);
disp(['MT: value_v1 = ', num2str(mean(v1_MT,'omitnan'),'%.3f'), '±', num2str(std(v1_MT,'omitnan'),'%.3f'), ...
      ', value_v2 = ', num2str(mean(v2_MT,'omitnan'),'%.3f'), '±', num2str(std(v2_MT,'omitnan'),'%.3f'), ...
      '; time_v1 = ', num2str(mean(time_v1_MT,'omitnan'),'%.3f'), '±', num2str(std(time_v1_MT,'omitnan'),'%.3f'), ...
      ', time_v2 = ', num2str(mean(time_v2_MT,'omitnan'),'%.3f'), '±', num2str(std(time_v2_MT,'omitnan'),'%.3f'), '.']);
disp(['ETF: value_v1 = ', num2str(mean(v1_ETF,'omitnan'),'%.3f'), '±', num2str(std(v1_ETF,'omitnan'),'%.3f'), ...
      ', value_v2 = ', num2str(mean(v2_ETF,'omitnan'),'%.3f'), '±', num2str(std(v2_ETF,'omitnan'),'%.3f'), ...
      '; time_v1 = ', num2str(mean(time_v1_ETF,'omitnan'),'%.3f'), '±', num2str(std(time_v1_ETF,'omitnan'),'%.3f'), ...
      ', time_v2 = ', num2str(mean(time_v2_ETF,'omitnan'),'%.3f'), '±', num2str(std(time_v2_ETF,'omitnan'),'%.3f'), '.']);
disp(['DVR: value_v1 = ', num2str(mean(v1_DVR,'omitnan'),'%.3f'), '±', num2str(std(v1_DVR,'omitnan'),'%.3f'), ...
      ', value_v2 = ', num2str(mean(v2_DVR,'omitnan'),'%.3f'), '±', num2str(std(v2_DVR,'omitnan'),'%.3f'), ...
      '; time_v1 = ', num2str(mean(time_v1_DVR,'omitnan'),'%.3f'), '±', num2str(std(time_v1_DVR,'omitnan'),'%.3f'), ...
      ', time_v2 = ', num2str(mean(time_v2_DVR,'omitnan'),'%.3f'), '±', num2str(std(time_v2_DVR,'omitnan'),'%.3f'), '.']);

disp('Pairwise t-tests between groups (p<0.05 indicates significance):');
print_ttest_pair('value_v1', v1_MT, v1_ETF, 'MT', 'ETF');
print_ttest_pair('value_v1', v1_MT, v1_DVR, 'MT', 'DVR');
print_ttest_pair('value_v1', v1_ETF, v1_DVR, 'ETF', 'DVR');
print_ttest_pair('value_v2', v2_MT, v2_ETF, 'MT', 'ETF');
print_ttest_pair('value_v2', v2_MT, v2_DVR, 'MT', 'DVR');
print_ttest_pair('value_v2', v2_ETF, v2_DVR, 'ETF', 'DVR');
print_ttest_pair('time_v1', time_v1_MT, time_v1_ETF, 'MT', 'ETF');
print_ttest_pair('time_v1', time_v1_MT, time_v1_DVR, 'MT', 'DVR');
print_ttest_pair('time_v1', time_v1_ETF, time_v1_DVR, 'ETF', 'DVR');
print_ttest_pair('time_v2', time_v2_MT, time_v2_ETF, 'MT', 'ETF');
print_ttest_pair('time_v2', time_v2_MT, time_v2_DVR, 'MT', 'DVR');
print_ttest_pair('time_v2', time_v2_ETF, time_v2_DVR, 'ETF', 'DVR');

%% Probability that MMoS < 0 at the two valleys for three strategies
prob_v1 = [mean(v1_MT < 0, 'omitnan'); mean(v1_ETF < 0, 'omitnan'); mean(v1_DVR < 0, 'omitnan')];
prob_v2 = [mean(v2_MT < 0, 'omitnan'); mean(v2_ETF < 0, 'omitnan'); mean(v2_DVR < 0, 'omitnan')];

table_prob_neg = table(prob_v1, prob_v2, ...
    'VariableNames', {'Prob_V1_MMoS_lt0', 'Prob_V2_MMoS_lt0'}, ...
    'RowNames', {'MT','ETF','DVR'});
disp('Probability that MMoS < 0 at the two valleys:');
disp(table_prob_neg);
disp(['MT: valley 1 = ', num2str(prob_v1(1)*100, '%.1f'), '%, valley 2 = ', num2str(prob_v2(1)*100, '%.1f'), '%.']);
disp(['ETF: valley 1 = ', num2str(prob_v1(2)*100, '%.1f'), '%, valley 2 = ', num2str(prob_v2(2)*100, '%.1f'), '%.']);
disp(['DVR: valley 1 = ', num2str(prob_v1(3)*100, '%.1f'), '%, valley 2 = ', num2str(prob_v2(3)*100, '%.1f'), '%.']);


%% Paper figure: Fig. 1
for idx_seg = 1:length(cellSegs)
    seg = cellSegs{idx_seg};
    seg.xcom.diff = seg.xcom_cmp_h.y-seg.xcom_hof.y;
    cellSegs{idx_seg} = seg;
end

cellSegs_MT = cellSegs(cellfun(@(x) x.info.idx_sts == 1, cellSegs));
cellSegs_ETF = cellSegs(cellfun(@(x) x.info.idx_sts == 2, cellSegs));
cellSegs_DVR = cellSegs(cellfun(@(x) x.info.idx_sts == 3, cellSegs));

str_paras = {'seg.xcom_hof.y','seg.xcom_cmp_h.y','seg.xcom.diff'};
fig_options = struct();
fig_options.str_paras = str_paras;
fig_options.figure_name = 'The Average Trends of CoM and XcoM in Anteroposterior Axis';
fig_options.legend_names = {'XcoM','VDI-XcoM','(VDI-XcoM)-(XcoM)'};
fig_options.flag_bw = flag_bw;
fig_options.flag_std = false;
fig_options.y_name = 'Position / m';
FigureMeanAndStd_com_cmp(cellSegs_MT, cellSegs_ETF, cellSegs_DVR, fig_options);

%% Paper figure: Fig. 2
for idx_seg = 1:length(cellSegs)
    seg = cellSegs{idx_seg};
    seg.item.vel_hof = seg.xcom_hof.y - seg.com.y;
    seg.item.vel_cmp = seg.xcom_cmp.y - seg.com.y;
    seg.item.h = seg.xcom_cmp_h.y - seg.xcom_cmp.y;
    cellSegs{idx_seg} = seg;
end
cellSegs_MT = cellSegs(cellfun(@(x) x.info.idx_sts == 1, cellSegs));
cellSegs_ETF = cellSegs(cellfun(@(x) x.info.idx_sts == 2, cellSegs)); %#ok<NASGU>
cellSegs_DVR = cellSegs(cellfun(@(x) x.info.idx_sts == 3, cellSegs)); %#ok<NASGU>

str_paras = {'seg.com.y','seg.item.vel_hof','seg.item.vel_cmp','seg.item.h'};
fig_options = struct();
fig_options.str_paras = str_paras;
fig_options.figure_name = 'The Average Trends of CoM and XcoM in Anteroposterior Axis'; 
fig_options.legend_names = {'CoM','Velocity/\omega_{XcoM}','Velocity/\omega_{VDI-XcoM}','Angular momentum term'};
fig_options.flag_bw = flag_bw;
fig_options.flag_std = false;
fig_options.y_name = 'Position / m';
FigureMeanAndStd_com_cmp_single(cellSegs_MT, fig_options);

%% Paper figure: Fig. 3
str_paras = {'seg.omega_hof','seg.omega_cmp'};
fig_options = struct(); 
fig_options.str_paras = str_paras;
fig_options.figure_name = 'The Average Trends of Omega'; 
fig_options.legend_names = {'\omega_{XcoM}','\omega_{VDI-XcoM}'};
fig_options.flag_bw = flag_bw;
fig_options.flag_std = false;
fig_options.y_name = '\omega / s^{-1}';
FigureMeanAndStd_com_cmp_single(cellSegs_MT, fig_options);

%% Paper figure: Fig. 4
str_paras = {'seg.mos.cmp_h_plantar_fixed.sum','seg.mos.hof_new.sum','seg.mos.cmp_h_new.sum'};
fig_options = struct();
fig_options.str_paras = str_paras;
fig_options.figure_name = 'The Average Trends of MoS';
fig_options.legend_names = {'MoS_{plantar}','MoS_{XcoM}','MMoS'};
fig_options.flag_bw = flag_bw;
fig_options.flag_std = false;
fig_options.y_name = 'Distance / m';
FigureMeanAndStd_com_cmp(cellSegs_MT, cellSegs_ETF, cellSegs_DVR, fig_options);

%% Compare differences between MMoS and MoS_XcoM across three stages
disp('Compare MMoS vs MoS_{XcoM} across three stages (within each strategy: compute per-seg stage means, then paired t-test):');
stage_names = {'Stage 1: start->seat-off', 'Stage 2: seat-off->minGRF', 'Stage 3: minGRF->end'};
strategy_names = {'MT','ETF','DVR'};
cellSegs_by_strategy = {cellSegs_MT, cellSegs_ETF, cellSegs_DVR};
for i_strategy = 1:3
    [mos_hof_stage, mos_cmp_stage] = collect_stage_mos_stage_means(cellSegs_by_strategy{i_strategy});
    for i_stage = 1:3
        print_paired_mos_means_ttest([strategy_names{i_strategy}, ' ', stage_names{i_stage}], ...
            mos_hof_stage{i_stage}, mos_cmp_stage{i_stage});
    end
end

function ratio = calc_slow_varying_ratio(omega, time)
    omega = omega(:);
    if nargin < 2 || isempty(time) || numel(time) ~= numel(omega)
        time = (1:numel(omega)).';
    else
        time = time(:);
    end
    if numel(omega) < 2
        ratio = nan(size(omega));
        return;
    end
    domega = gradient(omega, time);
    denom = max(omega.^2, eps);
    ratio = abs(domega) ./ denom;
end

function stats = calc_strategy_stats_from_seg(cellSegs)
    nSeg = numel(cellSegs);
    durations = nan(nSeg,1);
    seat_offs = nan(nSeg,1);
    trunk_flex_min = nan(nSeg,1);
    max_grf = nan(nSeg,1);

    for i = 1:nSeg
        seg = cellSegs{i};
        durations(i) = seg.time_sts.time_end - seg.time_sts.time_start;
        seat_offs(i) = seg.time_sts.time_seat_off - seg.time_sts.time_start;

        if isfield(seg, 'ja') && isfield(seg.ja, 'lumbar_extension')
            trunk_flex_min(i) = min(seg.ja.lumbar_extension);
        end
        if isfield(seg, 'grf') && isfield(seg.grf, 'plantar_z')
            max_grf(i) = max(seg.grf.plantar_z);
        end
    end

    stats.duration_mean = mean(durations, 'omitnan');
    stats.duration_std = std(durations, 'omitnan');
    stats.seat_off_mean = mean(seat_offs, 'omitnan');
    stats.seat_off_std = std(seat_offs, 'omitnan');
    stats.trunk_flex_mean = mean(trunk_flex_min, 'omitnan');
    stats.trunk_flex_std = std(trunk_flex_min, 'omitnan');
    stats.max_grf_mean = mean(max_grf, 'omitnan');
    stats.max_grf_std = std(max_grf, 'omitnan');

    stats.duration_vals = durations;
    stats.seat_off_vals = seat_offs;
    stats.trunk_flex_vals = trunk_flex_min;
    stats.max_grf_vals = max_grf;
end

function print_ttest_pair(param_name, a, b, group_a, group_b)
    a = a(:); b = b(:);
    a = a(~isnan(a)); b = b(~isnan(b));
    if numel(a) < 2 || numel(b) < 2
        disp([param_name, ' ', group_a, ' vs ', group_b, ' - insufficient samples; cannot perform t-test.']);
        return;
    end
    [h,p] = ttest2(a, b, 'Vartype', 'unequal');
    if h == 1
        sig_text = 'significant';
    else
        sig_text = 'not significant';
    end
    disp([param_name, ' ', group_a, ' vs ', group_b, ...
          ': p = ', num2str(p, '%.4f'), ', h = ', num2str(h), ' (', sig_text, ')']);
end

function print_paired_mos_ttest(stage_name, mos_hof, mos_cmp)
    mos_hof = mos_hof(:);
    mos_cmp = mos_cmp(:);
    valid = ~isnan(mos_hof) & ~isnan(mos_cmp);
    mos_hof = mos_hof(valid);
    mos_cmp = mos_cmp(valid);
    if numel(mos_hof) < 2 || numel(mos_cmp) < 2
        disp(['[', stage_name, '] insufficient samples; cannot perform paired t-test.']);
        return;
    end
    [h,p] = ttest(mos_hof, mos_cmp);
    diff_vals = mos_hof - mos_cmp;
    diff_mean = mean(diff_vals, 'omitnan');
    diff_std = std(diff_vals, 'omitnan');
    if diff_mean > 0
        dir_text = 'greater';
    elseif diff_mean < 0
        dir_text = 'smaller';
    else
        dir_text = 'almost the same';
    end
    if h == 1
        sig_text = 'significant';
    else
        sig_text = 'not significant';
    end
    disp(['[', stage_name, '] MoS_{XcoM} is on average ', dir_text, ' than MoS_{VDI-XcoM}', ...
          ' (difference mean±SD: ', num2str(diff_mean, '%.4f'), '±', num2str(diff_std, '%.4f'), ...
          '; paired t-test, p = ', num2str(p, '%.4f'), ', ', sig_text, ').']);
end

function print_paired_mos_means_ttest(stage_name, mos_hof, mos_cmp)
    mos_hof = mos_hof(:);
    mos_cmp = mos_cmp(:);
    valid = ~isnan(mos_hof) & ~isnan(mos_cmp);
    mos_hof = mos_hof(valid);
    mos_cmp = mos_cmp(valid);
    if numel(mos_hof) < 2 || numel(mos_cmp) < 2
        disp(['[', stage_name, '] insufficient samples; cannot perform paired t-test.']);
        return;
    end

    mos_hof_mean = mean(mos_hof, 'omitnan');
    mos_hof_std = std(mos_hof, 'omitnan');
    mos_cmp_mean = mean(mos_cmp, 'omitnan');
    mos_cmp_std = std(mos_cmp, 'omitnan');

    [h,p] = ttest(mos_hof, mos_cmp);
    if h == 1
        sig_text = 'significant';
    else
        sig_text = 'not significant';
    end

    disp(['[', stage_name, '] MoS_{XcoM} = ', num2str(mos_hof_mean, '%.4f'), '±', num2str(mos_hof_std, '%.4f'), ...
          '，MMoS = ', num2str(mos_cmp_mean, '%.4f'), '±', num2str(mos_cmp_std, '%.4f'), ...
          '; paired t-test p = ', num2str(p, '%.4f'), ' (', sig_text, ').']);
end

function [mos_hof_stage, mos_cmp_stage] = collect_stage_mos_stage_means(cellSegs)
    mos_hof_stage = {[], [], []};
    mos_cmp_stage = {[], [], []};
    for idx_seg = 1:length(cellSegs)
        seg = cellSegs{idx_seg};
        if ~isfield(seg, 'time_sts') || ~isfield(seg, 'times') || ~isfield(seg.times, 'union')
            continue;
        end
        if ~isfield(seg, 'mos') || ~isfield(seg.mos, 'hof_new') || ~isfield(seg.mos.hof_new, 'sum') ...
                || ~isfield(seg.mos, 'cmp_h_new') || ~isfield(seg.mos.cmp_h_new, 'sum')
            continue;
        end
        time = seg.times.union(:);
        mos_hof = seg.mos.hof_new.sum(:);
        mos_cmp = seg.mos.cmp_h_new.sum(:);
        if isempty(time) || isempty(mos_hof) || isempty(mos_cmp)
            continue;
        end
        n = min([numel(time), numel(mos_hof), numel(mos_cmp)]);
        time = time(1:n);
        mos_hof = mos_hof(1:n);
        mos_cmp = mos_cmp(1:n);

        idx_start = GetIdxTime(time, seg.time_sts.time_start);
        idx_seat = GetIdxTime(time, seg.time_sts.time_seat_off);
        idx_min = GetIdxTime(time, seg.time_sts.time_min_grf_plantar);
        idx_end = GetIdxTime(time, seg.time_sts.time_end);
        if any(isempty([idx_start, idx_seat, idx_min, idx_end]))
            continue;
        end
        idxs = sort([idx_start, idx_seat, idx_min, idx_end]);
        idx_start = idxs(1);
        idx_seat = idxs(2);
        idx_min = idxs(3);
        idx_end = idxs(4);
        if idx_start >= idx_end
            continue;
        end

        ranges = {idx_start:idx_seat, idx_seat:idx_min, idx_min:idx_end};
        for i_stage = 1:3
            rr = ranges{i_stage};
            rr = rr(rr >= 1 & rr <= n);
            if isempty(rr)
                continue;
            end
            valid = ~isnan(mos_hof(rr)) & ~isnan(mos_cmp(rr));
            if ~any(valid)
                continue;
            end
            % Keep one mean per seg per stage, then concatenate within strategy for paired t-test
            mos_hof_stage{i_stage}(end+1,1) = mean(mos_hof(rr(valid)), 'omitnan');
            mos_cmp_stage{i_stage}(end+1,1) = mean(mos_cmp(rr(valid)), 'omitnan');
        end
    end
end