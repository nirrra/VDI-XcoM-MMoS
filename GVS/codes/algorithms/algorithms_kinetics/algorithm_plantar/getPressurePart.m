%% FUNC getPressurePart：分区压力计算
function [pressurePart] = getPressurePart(ptsParts,img)
    pressurePart = zeros(2,size(ptsParts,2));
    for i = 1:2
        for j = 1:size(pressurePart,2)
            pressure = 0;
            pts = ptsParts{i,j};
            pts(:,2) = 33-pts(:,2);
            pts = [pts(:,2),pts(:,1)];
            for m = 1:size(pts,1)
                pressure = pressure+img(pts(m,1),pts(m,2));
            end
            pressurePart(i,j) = pressure;
        end
    end
end