%% 根据COP和COM确定delays
delay_times_sts = zeros(length(times_start),1);

for i = 1:length(times_start)
    delay_time_sts = delay_times_sts(i);
    % Create figure
    figure; 
    set(gcf,'position',[100,100,1600,960]);
    
    % Initialize variables
    adjusting = true;
    last_delay = delay_time_sts;
    
    while adjusting
        % Plot original data
        subplot(2,1,1); cla; hold on; grid on;
        plot(times.union,DivMean(stream.PELVIS.z),'LineWidth',2,'Color',colors(3,:));
        plot(times.union,DivMean(posCOMSegments.Trunk.y),'LineWidth',2,'Color',colors(4,:));
        plot(times.plantar,30*DivMean(sum(sum(pressurePlantar2D,2),3))./1e5+0.05,'LineWidth',2,'Color',colors(1,:));
        xline([times_start(i),times_end(i)],'r-');
        hold off; 
        legend('骨盆高度','COM','足底压力'); 
        title([num2str(i),'/',num2str(length(times_start)),' 校准前，先点击绿线']);
        
        % Plot adjusted data
        subplot(2,1,2); cla; hold on; grid on;
        plot(times.union,DivMean(stream.PELVIS.z),'LineWidth',2,'Color',colors(3,:));
        plot(times.union,DivMean(posCOMSegments.Trunk.y),'LineWidth',2,'Color',colors(4,:));
        plot(times.plantar+delay_time_sts,30*DivMean(sum(sum(pressurePlantar2D,2),3))./1e5+0.05,'LineWidth',2,'Color',colors(1,:));
        hold off; 
        legend('骨盆高度','COM','足底压力'); 
        title([num2str(i),'/',num2str(length(times_start)),' 校准后 ',num2str(delay_time_sts),'s (按ESC确认)']);
        
        % Get user input
        subplot(2,1,1);
        title([num2str(i),'/',num2str(length(times_start)),' 点击两个点确定延迟 (先绿后灰，按ESC确认当前延迟)']);
        try
            [x, ~, button] = ginput(2);
            if ~isempty(button) && any(button == 27) % ESC pressed
                adjusting = false;
            else
                last_delay = delay_time_sts; % Store last good delay
                delay_time_sts = x(1)-x(2); % Calculate new delay
            end
        catch
            % If user closes figure or other error, exit loop
            adjusting = false;
        end
    end
    
    
    % Final plot with confirmed delay
    subplot(2,1,2); cla; hold on; grid on;
    plot(times.union,DivMean(stream.PELVIS.z),'LineWidth',2,'Color',colors(3,:));
    plot(times.union,DivMean(posCOMSegments.Trunk.y),'LineWidth',2,'Color',colors(4,:));
    plot(times.plantar+delay_time_sts,30*DivMean(sum(sum(pressurePlantar2D,2),3))./1e5+0.05,'LineWidth',2,'Color',colors(1,:));
    hold off; 
    legend('骨盆高度','COM','足底压力'); 
    title(['最终校准结果 ',num2str(delay_time_sts),'s']);
    
    close(gcf);

    delay_times_sts(i) = delay_time_sts;
end

% Display final delay time
disp('Final delay times sts: ');

str = num2str(delay_times_sts(1));
for i = 2:length(delay_times_sts)
    str = [str,', ',num2str(delay_times_sts(i))];
end

% 添加方括号
str = ['delays_stss{',num2str(idx_file),'} = [' str '];'];
disp(str);

