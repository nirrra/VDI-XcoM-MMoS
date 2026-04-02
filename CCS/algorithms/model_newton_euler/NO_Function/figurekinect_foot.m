clear;
close all;
 %% 预设
%步道坐标系是人为指定的，步道坐标系原点与kinect原始位置固定是远离
i_p =0;  %i_p =0表示步道图片坐标系原点和步道坐标系原点远离
%步道坐标系是人为指定的，步道坐标系原点与kinect原始位置远离
Distance = 1;% 离步道坐标系原点Distance之前的kinect数据由Sub提供
i=1;
%% 步道数据读取
pathname = ['Pathway',' (', num2str(i),')', '.txt'];
kinectname = ['Kinect_Azure',' (', num2str(i),')', '.txt'];
Pathstream = Read_Pathway(pathname);

T_filename = 'Settings.txt';
[Sub2Mas_T,Mas2Pathway_T] = T_Read(T_filename);

% 求解步道板子块数
maxrow  = 0;
for row=1:length(Pathstream.count)
    maxrow(row) =  max(Pathstream.x{row});
end
maxone = max(maxrow);
numpath = double(ceil((maxone)/32));
%步道时间
intial_time_pathway = min(Pathstream.time);
end_time_pathway = max(Pathstream.time);
pathtime_interval = round(seconds(end_time_pathway - intial_time_pathway)/length(Pathstream.count),3);
disp([pathname,':步道采样频率:',num2str(1/pathtime_interval)]);
Pathstream.time=(0:pathtime_interval:(length(Pathstream.time)-1)*pathtime_interval)';
%原始足迹
footprint1 = FootprintMerge(Pathstream, numpath);
%第一次去除坏点
Pathstream = Remove_Bad_Points_Stepone(Pathstream);
%足迹识别
footprint2 = FootprintMerge(Pathstream, numpath);
[label, left, right, n] = Mark(footprint2);%坐标还是原始坐标，向下为x，向右为y
% 第二次去除坏点，脚印之外的点
Pathstream = Remove_Bad_Points_Steptwo(Pathstream,label,n);
% 画脚印
figure;
footprint3 = FootprintMerge(Pathstream, numpath);
subplot(131)
imshow(footprint1)
subplot(132)
imshow(footprint2)
subplot(133)
imshow(footprint3)
% 计算单个脚印时间
for j = 1: 1: n
    %足迹时间
    [x, y] = find(label == j);
    duration =[];
    for k = 1: 1: length(Pathstream.count)
        if ~isempty(intersect([x, y], double([Pathstream.x{k}, Pathstream.y{k}]), 'rows'))
            duration = [duration; Pathstream.time(k)];
        end
    end
    support{j} = duration;  % 算出每隔脚印出现和结束的时间
end

%% 判断步行开始方向，即判断人体坐标系和步道坐标系(认为指定)是否一致
%人体坐标系和步道坐标系一致表示 人从远离kinect端开始行走

start_Proximal = 0; %表示人体坐标系和步道坐标系一致,从远kinect端行走，Proximal：近端的
if(mean(support{n})<mean(support{1})) %从靠近kinect端开始行走
    start_Proximal = 1; %表示从靠近kinect端开始行走,表示人体坐标系和步道坐标系不一致
    supporttemp = support;
    for k = 1:n
        support{k} = supporttemp{n+1-k};
    end
    label = n+1 - label;
    label(label == n+1) = 0;
    lefttemp = n+1-left;
    righttemp = n+1-right;
    right = sort(lefttemp);
    left = sort(righttemp);
end
tstart=1000*min(support{1});
tstop=1000*max(support{n});


%% kinect数据读取
[Mas_stream_all,Sub_stream_all] = Kinect_Azure_Read(kinectname);
%寻找目标人物
for bodyid = 1:length(Mas_stream_all)
    Mas_stream = Mas_stream_all{bodyid};
    % kinect_Azure到步道坐标系
    Kinect_Mas_stream = Transform_Mas2Pathway(Mas2Pathway_T,Mas_stream);
    Kinect_Mas_stream.wtime = seconds(Kinect_Mas_stream.wtime - intial_time_pathway);
    % Mas kinect 找出目标人物
    % 获取有效时间
    match_Mas = find(Kinect_Mas_stream.wtime >= (min(support{1})) & Kinect_Mas_stream.wtime <= (max((support{n}))));
    PELVIS_Mas_x = 0;
    PELVIS_Mas_y = 0;
    for j = 1:length(match_Mas)
        m = match_Mas(j);
        PELVIS_Mas_x(j) = Kinect_Mas_stream.PELVIS.x(m);
        PELVIS_Mas_y(j) = Kinect_Mas_stream.PELVIS.y(m);
    end
    % 识别站在步道上的时间比例，超过0.5 则视为被测对象
    xpencent = length(find(PELVIS_Mas_x >0 & PELVIS_Mas_x<0.48))/length(match_Mas);
    ypencent = length(find(PELVIS_Mas_y >0.32 & PELVIS_Mas_y<(numpath+1)*0.32))/length(match_Mas);
    if xpencent>0.5 && ypencent>0.5
        break;
    end
end
for bodyid = 1:length(Sub_stream_all)
    Sub_stream = Sub_stream_all{bodyid};
    % kinect_Azure到步道坐标系
    Sub_stream = Transform_Sub2Mas(Sub2Mas_T,Sub_stream);
    Kinect_Sub_stream = Transform_Mas2Pathway(Mas2Pathway_T,Sub_stream);
    Kinect_Sub_stream.wtime = seconds(Kinect_Sub_stream.wtime - intial_time_pathway);
    % Sub kinect 找出目标人物
    % 获取有效时间
    PELVIS_Sub_x = 0;
    PELVIS_Sub_y = 0;
    match_Sub = find(Kinect_Sub_stream.wtime >= (min(support{1})) & Kinect_Sub_stream.wtime <= (max((support{n}))));
    for j = 1:length(match_Sub)
        m = match_Sub(j);
        PELVIS_Sub_x(j) = Kinect_Sub_stream.PELVIS.x(m);
        PELVIS_Sub_y(j) = Kinect_Sub_stream.PELVIS.y(m);
    end
    % 识别站在步道上的时间比例，超过0.5 则视为被测对象
    xpencent = length(find(PELVIS_Sub_x >0 & PELVIS_Sub_x<0.48))/length(match_Sub);
    ypencent = length(find(PELVIS_Sub_y >0.32 & PELVIS_Sub_y<(numpath+1)*0.32))/length(match_Sub);
    if xpencent>0.5 && ypencent>0.5
        break;
    end
end
%% kinect 数据合并
Kinectstream = Kinectstream_Merge(Kinect_Mas_stream,Kinect_Sub_stream,start_Proximal,Distance);
match_K_P = find(Kinectstream.wtime >= (min(support{1})) & Kinectstream.wtime <= (max((support{n}))));
%% kinect 转换到人体坐标系
if start_Proximal ==0
    disp('从远kinect端开始行走');
else
    disp('从近kinect端开始行走');
    %步道坐标系到人体坐标系
    Pathway2Human_T = [-1,0,0,0.48;0,-1,0,0.32*numpath;0,0,1,0;0,0,0,1];
    Kinectstream = Transform_Mas2Pathway(Pathway2Human_T,Kinectstream);
