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
flag_show_figs = true;

PartInitialization;

height_sit = 0.52;
plantar_buttock_displacement = 0.45;

%% 读取数据

cellData = ReadAndSortDataKinect2();

%% 单个被试

clc;close all;
idxFile = 9;

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

%% 计算CoM/XcoM/VDI-XcoM
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
mos_com_new = calc_mos_signed_distance(com, bos_new, times);
mos_hof_plantar = calc_mos_signed_distance(xcom_hof, bos_plantar, times);
mos_hof_new = calc_mos_signed_distance(xcom_hof, bos_new, times);
mos_cmp_h_new = calc_mos_signed_distance(xcom_cmp_h, bos_new, times);

figure;
set(gcf, 'Units','normalized', 'OuterPosition',[0 0 1 1], 'color', 'w');
hold on;
p1 = plot(times.union,mos_hof_plantar.sum, 'LineWidth', 1.8, 'DisplayName','XCoM_{Hof} vs BoS_{Plantar}');
p2 = plot(times.union,mos_hof_new.sum, 'LineWidth', 1.8, 'LineStyle','--', 'DisplayName','XCoM_{Hof} vs BoS_{New}');
p3 = plot(times.union,mos_cmp_h_new.sum, 'LineWidth', 1.8, 'LineStyle','-.', 'DisplayName','XCoM_{CMP} vs BoS_{New}');
yline(0, 'k:', 'LineWidth', 1);
xline(times_start, 'r--', 'LineWidth', 1);
xline(times_end, 'b--', 'LineWidth', 1);
hold off;
title('Margin of Stability (MoS)');
xlabel('Frame');
ylabel('MoS (m)');
set(gca, 'FontName','Times New Roman', 'FontSize', 12, 'LineWidth', 1);
box on;
grid on;

%% 寻找MMoS的两个谷值
signal = mos_cmp_h_new.sum;
[~,idxs_v1] = findpeaks(-signal,'MinPeakDistance',100,'MinPeakHeight',-min(signal)-range(signal)/5);


idxs_v2 = zeros(size(idxs_v1));
for i = 1:length(idxs_v1)
    idx_v1 = idxs_v1(i);
    for aux = idx_v1:idx_v1+20
        if signal(aux) == max(signal(aux-5:aux+5)) && signal(aux)-signal(idx_v1) > range(signal)*0.7
            break;
        end
    end
    for idx_v2 = aux:aux+50
        if signal(idx_v2) == min(signal(idx_v2-5:idx_v2+5))
            break;
        end
    end
    idxs_v2(i) = idx_v2;
end

figure;
hold on;
plot(mos_cmp_h_new.sum, 'LineWidth', 1.8, 'LineStyle','-.', 'DisplayName','XCoM_{CMP} vs BoS_{New}');
plot(idxs_v1,signal(idxs_v1),'ro');
plot(idxs_v2,signal(idxs_v2),'bo');
hold off;

%% 作图：显示CoM、XcoM、BoS（保存为AVI）
if false
    fig = figure;
    set(fig, 'Position', [100, 100, 1280, 960], 'color', 'w');
    v = VideoWriter('CoM_XcoM_BoS.avi');
    v.FrameRate = 30;
    open(v);
    for idx_frame = 1:length(times.union)
        idx_vicon = GetIdxTime(times.vicon,[times.union(idx_frame)]);
        clf(fig);
        hold on;
        plot(com.x(idx_vicon),com.y(idx_vicon),'ro','DisplayName','CoM');
        plot(xcom_hof.x(idx_vicon),xcom_hof.y(idx_vicon),'go','DisplayName','XcoM hof');
        plot(xcom_cmp.x(idx_vicon),xcom_cmp.y(idx_vicon),'bo','DisplayName','XcoM cmp');
        plot(xcom_cmp_h.x(idx_vicon),xcom_cmp_h.y(idx_vicon),'mo','DisplayName','XcoM cmp h');
        if exist('bos_plantar_left')
            plot(bos_plantar_left.x{idx_frame},bos_plantar_left.y{idx_frame},'g-','DisplayName','BoS Plantar Left');
            plot(bos_plantar_right.x{idx_frame},bos_plantar_right.y{idx_frame},'g-','DisplayName','BoS Plantar Right');
        else
            plot(bos_plantar.x{idx_frame},bos_plantar.y{idx_frame},'g-','DisplayName','BoS Plantar');
        end
        plot(bos_buttock.x{idx_frame},bos_buttock.y{idx_frame},'r-','DisplayName','BoS Buttock');
        plot(bos_new.x{idx_frame},bos_new.y{idx_frame},'b-','DisplayName','BoS New');
        plot(bos_plantar_fixed.x{idx_frame},bos_plantar_fixed.y{idx_frame},'c-','DisplayName','BoS Plantar Fixed');
        plot(bos_buttock_fixed.x{idx_frame},bos_buttock_fixed.y{idx_frame},'m-','DisplayName','BoS Buttock Fixed');
        plot(bos_total_fixed.x{idx_frame},bos_total_fixed.y{idx_frame},'y-','DisplayName','BoS Total Fixed');
        hold off;
        axis equal;
        legend('Location','northeast');
        if exist('alphas_left') && exist('alphas_right')
            title(['CoM、XcoM、BoS - 帧数: ', num2str(idx_frame), ...
                ' alpha_left: ', num2str(alphas_left(idx_frame)), ...
                ' alpha_right: ', num2str(alphas_right(idx_frame)), ...
                ' delta: [', num2str(deltas(idx_frame,1)), ', ', num2str(deltas(idx_frame,2)), ']']);
        else
            title(['CoM、XcoM、BoS - 帧数: ', num2str(idx_frame), ...
                ' alpha: ', num2str(alphas(idx_frame)), ...
                ' delta: [', num2str(deltas(idx_frame,1)), ', ', num2str(deltas(idx_frame,2)), ']']);
        end
        xlabel('X / m');
        ylabel('Y / m');
        grid on;
        xlim([-0.8,0.2]); ylim([-0.8,0.5]);
        drawnow;
        writeVideo(v, getframe(fig));
    end
    close(v);
end
