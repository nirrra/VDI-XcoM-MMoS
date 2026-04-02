figure; hold on;
plot(times.plantar,10e-6*sum(data.plantar.dataAllOri,2));
% plot(times.buttock,10e-6*sum(data.buttock.dataAllOri,2));
plot(times.plantar,copPlantar.x);
plot(times.plantar,copPlantar.y);
hold off;
xlim([times.union(1),times.union(end)]);
legend('足底压力','左右COP','前后COP');
title('请选择所有站起的起始点和结束点，按ESC结束');
set(gcf,'position',[100,100,1280,720]);

flag_esc = false;

times_sts = [];
while ~flag_esc
    [x, ~, button] = ginput(1);

    if button == 27
        flag_esc = true;
    end

    times_sts(end+1) = x;
end

close(gcf);

times_sts(end) = [];
disp('times_sts: ');
DispArray(times_sts);