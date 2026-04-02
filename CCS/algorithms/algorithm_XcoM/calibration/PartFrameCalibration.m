
if flag_floor
    %% 使用水平面文件校准
    
    transform_floor = Read_Floor(filename_floor);
    
    % 骨骼点旋转
    stream = Transform_Azure(transform_floor,stream);
    
    % 点云旋转
    for i = 1:numel(pointclouds)
        aux = transform_floor(1:3,1:3) * pointclouds{1,i}';
        aux = aux + 1000*transform_floor(1:3,4);
        pointclouds{1,i} = aux';
    end

    % 平移，以两个FOOT中点为原点
    transform_foot = [(median(stream.FOOT_LEFT.x)+median(stream.FOOT_RIGHT.x))/2,...
        (median(stream.FOOT_LEFT.y)+median(stream.FOOT_RIGHT.y))/2,...
        (median(stream.FOOT_LEFT.z)+median(stream.FOOT_RIGHT.z))/2];
    stream = Transform_Azure([1,0,0,-transform_foot(1);0,1,0,-transform_foot(2);0,0,1,-transform_foot(3);0,0,0,1],stream);

    for i = 1:numel(pointclouds)
        pointclouds{1,i} = pointclouds{1,i} - 1000*transform_foot;
    end
else
    %% 通过水平面选点校准

    % 数据坐标系转换（x = x; y = z; z = -y）
    % 以摄像头为原点：x右，y前，z上
    for i = 1:numel(pointclouds)
        pointclouds{1,i} = pointclouds{1,i}(:,[1,3,2]);
        pointclouds{1,i}(:,3) = -pointclouds{1,i}(:,3);
    end
    
    tmKinect = [1 0 0 0;0 0 1 0;0 -1 0 0;0 0 0 1];
    stream = Transform_Azure(tmKinect,stream);

    if flag_select_paras
        hFigure = DrawPointclouds(pointclouds,100); title('请选择3个水平面的点，填入horizontal_planes');
        set(gcf,'Position',[100,100,1280,720]);

        % 初始化存储点击点的坐标
        global horizontal_plane clickCount;
        horizontal_plane = zeros(3, 3); % 存储3个点的坐标
        clickCount = 0; % 点击计数器
        
        % 启用数据光标模式
        datacursormode on;
        hCursor = datacursormode(hFigure);
        set(hCursor, 'UpdateFcn', @ClickPointsCallBack);
        
        % 等待用户完成点击或按下 ESC 键
        disp('请点击图中的点选择3个点，或按 ESC 键退出。');
        while true
            % 等待用户按下键盘或鼠标
            key = waitforbuttonpress;
            
            % 如果按下的是键盘
            if key == 1
                % 获取按下的键
                keyPressed = get(gcf, 'CurrentCharacter');
                
                % 如果按下的是 ESC 键
                if double(keyPressed) == 27
                    close(hFigure); % 关闭 figure
                    break; % 退出循环
                end
            end
        end
        
    else
        horizontal_plane = horizontal_planes{idx_file};
    end

    % 水平面修正
    % DrawPointclouds(pointclouds,100);
    rotation_matrix = PlaneRotation(horizontal_plane);
    % 点云旋转
    for i = 1:numel(pointclouds)
        aux = rotation_matrix * pointclouds{1,i}';
        pointclouds{1,i} = aux';
    end
    % 骨骼点旋转
    tmKinect(1:3,1:3) = rotation_matrix;
    stream = Transform_Azure(tmKinect,stream);

    % 判断是否需要再绕y轴转180度
    if median(stream.HEAD.z)<median(stream.FOOT_LEFT.z)
        rotation_matrix = [1,0,0;0,-1,0;0,0,-1];
        % 点云旋转
        for i = 1:numel(pointclouds)
            aux = rotation_matrix * pointclouds{1,i}';
            pointclouds{1,i} = aux';
        end
        % 骨骼点旋转
        tmKinect(1:3,1:3) = rotation_matrix;
        stream = Transform_Azure(tmKinect,stream);
    end

    % 平移，以两个FOOT中点为原点
    transform_foot = [(median(stream.FOOT_LEFT.x)+median(stream.FOOT_RIGHT.x))/2,...
        (median(stream.FOOT_LEFT.y)+median(stream.FOOT_RIGHT.y))/2,...
        (median(stream.FOOT_LEFT.z)+median(stream.FOOT_RIGHT.z))/2];
    stream = Transform_Azure([1,0,0,-transform_foot(1);0,1,0,-transform_foot(2);0,0,1,-transform_foot(3);0,0,0,1],stream);

    for i = 1:numel(pointclouds)
        pointclouds{1,i} = pointclouds{1,i} - 1000*transform_foot;
    end

end

% DrawPointclouds(pointclouds,100);
% DrawKinectFrame(stream,100);
DrawPointclouds_kinect(pointclouds,stream,100); title('坐标系校准后');

