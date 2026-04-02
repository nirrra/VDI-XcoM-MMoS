
%% 时间跨度,包含的是具有实际意义的单，双支撑相，可以用于生物力学计算
support_time_temp = [];
for i=1:length(single_support_time)
    support_time_temp = [support_time_temp;single_support_time{i}];
    
end
for i=1:length(double_support_time)
    support_time_temp = [support_time_temp;double_support_time{i}];
end
first_index = min(support_time_temp);
end_index = max(support_time_temp);

supporttime = cell(length(support_time),1);
for i = 1:length(support_time)
    supporttime{i} = int32(support_time{i} * 1000);%将时间变成毫秒
end
tstart = min(supporttime{1});%毫秒，int32
tstop= max(supporttime{end});


kinect_cell_arrays = Kinect_Azure_Struct_To_Array(Kinectstream);
%% 地面对人体反作用力
ground_force.x =segments_force.reaction_force_Foot_Left_distal.x + segments_force.reaction_force_Foot_Right_distal.x;
ground_force.y =segments_force.reaction_force_Foot_Left_distal.y + segments_force.reaction_force_Foot_Right_distal.y;
ground_force.z =segments_force.reaction_force_Foot_Left_distal.z + segments_force.reaction_force_Foot_Right_distal.z;
valid_time = (first_index:end_index)/inter_freq;

figure
subplot(3,1,1),plot(valid_time,ground_force.x(first_index:end_index))
title('地面对人体反作用力')
ylabel('x方向，额状面(N)')
subplot(3,1,2),plot(valid_time,ground_force.y(first_index:end_index))
ylabel('y方向，额状面(N)')
subplot(3,1,3),plot(valid_time,ground_force.z(first_index:end_index))
ylabel('z方向，额状面(N)')

% 地面对左脚反作用力
figure
subplot(3,1,1),plot(valid_time,ground_force_Left.x(first_index:end_index))
title('地面对左脚反作用力')
ylabel('x方向，额状面(N)')
subplot(3,1,2),plot(valid_time,ground_force_Left.y(first_index:end_index))
ylabel('y方向，额状面(N)')
subplot(3,1,3),plot(valid_time,ground_force_Left.z(first_index:end_index))
ylabel('z方向，额状面(N)')
% 地面对右脚反作用力
figure
subplot(3,1,1),plot(valid_time,ground_force_Right.x(first_index:end_index))
title('地面对右脚反作用力')
ylabel('x方向，额状面(N)')
subplot(3,1,2),plot(valid_time,ground_force_Right.y(first_index:end_index))
ylabel('y方向，额状面(N)')
subplot(3,1,3),plot(valid_time,ground_force_Right.z(first_index:end_index))
ylabel('z方向，额状面(N)')

%% 地面对人体反作用力偶矩
ground_couple_moment_global.x = ground_couple_moment_global_Left.x + ground_couple_moment_global_Right.x;
ground_couple_moment_global.y = ground_couple_moment_global_Left.y + ground_couple_moment_global_Right.y;
ground_couple_moment_global.z = ground_couple_moment_global_Left.z + ground_couple_moment_global_Right.z;

figure
subplot(3,1,1),plot(valid_time,ground_couple_moment_global.x(first_index:end_index))
title('地面对人体反作用力偶矩')
ylabel('x方向(N*m)')
subplot(3,1,2),plot(valid_time,ground_couple_moment_global.y(first_index:end_index))
ylabel('y方向(N*m)')
subplot(3,1,3),plot(valid_time,ground_couple_moment_global.z(first_index:end_index))
ylabel('z方向(N*m)')

