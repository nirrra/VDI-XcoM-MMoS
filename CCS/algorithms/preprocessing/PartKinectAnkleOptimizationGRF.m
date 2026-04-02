% PartKinectAnkleOptimizationGRF
% 参考 CreateDatasetInterpMC.m 的踝关节校准步骤（GRFTest版本移植）
% 说明：
% - 作为脚本运行（依赖工作区变量），输出 streamInterOptimized
% - 期望输入变量：
%   - streamInter: Kinect关节点流（字段含 .x/.y/.z，含 HEAD/FOOT_LEFT/FOOT_RIGHT/ANKLE_LEFT/ANKLE_RIGHT/KNEE_LEFT/KNEE_RIGHT/HIP_LEFT/HIP_RIGHT）
%   - pressurePlantar2D:  [T,32,32] 或 [T,1024] 足底阵列（用于生成整体模板）
%   - pressurePlantar2DInter: [T,32,32] 或 [T,1024] 足底阵列（逐帧校准）
%   - height: 身高（cm）
%
% - 输出变量：
%   - streamInterOptimized: 校准后的 streamInter（增加/更新 M1/M5/C/KNEE_LEFT2/KNEE_RIGHT2 等字段）

streamInterOptimized = ankle_optimization_grf(streamInter, pressurePlantar2D, pressurePlantar2DInter, height);

