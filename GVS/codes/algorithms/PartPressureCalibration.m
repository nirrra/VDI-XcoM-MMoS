% 阵列校准到单位N
% [ratioV2P_P,ratioV2P_H] = Voltage2Pressure(times,pressurePlantar,pressureHip,weight);
ratioV2P_P = prctile(grf.left_force_vy+grf.right_force_vy,95)./prctile(sum(pressurePlantar,2),95);
ratioV2P_H = prctile(grf.hip_force_vy,95)./prctile(sum(pressureHip,2),95);

% figure; 
% subplot(2,1,1);hold on;
% plot(times.plantar,sum(pressurePlantar,2));
% plot(times.grf,grf.left_force_vy+grf.right_force_vy);
% hold off; legend('阵列','测力台'); title('足底压力校准');
% subplot(2,1,2);hold on;
% plot(times.hip,sum(pressureHip,2));
% plot(times.grf,grf.hip_force_vy);
% hold off; legend('阵列','测力台'); title('臀底压力校准');

pressurePlantar = ratioV2P_P.*pressurePlantar; pressurePlantar2D = ratioV2P_P.*pressurePlantar2D;
pressureHip = ratioV2P_H.*pressureHip; pressureHip2D = ratioV2P_H.*pressureHip2D;
[p_listPlantar,ptsPartsAnotomy] = CalPlantarPressures(pressurePlantar2D);