% 地面对左脚反作用力偶矩
figure
subplot(3,1,1),plot(valid_time,ground_couple_moment_global_Left.x(first_index:end_index))
title('地面对左脚反作用力偶矩')
ylabel('x方向(N*m )')
subplot(3,1,2),plot(valid_time,ground_couple_moment_global_Left.y(first_index:end_index))
ylabel('y方向(N*m)')
subplot(3,1,3),plot(valid_time,ground_couple_moment_global_Left.z(first_index:end_index))
ylabel('z方向(N*m)')
% 地面对右脚反作用力偶矩
figure
subplot(3,1,1),plot(valid_time,ground_couple_moment_global_Right.x(first_index:end_index))
title('地面对右脚反作用力偶矩')
ylabel('x方向(N*m)')
subplot(3,1,2),plot(valid_time,ground_couple_moment_global_Right.y(first_index:end_index))
ylabel('y方向(N*m)')
subplot(3,1,3),plot(valid_time,ground_couple_moment_global_Right.z(first_index:end_index))
ylabel('z方向(N*m)')
%% 踝关节力，力矩
% 左踝关节作用力
figure
subplot(3,1,1),plot(valid_time,segments_force.reaction_force_Foot_Left_proximal.x(first_index:end_index))
title('左踝关节受到的作用力')
ylabel('x方向，额状面(N)')
subplot(3,1,2),plot(valid_time,segments_force.reaction_force_Foot_Left_proximal.y(first_index:end_index))
ylabel('y方向，额状面(N)')
subplot(3,1,3),plot(valid_time,segments_force.reaction_force_Foot_Left_proximal.z(first_index:end_index))
ylabel('z方向，额状面(N)')
% 左踝关节作用力矩
figure
for i =1:length(moment_reaction_couple_global.Foot_Left_proximal)
    Foot_Left_proximal_x(i) = moment_reaction_couple_global.Foot_Left_proximal{i}(1);
    Foot_Left_proximal_y(i) = moment_reaction_couple_global.Foot_Left_proximal{i}(2);
    Foot_Left_proximal_z(i) = moment_reaction_couple_global.Foot_Left_proximal{i}(3);
end
subplot(3,1,1),plot(valid_time,Foot_Left_proximal_x(first_index:end_index))
title('左踝关节受到的力矩')
ylabel('x方向，额状面(N*m)')
subplot(3,1,2),plot(valid_time,Foot_Left_proximal_y(first_index:end_index))
ylabel('y方向，额状面(N*m)')
subplot(3,1,3),plot(valid_time,Foot_Left_proximal_z(first_index:end_index))
ylabel('z方向，额状面(N*m)')

% 右踝关节作用力
figure
subplot(3,1,1),plot(valid_time,segments_force.reaction_force_Foot_Right_proximal.x(first_index:end_index))
title('右踝关节受到的作用力')
ylabel('x方向，额状面(N)')
subplot(3,1,2),plot(valid_time,segments_force.reaction_force_Foot_Right_proximal.y(first_index:end_index))
ylabel('y方向，额状面(N)')
subplot(3,1,3),plot(valid_time,segments_force.reaction_force_Foot_Right_proximal.z(first_index:end_index))
ylabel('z方向，额状面(N)')
% 右踝关节作用力矩
figure
for i =1:length(moment_reaction_couple_global.Foot_Right_proximal)
    Foot_Right_proximal_x(i) = moment_reaction_couple_global.Foot_Right_proximal{i}(1);
    Foot_Right_proximal_y(i) = moment_reaction_couple_global.Foot_Right_proximal{i}(2);
    Foot_Right_proximal_z(i) = moment_reaction_couple_global.Foot_Right_proximal{i}(3);
end
subplot(3,1,1),plot(valid_time,Foot_Right_proximal_x(first_index:end_index))
title('右踝关节受到的力矩')
ylabel('x方向，额状面(N*m)')
subplot(3,1,2),plot(valid_time,Foot_Right_proximal_y(first_index:end_index))
ylabel('y方向，额状面(N*m)')
subplot(3,1,3),plot(valid_time,Foot_Right_proximal_z(first_index:end_index))
ylabel('z方向，额状面(N*m)')
%% 膝关节力，力矩
% 左膝关节作用力
figure
subplot(3,1,1),plot(valid_time,segments_force.reaction_force_Shank_Left_proximal.x(first_index:end_index))
title('左膝关节受到的作用力')
ylabel('x方向，额状面(N)')
subplot(3,1,2),plot(valid_time,segments_force.reaction_force_Shank_Left_proximal.y(first_index:end_index))
ylabel('y方向，额状面(N)')
subplot(3,1,3),plot(valid_time,segments_force.reaction_force_Shank_Left_proximal.z(first_index:end_index))
ylabel('z方向，额状面(N)')
% 左膝关节作用力矩
figure
for i =1:length(moment_reaction_couple_global.Shank_Left_proximal)
    Shank_Left_proximal_x(i) = moment_reaction_couple_global.Shank_Left_proximal{i}(1);
    Shank_Left_proximal_y(i) = moment_reaction_couple_global.Shank_Left_proximal{i}(2);
    Shank_Left_proximal_z(i) = moment_reaction_couple_global.Shank_Left_proximal{i}(3);