%% ===== local functions =====
function streamInterOptimized = ankle_optimization_grf(streamInter, pressurePlantar2D, pressurePlantar2DInter, height)
    % 米和阵列转换
    funcImg2Real = @(pos) [(pos(2)-16.5)*11.5,(16.5-pos(1))*11.5]./1000; % img->real: x右 y前 (m)

    % ---- 站立稳定段（用 HEAD.z） ----
    segStable = [];
    for i = 100:length(streamInter.wtime)-100
        if streamInter.HEAD.z(i) > max(streamInter.HEAD.z) - 0.1 && range(streamInter.HEAD.z(i-5:i+5)) < 0.02
            segStable(end+1) = i; %#ok<AGROW>
        end
    end
    if isempty(segStable)
        segStable = max(1, round(0.2*length(streamInter.wtime))):min(length(streamInter.wtime), round(0.8*length(streamInter.wtime)));
    end

    % ---- 整足模板（由足底压力累积图得到左右脚矩形 + M1/M5/C）----
    imgPlantarSum = sum_pressure_img(pressurePlantar2D);
    [imgLeft, imgRight] = GetImgsLR(imgPlantarSum);
    imgTemplatesLeft = GetImgTemplate(imgLeft, 'l');
    imgTemplatesRight = GetImgTemplate(imgRight, 'r');

    [hasPlantarLeft, rectLeft, M1LeftSum, M5LeftSum, CLeftSum] = GetRectInImg(imgPlantarSum, imgTemplatesLeft, 'l');
    [hasPlantarRight, rectRight, M1RightSum, M5RightSum, CRightSum] = GetRectInImg(imgPlantarSum, imgTemplatesRight, 'r');
    if ~hasPlantarLeft || ~hasPlantarRight
        % 若无法识别脚印，直接返回原始
        streamInterOptimized = streamInter;
        return;
    end

    [~, labelsLeft] = GetPartitionHalf(rectLeft);
    [~, labelsRight] = GetPartitionHalf(rectRight);

    % ---- 阵列->Kinect 平移（用稳定站立时双脚中点对齐）----
    posFootLeftPlantar = funcImg2Real((M1LeftSum + M5LeftSum) ./ 2);
    posFootRightPlantar = funcImg2Real((M1RightSum + M5RightSum) ./ 2);
    posOrigin = [streamInter.FOOT_LEFT.x + streamInter.FOOT_RIGHT.x, streamInter.FOOT_LEFT.y + streamInter.FOOT_RIGHT.y, streamInter.FOOT_LEFT.z + streamInter.FOOT_RIGHT.z] ./ 2;
    posOrigin = mean(posOrigin(segStable, :));
    vectorPlantar2Kinect = [posOrigin(1), posOrigin(2)] - (posFootLeftPlantar + posFootRightPlantar) ./ 2;

    M1LeftSumKinect = funcImg2Real(M1LeftSum) + vectorPlantar2Kinect;
    M5LeftSumKinect = funcImg2Real(M5LeftSum) + vectorPlantar2Kinect;
    CLeftSumKinect  = funcImg2Real(CLeftSum)  + vectorPlantar2Kinect;
    M1RightSumKinect = funcImg2Real(M1RightSum) + vectorPlantar2Kinect;
    M5RightSumKinect = funcImg2Real(M5RightSum) + vectorPlantar2Kinect;
    CRightSumKinect  = funcImg2Real(CRightSum)  + vectorPlantar2Kinect;

    posFootLeftSumKinect = (M1LeftSumKinect + M5LeftSumKinect) ./ 2;
    posFootRightSumKinect = (M1RightSumKinect + M5RightSumKinect) ./ 2;
    % 供后续长度估计与Knee优化使用（2D投影点）
    posAnkleLeftSumKinect = CLeftSumKinect;
    posAnkleRightSumKinect = CRightSumKinect;
    % ---- 足跟高度（近似：距骨到地面距离按身高校正）----
    hSum = 0.04 ./ 170 .* height;

    % ---- 估计小腿/大腿长度（用于 KneePosOptimization）----
    lenShank = ( ...
        norm(mean([streamInter.KNEE_LEFT.x(segStable), streamInter.KNEE_LEFT.y(segStable), streamInter.KNEE_LEFT.z(segStable)]) - [posAnkleLeftSumKinect, hSum]) + ...
        norm(mean([streamInter.KNEE_RIGHT.x(segStable), streamInter.KNEE_RIGHT.y(segStable), streamInter.KNEE_RIGHT.z(segStable)]) - [posAnkleRightSumKinect, hSum]) ) / 2;

    lenThigh = ( ...
        norm(mean([streamInter.KNEE_LEFT.x(segStable), streamInter.KNEE_LEFT.y(segStable), streamInter.KNEE_LEFT.z(segStable)]) - ...
             mean([streamInter.HIP_LEFT.x(segStable),  streamInter.HIP_LEFT.y(segStable),  streamInter.HIP_LEFT.z(segStable)])) + ...
        norm(mean([streamInter.KNEE_RIGHT.x(segStable), streamInter.KNEE_RIGHT.y(segStable), streamInter.KNEE_RIGHT.z(segStable)]) - ...
             mean([streamInter.HIP_RIGHT.x(segStable),  streamInter.HIP_RIGHT.y(segStable),  streamInter.HIP_RIGHT.z(segStable)])) ) / 2;

    % ---- 前脚掌点数估计足跟抬起高度 ----
    parasMLeft = zeros(length(streamInter.wtime), 1);
    parasMRight = zeros(length(streamInter.wtime), 1);
    for idxFrame = 1:length(streamInter.wtime)
        img = frame_pressure_img(pressurePlantar2DInter, idxFrame);
        parasMLeft(idxFrame) = nnz(img(labelsLeft == 1) > 0);
        parasMRight(idxFrame) = nnz(img(labelsRight == 1) > 0);
    end

    Fs = 50; Fc = 1; Wn = Fc/(Fs/2); n = 4;
    [b, a] = butter(n, Wn, 'low');
    parasMLeft = filtfilt(b, a, parasMLeft);
    parasMRight = filtfilt(b, a, parasMRight);

    vzLeft = -parasMLeft; vzLeft = (vzLeft - mean(vzLeft)) ./ rms(vzLeft);
    th = 0; vzLeft(vzLeft < th) = th; vzLeft = vzLeft - th;
    vzLeft = vzLeft ./ range(vzLeft) .* 0.06;

    vzRight = -parasMRight; vzRight = (vzRight - mean(vzRight)) ./ rms(vzRight);
    th = 0; vzRight(vzRight < th) = th; vzRight = vzRight - th;
    vzRight = vzRight ./ range(vzRight) .* 0.06;

    % ---- 足跟离地段（基于后脚跟分区压力 + ANKLE.z变化）----
    posAnkleLiftLeft = GetSegAnkleLift(streamInter, pressurePlantar2DInter, labelsLeft);
    posAnkleLiftRight = GetSegAnkleLift(streamInter, pressurePlantar2DInter, labelsRight);
    posAnkleLift = (posAnkleLiftLeft + posAnkleLiftRight) > 0;

    % ---- 逐帧生成足/踝点（沿用 GRFTest 的线性规则）----
    posFootLeftOptimized = zeros(length(streamInter.wtime), 3);
    posFootRightOptimized = zeros(length(streamInter.wtime), 3);
    posAnkleLeftOptimized = zeros(length(streamInter.wtime), 3);
    posAnkleRightOptimized = zeros(length(streamInter.wtime), 3);

    M1LeftOptimized = zeros(length(streamInter.wtime), 3);
    M5LeftOptimized = zeros(length(streamInter.wtime), 3);
    CLeftOptimized  = zeros(length(streamInter.wtime), 3);
    M1RightOptimized = zeros(length(streamInter.wtime), 3);
    M5RightOptimized = zeros(length(streamInter.wtime), 3);
    CRightOptimized  = zeros(length(streamInter.wtime), 3);

    for idxFrame = 1:length(streamInter.wtime)
        img = frame_pressure_img(pressurePlantar2DInter, idxFrame);

        % M1/M5 固定为模板点（XY来自模板，Z先置0，后续再用滤波）
        M1LeftOptimized(idxFrame, :) = [M1LeftSumKinect, 0];
        M5LeftOptimized(idxFrame, :) = [M5LeftSumKinect, 0];
        M1RightOptimized(idxFrame, :) = [M1RightSumKinect, 0];
        M5RightOptimized(idxFrame, :) = [M5RightSumKinect, 0];

        posFootLeftKinect = posFootLeftSumKinect;
        posFootRightKinect = posFootRightSumKinect;

        % 若前脚掌不受力，退回到稳定模板
        if sum(img(labelsLeft == 1), 'all') < 5
            posFootLeftKinect = posFootLeftSumKinect;
        end
        if sum(img(labelsRight == 1), 'all') < 5
            posFootRightKinect = posFootRightSumKinect;
        end

        % 足跟不受力（离地段）：增加踝点高度并轻微前移
        if posAnkleLift(idxFrame) == 1
            hL = hSum + vzLeft(idxFrame);
            vyL = vzLeft(idxFrame) / 2;
            hR = hSum + vzRight(idxFrame);
            vyR = vzRight(idxFrame) / 2;
        else
            hL = hSum; vyL = 0;
            hR = hSum; vyR = 0;
        end

        posFootLeftOptimized(idxFrame, :) = [posFootLeftKinect, 0];
        posAnkleLeftOptimized(idxFrame, :) = [CLeftSumKinect(1), CLeftSumKinect(2) + vyL, hL];
        CLeftOptimized(idxFrame, :) = [CLeftSumKinect(1), CLeftSumKinect(2) + vyL, hL - hSum];

        posFootRightOptimized(idxFrame, :) = [posFootRightKinect, 0];
        posAnkleRightOptimized(idxFrame, :) = [CRightSumKinect(1), CRightSumKinect(2) + vyR, hR];
        CRightOptimized(idxFrame, :) = [CRightSumKinect(1), CRightSumKinect(2) + vyR, hR - hSum];
    end

    % ---- 低通滤波并写入 streamInterOptimized ----
    Fs = 50; Fc = 6; Wn = Fc/(Fs/2); n = 4;
    [b, a] = butter(n, Wn, 'low');
    funcFilterJoint = @(data) filtfilt(b, a, data);

    streamInterOptimized = streamInter;
    streamInterOptimized.ANKLE_LEFT.x = funcFilterJoint(posAnkleLeftOptimized(:, 1));
    streamInterOptimized.ANKLE_LEFT.y = funcFilterJoint(posAnkleLeftOptimized(:, 2));
    streamInterOptimized.ANKLE_LEFT.z = funcFilterJoint(posAnkleLeftOptimized(:, 3));
    streamInterOptimized.FOOT_LEFT.x = funcFilterJoint(posFootLeftOptimized(:, 1));
    streamInterOptimized.FOOT_LEFT.y = funcFilterJoint(posFootLeftOptimized(:, 2));
    streamInterOptimized.FOOT_LEFT.z = funcFilterJoint(posFootLeftOptimized(:, 3));

    streamInterOptimized.ANKLE_RIGHT.x = funcFilterJoint(posAnkleRightOptimized(:, 1));
    streamInterOptimized.ANKLE_RIGHT.y = funcFilterJoint(posAnkleRightOptimized(:, 2));
    streamInterOptimized.ANKLE_RIGHT.z = funcFilterJoint(posAnkleRightOptimized(:, 3));
    streamInterOptimized.FOOT_RIGHT.x = funcFilterJoint(posFootRightOptimized(:, 1));
    streamInterOptimized.FOOT_RIGHT.y = funcFilterJoint(posFootRightOptimized(:, 2));
    streamInterOptimized.FOOT_RIGHT.z = funcFilterJoint(posFootRightOptimized(:, 3));

    % 追加阵列点（便于 jointsPick 输出）
    streamInterOptimized.M1_LEFT.x = funcFilterJoint(M1LeftOptimized(:, 1));
    streamInterOptimized.M1_LEFT.y = funcFilterJoint(M1LeftOptimized(:, 2));
    streamInterOptimized.M1_LEFT.z = funcFilterJoint(M1LeftOptimized(:, 3));
    streamInterOptimized.M5_LEFT.x = funcFilterJoint(M5LeftOptimized(:, 1));
    streamInterOptimized.M5_LEFT.y = funcFilterJoint(M5LeftOptimized(:, 2));
    streamInterOptimized.M5_LEFT.z = funcFilterJoint(M5LeftOptimized(:, 3));

    streamInterOptimized.M1_RIGHT.x = funcFilterJoint(M1RightOptimized(:, 1));
    streamInterOptimized.M1_RIGHT.y = funcFilterJoint(M1RightOptimized(:, 2));
    streamInterOptimized.M1_RIGHT.z = funcFilterJoint(M1RightOptimized(:, 3));
    streamInterOptimized.M5_RIGHT.x = funcFilterJoint(M5RightOptimized(:, 1));
    streamInterOptimized.M5_RIGHT.y = funcFilterJoint(M5RightOptimized(:, 2));
    streamInterOptimized.M5_RIGHT.z = funcFilterJoint(M5RightOptimized(:, 3));

    streamInterOptimized.C_LEFT.x = funcFilterJoint(CLeftOptimized(:, 1));
    streamInterOptimized.C_LEFT.y = funcFilterJoint(CLeftOptimized(:, 2));
    streamInterOptimized.C_LEFT.z = funcFilterJoint(CLeftOptimized(:, 3));
    streamInterOptimized.C_RIGHT.x = funcFilterJoint(CRightOptimized(:, 1));
    streamInterOptimized.C_RIGHT.y = funcFilterJoint(CRightOptimized(:, 2));
    streamInterOptimized.C_RIGHT.z = funcFilterJoint(CRightOptimized(:, 3));

    % 与 GRFTest 一致：修正 x 偏移（让下肢质心与足部中心对齐）
    aux = mean((streamInterOptimized.KNEE_LEFT.x + streamInterOptimized.KNEE_RIGHT.x + streamInterOptimized.HIP_LEFT.x + streamInterOptimized.HIP_RIGHT.x) ./ 4) - ...
        mean((streamInterOptimized.ANKLE_LEFT.x + streamInterOptimized.ANKLE_RIGHT.x + streamInterOptimized.FOOT_LEFT.x + streamInterOptimized.FOOT_RIGHT.x) ./ 4);

    streamInterOptimized.ANKLE_LEFT.x = streamInterOptimized.ANKLE_LEFT.x + aux;
    streamInterOptimized.ANKLE_RIGHT.x = streamInterOptimized.ANKLE_RIGHT.x + aux;
    streamInterOptimized.FOOT_LEFT.x = streamInterOptimized.FOOT_LEFT.x + aux;
    streamInterOptimized.FOOT_RIGHT.x = streamInterOptimized.FOOT_RIGHT.x + aux;
    streamInterOptimized.M1_LEFT.x = streamInterOptimized.M1_LEFT.x + aux;
    streamInterOptimized.M5_LEFT.x = streamInterOptimized.M5_LEFT.x + aux;
    streamInterOptimized.M1_RIGHT.x = streamInterOptimized.M1_RIGHT.x + aux;
    streamInterOptimized.M5_RIGHT.x = streamInterOptimized.M5_RIGHT.x + aux;
    streamInterOptimized.C_LEFT.x = streamInterOptimized.C_LEFT.x + aux;
    streamInterOptimized.C_RIGHT.x = streamInterOptimized.C_RIGHT.x + aux;

    % ===== 最优化 Knee（生成 KNEE_LEFT2 / KNEE_RIGHT2）=====
    options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', 'Display', 'none');
    posKneeLeftOptimized = [streamInterOptimized.KNEE_LEFT.x, streamInterOptimized.KNEE_LEFT.y, streamInterOptimized.KNEE_LEFT.z];
    posKneeRightOptimized = [streamInterOptimized.KNEE_RIGHT.x, streamInterOptimized.KNEE_RIGHT.y, streamInterOptimized.KNEE_RIGHT.z];

    for i = 1+10:length(streamInterOptimized.wtime)-10
        % left
        posAnkle = [streamInterOptimized.ANKLE_LEFT.x(i), streamInterOptimized.ANKLE_LEFT.y(i), streamInterOptimized.ANKLE_LEFT.z(i)];
        posKnee  = [streamInterOptimized.KNEE_LEFT.x(i),  streamInterOptimized.KNEE_LEFT.y(i),  streamInterOptimized.KNEE_LEFT.z(i)];
        posThigh = [streamInterOptimized.HIP_LEFT.x(i),   streamInterOptimized.HIP_LEFT.y(i),   streamInterOptimized.HIP_LEFT.z(i)];
        posKneeTrail1 = [streamInterOptimized.KNEE_LEFT.x(i-10), streamInterOptimized.KNEE_LEFT.y(i-10), streamInterOptimized.KNEE_LEFT.z(i-10)];
        posKneeTrail2 = [streamInterOptimized.KNEE_LEFT.x(i+10), streamInterOptimized.KNEE_LEFT.y(i+10), streamInterOptimized.KNEE_LEFT.z(i+10)];
        try
            aux = fminunc(@(params) KneePosOptimization(params, lenThigh, lenShank, posThigh, posKnee, posAnkle, posKneeTrail1, posKneeTrail2), posKnee, options);
            posKneeLeftOptimized(i,:) = aux;
        catch
            % fallback: keep original knee
            posKneeLeftOptimized(i,:) = posKnee;
        end

        % right
        posAnkle = [streamInterOptimized.ANKLE_RIGHT.x(i), streamInterOptimized.ANKLE_RIGHT.y(i), streamInterOptimized.ANKLE_RIGHT.z(i)];
        posKnee  = [streamInterOptimized.KNEE_RIGHT.x(i),  streamInterOptimized.KNEE_RIGHT.y(i),  streamInterOptimized.KNEE_RIGHT.z(i)];
        posThigh = [streamInterOptimized.HIP_RIGHT.x(i),   streamInterOptimized.HIP_RIGHT.y(i),   streamInterOptimized.HIP_RIGHT.z(i)];
        posKneeTrail1 = [streamInterOptimized.KNEE_RIGHT.x(i-10), streamInterOptimized.KNEE_RIGHT.y(i-10), streamInterOptimized.KNEE_RIGHT.z(i-10)];
        posKneeTrail2 = [streamInterOptimized.KNEE_RIGHT.x(i+10), streamInterOptimized.KNEE_RIGHT.y(i+10), streamInterOptimized.KNEE_RIGHT.z(i+10)];
        try
            aux = fminunc(@(params) KneePosOptimization(params, lenThigh, lenShank, posThigh, posKnee, posAnkle, posKneeTrail1, posKneeTrail2), posKnee, options);
            posKneeRightOptimized(i,:) = aux;
        catch
            posKneeRightOptimized(i,:) = posKnee;
        end
    end

    streamInterOptimized.KNEE_LEFT2.x = funcFilterJoint(posKneeLeftOptimized(:,1));
    streamInterOptimized.KNEE_LEFT2.y = funcFilterJoint(posKneeLeftOptimized(:,2));
    streamInterOptimized.KNEE_LEFT2.z = funcFilterJoint(posKneeLeftOptimized(:,3));
    streamInterOptimized.KNEE_RIGHT2.x = funcFilterJoint(posKneeRightOptimized(:,1));
    streamInterOptimized.KNEE_RIGHT2.y = funcFilterJoint(posKneeRightOptimized(:,2));
    streamInterOptimized.KNEE_RIGHT2.z = funcFilterJoint(posKneeRightOptimized(:,3));
