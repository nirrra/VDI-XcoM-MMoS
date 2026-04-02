function streamInter = Kinectstream_Rmoutliers_Filter_And_Interp_STS2(stream,fsInter,order_N)

kinect_cell_arrays = Kinect_Azure_Struct_To_Array(stream);
aux = Datetime2Time(stream.wtime);
for i = 1:length(kinect_cell_arrays)
    kinect_cell_arrays{i}.time = aux(i);
end
dataLength = length(kinect_cell_arrays);
numJoint = length(kinect_cell_arrays{1}.joints);
value = zeros(numJoint,3,dataLength);
t = zeros(dataLength,1);
for i = 1:dataLength
    value(:,:,i) = kinect_cell_arrays{i}.joints;
    t(i) = double(kinect_cell_arrays{i}.time); % 秒，t=wtime
end
% 寻找离群点
out_outliers_index_grubbs = zeros(length(kinect_cell_arrays),1);
for i = [3 7 11 12 13 15 16 17] % 重要的关节
    for j = 1:3
        [~,out_outliers_index_temp] = rmoutliers(reshape(value(i,j,:),length(kinect_cell_arrays),1),'grubbs');
        out_outliers_index_grubbs = out_outliers_index_grubbs + out_outliers_index_temp; % 只要有一个关节坐标是离群点，则认为该时刻数据为离群点
    end
end
% 去除离群点
idxOutliers = find(out_outliers_index_grubbs>0);
value(:,:,idxOutliers) = [];
t(idxOutliers) = [];
% spline插值，滤波
L_rmout = length(t);
time = (t(1):(1/fsInter):t(end))'; % 时间插值
L_t = length(time);
out_interp_freq = zeros(numJoint,3,L_t);
% 关节点插值
for i = 1:numJoint
    out_interp_freq(i,1,:) = Filter_And_Interp(fsInter,order_N,t,reshape(value(i,1,:),L_rmout,1),1); % X方向
    out_interp_freq(i,2,:) = Filter_And_Interp(fsInter,order_N,t,reshape(value(i,2,:),L_rmout,1),1); % Y方向
    out_interp_freq(i,3,:) = Filter_And_Interp(fsInter,order_N,t,reshape(value(i,3,:),L_rmout,1),1); % Z方向
end
% 格式转换到原来
kinect_cell_arrays_interp = cell(1,L_t);
for i = 1:L_t
    kinect_cell_arrays_interp{i}.time = time(i);
    kinect_cell_arrays_interp{i}.joints = out_interp_freq(:,:,i);
end
streamInter = Kinect_ArrayToStruct(kinect_cell_arrays_interp);