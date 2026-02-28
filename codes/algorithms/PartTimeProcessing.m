times = struct();
times.plantar = Datetime2Time(dataPlantar.datetimeF);
times.hip = Datetime2Time([dataPlantar.datetimeF(1);dataHip.datetimeF]); times.hip = times.hip(2:end);
times.kinect = stream.wtime;
times.grf = grf.time;
times.vicon = ik.time;

timeDelay1 = GetTimeDelayGRF2FSManually(times,idxFile);
timeDelay2 = GetTimeDelayKinect2ViconManually(times,idxFile);

times.grf = times.grf+timeDelay1;
times.vicon = times.vicon+timeDelay1;
times.kinect = times.kinect+timeDelay1+timeDelay2;

%% Further align insole arrays with GRF
% The possible time offset between the insole arrays and GRF is within ±0.06 s
maxLag = 0.06;
lagStep = 0.001;
lags = -maxLag:lagStep:maxLag;
win = [max([times.plantar(1),times.hip(1),times.grf(1),times.vicon(1),times.kinect(1)])+5, ...
    min([times.plantar(end),times.hip(end),times.grf(end),times.vicon(end),times.kinect(end)])-5];
% win = [20,80];

plantar_sum_raw = sum(pressurePlantar,2);
buttock_sum_raw = sum(pressureHip,2);
grf_plantar_raw = grf.left_force_vy + grf.right_force_vy;
grf_buttock_raw = grf.hip_force_vy;

aux = GetIdxTime(times.plantar, win);
timeP_win = times.plantar(aux(1):aux(2));
plantar_sum_win = plantar_sum_raw(aux(1):aux(2));
aux = GetIdxTime(times.hip, win);
timeH_win = times.hip(aux(1):aux(2));
buttock_sum_win = buttock_sum_raw(aux(1):aux(2));

icc_pl = nan(length(lags),1);
icc_bt = nan(length(lags),1);
for i = 1:length(lags)
    lag = lags(i);
    grf_pl_i = interp1(times.grf + lag, grf_plantar_raw, timeP_win, 'pchip', 'extrap');
    grf_bt_i = interp1(times.grf + lag, grf_buttock_raw, timeH_win, 'pchip', 'extrap');

    pl_norm = (plantar_sum_win - min(plantar_sum_win)) ./ max(eps, range(plantar_sum_win));
    bt_norm = (buttock_sum_win - min(buttock_sum_win)) ./ max(eps, range(buttock_sum_win));
    grf_pl_norm = (grf_pl_i - min(grf_pl_i)) ./ max(eps, range(grf_pl_i));
    grf_bt_norm = (grf_bt_i - min(grf_bt_i)) ./ max(eps, range(grf_bt_i));

    icc_pl(i) = calc_icc_from_vectors(pl_norm, grf_pl_norm);
    icc_bt(i) = calc_icc_from_vectors(bt_norm, grf_bt_norm);
end

[~, idx_best_pl] = max(icc_pl);
[~, idx_best_bt] = max(icc_bt);
timeDelay_icc_pl = lags(idx_best_pl);
timeDelay_icc_bt = lags(idx_best_bt);

%% Further align Kinect with Vicon
joint_angles = CalJointAngles(stream);
hip_kinect = joint_angles.hipFlexionL + joint_angles.hipFlexionR;
hip_vicon = ik.hip_flexion_r + ik.hip_flexion_l;

aux = GetIdxTime(times.kinect, win);
timeK_win = times.kinect(aux(1):aux(2));
hip_kinect_win = hip_kinect(aux(1):aux(2));

icc_kv = nan(length(lags),1);
for i = 1:length(lags)
    lag = lags(i);
    hip_vicon_i = interp1(times.vicon + lag, hip_vicon, timeK_win, 'pchip', 'extrap');
    hip_k_norm = (hip_kinect_win - min(hip_kinect_win)) ./ max(eps, range(hip_kinect_win));
    hip_v_norm = (hip_vicon_i - min(hip_vicon_i)) ./ max(eps, range(hip_vicon_i));
    icc_kv(i) = calc_icc_from_vectors(hip_k_norm, hip_v_norm);
end
[~, idx_best_kv] = max(icc_kv);
timeDelay_icc_kv = lags(idx_best_kv);

%% Plot: alignment after ICC-based calibration
figVisible = 'off';
if flag_show_figs
    figVisible = 'on';
end
fig_align = figure('Visible', figVisible);
set(fig_align, 'Position', [100, 100, 1280, 900], 'color', 'w');
subplot(3,1,1); hold on;
grf_pl_aligned = interp1(times.grf + timeDelay_icc_pl, grf_plantar_raw, timeP_win, 'pchip', 'extrap');
grf_pl_norm = (grf_pl_aligned - min(grf_pl_aligned)) ./ max(eps, range(grf_pl_aligned));
pl_norm = (plantar_sum_win - min(plantar_sum_win)) ./ max(eps, range(plantar_sum_win));
plot(timeP_win, pl_norm, 'DisplayName','Insole plantar (array)');
plot(timeP_win, grf_pl_norm, 'DisplayName','Force plate plantar');
hold off; grid on; legend('Location','best');
title(['Plantar alignment after ICC calibration, delay = ', num2str(timeDelay_icc_pl), ' s, ICC: ', num2str(icc_pl(idx_best_pl))]);
xlabel('Time / s'); ylabel('Norm');