end

function img = frame_pressure_img(P, idxFrame)
    if isempty(P)
        img = zeros(32, 32);
        return;
    end
    if ndims(P) == 3
        img = squeeze(P(idxFrame, :, :));
    else
        img = reshape(P(idxFrame, :), 32, 32);
    end
end

function imgSum = sum_pressure_img(P)
    if isempty(P)
        imgSum = zeros(32, 32);
        return;
    end
    if ndims(P) == 3
        imgSum = squeeze(sum(P, 1));
    else
        imgSum = reshape(sum(P, 1), 32, 32);
    end
end

%% ===== 从 ViconTest 移植的足底模板/分区函数（去除绘图副作用）=====
function [imgLeft, imgRight] = GetImgsLR(imgPlantarSum)
    pts = createPts(imgPlantarSum, ceil(max(imgPlantarSum(:))/100));
    labels = dbscanLabels(pts);
    ctrsPts = getCtrsPts(pts, labels);
    aux = [10*ctrsPts(:,1), ctrsPts(:,2)];
    [idxFoot, ctrsFoot] = kmeans(aux, 2);
    if ctrsFoot(1,1) > ctrsFoot(2,1)
        idxFoot = 3 - idxFoot;
    end
    labelsFoot = idxFoot(labels);
    rectx = zeros(2,5); recty = zeros(2,5);
    for i = 1:2
        [rectx(i,:), recty(i,:), ~, ~] = minboundrect(pts(labelsFoot==i,1), pts(labelsFoot==i,2));
    end
    [rectx, recty] = sortRect(rectx, recty);
    aux = zeros(size(imgPlantarSum));
    aux(max(1,(33-ceil(max(recty(1,:))))):min(32,(33-floor(min(recty(1,:))))), max(1,floor(min(rectx(1,:)))):min(32,ceil(max(rectx(1,:))))) = 1;
    imgLeft = imgPlantarSum .* aux;
    aux = zeros(size(imgPlantarSum));
    aux(max(1,(33-ceil(max(recty(2,:))))):min(32,(33-floor(min(recty(2,:))))), max(1,floor(min(rectx(2,:)))):min(32,ceil(max(rectx(2,:))))) = 1;
    imgRight = imgPlantarSum .* aux;
