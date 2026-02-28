% times.kinect = times.kinect+timeDelay
function timeDelay = GetTimeDelayKinect2ViconManually(times,i)
    posVicon = [1780 638 3536 299 658 210 402 52 472 517 194 486 564 531 349 797 588 260 803 ,...
                571 498 594 324 2047 929 1565 ,...
                740 1338 2389 800 736
                ];
    posKinect = [868 734 1329 692 73 581 354 732 894 200 103 190 213 68 132 231 247 394 418 ,...
                358 855 206 162 413 440 122 ,...
                1248 207 48 907 320
                ];
    if i > length(posVicon)
        timeDelay = 0;
        disp('超出手动标记的数据数量');
    else
        timeDelay = times.vicon(posVicon(i))-times.kinect(posKinect(i));
    end
end

% [hipFlexionL,~] = CalKinectJointAngle(stream.SPINE_NAVAL,stream.HIP_LEFT,stream.KNEE_LEFT);
% hipFlexionL = 170-hipFlexionL;
% dataK = hipFlexionL; dataV = ik.hip_flexion_l;
% figure;
% subplot(2,1,1); plot(dataV);
% subplot(2,1,2); plot(dataK);
% 
% posVicon = [1780 638 3536 299 658 210 402 52 472 517 194 486 564 531 349 797 588 260 803 ,...
%             571 498 594 324 2047 929 1565 ,...
%             740 1338 2389 800 736
%             ];
% posKinect = [868 734 1329 692 73 581 354 732 894 200 103 190 213 68 132 231 247 394 418 ,...
%             358 855 206 162 413 440 122 ,...
%             1248 207 48 907 320
%             ];
% timeDelay = times.vicon(posVicon(idxFile))-times.kinect(posKinect(idxFile));
% 
% figure; hold on;
% plot(times.vicon,dataV);
% plot(times.kinect+timeDelay,dataK);
% hold off; xlim([20,40]);