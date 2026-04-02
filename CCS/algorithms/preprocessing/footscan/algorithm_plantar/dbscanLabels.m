%% FUNC dbscanLabels：获取DBSCAN的labels
function [labels] = dbscanLabels(pts)
    minPts = 5; eps = 3;
    labels = dbscan(pts,eps,minPts);
    numParts = max(labels);% DBSCAN划分的区域数
    for i = 1:size(labels,1)
        if labels(i) == -1
            labels(i) = numParts+1;
            numParts = numParts+1;
        end
    end
    % 防止只划分一个区域
    if max(labels) == min(labels)
        aux = mean(pts,1); aux = aux(1);
%         aux = (max(pts)+min(pts))/2; aux = aux(1);
        for i = 1:size(pts,1)
            if pts(i,1)<=aux
                labels(i) = 1;
            else
                labels(i) = 2;
            end
        end
    end
end