end

function [imgTemplates] = GetImgTemplate(img, lr)
    angles = -45:5:45;
    cellImgs = cell(length(angles), 1);
    for i = 1:length(angles)
        aux = imrotate(img, angles(i), 'bicubic', 'crop');
        if max(aux(:)) > 0
            cellImgs{i} = aux ./ max(aux(:));
        else
            cellImgs{i} = aux;
        end
    end

    bestMatch = 0;
    bestParas = [1,1];
    for l = 1:17
        plantarTemplate = CreatePlantarTemplate(l, lr);
        for i = 1:length(cellImgs)
            aux = conv2(cellImgs{i}, rot90(plantarTemplate.template,2), 'full');
            if max(aux(:)) > bestMatch
                bestMatch = max(aux(:));
                bestParas = [i, l];
            end
        end
    end

    imgTemplate = cellImgs{bestParas(1)};
    l = bestParas(2);
    plantarTemplate = CreatePlantarTemplate(l, lr);

    aux = conv2(imgTemplate, rot90(plantarTemplate.template,2), 'full');
    [x, y] = find(aux == max(aux(:)), 1);
    x = x - 32 + 1; y = y - 32 + 1;
    rectTemplate = plantarTemplate.rect + [x, y] - [1, 1];
    rectTemplate = min(max(rectTemplate, 1), 32);

    imgTemplateShape = imgTemplate;
    imgTemplateShape(imgTemplateShape <= 0) = 0;
    imgTemplateShape(imgTemplateShape > 0) = 1;

    imgTemplateM = zeros(32,32);
    for i = min(rectTemplate(:,1)):min(rectTemplate(:,1))+6
        for j = max([1,min(rectTemplate(:,2))]):min([32,max(rectTemplate(:,2))])
            imgTemplateM(i,j) = 1;
        end
    end
    imgTemplateShapeM = imgTemplateM .* imgTemplateShape;
    imgTemplateM = imgTemplateM .* imgTemplate;

    imgTemplateC = zeros(32,32);
    for i = floor(mean(rectTemplate(:,1))):max(rectTemplate(:,1))
        for j = max([1,min(rectTemplate(:,2))]):min([32,max(rectTemplate(:,2))])
            imgTemplateC(i,j) = 1;
        end
    end
    imgTemplateShapeC = imgTemplateC .* imgTemplateShape;
    imgTemplateC = imgTemplateC .* imgTemplate;

    imgTemplateL = zeros(32,32);
    for i = min(rectTemplate(:,1))+6:floor(mean(rectTemplate(:,1)))
        for j = max([1,min(rectTemplate(:,2))]):min([32,max(rectTemplate(:,2))])
            imgTemplateL(i,j) = 1;
        end
    end
    imgTemplateShapeL = imgTemplateL .* imgTemplateShape;
    imgTemplateL = imgTemplateL .* imgTemplate;

    % M1/M5
    imgTemplateML = zeros(32,32);
    for i = min(rectTemplate(:,1)):floor(mean(rectTemplate(:,1)))
        for j = max([1,min(rectTemplate(:,2))]):min([32,max(rectTemplate(:,2))])
            imgTemplateML(i,j) = 1;
        end
    end
    imgTemplateML = imgTemplateML .* imgTemplate;
    [~, lineM] = max(sum(imgTemplateML,2));
    for i = 1:32
        if imgTemplateML(lineM,i) > 0.1*max(imgTemplate(:)), break; end
    end
    M5 = [lineM, i];
    for i = 32:-1:1
        if imgTemplateML(lineM,i) > 0.1*max(imgTemplate(:)), break; end
    end
    M1 = [lineM, i];
    if lr == 'r'
        aux = M1; M1 = M5; M5 = aux;
    end

    [i, j] = find(imgTemplateC == max(imgTemplateC(:)), 1);
    C = [i, j];

    imgTemplates.l = l;
    imgTemplates.imgTemplate = imgTemplate;
    imgTemplates.imgTemplateM = imgTemplateM;
    imgTemplates.imgTemplateC = imgTemplateC;
    imgTemplates.imgTemplateL = imgTemplateL;
    imgTemplates.rectTemplate = rectTemplate;
    imgTemplates.imgTemplateShape = imgTemplateShape;
    imgTemplates.imgTemplateShapeM = imgTemplateShapeM;
    imgTemplates.imgTemplateShapeC = imgTemplateShapeC;
    imgTemplates.imgTemplateShapeL = imgTemplateShapeL;
    imgTemplates.M1 = M1;
    imgTemplates.M5 = M5;
    imgTemplates.C = C;
