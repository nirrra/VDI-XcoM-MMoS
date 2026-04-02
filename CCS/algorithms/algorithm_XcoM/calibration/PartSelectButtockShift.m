%% 先后点击足部位置和臀部位置，得到水平位移
dj_buttock = 0;

figure; 
set(gcf,'position',[100,100,600,800]);

adjusting = true;
last_dj_buttock = dj_buttock;

% imgPlantar = reshape(pressurePlantar2DInter(idxFrame,:,:),32,32);
% imgHip = reshape(pressureHip2DInter(idxFrame,:,:),32,32);
imgPlantar = 10*reshape(mean(pressurePlantar2DInter(idx_segment_sitting,:,:),1),32,32);
imgHip = reshape(mean(pressureHip2DInter(idx_segment_sitting,:,:),1),32,32);

while adjusting
    imgHip_shifted = circshift(imgHip, [0, dj_buttock]);
    % 将超出范围的部分置为0
    if dj_buttock > 0
        imgHip_shifted(:, 1:dj_buttock) = 0; % 向右平移，左侧超出部分置0
    elseif dj_buttock < 0
        imgHip_shifted(:, end+dj_buttock+1:end) = 0; % 向左平移，右侧超出部分置0
    end

    subplot(1,2,1); cla;
    imshow(mat2gray([imgPlantar;imgHip]),'InitialMagnification','fit'); colormap parula;
    title('校准前');

    subplot(1,2,2); cla;
    imshow(mat2gray([imgPlantar;imgHip_shifted]),'InitialMagnification','fit'); colormap default;
    title(['校准后，位移：',num2str(dj_buttock)]);
    
    % Get user input
    subplot(1,2,1);
    title('点击两个点确定位移 (先足后臀，按ESC确认)');
    try
        [x, ~, button] = ginput(2);
        if ~isempty(button) && any(button == 27) % ESC pressed
            adjusting = false;
        else
            last_dj_buttock = dj_buttock; % Store last good shift
            dj_buttock = round(x(1)-x(2)); % Calculate new shift
        end
    catch
        % If user closes figure or other error, exit loop
        adjusting = false;
    end
end

% Display final buttock shift
disp('Final buttock shift: ');
disp(num2str(dj_buttock));

% Final plot with confirmed delay
subplot(1,2,2); cla;
imshow(mat2gray([imgPlantar;imgHip_shifted]),'InitialMagnification','fit'); colormap default;
title(['校准后，位移：',num2str(dj_buttock)]);

close(gcf);


