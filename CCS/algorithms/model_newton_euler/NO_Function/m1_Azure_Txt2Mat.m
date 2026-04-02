%% kinect视角的前方为z，原始kinect坐标是向下为y，向右是x，没有步道数据输入
clear;
close all;
addpath(genpath('.\2_Read'));
addpath(genpath('.\3_Preprocess'));addpath(genpath('.\4_Process'));
addpath(genpath('.\5_Result')); addpath(genpath('.\6_Figure'));
addpath(genpath('.\1_Data\data_all_txt_origin'));


%% 数据读取,转移矩阵读取
p=dir('.\1_Data\data_all_txt_origin');
state_number=size(p,1)-3;
for NAME = 1:state_number
    state = p(NAME + 2).name;%获取文件夹的名称（人名）
    p_state = dir(['.\1_Data\data_all_txt_origin\',state]);
    walk_number = size(p_state,1)-4;
    for i = 1:walk_number
%         state = 'fallw';
%         i = 8;
        filename = [state,'\walk',' (', num2str(i),')', '.txt'];
        disp(['开始显示:',state,'(',num2str(i),')']);
        %[Mas_stream_All,Sub_stream_All,Sub2Mas_T] = Read_Kinect_Azure_Cplus(filename);
        [Mas_stream_All,Sub_stream_All,~] = Read_Kinect_Azure_Cplus(filename);
        load([state,'\zSub2MasTbest.mat']);
        T_filename = [state,'\zSettingsbest.txt'];
        [~,Mas2Pathway_T] = T_Read(T_filename);
        %[Sub2Mas_T,Mas2Pathway_T] = T_Read(T_filename);
        %% 视频信息读取
        data_information = xlsread('视频信息.xlsx',state);
        tstart_move = data_information(i,2);%毫秒
        tend_move = data_information(i,6);%毫秒
        %% 数据截取参数设置，merge参数设置
        cut_range = [1.5,4.5];
        Distance = [1,5];
        %% 寻找目标人物,时间转换成了 毫秒,数据进行了截取,sub到mas
        %kinect time 最小值
        tstart_km = [];tstart_ks = [];
        for bodyid = 1:length(Mas_stream_All)
            tstart_km(bodyid) = Mas_stream_All{bodyid}.ktime(1);
        end
        for bodyid = 1:length(Sub_stream_All)
            tstart_ks(bodyid) = Sub_stream_All{bodyid}.ktime(1);
        end
        tstart_ktime = min([tstart_km,tstart_ks]);%kinect数据开始记录时间，kinect时间
        % window time 最小值
        tstart_wm = datetime;tstart_ws = datetime;
        for bodyid = 1:length(Mas_stream_All)
            tstart_wm(bodyid) = Mas_stream_All{bodyid}.wtime(1);
        end
        for bodyid = 1:length(Sub_stream_All)
            tstart_ws(bodyid) = Sub_stream_All{bodyid}.wtime(1);
        end
        tstart_wtime = min([tstart_wm,tstart_ws]);%kinect数据开始记录时间，windows时间
        %时间转换成了毫秒,数据按视频信息进行了截取，ktime == wtime，
        Kinectstream_Mas = FindTargetBody_NoPathway(Mas_stream_All,tstart_ktime,tstart_move,tend_move);
        Kinectstream_Sub_sub = FindTargetBody_NoPathway(Sub_stream_All,tstart_ktime,tstart_move,tend_move);%原始sub坐标系下的sub坐标
        
        %将数据在距离范围内截取
        Kinectstream_Mas = KinectStream_Cut(Kinectstream_Mas,cut_range);
        Kinectstream_Sub_sub = KinectStream_Cut(Kinectstream_Sub_sub,cut_range);
        
        %坐标转换到了mas
        Kinectstream_Sub = Transform_Azure(Sub2Mas_T,Kinectstream_Sub_sub);
        
        %% 数据合并
        %[Kinectstream_merge,Error] = Kinectstream_Merge_Confidence_Distance(Kinectstream_Mas,Kinectstream_Sub,Distance,Sub2Mas_T);
        %error = mean(Error.Joint1.x.^2 + Error.Joint1.y.^2 + Error.Joint1.z.^2 )
        flag1 = data_information(i,7);%标签信息1,sub去除末点帧数
        flag2 = data_information(i,8);%标签信息2 开始帧数+
        flag3 = data_information(i,9);%masorsub,sub:1 mas:2 ....sub,从开始起，0; sub，从抬脚起，3
        flag = [flag1,flag2,flag3];
        Kinectstream_merge = Kinectstream_Merge_Fall(Kinectstream_Mas,Kinectstream_Sub,flag);
        
        %% 数据打上标签，属于是大概的标签，基于肉眼识别，正常是0，跌倒是1
        %开始跌倒时间节点
        fall_start_time = max(data_information(i,3),data_information(i,4));%毫秒
        len_time = length(Kinectstream_merge.wtime);
        falllabel = zeros(len_time,1);
        for j = 1:length(Kinectstream_merge.wtime)
            if (Kinectstream_merge.wtime(j) >= fall_start_time && ~isnan(data_information(i,3)) && ~isnan(data_information(i,4)))
                falllabel(j,1) = 1;
            else
                falllabel(j,1) = 0;
            end
        end
        
        %% Mas坐标系转到matlab显示坐标系
        % Zbias = max([Kinectstream_Mas.ANKLE_LEFT.y;Kinectstream_Mas.ANKLE_RIGHT.y]);
        % Mas2matlab_T = [1 0 0 0;0 0 1 0;0 -1 0 Zbias;0 0 0 1];
        % Kinectstream_Mas = Transform_Azure(Mas2matlab_T,Kinectstream_Mas);
        % Kinectstream_Sub = Transform_Azure(Mas2matlab_T,Kinectstream_Sub);
        % Kinectstream_merge = Transform_Azure(Mas2matlab_T,Kinectstream_merge);
        %% Mas坐标系转到步道坐标系
        Kinectstream_Mas = Transform_Azure(Mas2Pathway_T,Kinectstream_Mas);
        Kinectstream_Sub = Transform_Azure(Mas2Pathway_T,Kinectstream_Sub);
        Kinectstream_merge = Transform_Azure(Mas2Pathway_T,Kinectstream_merge);
        %% 步道坐标系后移
        Ybias = 2;
        T_back = [1 0 0 0;0 1 0 Ybias;0 0 1 0;0 0 0 1];
        Kinectstream_Mas = Transform_Azure(T_back,Kinectstream_Mas);
        Kinectstream_Sub = Transform_Azure(T_back,Kinectstream_Sub);
        Kinectstream_merge = Transform_Azure(T_back,Kinectstream_merge);
        
        kinect_cell_arrays = Kinect_Azure_Struct_To_Array(Kinectstream_merge);
        filename = ['.\Data_Azure_MAT\',state,'(',num2str(i),')','_','Merge.mat'];
        save(filename,'Kinectstream_merge','falllabel','kinect_cell_arrays');
        %% 绘图
        %         %设置
        %         f_parameters.dt = 0.03;%间隔时间
        %         f_parameters.color3 = {[0 1 0],[0 1 0],[0 1 1]};%色彩关节点，肢体，须佐
        %         f_parameters.size = [1920 1080];%大小
        %         f_parameters.axis =[-1,1, 0 ,8 ,-0.4 ,2];
        %         % 格式转换
        %         kinect_cell_arrays_Mas = Kinect_Azure_Struct_To_Array(Kinectstream_Mas);
        %         kinect_cell_arrays_Sub = Kinect_Azure_Struct_To_Array(Kinectstream_Sub);
        %         kinect_cell_arrays_merge = Kinect_Azure_Struct_To_Array(Kinectstream_merge);
        % 绘图
        %         f_parameters.gifname = [state,'(',num2str(i),')','_','Mas.gif'];
        %         f_Figure_Kinect_Azure_Double(kinect_cell_arrays_Mas,f_parameters);
        %         %
        %         f_parameters.gifname = [state,'(',num2str(i),')','_','Sub.gif'];
        %         f_Figure_Kinect_Azure_Double(kinect_cell_arrays_Sub,f_parameters);
        %         %
        %         f_parameters.gifname = [state,'(',num2str(i),')','_','Masub.gif'];
        %         f_Figure_Kinect_Azure_Double_Togather(kinect_cell_arrays_Mas,kinect_cell_arrays_Sub,f_parameters);
        %
        %         f_parameters.gifname =[state,'(',num2str(i),')','_','Merge.gif'];
        %         f_Figure_Kinect_Azure_Double_Falllabel(kinect_cell_arrays_merge,falllabel,f_parameters);
        %         disp(['结束显示:',state, '(',num2str(i),')']);
        %         close all;
    end
end