end

function [hasPlantar, rect, M1, M5, C] = GetRectInImg(img, imgTemplates, lr)
    numPtsMax = nnz(imgTemplates.imgTemplate > 0);
    hasPlantar = true;
    angles = -45:5:45;

    if lr == 'l'
        img(:,17:32) = 0;
    else
        img(:,1:16) = 0;
    end

    numPts = nnz(img > 0);
    if numPts < 10
        rect = zeros(4,2);
        hasPlantar = false;
        M1 = [nan,nan]; M5 = [nan,nan]; C = [nan,nan];
        return;
    elseif numPts < numPtsMax*0.6
        imgTemplate = imgTemplates.imgTemplateM;
        imgTemplateShape = imgTemplates.imgTemplateShapeM;
    else
        imgTemplate = imgTemplates.imgTemplate;
        imgTemplateShape = imgTemplates.imgTemplateShape;
    end

    bestMatch = 0;
    rotAngle = 0;
    for i = 1:length(angles)
        aux = imrotate(img, angles(i), 'bicubic', 'crop');
        if max(aux(:)) > 0, aux = aux ./ max(aux(:)); end
        aux2 = conv2(aux, rot90(imgTemplate,2), 'full');
        if max(aux2(:)) > bestMatch
            bestMatch = max(aux2(:));
            rotAngle = angles(i);
        end
    end

    aux = conv2(imrotate(img, rotAngle, 'bicubic', 'crop'), rot90(imgTemplate,2), 'full');
    [x, y] = find(aux == max(aux(:)), 1);
    x = x - 32 + 1; y = y - 32 + 1;
    rect_r = imgTemplates.rectTemplate + [x, y] - [1, 1];

    sumOut = 0;
    for i = 1:32
        for j = 1:32
            if i < min(rect_r(:,1)) || i > max(rect_r(:,1)) || j < min(rect_r(:,2)) || j > max(rect_r(:,2))
                sumOut = sumOut + img(i,j);
            end
        end
    end
    if sumOut > 1000
        bestMatch = 0;
        for i = 1:length(angles)
            aux = imrotate(img, angles(i), 'bicubic', 'crop');
            if max(aux(:)) > 0, aux = aux ./ max(aux(:)); end
            aux2 = conv2(aux, rot90(imgTemplateShape,2), 'full');
            if max(aux2(:)) > bestMatch
                bestMatch = max(aux2(:));
                rotAngle = angles(i);
            end
        end
        aux = conv2(imrotate(img, rotAngle, 'bicubic', 'crop'), rot90(imgTemplateShape,2), 'full');
        [x, y] = find(aux == max(aux(:)), 1);
        x = x - 32 + 1; y = y - 32 + 1;
        rect_r = imgTemplates.rectTemplate + [x, y] - [1, 1];
    end

    rect = RotateRect(rect_r, [16.5,16.5], rotAngle);

    M1_r = imgTemplates.M1 + [x, y] - [1, 1];
    M5_r = imgTemplates.M5 + [x, y] - [1, 1];
    C_r  = imgTemplates.C  + [x, y] - [1, 1];
    M1 = RotatePt(M1_r, [16.5,16.5], rotAngle);
    M5 = RotatePt(M5_r, [16.5,16.5], rotAngle);
    C  = RotatePt(C_r,  [16.5,16.5], rotAngle);

    if lr == 'r'
        rect = rect(4:-1:1,:);
    end
