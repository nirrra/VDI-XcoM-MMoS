% times_sts = times_stss{idxFile};
% times_start = times_sts(1:2:end);
% times_end = times_sts(2:2:end);

%% 新方法
%% 粗定位
[posCOMSegments,vCOMSegments,accCOMSegments] = Segments_Velocity_Acceleration(streamInter,gender,fsInter);
inertia_rotary = CalRotaryInertia(gender,weight,streamInter,posCOMSegments);
data0 = inertia_rotary./100;
% 对data0进行2Hz低通滤波
fc = 0.5; % Hz
if numel(data0) > 12 && fsInter > 2*fc
    [b_lp, a_lp] = butter(2, fc/(fsInter/2), 'low');
    data0 = filtfilt(b_lp, a_lp, data0);
else
    data0 = smoothdata(data0, 'movmean', min(11, numel(data0)));
end

% 平滑
data1 = smoothdata(data0,'movmean',20);
% 差分
data2 = diff(data1);
% 将data2归一化到[0,1]
data2 = (data2-min(data2))/(max(data2)-min(data2));

[~,locPks] = findpeaks(data2,'MinPeakHeight',0.8);
[~,locVls] = findpeaks(-data2,'MinPeakHeight',-0.2);

% 将locPks和locVls配对，需要遵循：
% 1. locPks在locVls之前；
% 2. locPks和locVls之间的距离在3s到6s之间；
% 3. 一个locPks只能配对一个locVls，一个locVls只能配对一个locPks；
locPks_new = [];
locVls_new = [];
idxPk = 1; idxVl = 1;
while idxPk <= length(locPks) && idxVl <= length(locVls)
    if times.union(locPks(idxPk)) + 1 <= times.union(locVls(idxVl)) && times.union(locPks(idxPk)) + 10 >= times.union(locVls(idxVl))
        locPks_new = [locPks_new,locPks(idxPk)];
        locVls_new = [locVls_new,locVls(idxVl)];
        idxPk = idxPk + 1;
        idxVl = idxVl + 1;
    elseif times.union(locPks(idxPk)) + 1 > times.union(locVls(idxVl))
        idxVl = idxVl + 1;
    else
        idxPk = idxPk + 1;
    end
end

aux = [1];
for i = 2:length(locPks_new)
    if locPks_new(i)-locPks_new(i-1)>100
        aux(end+1) = i;
    end
end
locPks_new = locPks_new(aux);
locVls_new = locVls_new(aux);

timePks = times.union(locPks_new);
timeVls = times.union(locVls_new);
times_start = zeros(length(locPks_new),1);
times_end = zeros(length(locPks_new),1);
aux = median(timeVls-timePks);

for i = 1:length(times_start)
    times_start(i) = max(timePks(i)-aux/2,times.union(1));
end

for i = 1:length(locPks_new)-1
    times_end(i) = (timePks(i)+timeVls(i))/2;
end
times_end(end) = min(times_start(end)+median(times_end(1:end-1)-times_start(1:end-1)),times.union(end));

times_sts = sort([times_start;times_end]);

disp('times_sts: ');
DispArray(times_sts);

if flag_show_fig
    figure; hold on;
    plot(times.union,data0);
    plot(times.union,data1);
    plot(times.union(1:end-1),data2);
    plot(times.union(locPks_new),data2(locPks_new),'ro');
    plot(times.union(locVls_new),data2(locVls_new),'bo');
    xline(times_start,'r','LineWidth',1.5);
    xline(times_end,'b','LineWidth',1.5);
    hold off;
    legend('转动惯量','平滑','差分','峰值','谷值','起始点','结束点');
    title('转动惯量曲线');
    xlabel('时间 / s');
    ylabel('转动惯量 / kg*m*m');
    xlim([times.union(1),times.union(end)]);
    ylim([-1,2]);
    set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');
end

