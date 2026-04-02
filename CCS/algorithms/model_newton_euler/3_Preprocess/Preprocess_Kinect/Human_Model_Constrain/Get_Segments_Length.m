function segments_length = Get_Segments_Length(kinect_cell_arrays)
segmentsL = zeros(14,20);
startf = 6;
N = 20; % 取20个点，去除最大最小值求平均长度
for i = startf : (N + startf - 1)
    j = i-startf+1;
    segmentsL(1,j) = norm(kinect_cell_arrays{j}.joints(2,:) - kinect_cell_arrays{j}.joints(19,:));% segments_length.HeadNeck
    segmentsL(2,j) = norm((kinect_cell_arrays{j}.joints(11,:) + kinect_cell_arrays{j}.joints(15,:)) / 2 - ...
        (kinect_cell_arrays{j}.joints(3,:) + kinect_cell_arrays{j}.joints(7,:)) / 2) ;%segments_length.Trunk)
    segmentsL(3,j) = norm(kinect_cell_arrays{j}.joints(3,:) - kinect_cell_arrays{j}.joints(4,:));%segments_length.Upperarm
    segmentsL(4,j) = norm(kinect_cell_arrays{j}.joints(7,:) - kinect_cell_arrays{j}.joints(8,:));%segments_length.Upperarm
    segmentsL(5,j) = norm(kinect_cell_arrays{j}.joints(4,:) - kinect_cell_arrays{j}.joints(5,:));%segments_length.Forearm
    segmentsL(6,j) = norm(kinect_cell_arrays{j}.joints(8,:) - kinect_cell_arrays{j}.joints(9,:));%segments_length.Forearm
    segmentsL(7,j) = norm(kinect_cell_arrays{j}.joints(11,:) - kinect_cell_arrays{j}.joints(12,:));%segments_length.Thigh
    segmentsL(8,j) = norm(kinect_cell_arrays{j}.joints(15,:) - kinect_cell_arrays{j}.joints(16,:));%segments_length.Thigh
    segmentsL(9,j) = norm(kinect_cell_arrays{j}.joints(12,:) - kinect_cell_arrays{j}.joints(13,:));%segments_length.Shank
    segmentsL(10,j) = norm(kinect_cell_arrays{j}.joints(16,:) - kinect_cell_arrays{j}.joints(17,:));%segments_length.Shank
    segmentsL(11,j) = norm(kinect_cell_arrays{j}.joints(5,:) - kinect_cell_arrays{j}.joints(6,:));%segments_length.Hand
    segmentsL(12,j) = norm(kinect_cell_arrays{j}.joints(9,:) - kinect_cell_arrays{j}.joints(10,:));%segments_length.Hand
    segmentsL(13,j) = norm(kinect_cell_arrays{j}.joints(13,:) - kinect_cell_arrays{j}.joints(14,:));%segments_length.Foot
    segmentsL(14,j) = norm(kinect_cell_arrays{j}.joints(17,:) - kinect_cell_arrays{j}.joints(18,:));%egments_length.Foot
    
    segmentsL(15,j) = norm(kinect_cell_arrays{j}.joints(3,:) - kinect_cell_arrays{j}.joints(7,:));%segments_length.Shoulders
    segmentsL(16,j) = norm(kinect_cell_arrays{j}.joints(11,:) - kinect_cell_arrays{j}.joints(15,:));%segments_length.Pelvis
end
% 去除最大值，最小值
for i = 1:16
    [~,index] = min(segmentsL(i,:));
    segmentsL(i,index) = 0;
    [~,index] = max(segmentsL(i,:));
    segmentsL(i,index) = 0;   
end

% 平均
segments_length.HeadNeck = sum(segmentsL(1,:))/(N-2);
segments_length.Trunk = sum(segmentsL(2,:))/(N-2);
segments_length.Upperarm = 0.5*sum(segmentsL(3,:))/(N-2) + 0.5*sum(segmentsL(4,:))/(N-2);
segments_length.Forearm = 0.5*sum(segmentsL(5,:))/(N-2) + 0.5*sum(segmentsL(6,:))/(N-2);
segments_length.Thigh = 0.5*sum(segmentsL(7,:))/(N-2) + 0.5*sum(segmentsL(8,:))/(N-2);
segments_length.Shank = 0.5*sum(segmentsL(9,:))/(N-2) + 0.5*sum(segmentsL(10,:))/(N-2);

segments_length.Hand = 0.08;
segments_length.Foot = 0.15;

segments_length.Shoulders = sum(segmentsL(15,:))/(N-2);
segments_length.Pelvis = sum(segmentsL(16,:))/(N-2);
end