end
subplot(3,1,1),plot(valid_time,Shank_Left_proximal_x(first_index:end_index))
title('左膝关节受到的力矩')
ylabel('x方向，额状面(N*m)')
subplot(3,1,2),plot(valid_time,Shank_Left_proximal_y(first_index:end_index))
ylabel('y方向，额状面(N*m)')
subplot(3,1,3),plot(valid_time,Shank_Left_proximal_z(first_index:end_index))
ylabel('z方向，额状面(N*m)')

% 右膝关节作用力
figure
subplot(3,1,1),plot(valid_time,segments_force.reaction_force_Shank_Right_proximal.x(first_index:end_index))
title('右膝关节受到的作用力')
ylabel('x方向，额状面(N)')
subplot(3,1,2),plot(valid_time,segments_force.reaction_force_Shank_Right_proximal.y(first_index:end_index))
ylabel('y方向，额状面(N)')
subplot(3,1,3),plot(valid_time,segments_force.reaction_force_Shank_Right_proximal.z(first_index:end_index))
ylabel('z方向，额状面(N)')
% 右膝关节作用力矩
figure
for i =1:length(moment_reaction_couple_global.Shank_Right_proximal)
    Shank_Right_proximal_x(i) = moment_reaction_couple_global.Shank_Right_proximal{i}(1);
    Shank_Right_proximal_y(i) = moment_reaction_couple_global.Shank_Right_proximal{i}(2);
    Shank_Right_proximal_z(i) = moment_reaction_couple_global.Shank_Right_proximal{i}(3);
end
subplot(3,1,1),plot(valid_time,Shank_Right_proximal_x(first_index:end_index))
title('右膝关节受到的力矩')
ylabel('x方向，额状面(N*m)')
subplot(3,1,2),plot(valid_time,Shank_Right_proximal_y(first_index:end_index))
ylabel('y方向，额状面(N*m)')
subplot(3,1,3),plot(valid_time,Shank_Right_proximal_z(first_index:end_index))
ylabel('z方向，额状面(N*m)')

%% 髋关节力，力矩
% 左髋关节作用力
figure
subplot(3,1,1),plot(valid_time,segments_force.reaction_force_Thigh_Left_proximal.x(first_index:end_index))
title('左髋关节受到的作用力')
ylabel('x方向，额状面(N)')
subplot(3,1,2),plot(valid_time,segments_force.reaction_force_Thigh_Left_proximal.y(first_index:end_index))
ylabel('y方向，额状面(N)')
subplot(3,1,3),plot(valid_time,segments_force.reaction_force_Thigh_Left_proximal.z(first_index:end_index))
ylabel('z方向，额状面(N)')
% 左髋关节作用力矩
figure
for i =1:length(moment_reaction_couple_global.Thigh_Left_proximal)
    Thigh_Left_proximal_x(i) = moment_reaction_couple_global.Thigh_Left_proximal{i}(1);
    Thigh_Left_proximal_y(i) = moment_reaction_couple_global.Thigh_Left_proximal{i}(2);
    Thigh_Left_proximal_z(i) = moment_reaction_couple_global.Thigh_Left_proximal{i}(3);
end
subplot(3,1,1),plot(valid_time,Thigh_Left_proximal_x(first_index:end_index))
title('左髋关节受到的力矩')
ylabel('x方向，额状面(N*m)')
subplot(3,1,2),plot(valid_time,Thigh_Left_proximal_y(first_index:end_index))
ylabel('y方向，额状面(N*m)')
subplot(3,1,3),plot(valid_time,Thigh_Left_proximal_z(first_index:end_index))
ylabel('z方向，额状面(N*m)')

% 右髋关节作用力
figure
subplot(3,1,1),plot(valid_time,segments_force.reaction_force_Thigh_Right_proximal.x(first_index:end_index))
title('右髋关节受到的作用力')
ylabel('x方向，额状面(N)')
subplot(3,1,2),plot(valid_time,segments_force.reaction_force_Thigh_Right_proximal.y(first_index:end_index))
ylabel('y方向，额状面(N)')
subplot(3,1,3),plot(valid_time,segments_force.reaction_force_Thigh_Right_proximal.z(first_index:end_index))
ylabel('z方向，额状面(N)')
% 右髋关节作用力矩
figure
for i =1:length(moment_reaction_couple_global.Thigh_Right_proximal)
    Thigh_Right_proximal_x(i) = moment_reaction_couple_global.Thigh_Right_proximal{i}(1);
    Thigh_Right_proximal_y(i) = moment_reaction_couple_global.Thigh_Right_proximal{i}(2);
    Thigh_Right_proximal_z(i) = moment_reaction_couple_global.Thigh_Right_proximal{i}(3);
