% times_sts = times_stss{idxFile};
% times_start = times_sts(1:2:end);
% times_end = times_sts(2:2:end);

%% New method
%% Coarse localization
[posCOMSegments,vCOMSegments,accCOMSegments] = Segments_Velocity_Acceleration(streamInter,gender,fsInter);
inertia_rotary = CalRotaryInertia(gender,weight,streamInter,posCOMSegments);
data0 = inertia_rotary./100;
% Smoothing
data1 = smoothdata(data0,'movmean',20);
% Difference
data2 = diff(data1);
% Normalize data2 to [0, 1]
data2 = (data2-min(data2))/(max(data2)-min(data2));

[~,locPks] = findpeaks(data2,'MinPeakHeight',0.8);
[~,locVls] = findpeaks(-data2,'MinPeakHeight',-0.2);

% Pair locPks and locVls with the following rules:
% 1) locPks must occur before locVls;
% 2) the time gap between locPks and locVls should be between 3 s and 6 s;
% 3) one locPks pairs with at most one locVls, and vice versa.
locPks_new = [];
locVls_new = [];
idxPk = 1; idxVl = 1;
while idxPk <= length(locPks) && idxVl <= length(locVls)
    if times.union(locPks(idxPk)) + 1 <= times.union(locVls(idxVl)) && times.union(locPks(idxPk)) + 5 >= times.union(locVls(idxVl))
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

if flag_show_figs
    figure; hold on;
    plot(times.union,data0);
    plot(times.union,data1);
    plot(times.union(1:end-1),data2);
    plot(times.union(locPks_new),data2(locPks_new),'ro');
    plot(times.union(locVls_new),data2(locVls_new),'bo');
    xline(times_start,'r','LineWidth',1.5);
    xline(times_end,'b','LineWidth',1.5);
    hold off;
    legend('Rotary inertia','Smoothed','Difference','Peaks','Valleys','Start','End');
    title('Rotary inertia curve');
    xlabel('Time / s');
    ylabel('Rotary inertia / kg*m*m');
    xlim([times.union(1),times.union(end)]);
    ylim([-1,2]);
    set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');
end

%% Fine localization
% Extract all time_start and time_end from times_sts
times_sts_new = [];
for idx_sts = 1:length(times_sts)/2
    time_start = times_sts(2*idx_sts-1);
    time_end = times_sts(2*idx_sts);
    idx_start = GetIdxTime(times.union,time_start);
    idx_end = GetIdxTime(times.union,time_end);

    % 1) Search backward from time_start: in inertia_rotary, find the first point
    %    where range(signal(i-10:i)) < 1; that point becomes the new time_start.
    %    If not found within the previous 15 points, skip this segment.
    aux = idx_start;
    while aux > max(idx_start-40,1+10)
        if range(inertia_rotary(aux-40:aux))<0.5
            time_start = times.union(aux);
            break;
        end
        aux = aux - 1;
    end
    if aux == max(idx_start-40,1+10)
        aux = idx_start;
        while aux > max(idx_start-40,1+10)
            if range(inertia_rotary(aux-5:aux))<1
                time_start = times.union(aux);
                break;
            end
            aux = aux - 1;
        end

        if aux == max(idx_start-15,1+10)
            continue;
        end
    end

    % 2) Search forward from time_start: in Fz_buttock_f, the first point with
    %    signal(i) < 50 is the time_seat_off for this segment.
    while aux < idx_end
        if Fz_buttock_f(aux)<50
            time_seat_off = times.union(aux);
            break;
        end
        aux = aux + 1;
    end
    if aux == idx_end
        continue;
    end
    
    % 3) From time_seat_off to time_end: find the minimum of Fz_plantar_f;
    %    that point is time_min_grf_plantar for this segment.
    signal = Fz_plantar_f;

    idx_min_grf_plantar = aux;
    while idx_min_grf_plantar < idx_end
        if signal(idx_min_grf_plantar) == min(signal(aux:idx_end))
            break;
        end
        idx_min_grf_plantar = idx_min_grf_plantar + 1;
    end
    time_min_grf_plantar = times.union(idx_min_grf_plantar);

    % 4) From time_min_grf_plantar to time_end: in Fz_plantar_f, find the first
    %    point where range(signal(i:idx_end)) < 5 and abs(signal(i)-signal(idx_end)) < 2;
    %    that point becomes the new idx_end for this segment.
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

