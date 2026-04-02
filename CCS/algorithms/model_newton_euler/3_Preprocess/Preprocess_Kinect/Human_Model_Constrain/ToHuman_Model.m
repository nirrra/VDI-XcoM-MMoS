%% 程序功能将 kinectstream 数据 加入模型限制，使得各体段长度不随时间变化
function kinectstream_model = ToHuman_Model(kinectstream)
% 
kinect_cell_arrays = Kinect_Azure_Struct_To_Array(kinectstream);
%% 计算各段长度
segments_length = Get_Segments_Length(kinect_cell_arrays);
%% 优化,关节位置缩放
kinect_cell_arrays_model = cell(1,length(kinect_cell_arrays));
for i = 1:length(kinect_cell_arrays)
    disp(i);
    joints_position_origin = kinect_cell_arrays{i}.joints;
    joints0 = kinect_cell_arrays{i}.joints;
    % 优化参数设定
    A = [];
    b = [];
    Aeq = [];
    beq = []; 
    lb = joints0 - 0.1;
    ub = joints0 + 0.1;
    options = optimoptions('fmincon','MaxFunctionEvaluations',100000,'Display','notify');
    % 开始优化
    % fmincon：fun，目标函数；nonlcon，约束
    [joints_position_model,~,~,~] = ...
        fmincon(@(joints_position_model)Fmin(joints_position_model,joints_position_origin),joints0,A,b,Aeq,beq,lb,ub,...
        @(joints_position_model)Constrain(joints_position_model,segments_length),options);
    kinect_cell_arrays_model{i}.joints = joints_position_model;
    kinect_cell_arrays_model{i}.time = kinect_cell_arrays{i}.time;
end
%
kinectstream_model = Kinect_ArrayToStruct(kinect_cell_arrays_model);
end