end
subplot(3,1,1),plot(valid_time,Thigh_Right_proximal_x(first_index:end_index))
title('右髋关节受到的力矩')
ylabel('x方向，额状面(N*m)')
subplot(3,1,2),plot(valid_time,Thigh_Right_proximal_y(first_index:end_index))
ylabel('y方向，额状面(N*m)')
subplot(3,1,3),plot(valid_time,Thigh_Right_proximal_z(first_index:end_index))
ylabel('z方向，额状面(N*m)')
%%
close all;
%% 绘制动图 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 地面对人体反作用力绘动图
%设置坐标范围
xstart = -0.1;
xend =  0.7;
ystart = -0.32;
yend = (numpath + 1) * 0.32;

zstart = -0.1;
zend = 1.8;

m1 = find(Kinectstream.wtime > double(tstart)/1000,1,'first');
m2 = find(Kinectstream.wtime < double(tstop)/1000,1,'last');
% 算出左脚刚开始接触地面的时间
leftfootcontacttime = [];
leftfootleavetime = [];
for i=1:length(left)
    leftfootcontacttime(i) = min(supporttime{left(i)});
end

for i=1:length(left)
    leftfootleavetime(i) = max(supporttime{left(i)});
end

% 算出右脚刚开始接触地面的时间
rightfootcontacttime = [];
rightfootleavetime = [];
for i=1:length(right)
    rightfootcontacttime(i) = min(supporttime{right(i)});
end

for i=1:length(right)
    rightfootleavetime(i) = max(supporttime{right(i)});
end

ground_force_xstart = double(tstart)/1000;
ground_force_xend = double(tstop)/1000;