end

function [partitionTemplate, labelsTemplate] = GetPartitionHalf(rect, ~)
    ptsPlantar(1,:) = (rect(1,:) - rect(2,:))./2 + rect(2,:);
    ptsPlantar(2,:) = (rect(4,:) - rect(3,:))./2 + rect(3,:);

    partitionTemplate.sumM = GetRectTemplate([rect(1,:); ptsPlantar(1,:); ptsPlantar(2,:); rect(4,:)]);
    partitionTemplate.sumC = GetRectTemplate([ptsPlantar(1,:); rect(2,:); rect(3,:); ptsPlantar(2,:)]);

    labelsTemplate = zeros(32,32);
    labelsTemplate(partitionTemplate.sumM >= 0.5) = 1;
    labelsTemplate(partitionTemplate.sumC >= 0.5) = 2;

end

function template = GetRectTemplate(rect)
    template = zeros(32,32);
    for i = 1:32
        for j = 1:32
            rect_i = [i-0.5,j-0.5; i+0.5,j-0.5; i+0.5,j+0.5; i-0.5,j+0.5];
            flagInRect = true;
            for k = 1:4
                pt = rect_i(k,:);
                flagInRect = flagInRect & IsPointInsidePolygon(pt(1), pt(2), rect); %#ok<AGROW>
            end
            if flagInRect
                template(i,j) = 1;
            else
                template(i,j) = CalIntersectionArea(rect_i, rect);
            end
        end
    end
