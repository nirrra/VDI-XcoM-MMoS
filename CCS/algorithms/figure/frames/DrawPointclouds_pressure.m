%% 同时显示点云和压力分布
function [] = DrawPointclouds_pressure(pointclouds,pressurePlantar2DInter,pressureButtock2DInter,transform_plantar2kinect,idxFrame)
    figure; hold on;
    ax = gca;
    view(3); % 设置3D视图
    view(20, 10); % 方位角：0时看向Y轴，-90看向X轴；仰角：90看向-Z
    
    % 创建散点图对象
    h1 = scatter3(ax, [], [], [], 3, 'filled');
    h2 = surf(ax, [], [], [], 'EdgeColor', 'none'); % 压力分布图
    alpha(h2, 0.6); % 设置压力分布图的透明度
    set(gcf,'position',[100,100,720,960]);
    
    % 动画循环
    if nargin<5
        aux = 1:length(pointclouds);
    else
        aux = idxFrame;
    end
    for idxFrame = aux
        points = pointclouds{idxFrame};
        x1 = points(:,1); y1 = points(:,2); z1 = points(:,3);
        % 更新散点图数据
        set(h1, 'XData', x1, 'YData', y1, 'ZData', z1);
        
        % 更新压力分布图
        pressure = squeeze(pressurePlantar2DInter(idxFrame, :, :)); % 获取当前帧的压力分布
        pressure = [pressure;squeeze(pressureButtock2DInter(idxFrame, :, :))];
        [rows, cols] = size(pressure);
        
        % 将压力分布图的像素坐标转换为点云坐标系
        [j, i] = meshgrid(1:cols, 1:rows);
        x = -11.5 * (j - 0.5) + 1000*transform_plantar2kinect(1); % 转换为点云坐标系的x mm
        y = 11.5 * (i - 0.5) + 1000*transform_plantar2kinect(2);  % 转换为点云坐标系的y mm
        z_pressure = -50 * ones(size(x)); % 压力分布图显示在z = -100的平面上
    
        % 更新压力分布图的表面数据
        set(h2, 'XData', x, 'YData', y, 'ZData', z_pressure, 'CData', pressure);
    
        % 更新帧数文本
        title(sprintf('Frame: %d', idxFrame));
        
        xlabel('x 向右');
        ylabel('y 向前');
        zlabel('z 向上');
        axis equal;
        grid on;
    
        % 设置固定的坐标轴范围
        ax.XLim = [-700,700];
        ax.YLim = [-600,1000];
        ax.ZLim = [-100,1500];
    
        % 刷新图形
        drawnow;
        
        % 可选：添加暂停以控制动画速度
        pause(0.1);
    end
    hold off;