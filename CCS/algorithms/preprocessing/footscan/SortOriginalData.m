function [pressure,pressure2D] = SortOriginalData(dataAllOri)
valueBackground = 34; % 背景噪声大小
dataAllOri = dataAllOri-valueBackground; dataAllOri(dataAllOri<0) = 0; % 减去背景噪声

numData = size(dataAllOri,1);
pressure = zeros(size(dataAllOri));
pressure2D = zeros(numData,32,32);
for i = 1:numData
    pressure(i,:) = dataAllOri(i,:);
    pressure2D(i,:,:) = reshape(pressure(i,:),32,32)';
end

% 电平转换为N
% pressure = pressure./100;
% pressure2D = pressure2D./100;

end