% 计算足底各部分的压力
% 坐标系：imshow坐标系，x向下，y向右；pts坐标系，x向右，y向上；imshow下作图坐标系，x向右，y向下。rect在pts坐标系下。
function [p_list,ptsPartsAnotomy] = CalPlantarPressures(dataAll2DPlantar,flagDrawPlantar,filename)
if nargin < 2
    flagDrawPlantar = false;
    filename = 'test';
end
frameNum = size(dataAll2DPlantar,1);
imgPlantarSum = reshape(sum(dataAll2DPlantar),32,32);
% figure; imshow(mat2gray(imgPlantarSum),'InitialMagnification','fit');title('足底：完整轮廓原图'); colormap jet;
%% 获取足部外轮廓
% pts = createPts(imgPlantarSum, ceil(max(max(imgPlantarSum))/50));
pts = createPts(imgPlantarSum, 0);
labels = dbscanLabels(pts);
ctrsPts = getCtrsPts(pts, labels);
aux = [10*ctrsPts(:,1),ctrsPts(:,2)];% 拉伸X，使左右脚区分明显
[idxFoot, ctrsFoot] = kmeans(aux, 2);
% 判断左脚是否在左边
if ctrsFoot(1,1)>ctrsFoot(2,1)
    ctrsFoot = [ctrsFoot(2,:);ctrsFoot(1,:)];
    idxFoot = 3 - idxFoot; % 交换1,2
end
labelsFoot = idxFoot(labels); % labels转换为idxFoot
% 外切矩形
vtxx = zeros(2,4); vtxy = zeros(2,4); % 边中点
rectx = zeros(2,5); recty = zeros(2,5); % 顶点
for i = 1:2
    [rectx(i,:),recty(i,:),~,~] = minboundrect(pts(labelsFoot==i,1),pts(labelsFoot==i,2));
end
[rectx,recty] = sortRect(rectx,recty);
[rectx, recty] = correctRect(rectx, recty, imgPlantarSum);
[ptsRect, labelsRect] = getPtsRect(rectx,recty);
[labelsFootPartsAnotomy, ptsPartsAnotomy, linex, liney] = getFootPartitionAnotomy(ptsRect, rectx, recty, labelsRect);

if flagDrawPlantar
    figure('visible','off'); 
    imshow(mat2gray(imgPlantarSum),'InitialMagnification','fit'); title('解剖结构分区'); colormap jet;
    hold on;
    for i = 1:2
        line(linex(i,:)',33-liney(i,:)','color','red','linewidth',1.5);
    end
    hold off;
    print(filename, '-dpng', '-r300')
end

%% 计算足底各部分压力
% 先左后右：脚趾，跖骨1、2-4、5，足弓，足跟
pPlantarAnatomy = zeros(frameNum,12);
for i = 1:frameNum
    aux = getPressurePart(ptsPartsAnotomy,reshape(dataAll2DPlantar(i,:),32,32));
    pPlantarAnatomy(i,:) = [aux(1,:),aux(2,:)];
end
% pPlantarAnatomy = pPlantarAnatomy./10;
p_list.pPlantarAnatomy = pPlantarAnatomy;
p_list.pPlantarLeft = sum(pPlantarAnatomy(:,1:6),2); p_list.pPlantarRight = sum(pPlantarAnatomy(:,7:12),2);

%% 计算COP在前后方向比例
heightL = norm([rectx(1,1)-rectx(1,4),recty(1,1)-recty(1,4)]);
heightR = norm([rectx(2,1)-rectx(2,4),recty(2,1)-recty(2,4)]);

% 左右脚点集
ptsL = []; ptsR = [];
for i = 1:6
    ptsL = [ptsL;ptsPartsAnotomy{1,i}];
    ptsR = [ptsR;ptsPartsAnotomy{2,i}];
end

copXLs = zeros(frameNum,1); copXRs = zeros(frameNum,1); 
copYLs = zeros(frameNum,1); copYRs = zeros(frameNum,1);
ratioLs = zeros(frameNum,1); ratioRs = zeros(frameNum,1);
for i = 1:frameNum
    copXL = 0; copYL = 0; copXR = 0; copYR = 0;
    sumL = 0; sumR = 0;
    img = reshape(dataAll2DPlantar(i,:),32,32);
    % 计算左右脚COP位置
    for j = 1:size(ptsL,1)
        x = ptsL(j,1); y = ptsL(j,2);
        p = img(33-y,x);
        sumL = sumL+p;
        copXL = copXL+p*x;
        copYL = copYL+p*y;
    end
    for j = 1:size(ptsR,1)
        x = ptsR(j,1); y = ptsR(j,2);
        p = img(33-y,x);
        sumR = sumR+p;
        copXR = copXR+p*x;
        copYR = copYR+p*y;
    end
    copXL = copXL./sumL; copYL = copYL./sumL;
    copXR = copXR./sumR; copYR = copYR./sumR;
    copXLs(i,1) = copXL; copXRs(i,1) = copXR;
    copYLs(i,1) = copYL; copYRs(i,1) = copYR;

    rx = rectx(1,1:4); ry = recty(1,1:4);
    ratioLs(i,1) = norm(cross([rx(3)-rx(4),ry(3)-ry(4),1],[copXL-rx(4),copYL-ry(4),1]))/norm([rx(3)-rx(4),ry(3)-ry(4),0])/heightL; % 左下-右下
    rx = rectx(2,1:4); ry = recty(2,1:4);
    ratioRs(i,1) = norm(cross([rx(3)-rx(4),ry(3)-ry(4),1],[copXR-rx(4),copYR-ry(4),1]))/norm([rx(3)-rx(4),ry(3)-ry(4),0])/heightR; % 左下-右下
end
p_list.ratioLs = ratioLs; p_list.ratioRs = ratioRs;

%% 查看左右脚COP位置和比例。
% frame = 750;
% img = reshape(dataAll2DPlantar(frame,:),32,32);
% figure; imshow(mat2gray(img),'InitialMagnification','fit'); colormap default
% hold on; 
% plot(copXLs(frame),33-copYLs(frame),'r*');
% plot(copXRs(frame),33-copYRs(frame),'g*');
% plot(rectx(1,1:4),33-recty(1,1:4),'ro');
% plot(rectx(2,1:4),33-recty(2,1:4),'go');
% hold off;
% 
% disp([num2str(copXLs(frame)),', ',num2str(copYLs(frame))]);
% disp([num2str(copXRs(frame)),', ',num2str(copYRs(frame))]);
% disp(ratioLs(frame));disp(ratioRs(frame));


end