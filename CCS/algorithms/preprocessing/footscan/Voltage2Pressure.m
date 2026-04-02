% 电平值转换至实际压力
function [ratioV2P_P,ratioV2P_H] = Voltage2Pressure(times,pressurePlantar,pressureHip,weight)
sumP = sum(pressurePlantar,2);
sumH = sum(pressureHip,2);
aux = [];
for i = 6:length(sumP)-5
    if sumP(i)>0.6*max(sumP) && range(sumP(i-5:i+5))<max(sumP)/40
        aux = [aux,i];
    end
end
ratioV2P_P = weight*9.8./mean(sumP(aux));

aux = find(sumH<2000); aux = aux(1);
sumH(1:aux) = 0;
for i = 6:length(sumH)-5
    if sumH(i)>0.6*max(sumH) && range(sumH(i-5:i+5))<max(sumH)/15
        aux = [aux,i];
    end
end
timeH = times.hip(aux);
posP = GetIdxTime(times.plantar,timeH);
ratioV2P_H = (weight*9.8-ratioV2P_P*mean(sumP(posP)))./mean(sumH(aux));


end