% 设置%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%dt,表示每帧画图时的延迟时间，单位秒
%dt = 1/inter_freq;%间隔时间,实际间隔matlab处理不了，可能与主机性能有关
dt = 0.03;%间隔时间
color3 = {[0 1 0],[0.8500 0.3250 0.0980],[0.3 0.3 1]};%色彩关节点，肢体，须佐
gifsize = [720 1080];%大小
axislimb = [xstart,xend, ystart,yend ,zstart,zend];
gifname = 'Ground_force.gif';
%
figure;
fx = 0;
set(gcf, 'Position', [0 0 gifsize]);
%
subplot(10,1,[5 6]),pLGF=plot(0,0);
axis([ground_force_xstart,ground_force_xend,min(ground_force_Left.z)-100,max(ground_force_Left.z)+100]);
hold on
subplot(10,1,[7 8]),pRGF=plot(0,0);
axis([ground_force_xstart,ground_force_xend,min(ground_force_Right.z)-100,max(ground_force_Right.z)+100]);
hold on
subplot(10,1,[9 10]),pGF=plot(0,0);
axis([ground_force_xstart,ground_force_xend,min(ground_force.z)-100,max(ground_force.z)+100]);
hold on
%
subplot(10,1,[1 4]);
p1 = plot3(0,0,0);
p2 = plot3(0,0,0);
p3 = plot3(0,0,0);
xlabel('x')
ylabel('y')
zlabel('z')
title('VGRF','Fontsize',20)
axis(axislimb);
view([1 0 0]);
hold on
for t = tstart:1:tstop
    %画分界线左脚着地
    if ismember(t, leftfootcontacttime)
        subplot(10,1,[5 6]),
        line([double(t)/1000,double(t)/1000],[min(ground_force_Left.z)-100,max(ground_force_Left.z)+100],'color','k');
        text(double(t)/1000,(max(ground_force_Left.z)+100)*0.9,'左脚着地','HorizontalAlignment','right','FontSize',8);
    end
    %画分界线右脚着地
    if ismember(t, rightfootcontacttime)
        subplot(10,1,[7 8]),
        line([double(t)/1000,double(t)/1000],[min(ground_force_Right.z)-100,max(ground_force_Right.z)+100],'color','k');
        text(double(t)/1000,(max(ground_force_Right.z)+100)*0.9,'右脚着地','HorizontalAlignment','right','FontSize',8);
    end
    %画分界线左脚离地
    if ismember(t, leftfootleavetime)
        subplot(10,1,[5 6]),
        line([double(t)/1000,double(t)/1000],[min(ground_force_Left.z)-100,max(ground_force_Left.z)+100],'color','y');
        text(double(t)/1000,(max(ground_force_Left.z)+100)*0.9,'左脚离地','HorizontalAlignment','right','FontSize',8);
        
    end
    %画分界线右脚离地
    if ismember(t, rightfootleavetime)
        
        subplot(10,1,[7 8]),
        line([double(t)/1000,double(t)/1000],[min(ground_force_Right.z)-100,max(ground_force_Right.z)+100],'color','y');
        text(double(t)/1000,(max(ground_force_Right.z)+100)*0.9,'右脚离地','HorizontalAlignment','right','FontSize',8);
        
    end
    %% 画人体及地面对左脚反作用力偶矩
    if ismember(t,int32(1000*Kinectstream.wtime))
        fx = fx+1;
        m = find(int32(1000*Kinectstream.wtime) == t);
        if ishandle(pLGF)
            delete(pLGF);%把上一次的图像清掉
        end
        
        if ishandle(pRGF)
            delete(pRGF);%把上一次的图像清掉
        end
        if ishandle(pGF)
            delete(pGF);%把上一次的图像清掉
        end
        
        %% 地面反作用力
        subplot(10,1,[5 6]),pLGF=plot(Kinectstream.wtime(m1:m),ground_force_Left.z(m1:m),'b');
        
        xlabel('时间(S)','Fontsize',15)
        ylabel('左脚(N)','Fontsize',15)
        subplot(10,1,[ 7 8]),pRGF=plot(Kinectstream.wtime(m1:m),ground_force_Right.z(m1:m),'g');
        xlabel('时间(S)','Fontsize',15)
        ylabel('右脚(N)','Fontsize',15)
        subplot(10,1,[9 10]),pGF=plot(Kinectstream.wtime(m1:m),ground_force.z(m1:m),'r');
        xlabel('时间(S)','Fontsize',15)
        ylabel('和(N)','Fontsize',15)
        %% 画人体
        
        if ishandle(p1)
            delete(p1);
        end
        if ishandle(p2)
            delete(p2);
        end
        if ishandle(p3)
            delete(p3);
        end
        subplot(10,1,[1 4]);
        figure_body_part;
        
        %% 生成gif
        frame=getframe(gcf);
        imind=frame2im(frame);
        [imind,cm] = rgb2ind(imind,256);
        if fx ==1
            imwrite(imind,cm,gifname,'gif', 'Loopcount',inf,'DelayTime',dt);
        else
            imwrite(imind,cm,gifname,'gif','WriteMode','append','DelayTime',dt);
        end
        
    end
end
%% 踝关节力矩绘动图

