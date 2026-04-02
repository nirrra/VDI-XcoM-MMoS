%% FUNC getPtsRect：获得矩阵内的Pts
function [ptsRect, labelsRect] = getPtsRect(rectx,recty)
    ptsRect = []; labelsRect = [];
    for i = 1:32
        for j = 1:32
            aux = [i,j];
            for k = 1:2
                rx = rectx(k,1:4); ry = recty(k,1:4);
                if inRect(aux, rx, ry)
                    ptsRect = [ptsRect; aux];
                    labelsRect = [labelsRect;k];
                end
            end
        end
    end
    
%     figure; gscatter(ptsRect(:,1),ptsRect(:,2),labelsRect); axis equal; axis([0.5 32.5 0.5 32.5]); title('区分双脚');
%     hold on;
%     for i = 1:2
%         line(rectx(i,:)',recty(i,:)');
%         for j = 1:4
%             vtxx(i,j) = mean(rectx(i,j:j+1)); % 外切矩阵的中线
%             vtxy(i,j) = mean(recty(i,j:j+1));
%         end
%         plot(vtxx(i,[1,3]),vtxy(i,[1,3]),'-b'); plot(vtxx(i,[2,4]),vtxy(i,[2,4]),'-b');
%     end
end