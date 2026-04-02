clear;

i=1;
j=1;
%%
pathname = ['Pathway',' (', num2str(i),')', '.txt'];
if j==1
    Pathstream = Read_Pathway(pathname);
else
    Pathstream = Read_Pathway2(pathname);
end

% 求解步道板子块数
maxrow  = 0;
for row=1:length(Pathstream.count)
    maxrow(row) =  max(Pathstream.x{row});
end
maxone = max(maxrow);
numpath = double(ceil((maxone)/32));
%步道时间
intial_time_pathway = min(Pathstream.time);
end_time_pathway = max(Pathstream.time);
pathtime_interval = round(seconds(end_time_pathway - intial_time_pathway)/length(Pathstream.count),3);
disp([pathname,':步道采样频率:',num2str(1/pathtime_interval)]);
Pathstream.time=(0:pathtime_interval:(length(Pathstream.time)-1)*pathtime_interval)';
%原始足迹
footprint1 = FootprintMerge(Pathstream, numpath);
%第一次去除坏点
Pathstream = Remove_Bad_Points_Stepone(Pathstream);
%足迹识别
footprint2 = FootprintMerge(Pathstream, numpath);
[label, left, right, n] = Mark(footprint2);%坐标还是原始坐标，向下为x，向右为y
% 第二次去除坏点，脚印之外的点
Pathstream = Remove_Bad_Points_Steptwo(Pathstream,label,n);

figure(1);
footprint3 = FootprintMerge(Pathstream, numpath);
subplot(131)
imshow(footprint1)
subplot(132)
imshow(footprint2)
subplot(133)
imshow(footprint3)
% 计算单个脚印时间
for j = 1: 1: n
    %足迹时间
    [x, y] = find(label == j);
    duration =[];
    for k = 1: 1: length(Pathstream.count)
        if ~isempty(intersect([x, y], double([Pathstream.x{k}, Pathstream.y{k}]), 'rows'))
            duration = [duration; Pathstream.time(k)];
        end
    end
    support{j} = duration;  % 算出每隔脚印出现和结束的时间
end

if(mean(support{n})<mean(support{1})) %纠正每步的时间
    match_path = find(Pathstream.time >= (min(support{n})) & Pathstream.time <= (max((support{1}))));
else
    match_path = find(Pathstream.time >= (min(support{1})) & Pathstream.time <= (max((support{n}))));
end

%%
figure(2);
set(gcf, 'Position', [0 0 1920 1080]);
subplot(5, 2, [1 9]);
handle_footprint0 = plot(0, 0, '.b');
axis([0 0.48 0 numpath * 0.32]);
axis equal;
xlabel('x/m');
ylabel('y/m');
xlim([0 0.48 ]);
ylim([0 numpath * 0.32]);
hold on
%
subplot(5, 2, [2 10]);
hold on;
handle_footprint1 = plot(0, 0, '.b');
xlim([0 0.48 ]);
ylim([0 numpath * 0.32]);
axis equal;

for i = 1:length(match_path)
    if ishandle(handle_footprint0)
        delete(handle_footprint0);
    end
    [X, Y] = img2xy(double(Pathstream.x{match_path(i), 1}), double(Pathstream.y{match_path(i), 1}), numpath);
    subplot(5, 2, [1 9]);
    handle_footprint0 = plot(X, Y, '.b');
    xlabel('x/m');
    ylabel('y/m');
    xlim([0 0.48 ]);
    ylim([0 numpath * 0.32]);
    axis equal;
    %
    subplot(5, 2, [2 10]);
    plot(X, Y, '.b');
    xlabel('x/m');
    ylabel('y/m');
    xlim([0 0.48 ]);
    ylim([0 numpath * 0.32]);
    axis equal;
    pause(0.0001);
end