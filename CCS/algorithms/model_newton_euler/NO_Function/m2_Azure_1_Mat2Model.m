clear;
close all;
addpath(genpath('.\2_Read'));
addpath(genpath('.\3_Preprocess'));addpath(genpath('.\4_Process'));
addpath(genpath('.\5_Result')); addpath(genpath('.\6_Figure'));

global joints_position_origin segments_length;
p=dir('.\1_Data\data_all_txt_origin');
state_number=size(p,1)-3;
for NAME = 1:state_number
    state = p(NAME + 2).name;%获取文件夹的名称（人名）
    p_state = dir(['.\1_Data\data_all_txt_origin\',state]);
    walk_number = size(p_state,1)-4;
    for index = 1:walk_number
        clearvars -except  NAME  p state_number state walk_number index joints_position_origin segments_length
        %         index = 8;
        %         state = 'fallw';
        filename = ['.\Data_Azure_MAT\',state,'(',num2str(index),')','_','Merge.mat'];
        tic;
        load(filename);
        disp(filename);
        kinect_cell_arrays_origin = kinect_cell_arrays;
        falllabel_origin = falllabel;
        
        %% 插值滤波
        freq = 30;
        Order_N = 5;
        L = length(kinect_cell_arrays);
        value = zeros(19,3,L);
        t = zeros(L,1);
        for i = 1:L
            value(:,:,i) = kinect_cell_arrays{i}.joints;
            t(i) = double(kinect_cell_arrays{i}.time)/1000;%秒
        end
        time = (t(1):(1/30):t(end))';
        L_t = length(time);
        out_interp_freq = zeros(19,3,L_t);
        %线性插值，窗函数滤波
        for i = 1:19
            for j = 1:3
                out_interp_freq(i,j,:) = Filter_And_Interp(freq,Order_N,t,reshape(value(i,j,:),L,1));
            end
        end
        %格式转换到原来
        kinect_cell_arrays_interp = cell(1,L_t);
        for i = 1:L_t
            kinect_cell_arrays_interp{i}.time = int32(time(i) * 1000);
            kinect_cell_arrays_interp{i}.joints = out_interp_freq(:,:,i);
        end
        %% 重新加上跌倒标签
        fall_flag_index = find(falllabel_origin>0, 1 );%第一个开始跌倒的序号
        falllabel = zeros(L_t,1);
        if ~isempty(fall_flag_index)
            fall_flag_time = kinect_cell_arrays_origin{fall_flag_index}.time; 
            for i = 1:L_t
                if(kinect_cell_arrays_interp{i}.time>=fall_flag_time)
                    falllabel(i) = 1;
                end
            end
        end
        
        %% 计算各段长度
        
        segments_length = Get_Segments_Length(kinect_cell_arrays_interp);
        %% 优化,关节位置缩放
        kinect_cell_arrays_model = cell(1,length(kinect_cell_arrays_interp));
        for i = 1:length(kinect_cell_arrays_interp)
            joints_position_origin = kinect_cell_arrays_interp{i}.joints;
            joints0 = kinect_cell_arrays_interp{i}.joints;
            %优化参数设定
            A=[];
            b=[];
            Aeq=[];
            beq=[];
            lb=joints0 - 0.1;
            ub=joints0 + 0.1;
            options = optimoptions('fmincon','MaxFunctionEvaluations',10000);
            %开始优化
            [joints_position_model,fval,flag,out] = ...
                fmincon(@Fmin,joints0,A,b,Aeq,beq,lb,ub,@Constrain,options);
            
            kinect_cell_arrays_model{i}.joints = joints_position_model;
            kinect_cell_arrays_model{i}.time = kinect_cell_arrays_interp{i}.time;
        end
        
        filenamemodel = ['.\Data_Azure_MAT_After_Model\',state,'(',num2str(index),')','_','Merge.mat'];
        save(filenamemodel, 'kinect_cell_arrays_model','kinect_cell_arrays_origin', 'kinect_cell_arrays_interp','segments_length','falllabel','falllabel_origin');
        toc
    end
end
