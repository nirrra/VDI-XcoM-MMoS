function [stream] = RotateStreamXYZ(stream,axisRotate)
if nargin<2, axisRotate = 'yz'; end

if isempty(axisRotate), return; end

%% 站立稳定点
data = stream.HEAD.z;
idxStream = [];
for i = 1+10:length(data)-10
    if range(data(i-10:i+10))<0.01 && data(i)>max(data)-0.05
        idxStream = [idxStream,i];
    end
end
% figure; hold on;
% plot(stream.wtime,data);
% plot(stream.wtime(idxStream),data(idxStream),'ro');
% hold off; title('站立稳定点');

options = optimoptions('fminunc', 'Algorithm', 'quasi-newton','Display','notify'); % 优化参数
initialGuess = 0; % 猜测旋转角度为0度
%% 绕X轴
if contains(axisRotate,'x')
    rotAngleXOptimized = fminunc(@(params) StreamAxisXOptimization(params,stream,idxStream),initialGuess,options);
    tmRotateX = [1,0,0,0;...
                    0,cosd(rotAngleXOptimized),-sind(rotAngleXOptimized),0;...
                    0,sind(rotAngleXOptimized),cosd(rotAngleXOptimized),0;...
                    0,0,0,1];
    stream = Transform_Azure(tmRotateX,stream);
    disp(['绕X轴旋转角度：',num2str(rotAngleXOptimized)]);
end

%% 绕Y轴
if contains(axisRotate,'y')
    rotAngleYOptimized = fminunc(@(params) StreamAxisYOptimization(params,stream,idxStream),initialGuess,options);
    tmRotateY = [cosd(rotAngleYOptimized),0,sind(rotAngleYOptimized),0;...
                    0,1,0,0;...
                    -sind(rotAngleYOptimized),0,cosd(rotAngleYOptimized),0;...
                    0,0,0,1];
    stream = Transform_Azure(tmRotateY,stream);
    disp(['绕Y轴旋转角度：',num2str(rotAngleYOptimized)]);
end
%% 绕Z轴
if contains(axisRotate,'z')
    % 根据肩关节、髋关节连线
    rotAngleZOptimized = fminunc(@(params) StreamAxisZOptimization(params,stream,idxStream),initialGuess,options);
    
    tmRotateZ = [cosd(rotAngleZOptimized),-sind(rotAngleZOptimized),0,0;...
                    sind(rotAngleZOptimized),cosd(rotAngleZOptimized),0,0;...
                    0,0,1,0;...
                    0,0,0,1];
    
    stream = Transform_Azure(tmRotateZ,stream);
    disp(['绕Z轴旋转角度：',num2str(rotAngleZOptimized)]);
end

% DrawKinectFrame(stream,idxStream(1)); % 查看单帧，坐姿