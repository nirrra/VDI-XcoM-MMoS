function [mid,ischialLeft,ischialRight,idxSitStable,ptsHipLeft,ptsHipRight,grfHipLeft_F,grfHipRight_F] = GetHipMidAndPressureLR(pressureHip2DInter,streamInter,grfPlantar_F,height)
%% 寻找坐姿稳定段
% 膝关节角稳定
data = streamInter.KNEE_LEFT.z+streamInter.KNEE_RIGHT.z;
idxStream = [];
for i = 1+10:length(data)-10
    if range(data(i-10:i+10))<0.005
        idxStream = [idxStream,i];
    end
end

% 足底压力稳定
data = grfPlantar_F.z;
idxPlantar = [];
for i = 1+10:length(data)-10
    if data(i)<400 && range(data(i-10:i+10))<10
        idxPlantar = [idxPlantar,i];
    end
end

% 坐姿稳定点
idxSitStable = intersect(idxStream,idxPlantar);

%% 臀部中线
img = reshape(sum(pressureHip2DInter),32,32);
imgLog = log(img); imgLog(imgLog==-Inf)=0;
hipTemplate = createTemplate(height);
% figure; imshow(mat2gray(hipTemplate.template),'InitialMagnification','fit'); title('模板');
[ischialLeft,ischialRight,coccyx] = getPosDueToTemplate(img,hipTemplate);
mid = coccyx(2);

% figure; imshow(mat2gray(imgLog),'InitialMagnification','fit');
% hold on; 
% plot(ischialLeft(2),ischialLeft(1),'r*','markersize',10);
% plot(ischialRight(2),ischialRight(1),'g*','markersize',10);
% plot(coccyx(2),coccyx(1),'bo','markersize',10);
% hold off; legend('左坐骨结节','右坐骨结节','尾骨'); title('根据模板标注特征位置');
%% 左右点集
imgBi = zeros(size(img)); imgBi(img>ceil(max(max(img))/1000)) = 1;
% figure; imshow(mat2gray(imgBi),'InitialMagnification','fit'); title('完整轮廓');
[pts(:,2),pts(:,1)] = find(imgBi == 1); pts(:,2) = 33-pts(:,2);
% figure; scatter(pts(:,1),pts(:,2),'.'); axis equal; axis([0.5 32.5 0.5 32.5]); 

ptsHipLeft = []; ptsHipRight = [];
for i = 1:size(pts,1)
    pt = pts(i,:);
    if pt(1) <= mid
        ptsHipLeft = [ptsHipLeft;pt];
    end
    if pt(1) >= mid
        ptsHipRight = [ptsHipRight;pt];
    end
end
%% 左右压力
grfHipLeft = zeros(size(pressureHip2DInter,1),1);
grfHipRight = zeros(size(pressureHip2DInter,1),1);
for i = 1:size(pressureHip2DInter,1)
    img = reshape(pressureHip2DInter(i,:),32,32);
    
    for j = 1:length(ptsHipLeft)
        pt = ptsHipLeft(j,:);
        F = img(33-pt(2),pt(1));
        if pt(1) == mid
            F = F./2;
        end
        grfHipLeft(i) = grfHipLeft(i)+F;
    end

    for j = 1:length(ptsHipRight)
        pt = ptsHipRight(j,:);
        F = img(33-pt(2),pt(1));
        if pt(1) == mid
            F = F./2;
        end
        grfHipRight(i) = grfHipRight(i)+F;
    end

end


grfHipLeft_F.z = grfHipLeft; grfHipLeft_F.x = zeros(size(grfHipLeft_F.z)); grfHipLeft_F.y = zeros(size(grfHipLeft_F.z));
grfHipRight_F.z = grfHipRight; grfHipRight_F.x = zeros(size(grfHipRight_F.z)); grfHipRight_F.y = zeros(size(grfHipRight_F.z));