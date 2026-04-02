%% Kinectstream, W插值滤波
function Kinectstream_F_I = Kinectstream_Rmoutliers_Filter_And_Interp(stream,freq,order_N)
[xcom_human, ycom_human, zcom_human] = Gravity_KinectAzure(stream, 'M');
kinect_cell_arrays = Kinect_Azure_Struct_To_Array(stream);
dataLength = length(kinect_cell_arrays);
numJoint = length(kinect_cell_arrays{1}.joints);
value = zeros(numJoint,3,dataLength);
t = zeros(dataLength,1);
for i = 1:dataLength
    value(:,:,i) = kinect_cell_arrays{i}.joints;
    t(i) = double(kinect_cell_arrays{i}.time); % 秒，t=wtime
end

%% 去除离群点1 grubbs
% out_outliers_index_grubbs = zeros(L,1);
% % 寻找离群点
% for i = [3 7 11 12 13 15 16 17] % 重要的关节
%     for j = 1:3
%         [~,out_outliers_index_temp] = rmoutliers(reshape(value(i,j,:),L,1),'grubbs');
%         out_outliers_index_grubbs = out_outliers_index_grubbs + out_outliers_index_temp; % 只要有一个关节坐标是离群点，则认为该时刻数据为离群点
%     end
% end
% % 去除离群点
% value(:,:,out_outliers_index_grubbs>0) = [];
% t(out_outliers_index_grubbs>0) = [];
%% 去除离群点2 速度 median
% out_outliers_index_median = zeros(dataLength,1);
% t_sd = zeros(numJoint,3,dataLength);
% for i = 1:numJoint
%     for j = 1:3
%         t_sd(i,j,:) = t;
%     end
% end
% % 求速度
% value_sd = zeros(numJoint,3,dataLength);
% value_sd(:,:,2:end) = (value(:,:,2:end) - value(:,:,1:end-1)) ./ (t_sd(:,:,2:end) - t_sd(:,:,1:end-1));
% % 寻找离群点
% for i = [3 7 11 12 13 15 16 17] % 重要的关节
%     for j = 1:3
%         [~,out_outliers_index_temp] = rmoutliers(reshape(value_sd(i,j,:),dataLength,1),'median');
%         out_outliers_index_median = out_outliers_index_median + out_outliers_index_temp; % 只要有一个关节坐标是离群点，则认为该时刻数据为离群点
%     end
% end
% % 去除离群点
% value(:,:,out_outliers_index_median>0) = [];
% t(out_outliers_index_median>0) = [];
%% 去除离群点3 根据质心
% out_outliers_index_median = zeros(length(t),1);
% t_sd = zeros(numJoint,3,length(t));
% for i = 1:numJoint
%     for j = 1:3
%         t_sd(i,j,:) = t;
%     end
% end
% % 寻找离群点
% [~,out_outliers_index_temp] = rmoutliers(zcom_human,'median');
% out_outliers_index_median = out_outliers_index_median + out_outliers_index_temp; % 只要有一个关节坐标是离群点，则认为该时刻数据为离群点
% % 去除离群点
% value(:,:,out_outliers_index_median>0) = [];
% t(out_outliers_index_median>0) = [];
%% spline插值，滤波
L_rmout = length(t);
time = (t(1):(1/freq):t(end))'; % 时间插值
L_t = length(time);
out_interp_freq = zeros(numJoint,3,L_t);
% 关节点插值
for i = 1:numJoint
    out_interp_freq(i,1,:) = Filter_And_Interp(freq,order_N,t,reshape(value(i,1,:),L_rmout,1),1); % X方向
    out_interp_freq(i,2,:) = Filter_And_Interp(freq,order_N,t,reshape(value(i,2,:),L_rmout,1),1); % Y方向
    out_interp_freq(i,3,:) = Filter_And_Interp(freq,order_N,t,reshape(value(i,3,:),L_rmout,1),1); % Z方向
end
% 格式转换到原来
kinect_cell_arrays_interp = cell(1,L_t);
for i = 1:L_t
    kinect_cell_arrays_interp{i}.time = time(i);
    kinect_cell_arrays_interp{i}.joints = out_interp_freq(:,:,i);
end
Kinectstream_F_I = Kinect_ArrayToStruct(kinect_cell_arrays_interp);
end