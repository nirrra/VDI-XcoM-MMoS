% 查看坐标系是否准确
figure; 
subplot(1,3,1);
img = reshape(pressurePlantar2D(100,:),32,32);
imshow(mat2gray(img),'InitialMagnification','fit'); colormap default;
subplot(1,3,2);
img = reshape(pressureButtock2D(100,:),32,32);
imshow(mat2gray(img),'InitialMagnification','fit'); colormap default;
subplot(1,3,3);
DrawKinectFrame(stream,100,false);
title('fig.1 坐标系验证');