function com_ankle_angle = Com_Ankle_Angle(kinect_cell_arrays_model,supporttime,L_R,sex)
threshold = 0.05;%用于计算，双足是否着地，双足垂直距离小于阈值则认为是 双支撑

%% 判断是否输入supporttime
if length(supporttime) == 1  %表示supporttime 需要自动计算
    %%
    len = length(kinect_cell_arrays_model);
    
    com = zeros(len,3);
    
        footLx = zeros(len_com,1);
    footLy = zeros(len_com,1);
    footLz = zeros(len_com,1);
    
    footRx = zeros(len_com,1);
    footRy = zeros(len_com,1);
    footRz = zeros(len_com,1);
    
    ankleL = zeros(len,3);
    ankleR = zeros(len,3);
    
    com_ankle_angle = zeros(len,1) + 720;
    %
    for i = 1:len
        joints_position_model = kinect_cell_arrays_model{i}.joints;
        [com(i,1),com(i,2),com(i,3)] = Gravity_Kinectarray(joints_position_model,sex);%y是前进方向
        
        footLx(i) = joints_position_model(14,1);
        footLy(i) = joints_position_model(14,2);
        footLz(i) = joints_position_model(14,3);
        
        footRx(i) = joints_position_model(18,1);
        footRy(i) = joints_position_model(18,2);
        footRz(i) = joints_position_model(18,3);
        
        ankleL(i,:) = joints_position_model(13,:);
        ankleR(i,:) = joints_position_model(17,:);
    end
    
    %% 求解单双支撑相 大腿角度(与垂线夹角，矢状面)
    for i = 1:len
        dis = footLz(i) - footRz(i);
        if abs(dis)<= threshold
            %
            com_ankle_L =  ankleL(i,:) - com(i,:);
            A = [0 0 -1];
            B = [0 com_ankle_L(2) com_ankle_L(3)];
            com_ankle_angletemp(1) =  rad2deg(acos(dot(A, B) / (norm(A) * norm(B))));
            direction = cross(A,B);
            if(direction(1)<0)
                com_ankle_angletemp(1) = -com_ankle_angletemp(1);
            end
            %
            com_ankle_R =  ankleR(i,:) - com(i,:);
            A = [0 0 -1];
            B = [0 com_ankle_R(2) com_ankle_R(3)];
            com_ankle_angletemp(2) =  rad2deg(acos(dot(A, B) / (norm(A) * norm(B))));
            direction = cross(A,B);
            if(direction(1)<0)
                com_ankle_angletemp(2) = -com_ankle_angletemp(2);
            end
            
            com_ankle_angle(i) = max(com_ankle_angletemp);
        else
            if dis > 0
                com_ankle_R =  ankleR(i,:) - com(i,:);
                A = [0 0 -1];
                B = [0 com_ankle_R(2) com_ankle_R(3)];
                com_ankle_angle(i) =  rad2deg(acos(dot(A, B) / (norm(A) * norm(B))));
                direction = cross(A,B);
                if(direction(1)<0)
                    com_ankle_angle(i) = -com_ankle_angle(i);
                end
            else
                com_ankle_L =  ankleL(i,:) - com(i,:);
                A = [0 0 -1];
                B = [0 com_ankle_L(2) com_ankle_L(3)];
                com_ankle_angle(i) =  rad2deg(acos(dot(A, B) / (norm(A) * norm(B))));
                direction = cross(A,B);
                if(direction(1)<0)
                    com_ankle_angle(i) = -com_ankle_angle(i);
                end
            end
            
        end
    end
    
else
    %%
    len = length(kinect_cell_arrays_model);
    
    com = zeros(len,3);
    
    ankleL = zeros(len,3);
    ankleR = zeros(len,3);
    
    com_ankle_angle = zeros(len,1) + 720;
    %
    for i = 1:len
        joints_position_model = kinect_cell_arrays_model{i}.joints;
        [com(i,1),com(i,2),com(i,3)] = Gravity_Kinectarray(joints_position_model,sex);%y是前进方向
        ankleL(i,:) = joints_position_model(13,:);
        ankleR(i,:) = joints_position_model(17,:);
    end
    
    %% 求解单双支撑相 大腿角度(与垂线夹角，矢状面)
    supporttime_min = supporttime{1}(1);
    supporttime_max = max([supporttime{end}(end),supporttime{end - 1}(end)]);
    for i = 1:len
        
        if(kinect_cell_arrays_model{i}.time > (supporttime_min - 5) && kinect_cell_arrays_model{i}.time < (supporttime_max + 5))%在有效时间内
            k = 1;
            for j=1:length(supporttime)
                if(kinect_cell_arrays_model{i}.time > (supporttime{j}(1) - 5) && kinect_cell_arrays_model{i}.time < (supporttime{j}(end) + 5))
                    
                    if(L_R{j}) == 'L'
                        com_ankle_L =  ankleL(i,:) - com(i,:);
                        A = [0 0 -1];
                        B = [0 com_ankle_L(2) com_ankle_L(3)];
                        com_ankle_angletemp(k) =  rad2deg(acos(dot(A, B) / (norm(A) * norm(B))));
                        direction = cross(A,B);
                        if(direction(1)<0)
                            com_ankle_angletemp(k) = -com_ankle_angletemp(k);
                        end
                    else
                        com_ankle_R =  ankleR(i,:) - com(i,:);
                        A = [0 0 -1];
                        B = [0 com_ankle_R(2) com_ankle_R(3)];
                        com_ankle_angletemp(k) =  rad2deg(acos(dot(A, B) / (norm(A) * norm(B))));
                        direction = cross(A,B);
                        if(direction(1)<0)
                            com_ankle_angletemp(k) = -com_ankle_angletemp(k);
                        end
                    end
                    k = k+1;
                end
            end
            com_ankle_angle(i) = max(com_ankle_angletemp);
            
        end
    end
    
    
end
end