%% 细定位
% times_sts提取所有time_start和time_end
times_sts_new = [];
for idx_sts = 1:length(times_sts)/2
    time_start = times_sts(2*idx_sts-1);
    time_end = times_sts(2*idx_sts);
    idx_start = GetIdxTime(times.union,time_start);
    idx_end = GetIdxTime(times.union,time_end);

    % 1) 细化起点：从粗略 time_start 往前回溯，寻找“基本静止段”作为新的起点。
    %    这里用 inertia_rotary 在一个短窗口内的波动范围 range(...) 来判断是否静止。
    aux = idx_start;
    % 第一轮：40 点窗口，阈值更严格（<0.5），优先找更稳定的静止段。
    % while 的下界是 max(idx_start-40, 1+40)，确保 aux-40 不会越界到 1 以下。
    while aux > max(idx_start-40,1+40)
        if range(inertia_rotary(aux-40:aux))<0.5
            % 找到满足条件的最早回溯点，更新 time_start
            time_start = times.union(aux);
            break;
        end
        aux = aux - 1;
    end
    % 如果第一轮没找到（aux 退到下界），启用更宽松的兜底策略。
    if aux == max(idx_start-40,1+40)
        aux = idx_start;
        % 第二轮：缩小到 5 点窗口，但阈值放宽到 <1，提升召回率。
        while aux > max(idx_start-40,1+40)
            if range(inertia_rotary(aux-5:aux))<1
                % 兜底命中后同样更新起点
                time_start = times.union(aux);
                break;
            end
            aux = aux - 1;
        end

        % 两轮都失败：说明在可回溯区间内找不到可靠静止段，跳过当前 STS 片段。
        if aux == max(idx_start-40,1+40)
            continue;
        end
    end

    % 2. 从time_start往后，signal = Fz_buttock_f中第一个signal(i)<50的点，该点为该段的time_seat_off
    while aux < idx_end
        if Fz_buttock_f(aux)<50
            idx_seat_off = aux;
            time_seat_off = times.union(aux);
            break;
        end
        aux = aux + 1;
    end
    if aux == idx_end
        continue;
    end

    % 先找到站起后峰值
    aux = max([idx_start,1+2]);
    while aux<idx_seat_off+10
        if Fz_plantar_f(aux)>300 && Fz_plantar_f(aux) == max(Fz_plantar_f(aux-2:aux+2))
            break;
        end
        aux = aux + 1;
    end
    
    % 3. 从time_seat_off往后一直找到time_end，signal = Fz_buttock_f的最小值，该点为该段的time_min_grf_plantar
    signal = Fz_plantar_f;

    idx_min_grf_plantar = aux;
    while idx_min_grf_plantar < idx_end
        if signal(idx_min_grf_plantar) == min(signal(aux:idx_end))
            break;
        end
        idx_min_grf_plantar = idx_min_grf_plantar + 1;
    end
    time_min_grf_plantar = times.union(idx_min_grf_plantar);

    % 4. 从time_min_grf_plantar往后一直找到time_end，signal = Fz_buttock_f，第一个满足range(signal(i:idx_end))<5 
    % 且 abs(signal(i)-signal(idx_end))<2的点，该点为该段新的idx_end
    signal = Fz_plantar_f;
    aux = idx_min_grf_plantar;
    while aux < idx_end
        if range(signal(aux:idx_end)) < 5 && abs(signal(aux) - signal(idx_end)) < 2
            idx_end = aux;
            time_end = times.union(idx_end);
            break;
        end
        aux = aux + 1;
    end

    times_sts_new = [times_sts_new;[time_start,time_seat_off,time_min_grf_plantar,time_end]];
end

times_sts = times_sts_new;
times_start = times_sts(:,1);
times_seat_off = times_sts(:,2);
times_min_grf_plantar = times_sts(:,3);
times_end = times_sts(:,4);

%% 查看分段
figVisible = 'off';
if flag_show_fig
    figVisible = 'on';
end
aux = [20,40];
fig_segments = figure('Visible', figVisible);
set(fig_segments, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');
subplot(2,1,1); hold on;
p1 = plot(times.union,Fz_plantar_f,'DisplayName','Fz Plantar');
p2 = plot(times.union,Fz_buttock_f,'DisplayName','Fz Buttock');
xline(times_start,'r--','LineWidth',1);
xline(times_seat_off,'g','LineWidth',1.5);
xline(times_min_grf_plantar,'b--','LineWidth',1);
xline(times_end,'k--','LineWidth',1);
% xlim(aux);
hold off;
legend([p1,p2],'Location','northeast');
title('GRF');
xlabel('Time (s)');
ylabel('Force (N)');
grid on; hold off;
subplot(2,1,2); hold on;
p1 = plot(times.union,inertia_rotary,'DisplayName','Inertia Rotary');
xline(times_start,'r--','LineWidth',1);
xline(times_seat_off,'g','LineWidth',1.5);
xline(times_min_grf_plantar,'b--','LineWidth',1);
xline(times_end,'k--','LineWidth',1);
% xlim(aux);
hold off;
legend([p1],'Location','northeast');
title('Inertia Rotary');
xlabel('Time (s)');
ylabel('Inertia (kg*m^2)');
grid on; hold off;

outputDir = fullfile('outputs', 'sts_segments', str_group);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
outputName = sprintf('segments_%d.png', idx_file);
saveas(fig_segments, fullfile(outputDir, outputName));
if ~flag_show_fig
    close(fig_segments);
end