end
    %% 绘图
    
    xstart = -0.2;
    xend = 0.6;
    ystart = -1;
    yend = 4;
    zstart = 0;
    zend = 2;
    
    %% 绘图 x视角
    
    figure;
    
    %set(gca, 'LooseInset',[0 0 0 0]);
    set(gcf, 'Position', [0 0 1200 900]);
    handle_footprint = plot3(0,0,0);
    p = plot3(0,0,0);
    
    xlabel('x')
    ylabel('y')
    zlabel('z')
    axis equal;
    axis([xstart,xend,ystart,yend,zstart,zend]);
    view([1 0 0]);
    hold on
    
    for t = tstart:1:tstop
        %画足迹
        if ismember(int32(t), int32(1000*Pathstream.time))
            
            if ishandle(handle_footprint)
                delete(handle_footprint);%把上一次的图像清掉
            end
            
            f = find(int32(1000 * Pathstream.time) == int32(t));
            [X, Y] = img2xy_new(double(Pathstream.x{f, 1}), double(Pathstream.y{f, 1}), numpath,i_p,start_Proximal);
            Z=zeros(length(X),1)+0.01;
            handle_footprint = plot3(X,Y,Z,'.k');
        end
        %画人体
        if ismember(int32(t), int32(1000 * Kinectstream.wtime))
            
            if ishandle(p)
                delete(p);
            end
            
            m = find(int32(1000 * Kinectstream.wtime) == int32(t));
            x1(1)=Kinectstream.PELVIS.x(m) ;y1(1)=Kinectstream.PELVIS.y(m);z1(1)=Kinectstream.PELVIS.z(m);
            x1(2)=Kinectstream.SPINE_NAVAL.x(m);  y1(2)=Kinectstream.SPINE_NAVAL.y(m); z1(2)=Kinectstream.SPINE_NAVAL.z(m);
            %
            x2(1)=Kinectstream.SPINE_NAVAL.x(m);  y2(1)=Kinectstream.SPINE_NAVAL.y(m); z2(1)=Kinectstream.SPINE_NAVAL.z(m);
            x2(2)=Kinectstream.SPINE_CHEST.x(m);  y2(2)=Kinectstream.SPINE_CHEST.y(m); z2(2)=Kinectstream.SPINE_CHEST.z(m);
            %
            x3(1)=Kinectstream.SPINE_CHEST.x(m) ; y3(1)=Kinectstream.SPINE_CHEST.y(m); z3(1)=Kinectstream.SPINE_CHEST.z(m);
            x3(2)=Kinectstream.NECK.x(m);  y3(2)=Kinectstream.NECK.y(m); z3(2)=Kinectstream.NECK.z(m);
            %
            x4(1)=Kinectstream.SPINE_CHEST.x(m) ; y4(1)=Kinectstream.SPINE_CHEST.y(m); z4(1)=Kinectstream.SPINE_CHEST.z(m);
            x4(2)=Kinectstream.CLAVICLE_LEFT.x(m);  y4(2)=Kinectstream.CLAVICLE_LEFT.y(m); z4(2)=Kinectstream.CLAVICLE_LEFT.z(m);
            %
            x5(1)=Kinectstream.CLAVICLE_LEFT.x(m);  y5(1)=Kinectstream.CLAVICLE_LEFT.y(m); z5(1)=Kinectstream.CLAVICLE_LEFT.z(m);
            x5(2)=Kinectstream.SHOULDER_LEFT.x(m);  y5(2)=Kinectstream.SHOULDER_LEFT.y(m); z5(2)=Kinectstream.SHOULDER_LEFT.z(m);
            %
            x6(1)=Kinectstream.SHOULDER_LEFT.x(m);  y6(1)=Kinectstream.SHOULDER_LEFT.y(m); z6(1)=Kinectstream.SHOULDER_LEFT.z(m);
            x6(2)=Kinectstream.ELBOW_LEFT.x(m);  y6(2)=Kinectstream.ELBOW_LEFT.y(m); z6(2)=Kinectstream.ELBOW_LEFT.z(m);
            %
            x7(1)=Kinectstream.ELBOW_LEFT.x(m);  y7(1)=Kinectstream.ELBOW_LEFT.y(m); z7(1)=Kinectstream.ELBOW_LEFT.z(m);
            x7(2)=Kinectstream.WRIST_LEFT.x(m);  y7(2)=Kinectstream.WRIST_LEFT.y(m);  z7(2)=Kinectstream.WRIST_LEFT.z(m);
            %
            x8(1)=Kinectstream.WRIST_LEFT.x(m);  y8(1)=Kinectstream.WRIST_LEFT.y(m);  z8(1)=Kinectstream.WRIST_LEFT.z(m);
            x8(2)=Kinectstream.HAND_LEFT.x(m);   y8(2)=Kinectstream.HAND_LEFT.y(m);  z8(2)=Kinectstream.HAND_LEFT.z(m);
            %
            x9(1)=Kinectstream.HAND_LEFT.x(m);   y9(1)=Kinectstream.HAND_LEFT.y(m);  z9(1)=Kinectstream.HAND_LEFT.z(m);
            x9(2)=Kinectstream.HANDTIP_LEFT.x(m);   y9(2)=Kinectstream.HANDTIP_LEFT.y(m);  z9(2)=Kinectstream.HANDTIP_LEFT.z(m);
            %p
            x10(1)=Kinectstream.WRIST_LEFT.x(m) ; y10(1)=Kinectstream.WRIST_LEFT.y(m); z10(1)=Kinectstream.WRIST_LEFT.z(m);
            x10(2)=Kinectstream.THUMB_LEFT.x(m); y10(2)=Kinectstream.THUMB_LEFT.y(m); z10(2)=Kinectstream.THUMB_LEFT.z(m);
            %
            x11(1)=Kinectstream.SPINE_CHEST.x(m) ; y11(1)=Kinectstream.SPINE_CHEST.y(m); z11(1)=Kinectstream.SPINE_CHEST.z(m);
            x11(2)=Kinectstream.CLAVICLE_RIGHT.x(m); y11(2)=Kinectstream.CLAVICLE_RIGHT.y(m); z11(2)=Kinectstream.CLAVICLE_RIGHT.z(m);
            %
            x12(1)=Kinectstream.CLAVICLE_RIGHT.x(m); y12(1)=Kinectstream.CLAVICLE_RIGHT.y(m); z12(1)=Kinectstream.CLAVICLE_RIGHT.z(m);
            x12(2)=Kinectstream.SHOULDER_RIGHT.x(m); y12(2)=Kinectstream.SHOULDER_RIGHT.y(m); z12(2)=Kinectstream.SHOULDER_RIGHT.z(m);
            %
            x13(1)=Kinectstream.SHOULDER_RIGHT.x(m); y13(1)=Kinectstream.SHOULDER_RIGHT.y(m); z13(1)=Kinectstream.SHOULDER_RIGHT.z(m);
            x13(2)=Kinectstream.ELBOW_RIGHT.x(m);  y13(2)=Kinectstream.ELBOW_RIGHT.y(m); z13(2)=Kinectstream.ELBOW_RIGHT.z(m);
            %
            x14(1)=Kinectstream.ELBOW_RIGHT.x(m);  y14(1)=Kinectstream.ELBOW_RIGHT.y(m); z14(1)=Kinectstream.ELBOW_RIGHT.z(m);
            x14(2)=Kinectstream.WRIST_RIGHT.x(m);  y14(2)=Kinectstream.WRIST_RIGHT.y(m); z14(2)=Kinectstream.WRIST_RIGHT.z(m);
            %
            x15(1)=Kinectstream.WRIST_RIGHT.x(m);  y15(1)=Kinectstream.WRIST_RIGHT.y(m); z15(1)=Kinectstream.WRIST_RIGHT.z(m);
            x15(2)=Kinectstream.HAND_RIGHT.x(m);  y15(2)=Kinectstream.HAND_RIGHT.y(m); z15(2)=Kinectstream.HAND_RIGHT.z(m);
            %
            x16(1)=Kinectstream.HAND_RIGHT.x(m);  y16(1)=Kinectstream.HAND_RIGHT.y(m); z16(1)=Kinectstream.HAND_RIGHT.z(m);
            x16(2)=Kinectstream.HANDTIP_RIGHT.x(m); y16(2)=Kinectstream.HANDTIP_RIGHT.y(m); z16(2)=Kinectstream.HANDTIP_RIGHT.z(m);
            %
            x17(1)=Kinectstream.WRIST_RIGHT.x(m) ; y17(1)=Kinectstream.WRIST_RIGHT.y(m); z17(1)=Kinectstream.WRIST_RIGHT.z(m);
            x17(2)=Kinectstream.THUMB_RIGHT.x(m);    y17(2)=Kinectstream.THUMB_RIGHT.y(m);   z17(2)=Kinectstream.THUMB_RIGHT.z(m);
            %
            x18(1)=Kinectstream.PELVIS.x(m) ; y18(1)=Kinectstream.PELVIS.y(m);  z18(1)=Kinectstream.PELVIS.z(m);
            x18(2)=Kinectstream.HIP_LEFT.x(m); y18(2)=Kinectstream.HIP_LEFT.y(m); z18(2)=Kinectstream.HIP_LEFT.z(m);
            %
            x19(1)=Kinectstream.HIP_LEFT.x(m); y19(1)=Kinectstream.HIP_LEFT.y(m); z19(1)=Kinectstream.HIP_LEFT.z(m);
            x19(2)=Kinectstream.KNEE_LEFT.x(m); y19(2)=Kinectstream.KNEE_LEFT.y(m); z19(2)=Kinectstream.KNEE_LEFT.z(m);
            %
            x20(1)=Kinectstream.KNEE_LEFT.x(m); y20(1)=Kinectstream.KNEE_LEFT.y(m); z20(1)=Kinectstream.KNEE_LEFT.z(m);
            x20(2)=Kinectstream.ANKLE_LEFT.x(m); y20(2)=Kinectstream.ANKLE_LEFT.y(m);    z20(2)=Kinectstream.ANKLE_LEFT.z(m);
            %
            x21(1)=Kinectstream.ANKLE_LEFT.x(m); y21(1)=Kinectstream.ANKLE_LEFT.y(m);    z21(1)=Kinectstream.ANKLE_LEFT.z(m);
            x21(2)=Kinectstream.FOOT_LEFT.x(m); y21(2)=Kinectstream.FOOT_LEFT.y(m);    z21(2)=Kinectstream.FOOT_LEFT.z(m);
            %
            x22(1)=Kinectstream.PELVIS.x(m) ; y22(1)=Kinectstream.PELVIS.y(m); z22(1)=Kinectstream.PELVIS.z(m);
            x22(2)=Kinectstream.HIP_RIGHT.x(m); y22(2)=Kinectstream.HIP_RIGHT.y(m);    z22(2)=Kinectstream.HIP_RIGHT.z(m);
            %
            x23(1)=Kinectstream.HIP_RIGHT.x(m); y23(1)=Kinectstream.HIP_RIGHT.y(m);    z23(1)=Kinectstream.HIP_RIGHT.z(m);
            x23(2)=Kinectstream.KNEE_RIGHT.x(m); y23(2)=Kinectstream.KNEE_RIGHT.y(m);    z23(2)=Kinectstream.KNEE_RIGHT.z(m);
            %
            x24(1)=Kinectstream.KNEE_RIGHT.x(m); y24(1)=Kinectstream.KNEE_RIGHT.y(m);    z24(1)=Kinectstream.KNEE_RIGHT.z(m);
            x24(2)=Kinectstream.ANKLE_RIGHT.x(m); y24(2)=Kinectstream.ANKLE_RIGHT.y(m);    z24(2)=Kinectstream.ANKLE_RIGHT.z(m);
            %
            x25(1)=Kinectstream.ANKLE_RIGHT.x(m); y25(1)=Kinectstream.ANKLE_RIGHT.y(m);    z25(1)=Kinectstream.ANKLE_RIGHT.z(m);
            x25(2)=Kinectstream.FOOT_RIGHT.x(m); y25(2)=Kinectstream.FOOT_RIGHT.y(m);    z25(2)=Kinectstream.FOOT_RIGHT.z(m);
            %%%%%%%%%%%%%%%%%%%%%头部区域
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            x26(1)=Kinectstream.NECK.x(m) ; y26(1)=Kinectstream.NECK.y(m); z26(1)=Kinectstream.NECK.z(m);
            x26(2)=Kinectstream.HEAD.x(m); y26(2)=Kinectstream.HEAD.y(m);    z26(2)=Kinectstream.HEAD.z(m);
            %
            x27(1)=Kinectstream.HEAD.x(m); y27(1)=Kinectstream.HEAD.y(m);    z27(1)=Kinectstream.HEAD.z(m);
            x27(2)=Kinectstream.NOSE.x(m); y27(2)=Kinectstream.NOSE.y(m);    z27(2)=Kinectstream.NOSE.z(m);
            %
            x28(1)=Kinectstream.HEAD.x(m); y28(1)=Kinectstream.HEAD.y(m);    z28(1)=Kinectstream.HEAD.z(m);
            x28(2)=Kinectstream.EYE_LEFT.x(m); y28(2)=Kinectstream.EYE_LEFT.y(m);    z28(2)=Kinectstream.EYE_LEFT.z(m);
            %
            x29(1)=Kinectstream.HEAD.x(m); y29(1)=Kinectstream.HEAD.y(m);    z29(1)=Kinectstream.HEAD.z(m);
            x29(2)=Kinectstream.EAR_LEFT.x(m); y29(2)=Kinectstream.EAR_LEFT.y(m);    z29(2)=Kinectstream.EAR_LEFT.z(m);
            %
            x30(1)=Kinectstream.HEAD.x(m); y30(1)=Kinectstream.HEAD.y(m);    z30(1)=Kinectstream.HEAD.z(m);
            x30(2)=Kinectstream.EYE_RIGHT.x(m); y30(2)=Kinectstream.EYE_RIGHT.y(m);    z30(2)=Kinectstream.EYE_RIGHT.z(m);
            %
            x31(1)=Kinectstream.HEAD.x(m); y31(1)=Kinectstream.HEAD.y(m);    z31(1)=Kinectstream.HEAD.z(m);
            x31(2)=Kinectstream.EAR_RIGHT.x(m); y31(2)=Kinectstream.EAR_RIGHT.y(m);    z31(2)=Kinectstream.EAR_RIGHT.z(m);
            %
            
            %     cla;
            %     hold on
            p= plot3(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,x5,y5,z5,x6,y6,z6,x7,y7,z7,x8,y8,z8,x9,y9,z9,x10,y10,z10,....
                x11,y11,z11,x12,y12,z12,x13,y13,z13,x14,y14,z14,x15,y15,z15,x16,y16,z16,x17,y17,z17,...
                x18,y18,z18,x19,y19,z19,x20,y20,z20,x21,y21,z21,x22,y22,z22,x23,y23,z23,x24,y24,z24,...
                x25,y25,z25,x26,y26,z26,x27,y27,z27,x28,y28,z28,x29,y29,z29,x30,y30,z30,x31,y31,z31);
            %设置线条属性
            %头颈部
            p(29).LineWidth=15;
            p(29).Color='y';
            p(30).LineWidth=1;
            p(30).Color='w';
            p(30).LineStyle='none';
            
            p(28).LineWidth=1;
            p(28).Color='w';
            p(28).LineStyle='none';
            p(31).LineWidth=15;
            p(31).Color='y';
            
            p(27).LineWidth=1;
            p(27).Color='w';
            p(27).LineStyle='none';
            p(26).LineWidth=10;
            p(26).Color='y';
            %左肩手
            p(5).LineWidth=12;
            p(5).Color='b';
            
            p(6).LineWidth=10;
            p(6).Color='b';
            
            p(7).LineWidth=9;
            p(7).Color='b';
            
            p(8).LineWidth=5;
            p(8).Color='y';
            
            p(9).LineWidth=0.1;
            p(9).Color='w';
            p(9).LineStyle='none';
            
            p(10).LineWidth=5;
            p(10).Color='y';
            
            %右肩手
            p(12).LineWidth=12;
            p(12).Color='b';
            
            p(13).LineWidth=10;
            p(13).Color='b';
            
            p(14).LineWidth=9;
            p(14).Color='b';
            
            p(15).LineWidth=5;
            p(15).Color='y';
            
            p(16).LineWidth=0.1;
            p(16).Color='w';
            p(16).LineStyle='none';
            
            p(17).LineWidth=5;
            p(17).Color='y';
            %身躯
            p(3).LineWidth=15;
            p(3).Color='b';
            
            p(4).LineWidth=10;
            p(4).Color='b';
            
            p(11).LineWidth=10;
            p(11).Color='b';
            
            p(2).LineWidth=15;
            p(2).Color='b';
            
            p(1).LineWidth=15;
            p(1).Color='b';
            
            %左下肢
            p(18).LineWidth=8;
            p(18).Color='k';
            
            p(19).LineWidth=13;
            p(19).Color='k';
            
            p(20).LineWidth=10;
            p(20).Color='k';
            
            p(21).LineWidth=8;
            p(21).Color=[0.3 0.3 0.3];
            
            %右下肢
            p(22).LineWidth=8;
            p(22).Color='k';
            
            p(23).LineWidth=13;
            p(23).Color='k';
            
            p(24).LineWidth=10;
            p(24).Color='k';
            
            p(25).LineWidth=8;
            p(25).Color=[0.3 0.3 0.3];
            
            %生成gif
            
            frame=getframe(gcf);
            imind=frame2im(frame);
            [imind,cm] = rgb2ind(imind,256);
            if m==match_K_P(1)
                imwrite(imind,cm,'gaitpkx.gif','gif', 'Loopcount',inf,'DelayTime',0.03);
            else
                imwrite(imind,cm,'gaitpkx.gif','gif','WriteMode','append','DelayTime',0.03);
            end
        end
    end
    hold off
    
    %% 绘图 y视角
    
    
    figure;
    %set(gca, 'LooseInset',[0 0 0 0]);
    set(gcf, 'Position', [0 0 1200 900]);
    handle_footprint = plot3(0,0,0);
    p = plot3(0,0,0);
    xlabel('x')
    ylabel('y')
    zlabel('z')
    axis equal;
    axis([xstart,xend,ystart,yend,zstart,zend]);
    view([0 1 0])
    hold on
    for t = tstart:1:tstop
        %画足迹
        if ismember(int32(t), int32(1000 * Pathstream.time))
            
            if ishandle(handle_footprint)
                delete(handle_footprint);%把上一次的图像清掉
            end
            
            f = find(int32(1000 * Pathstream.time) == int32(t));
            [X, Y] = img2xy_new(double(Pathstream.x{f, 1}), double(Pathstream.y{f, 1}), numpath,i_p,start_Proximal);
            Z=zeros(length(X),1)+0.01;
            handle_footprint = plot3(X,Y,Z,'.k');
        end
        %画人体
        if ismember(int32(t), int32(1000 * Kinectstream.wtime))
            
            if ishandle(p)
                delete(p);
            end
            
            m = find(int32(1000 * Kinectstream.wtime) == int32(t));
            x1(1)=Kinectstream.PELVIS.x(m) ;y1(1)=Kinectstream.PELVIS.y(m);z1(1)=Kinectstream.PELVIS.z(m);
            x1(2)=Kinectstream.SPINE_NAVAL.x(m);  y1(2)=Kinectstream.SPINE_NAVAL.y(m); z1(2)=Kinectstream.SPINE_NAVAL.z(m);
            %
            x2(1)=Kinectstream.SPINE_NAVAL.x(m);  y2(1)=Kinectstream.SPINE_NAVAL.y(m); z2(1)=Kinectstream.SPINE_NAVAL.z(m);
            x2(2)=Kinectstream.SPINE_CHEST.x(m);  y2(2)=Kinectstream.SPINE_CHEST.y(m); z2(2)=Kinectstream.SPINE_CHEST.z(m);
            %
            x3(1)=Kinectstream.SPINE_CHEST.x(m) ; y3(1)=Kinectstream.SPINE_CHEST.y(m); z3(1)=Kinectstream.SPINE_CHEST.z(m);
            x3(2)=Kinectstream.NECK.x(m);  y3(2)=Kinectstream.NECK.y(m); z3(2)=Kinectstream.NECK.z(m);
            %
            x4(1)=Kinectstream.SPINE_CHEST.x(m) ; y4(1)=Kinectstream.SPINE_CHEST.y(m); z4(1)=Kinectstream.SPINE_CHEST.z(m);
            x4(2)=Kinectstream.CLAVICLE_LEFT.x(m);  y4(2)=Kinectstream.CLAVICLE_LEFT.y(m); z4(2)=Kinectstream.CLAVICLE_LEFT.z(m);
            %
            x5(1)=Kinectstream.CLAVICLE_LEFT.x(m);  y5(1)=Kinectstream.CLAVICLE_LEFT.y(m); z5(1)=Kinectstream.CLAVICLE_LEFT.z(m);
            x5(2)=Kinectstream.SHOULDER_LEFT.x(m);  y5(2)=Kinectstream.SHOULDER_LEFT.y(m); z5(2)=Kinectstream.SHOULDER_LEFT.z(m);
            %
            x6(1)=Kinectstream.SHOULDER_LEFT.x(m);  y6(1)=Kinectstream.SHOULDER_LEFT.y(m); z6(1)=Kinectstream.SHOULDER_LEFT.z(m);
            x6(2)=Kinectstream.ELBOW_LEFT.x(m);  y6(2)=Kinectstream.ELBOW_LEFT.y(m); z6(2)=Kinectstream.ELBOW_LEFT.z(m);
            %
            x7(1)=Kinectstream.ELBOW_LEFT.x(m);  y7(1)=Kinectstream.ELBOW_LEFT.y(m); z7(1)=Kinectstream.ELBOW_LEFT.z(m);
            x7(2)=Kinectstream.WRIST_LEFT.x(m);  y7(2)=Kinectstream.WRIST_LEFT.y(m);  z7(2)=Kinectstream.WRIST_LEFT.z(m);
            %
            x8(1)=Kinectstream.WRIST_LEFT.x(m);  y8(1)=Kinectstream.WRIST_LEFT.y(m);  z8(1)=Kinectstream.WRIST_LEFT.z(m);
            x8(2)=Kinectstream.HAND_LEFT.x(m);   y8(2)=Kinectstream.HAND_LEFT.y(m);  z8(2)=Kinectstream.HAND_LEFT.z(m);
            %
            x9(1)=Kinectstream.HAND_LEFT.x(m);   y9(1)=Kinectstream.HAND_LEFT.y(m);  z9(1)=Kinectstream.HAND_LEFT.z(m);
            x9(2)=Kinectstream.HANDTIP_LEFT.x(m);   y9(2)=Kinectstream.HANDTIP_LEFT.y(m);  z9(2)=Kinectstream.HANDTIP_LEFT.z(m);
            %p
            x10(1)=Kinectstream.WRIST_LEFT.x(m) ; y10(1)=Kinectstream.WRIST_LEFT.y(m); z10(1)=Kinectstream.WRIST_LEFT.z(m);
            x10(2)=Kinectstream.THUMB_LEFT.x(m); y10(2)=Kinectstream.THUMB_LEFT.y(m); z10(2)=Kinectstream.THUMB_LEFT.z(m);
            %
            x11(1)=Kinectstream.SPINE_CHEST.x(m) ; y11(1)=Kinectstream.SPINE_CHEST.y(m); z11(1)=Kinectstream.SPINE_CHEST.z(m);
            x11(2)=Kinectstream.CLAVICLE_RIGHT.x(m); y11(2)=Kinectstream.CLAVICLE_RIGHT.y(m); z11(2)=Kinectstream.CLAVICLE_RIGHT.z(m);
            %
            x12(1)=Kinectstream.CLAVICLE_RIGHT.x(m); y12(1)=Kinectstream.CLAVICLE_RIGHT.y(m); z12(1)=Kinectstream.CLAVICLE_RIGHT.z(m);
            x12(2)=Kinectstream.SHOULDER_RIGHT.x(m); y12(2)=Kinectstream.SHOULDER_RIGHT.y(m); z12(2)=Kinectstream.SHOULDER_RIGHT.z(m);
            %
            x13(1)=Kinectstream.SHOULDER_RIGHT.x(m); y13(1)=Kinectstream.SHOULDER_RIGHT.y(m); z13(1)=Kinectstream.SHOULDER_RIGHT.z(m);
            x13(2)=Kinectstream.ELBOW_RIGHT.x(m);  y13(2)=Kinectstream.ELBOW_RIGHT.y(m); z13(2)=Kinectstream.ELBOW_RIGHT.z(m);
            %
            x14(1)=Kinectstream.ELBOW_RIGHT.x(m);  y14(1)=Kinectstream.ELBOW_RIGHT.y(m); z14(1)=Kinectstream.ELBOW_RIGHT.z(m);
            x14(2)=Kinectstream.WRIST_RIGHT.x(m);  y14(2)=Kinectstream.WRIST_RIGHT.y(m); z14(2)=Kinectstream.WRIST_RIGHT.z(m);
            %
            x15(1)=Kinectstream.WRIST_RIGHT.x(m);  y15(1)=Kinectstream.WRIST_RIGHT.y(m); z15(1)=Kinectstream.WRIST_RIGHT.z(m);
            x15(2)=Kinectstream.HAND_RIGHT.x(m);  y15(2)=Kinectstream.HAND_RIGHT.y(m); z15(2)=Kinectstream.HAND_RIGHT.z(m);
            %
            x16(1)=Kinectstream.HAND_RIGHT.x(m);  y16(1)=Kinectstream.HAND_RIGHT.y(m); z16(1)=Kinectstream.HAND_RIGHT.z(m);
            x16(2)=Kinectstream.HANDTIP_RIGHT.x(m); y16(2)=Kinectstream.HANDTIP_RIGHT.y(m); z16(2)=Kinectstream.HANDTIP_RIGHT.z(m);
            %
            x17(1)=Kinectstream.WRIST_RIGHT.x(m) ; y17(1)=Kinectstream.WRIST_RIGHT.y(m); z17(1)=Kinectstream.WRIST_RIGHT.z(m);
            x17(2)=Kinectstream.THUMB_RIGHT.x(m);    y17(2)=Kinectstream.THUMB_RIGHT.y(m);   z17(2)=Kinectstream.THUMB_RIGHT.z(m);
            %
            x18(1)=Kinectstream.PELVIS.x(m) ; y18(1)=Kinectstream.PELVIS.y(m);  z18(1)=Kinectstream.PELVIS.z(m);
            x18(2)=Kinectstream.HIP_LEFT.x(m); y18(2)=Kinectstream.HIP_LEFT.y(m); z18(2)=Kinectstream.HIP_LEFT.z(m);
            %
            x19(1)=Kinectstream.HIP_LEFT.x(m); y19(1)=Kinectstream.HIP_LEFT.y(m); z19(1)=Kinectstream.HIP_LEFT.z(m);
            x19(2)=Kinectstream.KNEE_LEFT.x(m); y19(2)=Kinectstream.KNEE_LEFT.y(m); z19(2)=Kinectstream.KNEE_LEFT.z(m);
            %
            x20(1)=Kinectstream.KNEE_LEFT.x(m); y20(1)=Kinectstream.KNEE_LEFT.y(m); z20(1)=Kinectstream.KNEE_LEFT.z(m);
            x20(2)=Kinectstream.ANKLE_LEFT.x(m); y20(2)=Kinectstream.ANKLE_LEFT.y(m);    z20(2)=Kinectstream.ANKLE_LEFT.z(m);
            %
            x21(1)=Kinectstream.ANKLE_LEFT.x(m); y21(1)=Kinectstream.ANKLE_LEFT.y(m);    z21(1)=Kinectstream.ANKLE_LEFT.z(m);
            x21(2)=Kinectstream.FOOT_LEFT.x(m); y21(2)=Kinectstream.FOOT_LEFT.y(m);    z21(2)=Kinectstream.FOOT_LEFT.z(m);
            %
            x22(1)=Kinectstream.PELVIS.x(m) ; y22(1)=Kinectstream.PELVIS.y(m); z22(1)=Kinectstream.PELVIS.z(m);
            x22(2)=Kinectstream.HIP_RIGHT.x(m); y22(2)=Kinectstream.HIP_RIGHT.y(m);    z22(2)=Kinectstream.HIP_RIGHT.z(m);
            %
            x23(1)=Kinectstream.HIP_RIGHT.x(m); y23(1)=Kinectstream.HIP_RIGHT.y(m);    z23(1)=Kinectstream.HIP_RIGHT.z(m);
            x23(2)=Kinectstream.KNEE_RIGHT.x(m); y23(2)=Kinectstream.KNEE_RIGHT.y(m);    z23(2)=Kinectstream.KNEE_RIGHT.z(m);
            %
            x24(1)=Kinectstream.KNEE_RIGHT.x(m); y24(1)=Kinectstream.KNEE_RIGHT.y(m);    z24(1)=Kinectstream.KNEE_RIGHT.z(m);
            x24(2)=Kinectstream.ANKLE_RIGHT.x(m); y24(2)=Kinectstream.ANKLE_RIGHT.y(m);    z24(2)=Kinectstream.ANKLE_RIGHT.z(m);
            %
            x25(1)=Kinectstream.ANKLE_RIGHT.x(m); y25(1)=Kinectstream.ANKLE_RIGHT.y(m);    z25(1)=Kinectstream.ANKLE_RIGHT.z(m);
            x25(2)=Kinectstream.FOOT_RIGHT.x(m); y25(2)=Kinectstream.FOOT_RIGHT.y(m);    z25(2)=Kinectstream.FOOT_RIGHT.z(m);
            %%%%%%%%%%%%%%%%%%%%%头部区域
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            x26(1)=Kinectstream.NECK.x(m) ; y26(1)=Kinectstream.NECK.y(m); z26(1)=Kinectstream.NECK.z(m);
            x26(2)=Kinectstream.HEAD.x(m); y26(2)=Kinectstream.HEAD.y(m);    z26(2)=Kinectstream.HEAD.z(m);
            %
            x27(1)=Kinectstream.HEAD.x(m); y27(1)=Kinectstream.HEAD.y(m);    z27(1)=Kinectstream.HEAD.z(m);
            x27(2)=Kinectstream.NOSE.x(m); y27(2)=Kinectstream.NOSE.y(m);    z27(2)=Kinectstream.NOSE.z(m);
            %
            x28(1)=Kinectstream.HEAD.x(m); y28(1)=Kinectstream.HEAD.y(m);    z28(1)=Kinectstream.HEAD.z(m);
            x28(2)=Kinectstream.EYE_LEFT.x(m); y28(2)=Kinectstream.EYE_LEFT.y(m);    z28(2)=Kinectstream.EYE_LEFT.z(m);
            %
            x29(1)=Kinectstream.HEAD.x(m); y29(1)=Kinectstream.HEAD.y(m);    z29(1)=Kinectstream.HEAD.z(m);
            x29(2)=Kinectstream.EAR_LEFT.x(m); y29(2)=Kinectstream.EAR_LEFT.y(m);    z29(2)=Kinectstream.EAR_LEFT.z(m);
            %
            x30(1)=Kinectstream.HEAD.x(m); y30(1)=Kinectstream.HEAD.y(m);    z30(1)=Kinectstream.HEAD.z(m);
            x30(2)=Kinectstream.EYE_RIGHT.x(m); y30(2)=Kinectstream.EYE_RIGHT.y(m);    z30(2)=Kinectstream.EYE_RIGHT.z(m);
            %
            x31(1)=Kinectstream.HEAD.x(m); y31(1)=Kinectstream.HEAD.y(m);    z31(1)=Kinectstream.HEAD.z(m);
            x31(2)=Kinectstream.EAR_RIGHT.x(m); y31(2)=Kinectstream.EAR_RIGHT.y(m);    z31(2)=Kinectstream.EAR_RIGHT.z(m);
            %
            
            %             cla;
            %             hold on
            p= plot3(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,x5,y5,z5,x6,y6,z6,x7,y7,z7,x8,y8,z8,x9,y9,z9,x10,y10,z10,....
                x11,y11,z11,x12,y12,z12,x13,y13,z13,x14,y14,z14,x15,y15,z15,x16,y16,z16,x17,y17,z17,...
                x18,y18,z18,x19,y19,z19,x20,y20,z20,x21,y21,z21,x22,y22,z22,x23,y23,z23,x24,y24,z24,...
                x25,y25,z25,x26,y26,z26,x27,y27,z27,x28,y28,z28,x29,y29,z29,x30,y30,z30,x31,y31,z31);
            
            %设置线条属性
            %头颈部
            p(29).LineWidth=30;
            p(29).Color='y';
            p(30).LineWidth=1;
            p(30).Color='w';
            p(28).LineStyle='none';
            
            
            p(28).LineWidth=1;
            p(28).Color='w';
            p(28).LineStyle='none';
            p(31).LineWidth=30;
            p(31).Color='y';
            
            p(27).LineWidth=1;
            p(27).Color='w';
            p(27).LineStyle='none';
            p(26).LineWidth=15;
            p(26).Color='y';
            %左肩手
            p(5).LineWidth=22;
            p(5).Color='b';
            
            p(6).LineWidth=20;
            p(6).Color='b';
            
            p(7).LineWidth=19;
            p(7).Color='b';
            
            p(8).LineWidth=10;
            p(8).Color='y';
            
            p(9).LineWidth=0.1;
            p(9).Color='w';
            p(9).LineStyle='none';
            
            p(10).LineWidth=10;
            p(10).Color='y';
            
            %右肩手
            p(12).LineWidth=22;
            p(12).Color='b';
            
            p(13).LineWidth=20;
            p(13).Color='b';
            
            p(14).LineWidth=19;
            p(14).Color='b';
            
            p(15).LineWidth=10;
            p(15).Color='y';
            
            p(16).LineWidth=0.1;
            p(16).Color='w';
            p(16).LineStyle='none';
            
            p(17).LineWidth=10;
            p(17).Color='y';
            %身躯
            p(3).LineWidth=40;
            p(3).Color='b';
            
            p(4).LineWidth=50;
            p(4).Color='b';
            
            p(11).LineWidth=50;
            p(11).Color='b';
            
            p(2).LineWidth=50;
            p(2).Color='b';
            
            p(1).LineWidth=50;
            p(1).Color='b';
            
            %左下肢
            p(18).LineWidth=2;
            p(18).Color='k';
            
            p(19).LineWidth=30;
            p(19).Color='k';
            
            p(20).LineWidth=20;
            p(20).Color='k';
            
            p(21).LineWidth=20;
            p(21).Color=[0.3 0.3 0.3];
            
            %右下肢
            p(22).LineWidth=2;
            p(22).Color='k';
            
            p(23).LineWidth=30;
            p(23).Color='k';
            
            p(24).LineWidth=20;
            p(24).Color='k';
            
            p(25).LineWidth=20;
            p(25).Color=[0.3 0.3 0.3];
            
            
            p(32)=plot3(x26(2)-0.035,y28(2),z26(2)+0.07,'.k','MarkerSize',30);%左眼睛
            p(33)=plot3(x26(2)+0.035,y28(2),z26(2)+0.07,'.k','MarkerSize',30);%右眼睛
            p(34)=plot3(x26(2),y28(2),z26(2),'.k','MarkerSize',30);%嘴巴
            %生成gif
            frame=getframe(gcf);
            imind=frame2im(frame);
            [imind,cm] = rgb2ind(imind,256);
            if m==match_K_P(1)
                imwrite(imind,cm,'gaitpky.gif','gif', 'Loopcount',inf,'DelayTime',0.03);
            else
                imwrite(imind,cm,'gaitpky.gif','gif','WriteMode','append','DelayTime',0.03);
            end
        end
    end
    hold off
    %% 绘图 z视角
    
    figure;
    set(gcf, 'Position', [0 0 1200 900]);
    
    handle_footprint = plot3(0,0,0);
    p = plot3(0,0,0);
    xlabel('x')
    ylabel('y')
    zlabel('z')
    axis equal;
    axis([xstart,xend,ystart,yend,zstart,zend]);
    view([0 0 1])
    hold on
    for t = tstart:1:tstop
        %画足迹
        if ismember(int32(t), int32(1000 * Pathstream.time))
            
            if ishandle(handle_footprint)
                delete(handle_footprint);%把上一次的图像清掉
            end
            
            f = find(int32(1000 * Pathstream.time) == int(t));
            [X, Y] = img2xy_new(double(Pathstream.x{f, 1}), double(Pathstream.y{f, 1}), numpath,i_p,start_Proximal);
            Z=zeros(length(X),1)+0.01;
            handle_footprint = plot3(X,Y,Z,'.k');
        end
        %画人体
        if ismember(int32(t), int32(1000 * Kinectstream.wtime))
            
            if ishandle(p)
                delete(p);
            end
            
            m = find(int32(1000 * Kinectstream.wtime) == int32(t));
            
            x1(1)=Kinectstream.PELVIS.x(m) ;y1(1)=Kinectstream.PELVIS.y(m);z1(1)=Kinectstream.PELVIS.z(m);
            x1(2)=Kinectstream.SPINE_NAVAL.x(m);  y1(2)=Kinectstream.SPINE_NAVAL.y(m); z1(2)=Kinectstream.SPINE_NAVAL.z(m);
            %
            x2(1)=Kinectstream.SPINE_NAVAL.x(m);  y2(1)=Kinectstream.SPINE_NAVAL.y(m); z2(1)=Kinectstream.SPINE_NAVAL.z(m);
            x2(2)=Kinectstream.SPINE_CHEST.x(m);  y2(2)=Kinectstream.SPINE_CHEST.y(m); z2(2)=Kinectstream.SPINE_CHEST.z(m);
            %
            x3(1)=Kinectstream.SPINE_CHEST.x(m) ; y3(1)=Kinectstream.SPINE_CHEST.y(m); z3(1)=Kinectstream.SPINE_CHEST.z(m);
            x3(2)=Kinectstream.NECK.x(m);  y3(2)=Kinectstream.NECK.y(m); z3(2)=Kinectstream.NECK.z(m);
            %
            x4(1)=Kinectstream.SPINE_CHEST.x(m) ; y4(1)=Kinectstream.SPINE_CHEST.y(m); z4(1)=Kinectstream.SPINE_CHEST.z(m);
            x4(2)=Kinectstream.CLAVICLE_LEFT.x(m);  y4(2)=Kinectstream.CLAVICLE_LEFT.y(m); z4(2)=Kinectstream.CLAVICLE_LEFT.z(m);
            %
            x5(1)=Kinectstream.CLAVICLE_LEFT.x(m);  y5(1)=Kinectstream.CLAVICLE_LEFT.y(m); z5(1)=Kinectstream.CLAVICLE_LEFT.z(m);
            x5(2)=Kinectstream.SHOULDER_LEFT.x(m);  y5(2)=Kinectstream.SHOULDER_LEFT.y(m); z5(2)=Kinectstream.SHOULDER_LEFT.z(m);
            %
            x6(1)=Kinectstream.SHOULDER_LEFT.x(m);  y6(1)=Kinectstream.SHOULDER_LEFT.y(m); z6(1)=Kinectstream.SHOULDER_LEFT.z(m);
            x6(2)=Kinectstream.ELBOW_LEFT.x(m);  y6(2)=Kinectstream.ELBOW_LEFT.y(m); z6(2)=Kinectstream.ELBOW_LEFT.z(m);
            %
            x7(1)=Kinectstream.ELBOW_LEFT.x(m);  y7(1)=Kinectstream.ELBOW_LEFT.y(m); z7(1)=Kinectstream.ELBOW_LEFT.z(m);
            x7(2)=Kinectstream.WRIST_LEFT.x(m);  y7(2)=Kinectstream.WRIST_LEFT.y(m);  z7(2)=Kinectstream.WRIST_LEFT.z(m);
            %
            x8(1)=Kinectstream.WRIST_LEFT.x(m);  y8(1)=Kinectstream.WRIST_LEFT.y(m);  z8(1)=Kinectstream.WRIST_LEFT.z(m);
            x8(2)=Kinectstream.HAND_LEFT.x(m);   y8(2)=Kinectstream.HAND_LEFT.y(m);  z8(2)=Kinectstream.HAND_LEFT.z(m);
            %
            x9(1)=Kinectstream.HAND_LEFT.x(m);   y9(1)=Kinectstream.HAND_LEFT.y(m);  z9(1)=Kinectstream.HAND_LEFT.z(m);
            x9(2)=Kinectstream.HANDTIP_LEFT.x(m);   y9(2)=Kinectstream.HANDTIP_LEFT.y(m);  z9(2)=Kinectstream.HANDTIP_LEFT.z(m);
            %p
            x10(1)=Kinectstream.WRIST_LEFT.x(m) ; y10(1)=Kinectstream.WRIST_LEFT.y(m); z10(1)=Kinectstream.WRIST_LEFT.z(m);
            x10(2)=Kinectstream.THUMB_LEFT.x(m); y10(2)=Kinectstream.THUMB_LEFT.y(m); z10(2)=Kinectstream.THUMB_LEFT.z(m);
            %
            x11(1)=Kinectstream.SPINE_CHEST.x(m) ; y11(1)=Kinectstream.SPINE_CHEST.y(m); z11(1)=Kinectstream.SPINE_CHEST.z(m);
            x11(2)=Kinectstream.CLAVICLE_RIGHT.x(m); y11(2)=Kinectstream.CLAVICLE_RIGHT.y(m); z11(2)=Kinectstream.CLAVICLE_RIGHT.z(m);
            %
            x12(1)=Kinectstream.CLAVICLE_RIGHT.x(m); y12(1)=Kinectstream.CLAVICLE_RIGHT.y(m); z12(1)=Kinectstream.CLAVICLE_RIGHT.z(m);
            x12(2)=Kinectstream.SHOULDER_RIGHT.x(m); y12(2)=Kinectstream.SHOULDER_RIGHT.y(m); z12(2)=Kinectstream.SHOULDER_RIGHT.z(m);
            %
            x13(1)=Kinectstream.SHOULDER_RIGHT.x(m); y13(1)=Kinectstream.SHOULDER_RIGHT.y(m); z13(1)=Kinectstream.SHOULDER_RIGHT.z(m);
            x13(2)=Kinectstream.ELBOW_RIGHT.x(m);  y13(2)=Kinectstream.ELBOW_RIGHT.y(m); z13(2)=Kinectstream.ELBOW_RIGHT.z(m);
            %
            x14(1)=Kinectstream.ELBOW_RIGHT.x(m);  y14(1)=Kinectstream.ELBOW_RIGHT.y(m); z14(1)=Kinectstream.ELBOW_RIGHT.z(m);
            x14(2)=Kinectstream.WRIST_RIGHT.x(m);  y14(2)=Kinectstream.WRIST_RIGHT.y(m); z14(2)=Kinectstream.WRIST_RIGHT.z(m);
            %
            x15(1)=Kinectstream.WRIST_RIGHT.x(m);  y15(1)=Kinectstream.WRIST_RIGHT.y(m); z15(1)=Kinectstream.WRIST_RIGHT.z(m);
            x15(2)=Kinectstream.HAND_RIGHT.x(m);  y15(2)=Kinectstream.HAND_RIGHT.y(m); z15(2)=Kinectstream.HAND_RIGHT.z(m);
            %
            x16(1)=Kinectstream.HAND_RIGHT.x(m);  y16(1)=Kinectstream.HAND_RIGHT.y(m); z16(1)=Kinectstream.HAND_RIGHT.z(m);
            x16(2)=Kinectstream.HANDTIP_RIGHT.x(m); y16(2)=Kinectstream.HANDTIP_RIGHT.y(m); z16(2)=Kinectstream.HANDTIP_RIGHT.z(m);
            %
            x17(1)=Kinectstream.WRIST_RIGHT.x(m) ; y17(1)=Kinectstream.WRIST_RIGHT.y(m); z17(1)=Kinectstream.WRIST_RIGHT.z(m);
            x17(2)=Kinectstream.THUMB_RIGHT.x(m);    y17(2)=Kinectstream.THUMB_RIGHT.y(m);   z17(2)=Kinectstream.THUMB_RIGHT.z(m);
            %
            x18(1)=Kinectstream.PELVIS.x(m) ; y18(1)=Kinectstream.PELVIS.y(m);  z18(1)=Kinectstream.PELVIS.z(m);
            x18(2)=Kinectstream.HIP_LEFT.x(m); y18(2)=Kinectstream.HIP_LEFT.y(m); z18(2)=Kinectstream.HIP_LEFT.z(m);
            %
            x19(1)=Kinectstream.HIP_LEFT.x(m); y19(1)=Kinectstream.HIP_LEFT.y(m); z19(1)=Kinectstream.HIP_LEFT.z(m);
            x19(2)=Kinectstream.KNEE_LEFT.x(m); y19(2)=Kinectstream.KNEE_LEFT.y(m); z19(2)=Kinectstream.KNEE_LEFT.z(m);
            %
            x20(1)=Kinectstream.KNEE_LEFT.x(m); y20(1)=Kinectstream.KNEE_LEFT.y(m); z20(1)=Kinectstream.KNEE_LEFT.z(m);
            x20(2)=Kinectstream.ANKLE_LEFT.x(m); y20(2)=Kinectstream.ANKLE_LEFT.y(m);    z20(2)=Kinectstream.ANKLE_LEFT.z(m);
            %
            x21(1)=Kinectstream.ANKLE_LEFT.x(m); y21(1)=Kinectstream.ANKLE_LEFT.y(m);    z21(1)=Kinectstream.ANKLE_LEFT.z(m);
            x21(2)=Kinectstream.FOOT_LEFT.x(m); y21(2)=Kinectstream.FOOT_LEFT.y(m);    z21(2)=Kinectstream.FOOT_LEFT.z(m);
            %
            x22(1)=Kinectstream.PELVIS.x(m) ; y22(1)=Kinectstream.PELVIS.y(m); z22(1)=Kinectstream.PELVIS.z(m);
            x22(2)=Kinectstream.HIP_RIGHT.x(m); y22(2)=Kinectstream.HIP_RIGHT.y(m);    z22(2)=Kinectstream.HIP_RIGHT.z(m);
            %
            x23(1)=Kinectstream.HIP_RIGHT.x(m); y23(1)=Kinectstream.HIP_RIGHT.y(m);    z23(1)=Kinectstream.HIP_RIGHT.z(m);
            x23(2)=Kinectstream.KNEE_RIGHT.x(m); y23(2)=Kinectstream.KNEE_RIGHT.y(m);    z23(2)=Kinectstream.KNEE_RIGHT.z(m);
            %
            x24(1)=Kinectstream.KNEE_RIGHT.x(m); y24(1)=Kinectstream.KNEE_RIGHT.y(m);    z24(1)=Kinectstream.KNEE_RIGHT.z(m);
            x24(2)=Kinectstream.ANKLE_RIGHT.x(m); y24(2)=Kinectstream.ANKLE_RIGHT.y(m);    z24(2)=Kinectstream.ANKLE_RIGHT.z(m);
            %
            x25(1)=Kinectstream.ANKLE_RIGHT.x(m); y25(1)=Kinectstream.ANKLE_RIGHT.y(m);    z25(1)=Kinectstream.ANKLE_RIGHT.z(m);
            x25(2)=Kinectstream.FOOT_RIGHT.x(m); y25(2)=Kinectstream.FOOT_RIGHT.y(m);    z25(2)=Kinectstream.FOOT_RIGHT.z(m);
            %%%%%%%%%%%%%%%%%%%%%头部区域
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            x26(1)=Kinectstream.NECK.x(m) ; y26(1)=Kinectstream.NECK.y(m); z26(1)=Kinectstream.NECK.z(m);
            x26(2)=Kinectstream.HEAD.x(m); y26(2)=Kinectstream.HEAD.y(m);    z26(2)=Kinectstream.HEAD.z(m);
            %
            x27(1)=Kinectstream.HEAD.x(m); y27(1)=Kinectstream.HEAD.y(m);    z27(1)=Kinectstream.HEAD.z(m);
            x27(2)=Kinectstream.NOSE.x(m); y27(2)=Kinectstream.NOSE.y(m);    z27(2)=Kinectstream.NOSE.z(m);
            %
            x28(1)=Kinectstream.HEAD.x(m); y28(1)=Kinectstream.HEAD.y(m);    z28(1)=Kinectstream.HEAD.z(m);
            x28(2)=Kinectstream.EYE_LEFT.x(m); y28(2)=Kinectstream.EYE_LEFT.y(m);    z28(2)=Kinectstream.EYE_LEFT.z(m);
            %
            x29(1)=Kinectstream.HEAD.x(m); y29(1)=Kinectstream.HEAD.y(m);    z29(1)=Kinectstream.HEAD.z(m);
            x29(2)=Kinectstream.EAR_LEFT.x(m); y29(2)=Kinectstream.EAR_LEFT.y(m);    z29(2)=Kinectstream.EAR_LEFT.z(m);
            %
            x30(1)=Kinectstream.HEAD.x(m); y30(1)=Kinectstream.HEAD.y(m);    z30(1)=Kinectstream.HEAD.z(m);
            x30(2)=Kinectstream.EYE_RIGHT.x(m); y30(2)=Kinectstream.EYE_RIGHT.y(m);    z30(2)=Kinectstream.EYE_RIGHT.z(m);
            %
            x31(1)=Kinectstream.HEAD.x(m); y31(1)=Kinectstream.HEAD.y(m);    z31(1)=Kinectstream.HEAD.z(m);
            x31(2)=Kinectstream.EAR_RIGHT.x(m); y31(2)=Kinectstream.EAR_RIGHT.y(m);    z31(2)=Kinectstream.EAR_RIGHT.z(m);
            %
            
            %             cla;
            %             hold on
            p= plot3(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,x5,y5,z5,x6,y6,z6,x7,y7,z7,x8,y8,z8,x9,y9,z9,x10,y10,z10,....
                x11,y11,z11,x12,y12,z12,x13,y13,z13,x14,y14,z14,x15,y15,z15,x16,y16,z16,x17,y17,z17,...
                x18,y18,z18,x19,y19,z19,x20,y20,z20,x21,y21,z21,x22,y22,z22,x23,y23,z23,x24,y24,z24,...
                x25,y25,z25,x26,y26,z26,x27,y27,z27,x28,y28,z28,x29,y29,z29,x30,y30,z30,x31,y31,z31);
            %设置线条属性
            %头颈部
            p(29).LineWidth=15;
            p(29).Color='y';
            p(30).LineWidth=1;
            p(30).Color='w';
            p(30).LineStyle='none';
            
            p(28).LineWidth=1;
            p(28).Color='w';
            p(28).LineStyle='none';
            p(31).LineWidth=15;
            p(31).Color='y';
            
            p(27).LineWidth=1;
            p(27).Color='w';
            p(27).LineStyle='none';
            p(26).LineWidth=10;
            p(26).Color='y';
            %左肩手
            p(5).LineWidth=12;
            p(5).Color='b';
            
            p(6).LineWidth=10;
            p(6).Color='b';
            
            p(7).LineWidth=9;
            p(7).Color='b';
            
            p(8).LineWidth=5;
            p(8).Color='y';
            
            p(9).LineWidth=0.1;
            p(9).Color='w';
            p(9).LineStyle='none';
            
            p(10).LineWidth=5;
            p(10).Color='y';
            
            %右肩手
            p(12).LineWidth=12;
            p(12).Color='b';
            
            p(13).LineWidth=10;
            p(13).Color='b';
            
            p(14).LineWidth=9;
            p(14).Color='b';
            
            p(15).LineWidth=5;
            p(15).Color='y';
            
            p(16).LineWidth=0.1;
            p(16).Color='w';
            p(16).LineStyle='none';
            
            p(17).LineWidth=5;
            p(17).Color='y';
            %身躯
            p(3).LineWidth=15;
            p(3).Color='b';
            
            p(4).LineWidth=10;
            p(4).Color='b';
            
            p(11).LineWidth=10;
            p(11).Color='b';
            
            p(2).LineWidth=15;
            p(2).Color='b';
            
            p(1).LineWidth=15;
            p(1).Color='b';
            
            %左下肢
            p(18).LineWidth=8;
            p(18).Color='k';
            
            p(19).LineWidth=13;
            p(19).Color='k';
            
            p(20).LineWidth=10;
            p(20).Color='k';
            
            p(21).LineWidth=10;
            p(21).Color=[0.3 0.3 0.3];
            
            %右下肢
            p(22).LineWidth=8;
            p(22).Color='k';
            
            p(23).LineWidth=13;
            p(23).Color='k';
            
            p(24).LineWidth=10;
            p(24).Color='k';
            
            p(25).LineWidth=10;
            p(25).Color=[0.3 0.3 0.3];
            
            %生成gif
            frame=getframe(gcf);
            imind=frame2im(frame);
            [imind,cm] = rgb2ind(imind,256);
            if m==match_K_P(1)
                imwrite(imind,cm,'gaitpkz.gif','gif', 'Loopcount',inf,'DelayTime',0.03);
            else
                imwrite(imind,cm,'gaitpkz.gif','gif','WriteMode','append','DelayTime',0.03);
            end
        end
    end
    hold off
    
    %% 绘图 3d视角
    
    figure;
    set(gcf, 'Position', [0 0 1200 900]);
    handle_footprint = plot3(0,0,0);
    p = plot3(0,0,0);
    xlabel('x')
    ylabel('y')
    zlabel('z')
    axis equal;
    axis([xstart,xend,ystart,yend,zstart,zend]);
    view([1 1 0.5]);
    hold on
    for t = tstart:1:tstop
        %画足迹
        if ismember(int32(t), int32(1000 * Pathstream.time))
            
            if ishandle(handle_footprint)
                delete(handle_footprint);%把上一次的图像清掉
            end
            
            f = find(int32(1000 * Pathstream.time) == int32(t));
            [X, Y] = img2xy_new(double(Pathstream.x{f, 1}), double(Pathstream.y{f, 1}), numpath,i_p,start_Proximal);
            Z=zeros(length(X),1)+0.01;
            handle_footprint = plot3(X,Y,Z,'.k');
        end
        %画人体
        if ismember(int32(t), int32(1000 * Kinectstream.wtime))
            
            if ishandle(p)
                delete(p);
            end
            
            m = find(int32(1000 * Kinectstream.wtime) == int32(t));
            
            x1(1)=Kinectstream.PELVIS.x(m) ;y1(1)=Kinectstream.PELVIS.y(m);z1(1)=Kinectstream.PELVIS.z(m);
            x1(2)=Kinectstream.SPINE_NAVAL.x(m);  y1(2)=Kinectstream.SPINE_NAVAL.y(m); z1(2)=Kinectstream.SPINE_NAVAL.z(m);
            %
            x2(1)=Kinectstream.SPINE_NAVAL.x(m);  y2(1)=Kinectstream.SPINE_NAVAL.y(m); z2(1)=Kinectstream.SPINE_NAVAL.z(m);
            x2(2)=Kinectstream.SPINE_CHEST.x(m);  y2(2)=Kinectstream.SPINE_CHEST.y(m); z2(2)=Kinectstream.SPINE_CHEST.z(m);
            %
            x3(1)=Kinectstream.SPINE_CHEST.x(m) ; y3(1)=Kinectstream.SPINE_CHEST.y(m); z3(1)=Kinectstream.SPINE_CHEST.z(m);
            x3(2)=Kinectstream.NECK.x(m);  y3(2)=Kinectstream.NECK.y(m); z3(2)=Kinectstream.NECK.z(m);
            %
            x4(1)=Kinectstream.SPINE_CHEST.x(m) ; y4(1)=Kinectstream.SPINE_CHEST.y(m); z4(1)=Kinectstream.SPINE_CHEST.z(m);
            x4(2)=Kinectstream.CLAVICLE_LEFT.x(m);  y4(2)=Kinectstream.CLAVICLE_LEFT.y(m); z4(2)=Kinectstream.CLAVICLE_LEFT.z(m);
            %
            x5(1)=Kinectstream.CLAVICLE_LEFT.x(m);  y5(1)=Kinectstream.CLAVICLE_LEFT.y(m); z5(1)=Kinectstream.CLAVICLE_LEFT.z(m);
            x5(2)=Kinectstream.SHOULDER_LEFT.x(m);  y5(2)=Kinectstream.SHOULDER_LEFT.y(m); z5(2)=Kinectstream.SHOULDER_LEFT.z(m);
            %
            x6(1)=Kinectstream.SHOULDER_LEFT.x(m);  y6(1)=Kinectstream.SHOULDER_LEFT.y(m); z6(1)=Kinectstream.SHOULDER_LEFT.z(m);
            x6(2)=Kinectstream.ELBOW_LEFT.x(m);  y6(2)=Kinectstream.ELBOW_LEFT.y(m); z6(2)=Kinectstream.ELBOW_LEFT.z(m);
            %
            x7(1)=Kinectstream.ELBOW_LEFT.x(m);  y7(1)=Kinectstream.ELBOW_LEFT.y(m); z7(1)=Kinectstream.ELBOW_LEFT.z(m);
            x7(2)=Kinectstream.WRIST_LEFT.x(m);  y7(2)=Kinectstream.WRIST_LEFT.y(m);  z7(2)=Kinectstream.WRIST_LEFT.z(m);
            %
            x8(1)=Kinectstream.WRIST_LEFT.x(m);  y8(1)=Kinectstream.WRIST_LEFT.y(m);  z8(1)=Kinectstream.WRIST_LEFT.z(m);
            x8(2)=Kinectstream.HAND_LEFT.x(m);   y8(2)=Kinectstream.HAND_LEFT.y(m);  z8(2)=Kinectstream.HAND_LEFT.z(m);
            %
            x9(1)=Kinectstream.HAND_LEFT.x(m);   y9(1)=Kinectstream.HAND_LEFT.y(m);  z9(1)=Kinectstream.HAND_LEFT.z(m);
            x9(2)=Kinectstream.HANDTIP_LEFT.x(m);   y9(2)=Kinectstream.HANDTIP_LEFT.y(m);  z9(2)=Kinectstream.HANDTIP_LEFT.z(m);
            %p
            x10(1)=Kinectstream.WRIST_LEFT.x(m) ; y10(1)=Kinectstream.WRIST_LEFT.y(m); z10(1)=Kinectstream.WRIST_LEFT.z(m);
            x10(2)=Kinectstream.THUMB_LEFT.x(m); y10(2)=Kinectstream.THUMB_LEFT.y(m); z10(2)=Kinectstream.THUMB_LEFT.z(m);
            %
            x11(1)=Kinectstream.SPINE_CHEST.x(m) ; y11(1)=Kinectstream.SPINE_CHEST.y(m); z11(1)=Kinectstream.SPINE_CHEST.z(m);
            x11(2)=Kinectstream.CLAVICLE_RIGHT.x(m); y11(2)=Kinectstream.CLAVICLE_RIGHT.y(m); z11(2)=Kinectstream.CLAVICLE_RIGHT.z(m);
            %
            x12(1)=Kinectstream.CLAVICLE_RIGHT.x(m); y12(1)=Kinectstream.CLAVICLE_RIGHT.y(m); z12(1)=Kinectstream.CLAVICLE_RIGHT.z(m);
            x12(2)=Kinectstream.SHOULDER_RIGHT.x(m); y12(2)=Kinectstream.SHOULDER_RIGHT.y(m); z12(2)=Kinectstream.SHOULDER_RIGHT.z(m);
            %
            x13(1)=Kinectstream.SHOULDER_RIGHT.x(m); y13(1)=Kinectstream.SHOULDER_RIGHT.y(m); z13(1)=Kinectstream.SHOULDER_RIGHT.z(m);
            x13(2)=Kinectstream.ELBOW_RIGHT.x(m);  y13(2)=Kinectstream.ELBOW_RIGHT.y(m); z13(2)=Kinectstream.ELBOW_RIGHT.z(m);
            %
            x14(1)=Kinectstream.ELBOW_RIGHT.x(m);  y14(1)=Kinectstream.ELBOW_RIGHT.y(m); z14(1)=Kinectstream.ELBOW_RIGHT.z(m);
            x14(2)=Kinectstream.WRIST_RIGHT.x(m);  y14(2)=Kinectstream.WRIST_RIGHT.y(m); z14(2)=Kinectstream.WRIST_RIGHT.z(m);
            %
            x15(1)=Kinectstream.WRIST_RIGHT.x(m);  y15(1)=Kinectstream.WRIST_RIGHT.y(m); z15(1)=Kinectstream.WRIST_RIGHT.z(m);
            x15(2)=Kinectstream.HAND_RIGHT.x(m);  y15(2)=Kinectstream.HAND_RIGHT.y(m); z15(2)=Kinectstream.HAND_RIGHT.z(m);
            %
            x16(1)=Kinectstream.HAND_RIGHT.x(m);  y16(1)=Kinectstream.HAND_RIGHT.y(m); z16(1)=Kinectstream.HAND_RIGHT.z(m);
            x16(2)=Kinectstream.HANDTIP_RIGHT.x(m); y16(2)=Kinectstream.HANDTIP_RIGHT.y(m); z16(2)=Kinectstream.HANDTIP_RIGHT.z(m);
            %
            x17(1)=Kinectstream.WRIST_RIGHT.x(m) ; y17(1)=Kinectstream.WRIST_RIGHT.y(m); z17(1)=Kinectstream.WRIST_RIGHT.z(m);
            x17(2)=Kinectstream.THUMB_RIGHT.x(m);    y17(2)=Kinectstream.THUMB_RIGHT.y(m);   z17(2)=Kinectstream.THUMB_RIGHT.z(m);
            %
            x18(1)=Kinectstream.PELVIS.x(m) ; y18(1)=Kinectstream.PELVIS.y(m);  z18(1)=Kinectstream.PELVIS.z(m);
            x18(2)=Kinectstream.HIP_LEFT.x(m); y18(2)=Kinectstream.HIP_LEFT.y(m); z18(2)=Kinectstream.HIP_LEFT.z(m);
            %
            x19(1)=Kinectstream.HIP_LEFT.x(m); y19(1)=Kinectstream.HIP_LEFT.y(m); z19(1)=Kinectstream.HIP_LEFT.z(m);
            x19(2)=Kinectstream.KNEE_LEFT.x(m); y19(2)=Kinectstream.KNEE_LEFT.y(m); z19(2)=Kinectstream.KNEE_LEFT.z(m);
            %
            x20(1)=Kinectstream.KNEE_LEFT.x(m); y20(1)=Kinectstream.KNEE_LEFT.y(m); z20(1)=Kinectstream.KNEE_LEFT.z(m);
            x20(2)=Kinectstream.ANKLE_LEFT.x(m); y20(2)=Kinectstream.ANKLE_LEFT.y(m);    z20(2)=Kinectstream.ANKLE_LEFT.z(m);
            %
            x21(1)=Kinectstream.ANKLE_LEFT.x(m); y21(1)=Kinectstream.ANKLE_LEFT.y(m);    z21(1)=Kinectstream.ANKLE_LEFT.z(m);
            x21(2)=Kinectstream.FOOT_LEFT.x(m); y21(2)=Kinectstream.FOOT_LEFT.y(m);    z21(2)=Kinectstream.FOOT_LEFT.z(m);
            %
            x22(1)=Kinectstream.PELVIS.x(m) ; y22(1)=Kinectstream.PELVIS.y(m); z22(1)=Kinectstream.PELVIS.z(m);
            x22(2)=Kinectstream.HIP_RIGHT.x(m); y22(2)=Kinectstream.HIP_RIGHT.y(m);    z22(2)=Kinectstream.HIP_RIGHT.z(m);
            %
            x23(1)=Kinectstream.HIP_RIGHT.x(m); y23(1)=Kinectstream.HIP_RIGHT.y(m);    z23(1)=Kinectstream.HIP_RIGHT.z(m);
            x23(2)=Kinectstream.KNEE_RIGHT.x(m); y23(2)=Kinectstream.KNEE_RIGHT.y(m);    z23(2)=Kinectstream.KNEE_RIGHT.z(m);
            %
            x24(1)=Kinectstream.KNEE_RIGHT.x(m); y24(1)=Kinectstream.KNEE_RIGHT.y(m);    z24(1)=Kinectstream.KNEE_RIGHT.z(m);
            x24(2)=Kinectstream.ANKLE_RIGHT.x(m); y24(2)=Kinectstream.ANKLE_RIGHT.y(m);    z24(2)=Kinectstream.ANKLE_RIGHT.z(m);
            %
            x25(1)=Kinectstream.ANKLE_RIGHT.x(m); y25(1)=Kinectstream.ANKLE_RIGHT.y(m);    z25(1)=Kinectstream.ANKLE_RIGHT.z(m);
            x25(2)=Kinectstream.FOOT_RIGHT.x(m); y25(2)=Kinectstream.FOOT_RIGHT.y(m);    z25(2)=Kinectstream.FOOT_RIGHT.z(m);
            %%%%%%%%%%%%%%%%%%%%%头部区域
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            x26(1)=Kinectstream.NECK.x(m) ; y26(1)=Kinectstream.NECK.y(m); z26(1)=Kinectstream.NECK.z(m);
            x26(2)=Kinectstream.HEAD.x(m); y26(2)=Kinectstream.HEAD.y(m);    z26(2)=Kinectstream.HEAD.z(m);
            %
            x27(1)=Kinectstream.HEAD.x(m); y27(1)=Kinectstream.HEAD.y(m);    z27(1)=Kinectstream.HEAD.z(m);
            x27(2)=Kinectstream.NOSE.x(m); y27(2)=Kinectstream.NOSE.y(m);    z27(2)=Kinectstream.NOSE.z(m);
            %
            x28(1)=Kinectstream.HEAD.x(m); y28(1)=Kinectstream.HEAD.y(m);    z28(1)=Kinectstream.HEAD.z(m);
            x28(2)=Kinectstream.EYE_LEFT.x(m); y28(2)=Kinectstream.EYE_LEFT.y(m);    z28(2)=Kinectstream.EYE_LEFT.z(m);
            %
            x29(1)=Kinectstream.HEAD.x(m); y29(1)=Kinectstream.HEAD.y(m);    z29(1)=Kinectstream.HEAD.z(m);
            x29(2)=Kinectstream.EAR_LEFT.x(m); y29(2)=Kinectstream.EAR_LEFT.y(m);    z29(2)=Kinectstream.EAR_LEFT.z(m);
            %
            x30(1)=Kinectstream.HEAD.x(m); y30(1)=Kinectstream.HEAD.y(m);    z30(1)=Kinectstream.HEAD.z(m);
            x30(2)=Kinectstream.EYE_RIGHT.x(m); y30(2)=Kinectstream.EYE_RIGHT.y(m);    z30(2)=Kinectstream.EYE_RIGHT.z(m);
            %
            x31(1)=Kinectstream.HEAD.x(m); y31(1)=Kinectstream.HEAD.y(m);    z31(1)=Kinectstream.HEAD.z(m);
            x31(2)=Kinectstream.EAR_RIGHT.x(m); y31(2)=Kinectstream.EAR_RIGHT.y(m);    z31(2)=Kinectstream.EAR_RIGHT.z(m);
            %
            
            %             cla;
            %             hold on
            p= plot3(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,x5,y5,z5,x6,y6,z6,x7,y7,z7,x8,y8,z8,x9,y9,z9,x10,y10,z10,....
                x11,y11,z11,x12,y12,z12,x13,y13,z13,x14,y14,z14,x15,y15,z15,x16,y16,z16,x17,y17,z17,...
                x18,y18,z18,x19,y19,z19,x20,y20,z20,x21,y21,z21,x22,y22,z22,x23,y23,z23,x24,y24,z24,...
                x25,y25,z25,x26,y26,z26,x27,y27,z27,x28,y28,z28,x29,y29,z29,x30,y30,z30,x31,y31,z31);
            %设置线条属性
            %头颈部
            p(29).LineWidth=15;
            p(29).Color='y';
            p(30).LineWidth=1;
            p(30).Color='w';
            p(30).LineStyle='none';
            
            p(28).LineWidth=1;
            p(28).Color='w';
            p(28).LineStyle='none';
            p(31).LineWidth=15;
            p(31).Color='y';
            
            p(27).LineWidth=1;
            p(27).Color='w';
            p(27).LineStyle='none';
            p(26).LineWidth=10;
            p(26).Color='y';
            %左肩手
            p(5).LineWidth=12;
            p(5).Color='b';
            
            p(6).LineWidth=10;
            p(6).Color='b';
            
            p(7).LineWidth=9;
            p(7).Color='b';
            
            p(8).LineWidth=5;
            p(8).Color='y';
            
            p(9).LineWidth=0.1;
            p(9).Color='w';
            p(9).LineStyle='none';
            
            p(10).LineWidth=5;
            p(10).Color='y';
            
            %右肩手
            p(12).LineWidth=12;
            p(12).Color='b';
            
            p(13).LineWidth=10;
            p(13).Color='b';
            
            p(14).LineWidth=9;
            p(14).Color='b';
            
            p(15).LineWidth=5;
            p(15).Color='y';
            
            p(16).LineWidth=0.1;
            p(16).Color='w';
            p(16).LineStyle='none';
            
            p(17).LineWidth=5;
            p(17).Color='y';
            %身躯
            p(3).LineWidth=15;
            p(3).Color='b';
            
            p(4).LineWidth=10;
            p(4).Color='b';
            
            p(11).LineWidth=10;
            p(11).Color='b';
            
            p(2).LineWidth=15;
            p(2).Color='b';
            
            p(1).LineWidth=15;
            p(1).Color='b';
            
            %左下肢
            p(18).LineWidth=8;
            p(18).Color='k';
            
            p(19).LineWidth=13;
            p(19).Color='k';
            
            p(20).LineWidth=10;
            p(20).Color='k';
            
            p(21).LineWidth=10;
            p(21).Color=[0.3 0.3 0.3];
            
            %右下肢
            p(22).LineWidth=8;
            p(22).Color='k';
            
            p(23).LineWidth=13;
            p(23).Color='k';
            
            p(24).LineWidth=10;
            p(24).Color='k';
            
            p(25).LineWidth=10;
            p(25).Color=[0.3 0.3 0.3];
            %p(32)=plot3(x26(2)-0.035,y28(2)-0.07,z26(2)+0.07,'.k','MarkerSize',20);%左眼睛
            %p(33)=plot3(x26(2)+0.035,y28(2)-0.07,z26(2)+0.07,'.k','MarkerSize',20);%右眼睛
            %p(34)=plot3(x26(2),y28(2)-0.07,z26(2),'.k','MarkerSize',20);%嘴巴
            %生成gif
            frame=getframe(gcf);
            imind=frame2im(frame);
            [imind,cm] = rgb2ind(imind,256);
            if m==match_K_P(1)
                imwrite(imind,cm,'gaitpk3.gif','gif', 'Loopcount',inf,'DelayTime',0.03);
            else
                imwrite(imind,cm,'gaitpk3.gif','gif','WriteMode','append','DelayTime',0.03);
            end
        end
    end
    hold off
    
    
