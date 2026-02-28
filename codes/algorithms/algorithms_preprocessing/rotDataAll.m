%% FUNC rotDataAll：旋转所有数据
function [dataAllRot2D] = rotDataAll(dataAll2D, rotK)
    dataAllRot2D = dataAll2D;
    for i = 1:size(dataAll2D,1)
        aux = double(reshape(dataAll2D(i,:),32,32));
        aux = rot90(aux,rotK);
        dataAllRot2D(i,:,:) = reshape(aux,1,32,32);
    end
end