clear;
close all;

%% 数据读取

kinectname = ['026_body_2021_07_27_11_34_50_956', '.txt'];
kinectstream = Kinect_Azure_Read_Single(kinectname);
Kinectstream = kinectstream{1};
%% 时间转换成秒
Kinectstream.wtime = seconds(Kinectstream.wtime - min(Kinectstream.wtime));
matchss = 1:length(Kinectstream.wtime);

%
    xstart = -0.2;
    xend = 0.6;
    ystart = -1;
    yend = 4;
    zstart = 0;
    zend = 2;
    
    %% 绘图 z视角
    
    figure;
    set(gcf, 'Position', [0 0 1200 900]);
    p = plot3(0,0,0);
    xlabel('x')
    ylabel('y')
    zlabel('z')
    axis equal;
   % axis([xstart,xend,ystart,yend,zstart,zend]);
    view([0 0 1])
    hold on
    for m = matchss(1):matchss(end)
        %画人体
            if ishandle(p)
                delete(p);
            end
           
            
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
            if m==matchss(1)
                imwrite(imind,cm,'gaitpkz.gif','gif', 'Loopcount',inf,'DelayTime',0.03);
            else
                imwrite(imind,cm,'gaitpkz.gif','gif','WriteMode','append','DelayTime',0.03);
            end
    end
    hold off