%% Inspect segmentation
figVisible = 'off';
if flag_show_figs
    figVisible = 'on';
end
aux = [20,40];
fig_segments = figure('Visible', figVisible);
set(fig_segments, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');
subplot(4,1,1); hold on;
p1 = plot(times.union,Fz_plantar_f,'DisplayName','Fz Plantar');
p2 = plot(times.union,Fz_buttock_f,'DisplayName','Fz Buttock');
xline(times_start,'r--','LineWidth',1);
xline(times_seat_off,'g','LineWidth',1.5);
xline(times_min_grf_plantar,'b--','LineWidth',1);
xline(times_end,'k--','LineWidth',1);
xlim(aux);
hold off;
legend([p1,p2],'Location','northeast');
title('GRF');
xlabel('Time (s)');
ylabel('Force (N)');
grid on; hold off;
subplot(4,1,2); hold on;
p1 = plot(times.vicon,analysisGround.pos_pelvis_X,'DisplayName','Pelvis CoM Y');
p2 = plot(times.vicon,analysisGround.pos_pelvis_Y,'DisplayName','Pelvis CoM Z');
p3 = plot(times.vicon,analysisGround.pos_center_of_mass_X,'DisplayName','CoM Y');
p4 = plot(times.vicon,analysisGround.pos_center_of_mass_Y,'DisplayName','CoM Z');
xline(times_start,'r--','LineWidth',1);
xline(times_seat_off,'g','LineWidth',1.5);
xline(times_min_grf_plantar,'b--','LineWidth',1);
xline(times_end,'k--','LineWidth',1);
xlim(aux);
hold off;
legend([p1,p2,p3,p4],'Location','northeast');
title('CoM');
xlabel('Time (s)');
ylabel('Position (m)');
grid on; hold off;
subplot(4,1,3); hold on;
p1 = plot(times.vicon,ik.hip_flexion_r,'DisplayName','Hip Flexion');
p2 = plot(times.vicon,ik.ankle_angle_r,'DisplayName','Ankle Angle');
p3 = plot(times.vicon,ik.lumbar_extension,'DisplayName','Lumbar Extension');
xline(times_start,'r--','LineWidth',1);
xline(times_seat_off,'g','LineWidth',1.5);
xline(times_min_grf_plantar,'b--','LineWidth',1);
xline(times_end,'k--','LineWidth',1);
xlim(aux);
hold off;
legend([p1,p2,p3],'Location','northeast');
title('Joint Angles');
xlabel('Time (s)');
ylabel('Angle (deg)');
grid on; hold off;
subplot(4,1,4); hold on;
p1 = plot(times.union,inertia_rotary,'DisplayName','Inertia Rotary');
xline(times_start,'r--','LineWidth',1);
xline(times_seat_off,'g','LineWidth',1.5);
xline(times_min_grf_plantar,'b--','LineWidth',1);
xline(times_end,'k--','LineWidth',1);
xlim(aux);
hold off;
legend([p1],'Location','northeast');
title('Inertia Rotary');
xlabel('Time (s)');
ylabel('Inertia (kg*m^2)');
grid on; hold off;

outputDir = fullfile('outputs', 'images com cmp', 'segments');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
outputName = sprintf('segments_%d.png', idxFile);
saveas(fig_segments, fullfile(outputDir, outputName));
if ~flag_show_figs
    close(fig_segments);
end