subplot(3,1,2); hold on;
grf_bt_aligned = interp1(times.grf + timeDelay_icc_bt, grf_buttock_raw, timeH_win, 'pchip', 'extrap');
grf_bt_norm = (grf_bt_aligned - min(grf_bt_aligned)) ./ max(eps, range(grf_bt_aligned));
bt_norm = (buttock_sum_win - min(buttock_sum_win)) ./ max(eps, range(buttock_sum_win));
plot(timeH_win, bt_norm, 'DisplayName','Insole buttock (array)');
plot(timeH_win, grf_bt_norm, 'DisplayName','Force plate buttock');
hold off; grid on; legend('Location','best');
title(['Buttock alignment after ICC calibration, delay = ', num2str(timeDelay_icc_bt), ' s, ICC: ', num2str(icc_bt(idx_best_bt))]);
xlabel('Time / s'); ylabel('Norm');

subplot(3,1,3); hold on;
hip_vicon_aligned = interp1(times.vicon + timeDelay_icc_kv, hip_vicon, timeK_win, 'pchip', 'extrap');
hip_v_norm = (hip_vicon_aligned - min(hip_vicon_aligned)) ./ max(eps, range(hip_vicon_aligned));
hip_k_norm = (hip_kinect_win - min(hip_kinect_win)) ./ max(eps, range(hip_kinect_win));
plot(timeK_win, hip_k_norm, 'DisplayName','Kinect Hip');
plot(timeK_win, hip_v_norm, 'DisplayName','Vicon Hip');
hold off; grid on; legend('Location','best');
title(['Hip flexion alignment after ICC calibration, delay = ', num2str(timeDelay_icc_kv), ' s, ICC: ', num2str(icc_kv(idx_best_kv))]);
xlabel('Time / s'); ylabel('Norm');

outputDir = fullfile('outputs', 'images com cmp', 'time alignment');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
outputName = sprintf('time_alignment_%d.png', idxFile);
saveas(fig_align, fullfile(outputDir, outputName));
if ~flag_show_figs
    close(fig_align);
end
% Update times.plantar and times.hip (aligned to GRF)
times.plantar = times.plantar - timeDelay_icc_pl;
times.hip = times.hip - timeDelay_icc_bt;
% Update times.kinect (aligned to Vicon)
times.kinect = times.kinect - timeDelay_icc_kv;

%% Unify all time vectors in times
timeStart = []; timeEnd = [];
names = fieldnames(times);
for i = 1:length(names)
    timeStart(i) = times.(names{i})(1);
    timeEnd(i) = times.(names{i})(end);
end
timeStart = max(timeStart); timeEnd = min(timeEnd)-timeStart;
for i = 1:length(names)
    times.(names{i}) = times.(names{i})-timeStart;
end
timeStart = 0;

% Trim time: keep samples within [timeStart, timeEnd]
aux = GetIdxTime(times.kinect,[timeStart,timeEnd]); pKS1 = aux(1); pKE1 = aux(2); timeK = times.kinect(pKS1:pKE1);
aux = GetIdxTime(times.vicon,[timeStart,timeEnd]); pVS1 = aux(1); pVE1 = aux(2); timeV = times.vicon(pVS1:pVE1);
aux = GetIdxTime(times.grf,[timeStart,timeEnd]); pGS1 = aux(1); pGE1 = aux(2); timeG = times.grf(pGS1:pGE1);
aux = GetIdxTime(times.plantar,[timeStart,timeEnd]); pPS1 = aux(1); pPE1 = aux(2); timeP = times.plantar(pPS1:pPE1);
aux = GetIdxTime(times.hip,[timeStart,timeEnd]); pHS1 = aux(1); pHE1 = aux(2); timeH = times.hip(pHS1:pHE1);

% Use evenly spaced time to avoid duplicated sampling points in interpolation
timeP = linspace(timeP(1),timeP(end),length(timeP))';
timeH = linspace(timeH(1),timeH(end),length(timeH))';

names = fieldnames(stream);
for i = 2:length(names)
    stream.(names{i,1}).x = stream.(names{i,1}).x(pKS1:pKE1);
    stream.(names{i,1}).y = stream.(names{i,1}).y(pKS1:pKE1);
    stream.(names{i,1}).z = stream.(names{i,1}).z(pKS1:pKE1);
end
stream.wtime = timeK;

%% ======== Local functions ========
function icc = calc_icc_from_vectors(a, b)
    a = a(:); b = b(:);
    mask = isfinite(a) & isfinite(b);
    a = a(mask); b = b(mask);
    if numel(a) < 3
        icc = NaN;
        return;
    end
    data = [a, b];
    n = size(data,1);
    k = size(data,2);
    mean_row = mean(data, 2);
    mean_col = mean(data, 1);
    grand_mean = mean(data(:));
    MSR = k * sum((mean_row - grand_mean).^2) / (n - 1);
    MSE = sum(sum((data - mean_row - mean_col + grand_mean).^2)) / ((n - 1) * (k - 1));
    icc = (MSR - MSE) / (MSR + (k - 1) * MSE);
end