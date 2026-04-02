% Kinect（X左，Y后，Z上）转换到OpenSim坐标系（X右，Y前，Z上），根据COM
tmKinect2Opensim = GetKinect2OpensimT(stream,analysis,times,timeStart,timeEnd);
stream = Transform_Azure(tmKinect2Opensim,stream);

% 站立稳定段
segStable = [];
for i = 100:length(stream.wtime)-100
    if stream.HEAD.z(i)>max(stream.HEAD.z)-0.1 && range(stream.HEAD.z(i-5:i+5))<0.02
        segStable(end+1) = i;
    end
end
% figure; hold on;
% plot(stream.wtime,stream.HEAD.z);
% plot(stream.wtime(segStable),stream.HEAD.z(segStable),'ro');
% hold off;
% 坐标系原点统一至两脚中间
posOrigin = [stream.FOOT_LEFT.x+stream.FOOT_RIGHT.x,stream.FOOT_LEFT.y+stream.FOOT_RIGHT.y,stream.FOOT_LEFT.z+stream.FOOT_RIGHT.z]./2;
% posOrigin = mean(posOrigin(51:end-50,:));
posOrigin = mean(posOrigin(segStable,:));
tmFootOrigin = [1,0,0,-posOrigin(1);0,1,0,-posOrigin(2);0,0,1,-posOrigin(3);0,0,0,1];
stream = Transform_Azure(tmFootOrigin,stream);

% 绕Y/Z轴旋转关节点，使得人体竖直轴与z轴同向
stream = RotateStreamXYZ(stream,'xyz');

% DrawKinectFrame(stream,100);
modelHeight = max(stream.HEAD.z-mean([stream.FOOT_LEFT.z,stream.FOOT_RIGHT.z],2));
disp(['模型身高比：',num2str(100*modelHeight./heights(data.idxSub))]);