end

function posAnkleLift = GetSegAnkleLift(streamInter, pressurePlantar2DInter, labels)
    posAnkleLift = zeros(length(streamInter.wtime), 1);
    for idxFrame = 1:length(streamInter.wtime)
        img = frame_pressure_img(pressurePlantar2DInter, idxFrame);
        if sum(img(labels == 2), 'all') < 5
            posAnkleLift(idxFrame) = 1;
        end
    end
    for idxFrame = 1:length(streamInter.wtime)-6
        if posAnkleLift(idxFrame) + posAnkleLift(idxFrame+6) == 2
            posAnkleLift(idxFrame:idxFrame+6) = 1;
        end
    end
    startsLeft = intersect(find(posAnkleLift(2:end)==1), find(posAnkleLift(1:end)==0)) + 1;
    endsLeft = intersect(find(posAnkleLift==1), find(posAnkleLift(2:end)==0));
    if isempty(startsLeft) || isempty(endsLeft)
        posAnkleLift = zeros(length(streamInter.wtime), 1);
        return;
    end
    if startsLeft(1) > endsLeft(1), endsLeft(1) = []; end
    if ~isempty(startsLeft) && ~isempty(endsLeft) && startsLeft(end) > endsLeft(end), startsLeft(end) = []; end

    pos2 = zeros(length(streamInter.wtime), 1);
    for i = 1:min(length(startsLeft), length(endsLeft))
        if endsLeft(i) - startsLeft(i) < 10, continue; end
        aux = streamInter.ANKLE_LEFT.z(startsLeft(i):endsLeft(i));
        pks = findpeaks(aux);
        if ~isempty(pks) && max(pks) - min(aux) > 0.03
            pos2(startsLeft(i):endsLeft(i)) = 1;
        end
    end
    posAnkleLift = pos2;
end

function pts = createPts(img, th)
    imgBi = zeros(size(img));
    imgBi(img > th) = 1;
    bOpen = [1,1];
    imgBi = imerode(imgBi, bOpen);
    imgBi = imdilate(imgBi, bOpen);
    imgBi(1,:)=0; imgBi(32,:)=0; imgBi(:,1)=0; imgBi(:,32)=0;
    imgBi0 = zeros(32+4, 32+4);
    imgBi0(3:34, 3:34) = imgBi;
    for i = 1:32
        for j = 1:32
            if imgBi0(i+2,j+2) == 0 && img(i,j) > th && sum(sum(imgBi0(i:i+4,j:j+4))) >= 3
                imgBi(i,j) = 1;
            elseif imgBi0(i+2,j+2) == 1 && sum(sum(imgBi0(i:i+4,j:j+4))) < 3
                imgBi(i,j) = 0;
            end
        end
    end
    [pts(:,2), pts(:,1)] = find(imgBi == 1);
    pts(:,2) = 33 - pts(:,2);
end

function labels = dbscanLabels(pts)
    minPts = 5; eps = 3;
    labels = dbscan(pts, eps, minPts);
    numParts = max(labels);
    for i = 1:size(labels,1)
        if labels(i) == -1
            labels(i) = numParts + 1;
            numParts = numParts + 1;
        end
    end
    if max(labels) == min(labels)
        aux = mean(pts, 1); aux = aux(1);
        for i = 1:size(pts,1)
            if pts(i,1) <= aux
                labels(i) = 1;
            else
                labels(i) = 2;
            end
        end
    end
end

function ctrsPts = getCtrsPts(pts, labels)
    labelsImg = zeros(32,32);
    for i = 1:size(pts,1)
        labelsImg(pts(i,2), pts(i,1)) = labels(i);
    end
    stat = regionprops(labelsImg, 'centroid');
    ctrsPts = zeros(numel(stat), 2);
    for i = 1:numel(stat)
        ctrsPts(i,:) = [stat(i).Centroid(1), stat(i).Centroid(2)];
    end
end

