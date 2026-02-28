% Validate XcoM using Vicon + force plate data
close all; clear; clc
addpath(genpath('./algorithms'));
addpath(genpath('../data'));

%% Initialization

flag_select_paras = false;
flag_draw_bos = false;
flag_show_figs = true;

PartInitialization;

height_sit = 0.52;
plantar_buttock_displacement = 0.45;

%% Load data

cellData = ReadAndSortDataKinect2();

%% Single subject

clc;close all;
idxFile = 9;

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
PartCalculateBoS_left_right_buttock;

%% Compute MoS
% XcoM_hof to BoS_plantar; XcoM_hof to BoS_new; XcoM_cmp_h to BoS_new
mos_com_plantar = calc_mos_signed_distance(com, bos_plantar, times);
mos_com_new = calc_mos_signed_distance(com, bos_new, times);
mos_hof_plantar = calc_mos_signed_distance(xcom_hof, bos_plantar, times);
mos_hof_new = calc_mos_signed_distance(xcom_hof, bos_new, times);
mos_cmp_h_new = calc_mos_signed_distance(xcom_cmp_h, bos_new, times);

figure;
set(gcf, 'Units','normalized', 'OuterPosition',[0 0 1 1], 'color', 'w');
hold on;
p1 = plot(times.union,mos_hof_plantar.sum, 'LineWidth', 1.8, 'DisplayName','XcoM_{Hof} vs BoS_{Plantar}');
p2 = plot(times.union,mos_hof_new.sum, 'LineWidth', 1.8, 'LineStyle','--', 'DisplayName','XcoM_{Hof} vs BoS_{New}');
p3 = plot(times.union,mos_cmp_h_new.sum, 'LineWidth', 1.8, 'LineStyle','-.', 'DisplayName','VDI-XcoM vs BoS_{New}');
yline(0, 'k:', 'LineWidth', 1);
xline(times_start, 'r--', 'LineWidth', 1);
xline(times_end, 'b--', 'LineWidth', 1);
hold off;
title('Margin of Stability (MoS)');
xlabel('Frame');
ylabel('MoS (m)');
legend([p1,p2,p3]);
set(gca, 'FontName','Times New Roman', 'FontSize', 12, 'LineWidth', 1);
box on;
grid on;