% 设置
gifname = 'Ankle_Moment.gif';
%
figure;
fx = 0;
set(gcf, 'Position', [0 0 gifsize]);
%
subplot(10,1,[5 6]),plx=plot(0,0);
axis([ground_force_xstart,ground_force_xend,min(Foot_Left_proximal_x)-100,max(Foot_Left_proximal_x)+100]);
hold on
subplot(10,1,[7 8]),ply=plot(0,0);
axis([ground_force_xstart,ground_force_xend,min(Foot_Left_proximal_y)-100,max(Foot_Left_proximal_y)+100]);
hold on
subplot(10,1,[9 10]),plz=plot(0,0);
axis([ground_force_xstart,ground_force_xend,min(Foot_Left_proximal_z)-100,max(Foot_Left_proximal_z)+100]);
hold on
%
subplot(10,1,[1 4]);
p1 = plot3(0,0,0);
p2 = plot3(0,0,0);
p3 = plot3(0,0,0);
xlabel('x')
ylabel('y')
zlabel('z')
title('行走时左踝关节力矩','Fontsize',20)
axis(axislimb);
view([1 0 0]);
hold on
for t = tstart:1:tstop
    %画分界线左脚着地
    if ismember(t, leftfootcontacttime)
        subplot(10,1,[5 6]),
        line([double(t)/1000,double(t)/1000],[min(Foot_Left_proximal_x)-100,max(Foot_Left_proximal_x)+100],'color','k');
        text(double(t)/1000,(max(Foot_Left_proximal_x)+100)*0.9,'左脚着地','HorizontalAlignment','right','FontSize',8);
        
        subplot(10,1,[7 8]),
        line([double(t)/1000,double(t)/1000],[min(Foot_Left_proximal_y)-100,max(Foot_Left_proximal_y)+100],'color','k');
        text(double(t)/1000,(max(Foot_Left_proximal_y)+100)*0.9,'左脚着地','HorizontalAlignment','right','FontSize',8);
        
        subplot(10,1,[9 10]),
        line([double(t)/1000,double(t)/1000],[min(Foot_Left_proximal_z)-100,max(Foot_Left_proximal_z)+100],'color','k');
        text(double(t)/1000,(max(Foot_Left_proximal_z)+100)*0.9,'左脚着地','HorizontalAlignment','right','FontSize',8);
    end
    %画分界线左脚离地
    if ismember(t, leftfootleavetime)
        subplot(10,1,[5 6]),
        line([double(t)/1000,double(t)/1000],[min(Foot_Left_proximal_x)-100,max(Foot_Left_proximal_x)+100],'color','y');
        text(double(t)/1000,(max(Foot_Left_proximal_x)+100)*0.9,'左脚离地','HorizontalAlignment','right','FontSize',8);
        
        subplot(10,1,[7 8]),
        line([double(t)/1000,double(t)/1000],[min(Foot_Left_proximal_y)-100,max(Foot_Left_proximal_y)+100],'color','y');
        text(double(t)/1000,(max(Foot_Left_proximal_y)+100)*0.9,'左脚离地','HorizontalAlignment','right','FontSize',8);
        
        subplot(10,1,[9 10]),
        line([double(t)/1000,double(t)/1000],[min(Foot_Left_proximal_z)-100,max(Foot_Left_proximal_z)+100],'color','y');
        text(double(t)/1000,(max(Foot_Left_proximal_z)+100)*0.9,'左脚离地','HorizontalAlignment','right','FontSize',8);
    end
    
    %% 画人体及踝关节力矩
    if ismember(t,int32(1000*Kinectstream.wtime))
        fx = fx+1;
        m = find(int32(1000*Kinectstream.wtime) == t);
        if ishandle(plx)
            delete(plx);%把上一次的图像清掉
        end
        
        if ishandle(ply)
            delete(ply);%把上一次的图像清掉
        end
        if ishandle(plz)
            delete(plz);%把上一次的图像清掉
        end
        
        %% 踝关节力矩
        subplot(10,1,[5 6]),plx=plot(Kinectstream.wtime(m1:m),Foot_Left_proximal_x(m1:m),'b');
        
        ylabel('x方向(N*m)','Fontsize',15)
        xlabel('时间(S)','Fontsize',15)
        subplot(10,1,[ 7 8]),ply=plot(Kinectstream.wtime(m1:m),Foot_Left_proximal_y(m1:m),'g');
        ylabel('y方向(N*m)','Fontsize',15)
        xlabel('时间(N*m)','Fontsize',15)
        subplot(10,1,[9 10]),plz=plot(Kinectstream.wtime(m1:m),Foot_Left_proximal_z(m1:m),'r');
        ylabel('z方向(N*m)','Fontsize',15)
        xlabel('时间(S)','Fontsize',15)
       %% 画人体
        
        if ishandle(p1)
            delete(p1);
        end
        if ishandle(p2)
            delete(p2);
        end
        if ishandle(p3)
            delete(p3);
        end
        subplot(10,1,[1 4]);
        figure_body_part;
        
        %% 生成gif
        frame=getframe(gcf);
        imind=frame2im(frame);
        [imind,cm] = rgb2ind(imind,256);
        if fx ==1
            imwrite(imind,cm,gifname,'gif', 'Loopcount',inf,'DelayTime',dt);
        else
            imwrite(imind,cm,gifname,'gif','WriteMode','append','DelayTime',dt);
        end
        
    end
end
%% kinect 步道 统一 绘图
%设置
%f_parameters_KP.dt = 1/inter_freq;%间隔时间，matlab似乎不能处理过小的间隔
f_parameters_KP.dt = 0.03;%间隔时间
f_parameters_KP.color3 = {[0 1 0],[0.8500 0.3250 0.0980],[0.3 0.3 1]};%色彩关节点，肢体，须佐
f_parameters_KP.size = [1920 1080];%大小
f_parameters_KP.axis = [xstart,xend, ystart,yend ,zstart,zend];
f_parameters_KP.gifname = 'KP.gif';
f_Figure_Kinectarray_Pathway(kinect_cell_arrays,Pathstream,support_time,sex,f_parameters_KP)