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
title('请选择一个起始点，程序将自动生成STS时间段');
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1], 'color', 'w');

% 只需要点击一个点
[x0, ~] = ginput(1);

% 基于点击的x坐标生成times_sts
offset_array = [0,4,10,14,20,24,30,34,40,44];
times_sts = x0 + offset_array;

% 在图中显示生成的时间线
hold on;
for i = 1:length(times_sts)
    xline(times_sts(i), 'r--', 'LineWidth', 1.5, 'Alpha', 0.7);
end
hold off;

% 更新标题显示生成的时间点
title(sprintf('已生成STS时间段，起始点: %.2f', x0));

disp('times_sts: ');
DispArray(times_sts);