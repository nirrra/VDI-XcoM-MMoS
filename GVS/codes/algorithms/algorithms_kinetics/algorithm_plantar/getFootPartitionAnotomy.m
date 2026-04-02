%% FUNC getFootPartitionAnotomy：单足按照解剖结构区分
% 1-6: D1, MTK1, MTK2-4, MTK5, L, C
function [labelsFootParts, ptsParts, linex, liney] = getFootPartitionAnotomy(pts, rectx, recty, labelsFoot)
    ptsParts = cell(2,6);
    labelsFootParts = zeros(size(pts,1),1);
    linex = zeros(2,20); liney = zeros(2,20);
    linex(:,1:5) = rectx; liney(:,1:5) = recty;
    for i = 1:2
        rx = rectx(i,1:4); ry = recty(i,1:4);
        %pt1-6 从左到右，从上到下
        pt1 = [8/9*(rx(2)-rx(3))+rx(3), 8/9*(ry(2)-ry(3))+ry(3)];
        pt2 = [8/9*(rx(1)-rx(4))+rx(4), 8/9*(ry(1)-ry(4))+ry(4)];
        pt3 = [5/9*(rx(2)-rx(3))+rx(3), 5/9*(ry(2)-ry(3))+ry(3)];
        pt4 = [5/9*(rx(1)-rx(4))+rx(4), 5/9*(ry(1)-ry(4))+ry(4)];
        pt5 = [3/9*(rx(2)-rx(3))+rx(3), 3/9*(ry(2)-ry(3))+ry(3)];
        pt6 = [3/9*(rx(1)-rx(4))+rx(4), 3/9*(ry(1)-ry(4))+ry(4)];
        
        rx1 = rx; ry1 = ry; rx2 = rx; ry2 = ry; rx3 = rx; ry3 = ry; 
        rx4 = rx; ry4 = ry; rx5 = rx; ry5 = ry; rx6 = rx; ry6 = ry; 
        
        rx1(3) = pt1(1); ry1(3) = pt1(2);
        rx1(4) = pt2(1); ry1(4) = pt2(2);
        
        rx2(1) = (pt2(1)-pt1(1))/3+pt1(1); ry2(1) = (pt2(2)-pt1(2))/3+pt1(2);
        rx2(2) = pt1(1); ry2(2) = pt1(2);
        rx2(3) = pt3(1); ry2(3) = pt3(2);
        rx2(4) = (pt4(1)-pt3(1))/3+pt3(1); ry2(4) = (pt4(2)-pt3(2))/3+pt3(2);
        
        rx3(1) = (pt2(1)-pt1(1))*2/3+pt1(1); ry3(1) = (pt2(2)-pt1(2))*2/3+pt1(2);
        rx3(2) = (pt2(1)-pt1(1))/3+pt1(1); ry3(2) = (pt2(2)-pt1(2))/3+pt1(2);
        rx3(3) = (pt4(1)-pt3(1))/3+pt3(1); ry3(3) = (pt4(2)-pt3(2))/3+pt3(2);
        rx3(4) = (pt4(1)-pt3(1))*2/3+pt3(1); ry3(4) = (pt4(2)-pt3(2))*2/3+pt3(2);
        
        rx4(1) = pt2(1); ry4(1) = pt2(2);
        rx4(2) = (pt2(1)-pt1(1))*2/3+pt1(1); ry4(2) = (pt2(2)-pt1(2))*2/3+pt1(2);
        rx4(3) = (pt4(1)-pt3(1))*2/3+pt3(1); ry4(3) = (pt4(2)-pt3(2))*2/3+pt3(2);
        rx4(4) = pt4(1); ry4(4) = pt4(2);
        
        rx5(1) = pt4(1); ry5(1) = pt4(2);
        rx5(2) = pt3(1); ry5(2) = pt3(2);
        rx5(3) = pt5(1); ry5(3) = pt5(2);
        rx5(4) = pt6(1); ry5(4) = pt6(2);
        
        rx6(1) = pt6(1); ry6(1) = pt6(2);
        rx6(2) = pt5(1); ry6(2) = pt5(2);
        
        linex(i,6) = pt2(1); liney(i,6) = pt2(2);
        linex(i,7) = rx3(1); liney(i,7) = ry3(1);
        linex(i,8) = rx2(1); liney(i,8) = ry2(1);
        linex(i,9) = pt1(1); liney(i,9) = pt1(2);
        linex(i,10) = pt3(1); liney(i,10) = pt3(2);
        linex(i,11) = rx2(4); liney(i,11) = ry2(4);
        linex(i,12) = rx3(4); liney(i,12) = ry3(4);
        linex(i,13) = pt4(1); liney(i,13) = pt4(2);
        linex(i,14) = pt6(1); liney(i,14) = pt6(2);
        linex(i,15) = pt5(1); liney(i,15) = pt5(2);
        linex(i,16) = linex(i,10); liney(i,16) = liney(i,10);
        linex(i,17) = linex(i,11); liney(i,17) = liney(i,11);
        linex(i,18) = linex(i,8); liney(i,18) = liney(i,8);
        linex(i,19) = linex(i,7); liney(i,19) = liney(i,7);
        linex(i,20) = linex(i,12); liney(i,20) = liney(i,12);
        
        ptsFoot = pts(labelsFoot==i,:);
        for j = 1:size(ptsFoot,1)
            aux = ptsFoot(j,:);
            idxP =  find((pts(:,1)==aux(1)).*(pts(:,2)==aux(2)));
            if inRect(aux,rx1,ry1)
                ptsParts{i,1} = [ptsParts{i,1};aux];
                labelsFootParts(idxP) = (i-1)*size(ptsParts,2)+1;
            elseif inRect(aux,rx2,ry2)
                ptsParts{i,6-2*i} = [ptsParts{i,6-2*i};aux];
                labelsFootParts(idxP) = (i-1)*size(ptsParts,2)+6-2*i;
            elseif inRect(aux,rx4,ry4)
                ptsParts{i,2*i} = [ptsParts{i,2*i};aux];
                labelsFootParts(idxP) = (i-1)*size(ptsParts,2)+2*i;
            elseif inRect(aux,rx3,ry3)
                ptsParts{i,3} = [ptsParts{i,3};aux];
                labelsFootParts(idxP) = (i-1)*size(ptsParts,2)+3;
            elseif inRect(aux,rx6,ry6)
                ptsParts{i,6} = [ptsParts{i,6};aux];
                labelsFootParts(idxP) = (i-1)*size(ptsParts,2)+6;
            elseif inRect(aux,rx5,ry5)
                ptsParts{i,5} = [ptsParts{i,5};aux];
                labelsFootParts(idxP) = (i-1)*size(ptsParts,2)+5;
            end
        end
    end
    
end