function [rectx, recty, area, perimeter] = minboundrect(x, y, metric)
% minboundrect (John D'Errico) - 原实现移植
    if (nargin < 3) || isempty(metric)
        metric = 'a';
    elseif ~ischar(metric)
        error('metric must be a character flag if it is supplied.');
    else
        metric = lower(metric(:)');
        ind = strmatch(metric, {'area','perimeter'}); %#ok<STRCLFH>
        if isempty(ind)
            error('metric does not match either ''area'' or ''perimeter''');
        end
        metric = metric(1);
    end

    x = x(:); y = y(:);
    n = length(x);
    if n ~= length(y), error('x and y must be the same sizes'); end

    if n > 3
        edges = convhull(x, y);
        x = x(edges); y = y(edges);
        nedges = length(x) - 1;
    elseif n > 1
        nedges = n;
        x(end+1) = x(1); y(end+1) = y(1);
    else
        nedges = n;
    end

    switch nedges
        case 0
            rectx = []; recty = []; area = []; perimeter = []; return;
        case 1
            rectx = repmat(x, 1, 5); recty = repmat(y, 1, 5); area = 0; perimeter = 0; return;
        case 2
            rectx = x([1 2 2 1 1]); recty = y([1 2 2 1 1]); area = 0;
            perimeter = 2*sqrt(diff(x).^2 + diff(y).^2); return;
    end

    Rmat = @(theta) [cos(theta) sin(theta); -sin(theta) cos(theta)];
    ind = 1:(length(x)-1);
    edgeangles = atan2(y(ind+1) - y(ind), x(ind+1) - x(ind));
    edgeangles = unique(mod(edgeangles, pi/2));

    nang = length(edgeangles);
    area = inf; perimeter = inf; met = inf;
    xy = [x, y];
    for i = 1:nang
        rot = Rmat(-edgeangles(i));
        xyr = xy * rot;
        xymin = min(xyr, [], 1);
        xymax = max(xyr, [], 1);
        A_i = prod(xymax - xymin);
        P_i = 2*sum(xymax - xymin);
        if metric == 'a'
            M_i = A_i;
        else
            M_i = P_i;
        end
        if M_i < met
            met = M_i; area = A_i; perimeter = P_i;
            rect = [xymin; [xymax(1),xymin(2)]; xymax; [xymin(1),xymax(2)]; xymin];
            rect = rect * rot';
            rectx = rect(:,1);
            recty = rect(:,2);
        end
    end
end

function [rectx, recty] = sortRect(rectx, recty)
    for i = 1:2
        rx = rectx(i,1:4); ry = recty(i,1:4);
        [~, idx] = max(rx + ry);
        if idx > 1
            rx = [rx(:,idx:end), rx(:,1:idx-1)];
            ry = [ry(:,idx:end), ry(:,1:idx-1)];
        end
        rectx(i,1:4) = rx; rectx(i,5) = rectx(i,1);
        recty(i,1:4) = ry; recty(i,5) = recty(i,1);
    end
end

function plantarTemplate = CreatePlantarTemplate(l, lr)
    template = zeros(32,32);
    a = 30; b = 3;
    template(a-6:a-1, b+1:b+5) = 1;
    template(a-5:a-2, b+2:b+4) = 3;
    template(a-6-l:a-7, b+1:b+4) = 1;
    template(a-6-l-4:a-6-l-1, b+1:b+6) = 1;
    template(a-6-l-4:a-6-l-1, b+2:b+4) = 3;

    a2 = max(1, a-6-l-4-4); b2 = b+9;
    rect = [a2,b; a,b; a,b2; a2,b2];
    if lr == 'r'
        template = template(:, 32:-1:1);
        rect(:,2) = 33 - rect(:,2);
    end
    plantarTemplate.template = template;
    plantarTemplate.rect = rect;
end

function new_rect = RotateRect(rect, origin, degree)
    R = [cosd(degree), sind(degree); -sind(degree), cosd(degree)];
    new_rect = zeros(size(rect));
    for i = 1:size(rect,1)
        offset = rect(i,:) - origin;
        rotated_offset = R * offset';
        new_rect(i,:) = rotated_offset' + origin;
    end
end

function new_pt = RotatePt(pt, origin, degree)
    R = [cosd(degree), sind(degree); -sind(degree), cosd(degree)];
    offset = pt - origin;
    rotated_offset = R * offset';
    new_pt = rotated_offset' + origin;
end

function inside = IsPointInsidePolygon(x, y, rect)
    crossProducts = zeros(1,4);
    for i = 1:4
        i1 = mod(i,4) + 1;
        x1 = rect(i,1); y1 = rect(i,2);
        x2 = rect(i1,1); y2 = rect(i1,2);
        crossProducts(i) = (x2-x1) * (y-y1) - (y2-y1) * (x-x1);
    end
    inside = all(crossProducts .* crossProducts(1) > 0);
end

function intersectionArea = CalIntersectionArea(rect1, rect2)
    [x1_min, x1_max, y1_min, y1_max] = GetBoundingBox(rect1);
    [x2_min, x2_max, y2_min, y2_max] = GetBoundingBox(rect2);

    if x1_max < x2_min || x2_max < x1_min || y1_max < y2_min || y2_max < y1_min
        intersectionArea = 0;
        return;
    end

    intersectionXMin = max(x1_min, x2_min);
    intersectionXMax = min(x1_max, x2_max);
    intersectionYMin = max(y1_min, y2_min);
    intersectionYMax = min(y1_max, y2_max);

    if intersectionXMin < intersectionXMax && intersectionYMin < intersectionYMax
        numPoints = 3000;
        points = rand(numPoints, 2);
        points(:,1) = points(:,1) * (intersectionXMax - intersectionXMin) + intersectionXMin;
        points(:,2) = points(:,2) * (intersectionYMax - intersectionYMin) + intersectionYMin;
        pointsInRect1 = CountPointsInRect(points, rect1);
        pointsInRect2 = CountPointsInRect(points, rect2);
        pointsInIntersection = pointsInRect1 & pointsInRect2;
        intersectionArea = sum(pointsInIntersection) / numPoints * (intersectionXMax - intersectionXMin) * (intersectionYMax - intersectionYMin);
    else
        intersectionArea = 0;
    end
end

function [x_min, x_max, y_min, y_max] = GetBoundingBox(rect)
    x = rect(:,1); y = rect(:,2);
    x_min = min(x); x_max = max(x);
    y_min = min(y); y_max = max(y);
end

function pointsInRect = CountPointsInRect(points, rect)
    pointsInRect = false(size(points,1),1);
    for i = 1:length(pointsInRect)
        pointsInRect(i) = IsPointInsidePolygon(points(i,1), points(i,2), rect);
    end
end

