%% 根据COP和COM确定delays
delay_time = 0;

% Create figure
figure; 
set(gcf,'position',[100,100,1280,720]);

% Initialize variables
adjusting = true;
last_delay = delay_time;

while adjusting
    % Plot original data
    subplot(2,1,1); cla; hold on; grid on;
    plot(times.plantar,DivMean(sum(sum(pressurePlantar2D,2),3))./1e5,'LineWidth',2,'Color',colors(1,:));
    plot(times.kinect,DivMean(stream.PELVIS.z),'LineWidth',2,'Color',colors(3,:));
    plot(times.kinect,DivMean(posCOMSegments.Trunk.y),'LineWidth',2,'Color',colors(4,:));
    hold off; 
    legend('足底压力','骨盆高度','COM'); 
    title('校准前，先点击绿线');
    
    % Plot adjusted data
    subplot(2,1,2); cla; hold on; grid on;
    plot(times.plantar+delay_time,DivMean(sum(sum(pressurePlantar2D,2),3))./1e5,'LineWidth',2,'Color',colors(1,:));
    plot(times.kinect,DivMean(stream.PELVIS.z),'LineWidth',2,'Color',colors(3,:));
    plot(times.kinect,DivMean(posCOMSegments.Trunk.y),'LineWidth',2,'Color',colors(4,:));
    hold off; 
    legend('足底压力','骨盆高度','COM'); 
    title(['校准后 ',num2str(delay_time),'s (按ESC确认)']);
    
    % Get user input
    subplot(2,1,1);
    title('点击两个点确定延迟 (先绿后灰，按ESC确认当前延迟)');
    try
        [x, ~, button] = ginput(2);
        if ~isempty(button) && any(button == 27) % ESC pressed
            adjusting = false;
        else
            last_delay = delay_time; % Store last good delay
            delay_time = x(1)-x(2); % Calculate new delay
        end
    catch
        % If user closes figure or other error, exit loop
        adjusting = false;
    end
end

% Display final delay time
disp('Final delay time: ');
disp(num2str(delay_time));

% Final plot with confirmed delay
subplot(2,1,2); cla; hold on; grid on;
plot(times.plantar+delay_time,DivMean(sum(sum(pressurePlantar2D,2),3))./1e5,'LineWidth',2,'Color',colors(1,:));
plot(times.kinect,DivMean(stream.PELVIS.z),'LineWidth',2,'Color',colors(3,:));
plot(times.kinect,DivMean(posCOMSegments.Trunk.y),'LineWidth',2,'Color',colors(4,:));
hold off; 
legend('足底压力','骨盆高度','COM'); 
title(['最终校准结果 ',num2str(delay_time),'s']);

close(gcf);
