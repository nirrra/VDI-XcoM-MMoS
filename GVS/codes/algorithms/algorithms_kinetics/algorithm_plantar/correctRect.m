%% FUNC correctRect：对于长度相差过大的左右脚，重新调整
function [rectx, recty] = correctRect(rectx, recty, imgSum)

heightLeft = norm([rectx(1,1)-rectx(1,4),recty(1,1)-recty(1,4)]);
widthLeft = norm([rectx(1,1)-rectx(1,2),recty(1,1)-recty(1,2)]);
heightRight = norm([rectx(2,1)-rectx(2,4),recty(2,1)-recty(2,4)]);
widthRight = norm([rectx(2,1)-rectx(2,2),recty(2,1)-recty(2,2)]);
if abs(heightLeft-heightRight)>=2
%     disp(['重新调整rect，左脚',num2str(heightLeft),'；右脚',num2str(heightRight)]);
    if heightLeft>heightRight
        idxLong = 1;
        idxShort = 2;
        footRatio = heightLeft/heightRight;
    else
        idxLong = 2;
        idxShort = 1;
        footRatio = heightRight/heightLeft;
    end
    
    % 需要加长右脚（判定延长段点数是否大于阈值）或缩短左脚（根据前段或后段压力和）
    newRectx = rectx; newRecty = recty;
    newRectx(idxShort,1) = (rectx(idxShort,1)-rectx(idxShort,4))*footRatio+rectx(idxShort,4);
    newRecty(idxShort,1) = (recty(idxShort,1)-recty(idxShort,4))*footRatio+recty(idxShort,4);
    newRectx(idxShort,2) = (rectx(idxShort,2)-rectx(idxShort,3))*footRatio+rectx(idxShort,3);
    newRecty(idxShort,2) = (recty(idxShort,2)-recty(idxShort,3))*footRatio+recty(idxShort,3);
    rx = [newRectx(idxShort,1),newRectx(idxShort,2),rectx(idxShort,2),rectx(idxShort,1)];
    ry = [newRecty(idxShort,1),newRecty(idxShort,2),recty(idxShort,2),recty(idxShort,1)];
    cnt = 0;
    for i = 1:32
        for j = 1:32
            if inRect([i,j],rx,ry) && imgSum(33-j,i)>ceil(max(max(imgSum))/100)
                cnt = cnt+1;
            end
        end
    end
    if cnt>=2 % 加长区域点数大于阈值，加长短脚
        rectx = newRectx; recty = newRecty;
    else % 缩短长脚
        newRectxFore = rectx; newRectyFore = recty;
        newRectxFore(idxLong,1) = (rectx(idxLong,1)-rectx(idxLong,4))/footRatio+rectx(idxLong,4);
        newRectyFore(idxLong,1) = (recty(idxLong,1)-recty(idxLong,4))/footRatio+recty(idxLong,4);
        newRectxFore(idxLong,2) = (rectx(idxLong,2)-rectx(idxLong,3))/footRatio+rectx(idxLong,3);
        newRectyFore(idxLong,2) = (recty(idxLong,2)-recty(idxLong,3))/footRatio+recty(idxLong,3);
        rx = [rectx(idxLong,1),rectx(idxLong,2),newRectxFore(idxLong,2),newRectxFore(idxLong,1)];
        ry = [recty(idxLong,1),recty(idxLong,2),newRectyFore(idxLong,2),newRectyFore(idxLong,1)];
        pSumFore = 0;
        for i = 1:32
            for j = 1:32
                if inRect([i,j],rx,ry)
                    pSumFore = pSumFore + imgSum(33-j,i);
                end
            end
        end
        newRectxBack = rectx; newRectyBack = recty;
        newRectxBack(idxLong,3) = (rectx(idxLong,3)-rectx(idxLong,2))/footRatio+rectx(idxLong,2);
        newRectyBack(idxLong,3) = (recty(idxLong,3)-recty(idxLong,2))/footRatio+recty(idxLong,2);
        newRectxBack(idxLong,4) = (rectx(idxLong,4)-rectx(idxLong,1))/footRatio+rectx(idxLong,1);
        newRectyBack(idxLong,4) = (recty(idxLong,4)-recty(idxLong,1))/footRatio+recty(idxLong,1);
        rx = [newRectxBack(idxLong,4),newRectxBack(idxLong,3),rectx(idxLong,3),rectx(idxLong,4)];
        ry = [newRectyBack(idxLong,4),newRectyBack(idxLong,3),recty(idxLong,3),recty(idxLong,4)];
        pSumBack = 0;
        for i = 1:32
            for j = 1:32
                if inRect([i,j],rx,ry)
                    pSumBack = pSumBack + imgSum(33-j,i);
                end
            end
        end
        if pSumFore>pSumBack % 比较前后部分，舍去压力和小的部分
            rectx = newRectxBack; recty = newRectyBack;
        else
            rectx = newRectxFore; recty = newRectyFore;
        end
        
        % 计算足跟位置
        posHeel = zeros(2,2);
        for idxFoot = 1:2
            rx = rectx(idxFoot,1:4); ry = recty(idxFoot,1:4);
            rx(1) = (rx(1)-rx(4))*0.4+rx(4);
            rx(2) = (rx(2)-rx(3))*0.4+rx(3);
            ry(1) = (ry(1)-ry(4))*0.4+ry(4);
            ry(2) = (ry(2)-ry(3))*0.4+ry(3);
            maxNum = 0;
            for i = 1:31
                for j = 1:31
                    aux = imgSum(33-j,i)+imgSum(33-j-1,i)+imgSum(33-j,i+1)+imgSum(33-j-1,i+1);
                    if aux>maxNum
                        maxNum = aux;
                        posHeel(idxFoot,:) = [i+0.5,j+0.5];
                    end
                end
            end
        end
        % 舍去Long脚方框一部分后，若两脚足跟距下线距离相差过大，移动Long脚方框
        disHeel = zeros(2,1);
        disHeel(1) = norm(cross([rectx(1,3)-rectx(1,4),recty(1,3)-recty(1,4),1],[posHeel(1,1)-rectx(1,4),posHeel(1,2)-recty(1,4),1]))...
            /norm([rectx(1,3)-rectx(1,4),recty(1,3)-recty(1,4),0]);
        disHeel(2) = norm(cross([rectx(2,3)-rectx(2,4),recty(2,3)-recty(2,4),1],[posHeel(2,1)-rectx(2,4),posHeel(2,2)-recty(2,4),1]))...
            /norm([rectx(2,3)-rectx(2,4),recty(2,3)-recty(2,4),0]);
%         disp(['左脚足跟距离：',num2str(disHeel(1)),'；右脚足跟距离：',num2str(disHeel(2))]);
        if abs(disHeel(1)-disHeel(2))>=1
            movRatio = (disHeel(idxLong)-disHeel(idxShort))/norm([rectx(idxLong,1)-rectx(idxLong,4),recty(idxLong,1)-recty(idxLong,4)]);
            movx = movRatio*(rectx(idxLong,1)-rectx(idxLong,4));
            movy = movRatio*(recty(idxLong,1)-recty(idxLong,4));
            rectx(idxLong,:) = rectx(idxLong,:)+movx;
            recty(idxLong,:) = recty(idxLong,:)+movy;
        end
    end
    
    rectx(:,5) = rectx(:,1); recty(:,5) = recty(:,1);
end

end