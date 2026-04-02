function knee_angle = Knee_Angle(kinect_cell_arrays_model,supporttime,L_R)
threshold = 0.05;%用于计算，双足是否着地，双足垂直距离小于阈值则认为是 双支撑

%% 判断是否输入supporttime
if length(supporttime) == 1  %表示supporttime 需要自动计算
    
    %% 大腿(hip to knee)与小腿(knee to ankle)形成的角度
    len_hip = length(kinect_cell_arrays_model);
    
    footLx = zeros(len_hip,1);
    footLy = zeros(len_hip,1);
    footLz = zeros(len_hip,1);
    
    footRx = zeros(len_hip,1);
    footRy = zeros(len_hip,1);
    footRz = zeros(len_hip,1);
    
    hipL = zeros(len_hip,3);
    hipR = zeros(len_hip,3);
    
    kneeL = zeros(len_hip,3);
    kneeR = zeros(len_hip,3);
    
    ankleL = zeros(len_hip,3);
    ankleR = zeros(len_hip,3);
    
    knee_angle = zeros(len_hip,1) + 720;
    %
    for i = 1:len_hip
        joints_position_model = kinect_cell_arrays_model{i}.joints;
        
          footLx(i) = joints_position_model(14,1);
        footLy(i) = joints_position_model(14,2);
        footLz(i) = joints_position_model(14,3);
        
        footRx(i) = joints_position_model(18,1);
        footRy(i) = joints_position_model(18,2);
        footRz(i) = joints_position_model(18,3);
        
        hipL(i,:) = joints_position_model(11,:);
        hipR(i,:) = joints_position_model(15,:);
        
        kneeL(i,:) = joints_position_model(12,:);
        kneeR(i,:) = joints_position_model(16,:);
        
        ankleL(i,:) = joints_position_model(13,:);
        ankleR(i,:) = joints_position_model(17,:);
        
    end
    
    %% 求解单双支撑相 大腿角度(与垂线夹角，矢状面)
    
    for i = 1:len_hip
        dis = footLz(i) - footRz(i);
        if abs(dis)<= threshold
            thighL = kneeL(i,:) - hipL(i,:);
            shankL =  ankleL(i,:) - kneeL(i,:);
            knee_angletemp(1) =  rad2deg(acos(dot(thighL, shankL) / (norm(thighL) * norm(shankL))));
            
            thighR = kneeR(i,:) - hipR(i,:);
            shankR =  ankleR(i,:) - kneeR(i,:);
            knee_angletemp(2) =  rad2deg(acos(dot(thighR, shankR) / (norm(thighR) * norm(shankR))));
            
            knee_angle(i) = max(knee_angletemp);
        else
            if dis > 0
                thighR = kneeR(i,:) - hipR(i,:);
                shankR =  ankleR(i,:) - kneeR(i,:);
                knee_angle(i) =  rad2deg(acos(dot(thighR, shankR) / (norm(thighR) * norm(shankR))));
                
            else
                thighL = kneeL(i,:) - hipL(i,:);
                shankL =  ankleL(i,:) - kneeL(i,:);
                knee_angle(i)  =  rad2deg(acos(dot(thighL, shankL) / (norm(thighL) * norm(shankL))));
            end
            
        end
    end
    
    
    
else
    
    %% 大腿(hip to knee)与小腿(knee to ankle)形成的角度
    len_hip = length(kinect_cell_arrays_model);
    
    hipL = zeros(len_hip,3);
    hipR = zeros(len_hip,3);
    
    kneeL = zeros(len_hip,3);
    kneeR = zeros(len_hip,3);
    
    ankleL = zeros(len_hip,3);
    ankleR = zeros(len_hip,3);
    
    knee_angle = zeros(len_hip,1) + 720;
    %
    for i = 1:len_hip
        joints_position_model = kinect_cell_arrays_model{i}.joints;
        
        hipL(i,:) = joints_position_model(11,:);
        hipR(i,:) = joints_position_model(15,:);
        
        kneeL(i,:) = joints_position_model(12,:);
        kneeR(i,:) = joints_position_model(16,:);
        
        ankleL(i,:) = joints_position_model(13,:);
        ankleR(i,:) = joints_position_model(17,:);
        
    end
    
    %% 求解单双支撑相 大腿角度(与垂线夹角，矢状面)
    supporttime_min = supporttime{1}(1);
    supporttime_max = max([supporttime{end}(end),supporttime{end - 1}(end)]);
    for i = 1:len_hip
        
        if(kinect_cell_arrays_model{i}.time > (supporttime_min - 5) && kinect_cell_arrays_model{i}.time < (supporttime_max + 5))%在有效时间内
            k = 1;
            for j=1:length(supporttime)
                if(kinect_cell_arrays_model{i}.time > (supporttime{j}(1) - 5) && kinect_cell_arrays_model{i}.time < (supporttime{j}(end) + 5))
                    
                    if(L_R{j}) == 'L'
                        thighL = kneeL(i,:) - hipL(i,:);
                        shankL =  ankleL(i,:) - kneeL(i,:);
                        
                        knee_angletemp(k) =  rad2deg(acos(dot(thighL, shankL) / (norm(thighL) * norm(shankL))));
                        
                    else
                        thighR = kneeR(i,:) - hipR(i,:);
                        shankR =  ankleR(i,:) - kneeR(i,:);
                        
                        knee_angletemp(k) =  rad2deg(acos(dot(thighR, shankR) / (norm(thighR) * norm(shankR))));
                        
                    end
                    k = k+1;
                end
            end
            knee_angle(i) = max(knee_angletemp);
            
        end
    end
    
    
end
end