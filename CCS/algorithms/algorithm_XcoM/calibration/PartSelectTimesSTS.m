[copPlantar.x,copPlantar.y] = calCOP(pressurePlantar2D,1); copPlantar.x = copPlantar.x*0.001; copPlantar.y = -copPlantar.y*0.001;

figure; hold on;
p1 = plot(times.plantar,5e-4*sum(pressurePlantar2D,[2,3]),'DisplayName','足底压力');
p2 = plot(times.plantar,copPlantar.y,'DisplayName','前后CoP');

% p3 = plot(times.plantar,copPlantar.x,'DisplayName','左右CoP');

p3 = plot(times.union,com.y,'LineWidth',1.5,'DisplayName','前后CoM');
% p4 = plot(times.union,xcom.y,'LineWidth',1.5,'DisplayName','前后XcoM');
p5 = plot(times.union,com.z,'DisplayName','上下CoM');

p6 = plot(times.union,inertia_rotary./100,'LineWidth',1.5,'DisplayName','转动惯量');

hold off;
xlim([times.union(1),times.union(end)]);
legend([p1,p2,p3,p5,p6]);
title('请选择所有站起的起始点和结束点，按ESC结束');
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');

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