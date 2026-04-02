function [] = DrawPointclouds_frames(pointclouds,rangeXYZ,gridX,gridY,gridZ,idxsDBSCAN)
    figure; hold on;
    ax = gca;
    view(3); % 设置3D视图
    view(-20, 20); % 方位角：0时看向Y轴，-90看向X轴；仰角：90看向-Z
    
    % 创建散点图对象
    h1 = scatter3(ax, [], [], [], 3, 'filled');
    h2 = scatter3(ax, [], [], [], 3, 'filled');
    
    % 动画循环
    for i = 1:length(pointclouds)
        points = pointclouds{i};
        if nargin<6
            x1 = points(:,1); y1 = points(:,2); z1 = points(:,3);
            % 更新散点图数据
            set(h1, 'XData', x1, 'YData', y1, 'ZData', z1);
        else
            idxDBSCAN = idxsDBSCAN{i};
            idxHuman = find(idxDBSCAN==1);
            idxNoise = find(idxDBSCAN~=1);
        
            x1 = points(idxHuman,1); y1 = points(idxHuman,2); z1 = points(idxHuman,3);
            x2 = points(idxNoise,1); y2 = points(idxNoise,2); z2 = points(idxNoise,3);
            
            % 更新散点图数据
            set(h1, 'XData', x1, 'YData', y1, 'ZData', z1);
            set(h2, 'XData', x2, 'YData', y2, 'ZData', z2);
        end
        
        % 更新帧数文本
        title(sprintf('Frame: %d', i));
        
        xlabel('x 向右');
        ylabel('y 向前');
        zlabel('z 向上');
        axis equal;
        grid on;
    
        % 设置固定的坐标轴范围
        if nargin<2
            ax.XLim = [-2000,2000];
            ax.YLim = [-100,10000];
            ax.ZLim = [-1500,1500];
        else
            ax.XLim = [gridX(rangeXYZ(1,1)),gridX(rangeXYZ(1,2))];
            ax.YLim = [gridY(rangeXYZ(2,1)),gridY(rangeXYZ(2,2))];
            ax.ZLim = [gridZ(rangeXYZ(3,1)),gridZ(rangeXYZ(3,2))];
        %     ax.XLim = [-1000,1000];
        %     ax.YLim = [-100,5000];
        %     ax.ZLim = [-1000,1800];
        end

        % 刷新图形
        drawnow;
        
        % 可选：添加暂停以控制动画速度
        pause(0.1);
    end
    hold off;
end