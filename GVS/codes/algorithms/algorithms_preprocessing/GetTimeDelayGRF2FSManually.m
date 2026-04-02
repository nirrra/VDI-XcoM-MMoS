% times.grf = times.grf+timeDelay
function timeDelay = GetTimeDelayGRF2FSManually(times,i)
    posPlantar = [256 262 192 312 276 254 536 242 391 554 522 199 308 437 608 495 319 210 419 ,...
        310 1200 488 944 1226 1094 624 ,...
        343 341 523 302 250
        ];
    posGRF = [7949 3785 3642 12380 11650 10740 15253 7147 6804 16822 4260 4850 15724 11061 13608 16984 14965 8938 21050 ,...
        12441 70930 21300 51903 73502 59870 30175 ,...
        18462 17108 29580 14513 8508
        ];
    if i > length(posPlantar)
        timeDelay = 0;
        disp('超出手动标记的数据数量');
    else
        timeDelay = times.plantar(posPlantar(i))-times.grf(posGRF(i));
    end
end

% % 时间对齐
% times.plantar = Datetime2Time(dataPlantar.datetimeF);
% times.kinect = stream.wtime;
% times.grf = grf.time;
% 
% pLeftPlantar = sum(sum(pressurePlantar2D(:,:,1:16),3),2);
% pRightPlantar = sum(sum(pressurePlantar2D(:,:,17:32),3),2);
% pLeftGRF = grf.left_force_vy;
% pRightGRF = grf.right_force_vy;
% figure;
% subplot(2,1,1); hold on;
% plot(pLeftPlantar);
% plot(pRightPlantar); hold off; legend('左','右');
% subplot(2,1,2); hold on;
% plot(pLeftGRF);
% plot(pRightGRF); hold off; legend('左','右');
% 
% posPlantar = [256 262 192 312 276 254 536 242 391 554 522 199 308 437 608 495 319 210 419 ,...
%     310 1200 488 944 1226 1094 624 ,...
%     343 341 523 302 250
%     ];
% posGRF = [7949 3785 3642 12380 11650 10740 15253 7147 6804 16822 4260 4850 15724 11061 13608 16984 14965 8938 21050 ,...
%     12441 70930 21300 51903 73502 59870 30175 ,...
%     18462 17108 29580 14513 8508
%     ];
% timeDelay = times.plantar(posPlantar(idxFile))-times.grf(posGRF(idxFile));
% figure; hold on;
% plot(times.plantar,pLeftPlantar/50);
% % plot(times.plantar,pRightPlantar/100);
% plot(times.grf+timeDelay,pLeftGRF);
% % plot(times.grf+timeDelay,pRightGRF);
% hold off; xlim([20,40]);