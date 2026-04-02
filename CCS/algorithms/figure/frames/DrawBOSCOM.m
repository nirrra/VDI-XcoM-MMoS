function [] = DrawBOSCOM(times,pressurePlantar2DInter,pressureButtock2DInter,...
    com,xcom,bos,bos_plantar,copPlantar,colors,transform_plantar2kinect,filename_plantar,flag_save,idxFrames)

flag_frame = length(idxFrames)==1;


if flag_frame
    idxFrame = idxFrames;
    imgPlantar = reshape(pressurePlantar2DInter(idxFrame,:),32,32);
    imgButtock = reshape(pressureButtock2DInter(idxFrame,:),32,32);
        
    img = [imgPlantar;imgButtock];
    
    % bos
    bos_x = bos.x{idxFrame}; bos_y = bos.y{idxFrame};
    bos_plantar_x = bos_plantar.x{idxFrame}; bos_plantar_y = bos_plantar.y{idxFrame}; 
    
    f = figure;
    set(f, 'Position', [100, 100, 800, 600]); 
    clf(f);
    
    imshow(mat2gray(img),'InitialMagnification','fit'); colormap default;
    hold on;
    aux = FrameKinect2Footscan([com.x(idxFrame),com.y(idxFrame)],transform_plantar2kinect);
    p1 = plot(aux.x,aux.y,'o','Color',colors(2,:),'MarkerFaceColor',colors(2,:),'MarkerSize',4,'DisplayName','com');
    aux = FrameKinect2Footscan([xcom.x(idxFrame),xcom.y(idxFrame)],transform_plantar2kinect);
    p2 = plot(aux.x,aux.y,'o','Color',colors(4,:),'MarkerFaceColor',colors(4,:),'MarkerSize',4,'DisplayName','xcom');
    bos_image = FrameKinect2Footscan([bos_x,bos_y],transform_plantar2kinect);
    p3 = plot(bos_image.x,bos_image.y,'r-','DisplayName','bos');
    bos_plantar_image = FrameKinect2Footscan([bos_plantar_x,bos_plantar_y],transform_plantar2kinect);
    p4 = plot(bos_plantar_image.x,bos_plantar_image.y,'g-','DisplayName','bos');
    aux = FrameKinect2Footscan([copPlantar.x(idxFrame),copPlantar.y(idxFrame)],transform_plantar2kinect);
    p5 = plot(aux.x,aux.y,'o','Color',colors(5,:),'MarkerFaceColor',colors(5,:),'MarkerSize',4,'DisplayName','cop plantar');

    hold off;

    legend([p1,p2,p5], 'Location', 'southeast');
    title([num2str(idxFrame),' 帧；时间：',num2str(times.union(idxFrame)),' s']);

    if flag_save
        print(f, ['./outputs/images/',filename_plantar(1:end-5),'BOS_COM.png'],'-dpng','-r300');
    end

else
    if flag_save
        outputVideo = VideoWriter(['./outputs/videos/', filename_plantar(1:end-5), 'BOS_COM.mp4'], 'MPEG-4');
        outputVideo.Quality = 50;  
        outputVideo.FrameRate = 30;
        open(outputVideo);
    end
    
    % 预创建图形和图形对象
    f = figure('Visible', 'on', 'Position', [100, 100, 800, 600]); % 离屏渲染
    mean_com_x = mean(com.x); % 预计算均值
    mean_com_y = mean(com.y);

    % 初始化
    ax1_im = imshow([], 'InitialMagnification', 'fit');
    colormap default;
    hold on;
    p1 = plot(NaN, NaN, 'o', 'Color', colors(2,:), 'MarkerFaceColor', colors(2,:), 'MarkerSize', 4, 'DisplayName', 'com');
    p2 = plot(NaN, NaN, 'o', 'Color', colors(4,:), 'MarkerFaceColor', colors(4,:), 'MarkerSize', 4, 'DisplayName', 'xcom');
    p3 = plot(NaN, NaN, 'r-', 'DisplayName', 'bos');
    p4 = plot(NaN, NaN, 'g-', 'DisplayName', 'bos plantar');
    p5 = plot(NaN, NaN, 'o', 'Color', colors(5,:), 'MarkerFaceColor', colors(5,:), 'MarkerSize', 4, 'DisplayName', 'cop plantar');

    legend([p1,p2,p5], 'Location', 'southeast');
    hold off;
    
    for idxFrame = idxFrames
        imgPlantar = reshape(pressurePlantar2DInter(idxFrame,:),32,32);
        imgButtock = reshape(pressureButtock2DInter(idxFrame,:),32,32);
            
        img = [imgPlantar;imgButtock];

        set(ax1_im, 'CData', mat2gray(img));
        
        bos_x = bos.x{idxFrame};
        bos_y = bos.y{idxFrame};
        xbos_x = xbos.x{idxFrame};
        xbos_y = xbos.y{idxFrame};
        bos_plantar_x = bos_plantar.x{idxFrame}; 
        bos_plantar_y = bos_plantar.y{idxFrame};   

        % 更新COM/XCOM标记
        aux_com = FrameKinect2Footscan([com.x(idxFrame), com.y(idxFrame)], transform_plantar2kinect);
        set(p1, 'XData', aux_com.x, 'YData', aux_com.y);
        aux_xcom = FrameKinect2Footscan([xcom.x(idxFrame), xcom.y(idxFrame)], transform_plantar2kinect);
        set(p2, 'XData', aux_xcom.x, 'YData', aux_xcom.y);
        bos_image = FrameKinect2Footscan([bos_x,bos_y],transform_plantar2kinect);
        set(p3, 'XData', bos_image.x, 'YData', bos_image.y);
        bos_plantar_image = FrameKinect2Footscan([bos_plantar_x,bos_plantar_y],transform_plantar2kinect);
        set(p4, 'XData', bos_plantar_image.x, 'YData', bos_plantar_image.y);
        aux_cop = FrameKinect2Footscan([copPlantar.x(idxFrame), copPlantar.y(idxFrame)], transform_plantar2kinect);
        set(p5, 'XData', aux_cop.x, 'YData', aux_cop.y);
        
        % 更新标题并捕获帧
        title([num2str(idxFrame,'%04d'),' 帧；时间：',num2str(times.union(idxFrame),'%.4f'),' s']);
        drawnow limitrate; % 使用快速渲染模式
    
        if flag_save
            writeVideo(outputVideo, getframe(f));
        end
    end
    
    if flag_save
        close(outputVideo);
    end

    close(f);
end

