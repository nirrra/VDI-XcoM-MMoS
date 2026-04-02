function [imgLeft,imgRight,maskLeft,maskRight] = GetImgsLR(imgPlantarSum)
pts = createPts(imgPlantarSum, ceil(max(max(imgPlantarSum))/1000));
% figure;
% scatter(pts(:,1),pts(:,2));
% axis equal; xlim([0.5,32.5]); ylim([0.5,32.5]); title('点集');

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
% [rectx, recty] = correctRect(rectx, recty, imgPlantarSum);

% figure; imshow(mat2gray(imgPlantarSum),'InitialMagnification','fit'); colormap jet;
% hold on; 
% plot(rectx(1,1:4),33-recty(1,1:4),'r*');
% plot(rectx(2,1:4),33-recty(2,1:4),'g*');
% hold off;

maskLeft = zeros(size(imgPlantarSum)); 
maskLeft(max(1,(33-ceil(max(recty(1,:))))):min(32,(33-floor(min(recty(1,:))))),max(1,floor(min(rectx(1,:)))):min(32,ceil(max(rectx(1,:))))) = 1;
imgLeft = imgPlantarSum.*maskLeft;
maskRight = zeros(size(imgPlantarSum)); 
maskRight(max(1,(33-ceil(max(recty(2,:))))):min(32,(33-floor(min(recty(2,:))))),max(1,floor(min(rectx(2,:)))):min(32,ceil(max(rectx(2,:))))) = 1;
imgRight = imgPlantarSum.*maskRight;