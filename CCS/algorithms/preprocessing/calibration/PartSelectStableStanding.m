% 选择静止站立段
figure; hold on;
plot(times.union,posCOMSegments.Trunk.z);
plot(times.union,posCOMSegments.Trunk.y);
legend('竖直方向','前后方向');
set(gcf,'position',[100,100,1280,720]);
title('请选择站立段，按ESC结束');

flag_esc = false;

time_stable_stand = [];
while ~flag_esc
    [x,~,button] = ginput(1);

    if button == 27
        flag_esc = true;
    end

    time_stable_stand(end+1) = x;
end

close(gcf);

time_stable_stand(end) = [];
disp('time_stable_stand');
DispArray(time_stable_stand);