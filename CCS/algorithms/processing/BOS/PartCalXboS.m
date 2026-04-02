%% 动态BoS方案一：关联特征点

% 1. 在静坐段关联踝关节点、足关节点和足BoS，关联骨盆、髋关节和臀BoS。
% 2. 关节点与接触面（静坐段的关节点z轴位置）小于阈值时，认为存在潜在BoS。
% 3. 预测关节点未来的运动。
% 4. 根据未来关节点关联未来BoS，合并现有BoS。

%% 压力图像按PELVIS位置位移

seg = intersect(idx_segment_both,sts_segments.idx_end(1):sts_segments.idx_start(end));

% 寻找位于中央的臀底压力帧
idx_frame_middle = seg(round(length(seg)/2));

% 转换位移到像素单位
di_pixel = 1000*stream.PELVIS.y/11.5; % 列方向位移
dj_pixel = -1000*stream.PELVIS.x/11.5; % 行方向位移
di_middle = di_pixel(idx_frame_middle); dj_middle = dj_pixel(idx_frame_middle);
di_pixel = di_pixel-di_middle; dj_pixel = dj_pixel-dj_middle;

sumImg = zeros(32,32);
cnt = zeros(32,32);

[i_ref, j_ref] = meshgrid(1:32, 1:32);

for i = seg
    img = double(reshape(pressureButtock2DInter(i,:,:),32,32));
    di = di_pixel(i);
    dj = dj_pixel(i);

    % 计算当前帧对应的原图坐标
    i_orig = i_ref-di;
    j_orig = j_ref-dj;
    
    % 双线性插值，超出范围设为NaN
    interpolated = interp2(1:32,1:32,img,i_orig,j_orig,'linear',NaN);
    interpolated(isnan(interpolated)) = 0;

    validMask = ~isnan(interpolated);
    sumImg = sumImg+interpolated;
    cnt = cnt+validMask;
end

img_average = sumImg ./ length(seg);

% figure;
% subplot(1,2,1); imshow(mat2gray(reshape(pressureButtock2DInter(idx_frame_middle,:),32,32)),'InitialMagnification','fit'); colormap default; 
% title('位于中央的臀底压力帧');
% subplot(1,2,2); imshow(mat2gray(img_average),'InitialMagnification','fit'); colormap default; 
% title('平均帧');
% sgtitle('按PELVIS位置位移计算平均帧');

%% 平均帧的BoS

img = [zeros(32,32);img_average];

[bos_middle_x, bos_middle_y, mask_bos_middle] = CalBOS(img,max(img(:))/100);

%% 潜在BoS的阈值选取

height_below = 0.07; % 存在潜在BoS的阈值

% 静坐时的BoS
seg = intersect(idx_segment_both,sts_segments.idx_end(1):sts_segments.idx_start(end));
height_pelvis_seat = mean(stream.PELVIS.z(seg));
height_xbos = height_pelvis_seat+height_below;

%% XboS的计算
xbos = struct();
xbos.x = cell(length(times.union),1);
xbos.y = cell(length(times.union),1);

for idxFrame = 1:length(times.union)
% for idxFrame = 291
%     img = reshape(pressureButtock2DInter(idxFrame,:),32,32);
%     figure; imshow(mat2gray(img),'InitialMagnification','fit'); colormap default;
    
    flagXboS = stream.PELVIS.z(idxFrame)<height_xbos; % 骨盆高度低于阈值
    flagXboS = flagXboS && idxFrame-5>0 && stream.PELVIS.z(idxFrame)-stream.PELVIS.z(idxFrame-5)<=-0.05; % 向下运动
    flagXboS = flagXboS && ismember(idxFrame,idx_segment_single); % 臀部尚未接触

    if flagXboS
        % mask_bos_middle平移
        di = 1000/11.5*(stream.PELVIS.y(idxFrame)-stream.PELVIS.y(idx_frame_middle));
        dj = -1000/11.5*(stream.PELVIS.x(idxFrame)-stream.PELVIS.x(idx_frame_middle));
        
        i_orig = i_ref+di;
        j_orig = j_ref+dj;

        mask_bos_buttock = interp2(1:32,1:32,double(mask_bos_middle(33:64,:)),i_orig,j_orig,'linear',NaN);
        mask_bos_buttock(isnan(mask_bos_buttock)) = 0;
        mask_bos_buttock(mask_bos_buttock>0.5)=1;
        mask_bos_buttock(mask_bos_buttock<=0.5)=0;

        img = [reshape(pressurePlantar2DInter(idxFrame,:,:),32,32);mask_bos_buttock];
        [bos_x, bos_y] = CalBOS(img,0);

        xbos.x{idxFrame} = -bos_x+transform_plantar2kinect(1);
        xbos.y{idxFrame} = bos_y+transform_plantar2kinect(2);

%         figure;
%         subplot(1,2,1); hold on;
%         plot(com.x(idxFrame),com.y(idxFrame),'ro');
%         plot(bos.x{idxFrame},bos.y{idxFrame},'b-');
%         plot([0,-0.365,-0.365,0,0,0,-0.365]+transform_plantar2kinect(1),[0,0,0.365*2,0.365*2,0,0.365,0.365]+transform_plantar2kinect(2),'k-');
%         ax = gca;
%         ax.YDir = 'reverse';
%         legend('com','bos'); hold off; axis equal;
%         subplot(1,2,2); hold on;
%         plot(xcom.x(idxFrame),xcom.y(idxFrame),'ro');
%         plot(xbos.x{idxFrame},xbos.y{idxFrame},'b-');
%         plot([0,-0.365,-0.365,0,0,0,-0.365]+transform_plantar2kinect(1),[0,0,0.365*2,0.365*2,0,0.365,0.365]+transform_plantar2kinect(2),'k-');
%         ax = gca;
%         ax.YDir = 'reverse';
%         legend('xcom','xbos'); hold off; axis equal;
%         
%         sgtitle(['bos与xbos对比：',num2str(idxFrame),'帧']);
        
    else
        xbos.x{idxFrame} = bos.x{idxFrame};
        xbos.y{idxFrame} = bos.y{idxFrame};
    end
end

