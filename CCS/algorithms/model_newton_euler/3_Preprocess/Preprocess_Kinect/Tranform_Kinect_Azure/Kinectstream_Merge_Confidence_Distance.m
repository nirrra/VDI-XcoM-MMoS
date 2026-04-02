%% 用置信度信息,距离信息来融合两台kinect数据，
% 例子：Distance(1) = 1m,Distance(2) =4m，要求当前坐标系为 kinect视角的前方为z，原始kinect坐标是向下为y，向右是x
% x0=Sub2Mas_T(1,4),y0=sub2Mas_T(2,4),z0=sub2Mas_T(3,4),分别为sub 相机到mas相机的偏移,Error计算两套坐标系下骨骼点坐标的误差
function [kinectstream_Char,Error] = Kinectstream_Merge_Confidence_Distance(Kinectstream_Mas,Kinectstream_Sub,Distance,Sub2Mas_T,Mas2Pathway_T)
Pathway2Mas_T = inv(Mas2Pathway_T);
Mas2Sub_T = inv(Sub2Mas_T);
Pathway2Sub_T = Mas2Sub_T * Pathway2Mas_T;
%% 求采样频率
Kinectstream_Mas.ktime=double(Kinectstream_Mas.ktime)/10^7;%ktime 转化成秒，时间原点是机器时间，未和步道联系起来
Kinectstream_Sub.ktime=double(Kinectstream_Sub.ktime)/10^7;%ktime 转化成秒
starttimeMas = Kinectstream_Mas.ktime(1);
endtimeMas = Kinectstream_Mas.ktime(end);
starttimeSub = Kinectstream_Sub.ktime(1);
endtimeSub = Kinectstream_Sub.ktime(end);
fs = (length(Kinectstream_Mas.ktime) + length(Kinectstream_Sub.ktime) - 2) / (endtimeMas - starttimeMas + endtimeSub - starttimeSub);
%fs = 30 / 1000;
%% 时间合并准备，按等时间间隔分布
timeinterval = 1 / fs;%时间间隔
starttimemerge = min([starttimeMas,starttimeSub]);%秒
endtimemerge = max([endtimeMas,endtimeSub]);
countmerge = floor((endtimemerge - starttimemerge) * fs + 1); %预定时间刻度的个数
mas_sub_index = zeros(countmerge,2);
masindextemp = [];
subindextemp = [];
masst = 1;
subst = 1;
for i = 1:countmerge
    
    %mas时间序号并入
    for j = masst:length(Kinectstream_Mas.ktime)
        temp = 0;
        tmitemp = abs(Kinectstream_Mas.ktime(j) - starttimemerge- (i-1)*timeinterval);
        if(tmitemp <= 0.5*timeinterval)
            temp = temp + 1;
            masindextemp(temp) = j;
            masintertemp(temp) = tmitemp;
        end
        if(~isempty(masindextemp) && (masindextemp(1)<j || j==length(Kinectstream_Mas.ktime)))
            
            minindex = masindextemp(floor(masintertemp) == min(floor(masintertemp)));
            mas_sub_index(i,1) = minindex;
            masst = j - 1;
            masindextemp = [];
            break;
        end
    end
    %sub时间序号并入
    for k = subst:length(Kinectstream_Sub.ktime)
        temp = 0;
        tmitemp = abs(Kinectstream_Sub.ktime(k) - starttimemerge - (i-1)*timeinterval);
        if(tmitemp <= 0.5*timeinterval)
            temp = temp + 1;
            subindextemp(temp) = k;
            subintertemp(temp) = tmitemp;
        end
        if(~isempty(subindextemp) && (subindextemp(1)<k || k==length(Kinectstream_Sub.ktime)))
            
            minindex = subindextemp(floor(subintertemp) == min(floor(subintertemp)));
            mas_sub_index(i,2) = minindex;
            subst = k - 1;
            subindextemp = [];
            break;
        end
    end
end
%% char 转 number,方便操作
Kinectstream_Mas_Number = Kinect_Azure_Struct_Char2Number(Kinectstream_Mas);
Kinectstream_Sub_Number = Kinect_Azure_Struct_Char2Number(Kinectstream_Sub);
%%  数据合并
index = 0;
for i=1:length(mas_sub_index)
    flag = find(mas_sub_index(i,:)>0);
    if length(flag) == 1
        index = index +1;
        if(flag == 1) %只有mas有数据
            kinectstream_merge.ktime(index) = Kinectstream_Mas_Number.ktime(mas_sub_index(i,1));
            kinectstream_merge.wtime(index) = Kinectstream_Mas_Number.wtime(mas_sub_index(i,1));
            kinectstream_merge.name{index} = Kinectstream_Mas_Number.name{mas_sub_index(i,1)};
            
            for jn = 1:32
                Joint = ['Joint',num2str(jn)];
                
                kinectstream_merge.(Joint).Confidence(index) = Kinectstream_Mas_Number.(Joint).Confidence(mas_sub_index(i,1));
                kinectstream_merge.(Joint).x(index) = Kinectstream_Mas_Number.(Joint).x(mas_sub_index(i,1));
                kinectstream_merge.(Joint).y(index) = Kinectstream_Mas_Number.(Joint).y(mas_sub_index(i,1));
                kinectstream_merge.(Joint).z(index) = Kinectstream_Mas_Number.(Joint).z(mas_sub_index(i,1));
                kinectstream_merge.(Joint).Quaternion.w(index) = Kinectstream_Mas_Number.(Joint).Quaternion.w(mas_sub_index(i,1));
                kinectstream_merge.(Joint).Quaternion.x(index) = Kinectstream_Mas_Number.(Joint).Quaternion.x(mas_sub_index(i,1));
                kinectstream_merge.(Joint).Quaternion.y(index) = Kinectstream_Mas_Number.(Joint).Quaternion.y(mas_sub_index(i,1));
                kinectstream_merge.(Joint).Quaternion.z(index) = Kinectstream_Mas_Number.(Joint).Quaternion.z(mas_sub_index(i,1));
            end
        else %只有sub有数据
            kinectstream_merge.ktime(index) = Kinectstream_Sub_Number.ktime(mas_sub_index(i,2));
            kinectstream_merge.wtime(index) = Kinectstream_Sub_Number.wtime(mas_sub_index(i,2));
            kinectstream_merge.name{index} = Kinectstream_Sub_Number.name{mas_sub_index(i,2)};
            
            for jn = 1:32
                Joint = ['Joint',num2str(jn)];
                
                kinectstream_merge.(Joint).Confidence(index) = Kinectstream_Sub_Number.(Joint).Confidence(mas_sub_index(i,2));
                kinectstream_merge.(Joint).x(index) = Kinectstream_Sub_Number.(Joint).x(mas_sub_index(i,2));
                kinectstream_merge.(Joint).y(index) = Kinectstream_Sub_Number.(Joint).y(mas_sub_index(i,2));
                kinectstream_merge.(Joint).z(index) = Kinectstream_Sub_Number.(Joint).z(mas_sub_index(i,2));
                kinectstream_merge.(Joint).Quaternion.w(index) = Kinectstream_Sub_Number.(Joint).Quaternion.w(mas_sub_index(i,2));
                kinectstream_merge.(Joint).Quaternion.x(index) = Kinectstream_Sub_Number.(Joint).Quaternion.x(mas_sub_index(i,2));
                kinectstream_merge.(Joint).Quaternion.y(index) = Kinectstream_Sub_Number.(Joint).Quaternion.y(mas_sub_index(i,2));
                kinectstream_merge.(Joint).Quaternion.z(index) = Kinectstream_Sub_Number.(Joint).Quaternion.z(mas_sub_index(i,2));
            end
        end
        
    elseif length(flag) == 2 %mas和sub都有数据，通过置信度和距离来融合
        index = index +1;
        kinectstream_merge.ktime(index) = 0.5 * Kinectstream_Mas_Number.ktime(mas_sub_index(i,1)) + 0.5* Kinectstream_Sub_Number.ktime(mas_sub_index(i,2));
        kinectstream_merge.wtime(index) = Kinectstream_Mas_Number.wtime(mas_sub_index(i,1)) - ...
            0.5* (Kinectstream_Mas_Number.wtime(mas_sub_index(i,1)) - Kinectstream_Sub_Number.wtime(mas_sub_index(i,2)));
        %kinectstream_merge.wtime(index) = Kinectstream_Mas_Number.wtime(mas_sub_index(i,1));%因为日期不方便取平均，所以直接用Mas数据，不影响结果
        
        d_Sub = Pathway2Sub_T(3,:) *  [Kinectstream_Sub_Number.Joint1.x(mas_sub_index(i,2));...
            Kinectstream_Sub_Number.Joint1.y(mas_sub_index(i,2));Kinectstream_Sub_Number.Joint1.z(mas_sub_index(i,2));1];%髋关节到sub的距离
        %d_Mas = Kinectstream_Mas_Number.(Joint).z(mas_sub_index(i,1));
        d_Mas = Pathway2Mas_T(3,:) *  [Kinectstream_Mas_Number.Joint1.x(mas_sub_index(i,1));...
            Kinectstream_Mas_Number.Joint1.y(mas_sub_index(i,1));Kinectstream_Mas_Number.Joint1.z(mas_sub_index(i,1));1];%髋关节到Mas的距离
        %通过距离来判断
        d_flag_Mas = 1 * (d_Mas <= Distance(1)) + 3 * (d_Mas > Distance(1) && d_Mas <= Distance(2)) + 5 * (d_Mas > Distance(2));
        d_flag_Sub = 11 * (d_Sub <= Distance(1)) + 33 * (d_Sub > Distance(1) && d_Sub <= Distance(2)) + 55 * (d_Sub > Distance(2));
        d_flag = d_flag_Mas + d_flag_Sub;
        for jn = 1:32
            Joint = ['Joint',num2str(jn)];
            if(Kinectstream_Mas_Number.(Joint).Confidence(mas_sub_index(i,1)) > Kinectstream_Sub_Number.(Joint).Confidence(mas_sub_index(i,2)))
                kinectstream_merge.name{index} = 'MAS';
                kinectstream_merge.(Joint).Confidence(index) = Kinectstream_Mas_Number.(Joint).Confidence(mas_sub_index(i,1));
                kinectstream_merge.(Joint).x(index) = Kinectstream_Mas_Number.(Joint).x(mas_sub_index(i,1));
                kinectstream_merge.(Joint).y(index) = Kinectstream_Mas_Number.(Joint).y(mas_sub_index(i,1));
                kinectstream_merge.(Joint).z(index) = Kinectstream_Mas_Number.(Joint).z(mas_sub_index(i,1));
                kinectstream_merge.(Joint).Quaternion.w(index) = Kinectstream_Mas_Number.(Joint).Quaternion.w(mas_sub_index(i,1));
                kinectstream_merge.(Joint).Quaternion.x(index) = Kinectstream_Mas_Number.(Joint).Quaternion.x(mas_sub_index(i,1));
                kinectstream_merge.(Joint).Quaternion.y(index) = Kinectstream_Mas_Number.(Joint).Quaternion.y(mas_sub_index(i,1));
                kinectstream_merge.(Joint).Quaternion.z(index) = Kinectstream_Mas_Number.(Joint).Quaternion.z(mas_sub_index(i,1));
                
            elseif(Kinectstream_Mas_Number.(Joint).Confidence(mas_sub_index(i,1)) < Kinectstream_Sub_Number.(Joint).Confidence(mas_sub_index(i,2)))
                kinectstream_merge.name{index} = 'SUB';
                kinectstream_merge.(Joint).Confidence(index) = Kinectstream_Sub_Number.(Joint).Confidence(mas_sub_index(i,2));
                kinectstream_merge.(Joint).x(index) = Kinectstream_Sub_Number.(Joint).x(mas_sub_index(i,2));
                kinectstream_merge.(Joint).y(index) = Kinectstream_Sub_Number.(Joint).y(mas_sub_index(i,2));
                kinectstream_merge.(Joint).z(index) = Kinectstream_Sub_Number.(Joint).z(mas_sub_index(i,2));
                kinectstream_merge.(Joint).Quaternion.w(index) = Kinectstream_Sub_Number.(Joint).Quaternion.w(mas_sub_index(i,2));
                kinectstream_merge.(Joint).Quaternion.x(index) = Kinectstream_Sub_Number.(Joint).Quaternion.x(mas_sub_index(i,2));
                kinectstream_merge.(Joint).Quaternion.y(index) = Kinectstream_Sub_Number.(Joint).Quaternion.y(mas_sub_index(i,2));
                kinectstream_merge.(Joint).Quaternion.z(index) = Kinectstream_Sub_Number.(Joint).Quaternion.z(mas_sub_index(i,2));
            else %置信度一致，加入距离判断
                
                switch(d_flag)
                    case 36 %人体在两台 kinect 有效范围 内
                        kinectstream_merge.name{index} = 'MASSUB';
                        %计算两套坐标系下骨骼点坐标的误差
                        Error.(Joint).x(index) =  Kinectstream_Mas_Number.(Joint).x(mas_sub_index(i,1)) - Kinectstream_Sub_Number.(Joint).x(mas_sub_index(i,2));
                        Error.(Joint).y(index) =  Kinectstream_Mas_Number.(Joint).y(mas_sub_index(i,1)) - Kinectstream_Sub_Number.(Joint).y(mas_sub_index(i,2));
                        Error.(Joint).z(index) =  Kinectstream_Mas_Number.(Joint).z(mas_sub_index(i,1)) - Kinectstream_Sub_Number.(Joint).z(mas_sub_index(i,2));
                        %数据合并
                        kinectstream_merge.(Joint).Confidence(index) = Kinectstream_Mas_Number.(Joint).Confidence(mas_sub_index(i,1));
                        kinectstream_merge.(Joint).x(index) = 0.5*Kinectstream_Mas_Number.(Joint).x(mas_sub_index(i,1)) + 0.5*Kinectstream_Sub_Number.(Joint).x(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).y(index) = 0.5*Kinectstream_Mas_Number.(Joint).y(mas_sub_index(i,1)) + 0.5*Kinectstream_Sub_Number.(Joint).y(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).z(index) = 0.5*Kinectstream_Mas_Number.(Joint).z(mas_sub_index(i,1)) + 0.5*Kinectstream_Sub_Number.(Joint).z(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).Quaternion.w(index) = Kinectstream_Mas_Number.(Joint).Quaternion.w(mas_sub_index(i,1)) + Kinectstream_Sub_Number.(Joint).Quaternion.w(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).Quaternion.x(index) = Kinectstream_Mas_Number.(Joint).Quaternion.x(mas_sub_index(i,1)) + Kinectstream_Sub_Number.(Joint).Quaternion.x(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).Quaternion.y(index) = Kinectstream_Mas_Number.(Joint).Quaternion.y(mas_sub_index(i,1)) + Kinectstream_Sub_Number.(Joint).Quaternion.y(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).Quaternion.z(index) = Kinectstream_Mas_Number.(Joint).Quaternion.z(mas_sub_index(i,1)) + Kinectstream_Sub_Number.(Joint).Quaternion.z(mas_sub_index(i,2));
                    case {12 16  56 60}
                        kinectstream_merge.name{index} = 'MASSUB';
                        %数据合并
                        kinectstream_merge.(Joint).Confidence(index) = Kinectstream_Mas_Number.(Joint).Confidence(mas_sub_index(i,1));
                        kinectstream_merge.(Joint).x(index) = 0.5*Kinectstream_Mas_Number.(Joint).x(mas_sub_index(i,1)) + 0.5*Kinectstream_Sub_Number.(Joint).x(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).y(index) = 0.5*Kinectstream_Mas_Number.(Joint).y(mas_sub_index(i,1)) + 0.5*Kinectstream_Sub_Number.(Joint).y(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).z(index) = 0.5*Kinectstream_Mas_Number.(Joint).z(mas_sub_index(i,1)) + 0.5*Kinectstream_Sub_Number.(Joint).z(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).Quaternion.w(index) = Kinectstream_Mas_Number.(Joint).Quaternion.w(mas_sub_index(i,1)) + Kinectstream_Sub_Number.(Joint).Quaternion.w(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).Quaternion.x(index) = Kinectstream_Mas_Number.(Joint).Quaternion.x(mas_sub_index(i,1)) + Kinectstream_Sub_Number.(Joint).Quaternion.x(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).Quaternion.y(index) = Kinectstream_Mas_Number.(Joint).Quaternion.y(mas_sub_index(i,1)) + Kinectstream_Sub_Number.(Joint).Quaternion.y(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).Quaternion.z(index) = Kinectstream_Mas_Number.(Joint).Quaternion.z(mas_sub_index(i,1)) + Kinectstream_Sub_Number.(Joint).Quaternion.z(mas_sub_index(i,2));
                    case {34 38} %sub 优先
                        kinectstream_merge.name{index} = 'SUB';
                        kinectstream_merge.(Joint).Confidence(index) = Kinectstream_Sub_Number.(Joint).Confidence(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).x(index) = Kinectstream_Sub_Number.(Joint).x(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).y(index) = Kinectstream_Sub_Number.(Joint).y(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).z(index) = Kinectstream_Sub_Number.(Joint).z(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).Quaternion.w(index) = Kinectstream_Sub_Number.(Joint).Quaternion.w(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).Quaternion.x(index) = Kinectstream_Sub_Number.(Joint).Quaternion.x(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).Quaternion.y(index) = Kinectstream_Sub_Number.(Joint).Quaternion.y(mas_sub_index(i,2));
                        kinectstream_merge.(Joint).Quaternion.z(index) = Kinectstream_Sub_Number.(Joint).Quaternion.z(mas_sub_index(i,2));
                    case {14 58} % Mas优先
                        kinectstream_merge.name{index} = 'MAS';
                        kinectstream_merge.(Joint).Confidence(index) = Kinectstream_Mas_Number.(Joint).Confidence(mas_sub_index(i,1));
                        kinectstream_merge.(Joint).x(index) = Kinectstream_Mas_Number.(Joint).x(mas_sub_index(i,1));
                        kinectstream_merge.(Joint).y(index) = Kinectstream_Mas_Number.(Joint).y(mas_sub_index(i,1));
                        kinectstream_merge.(Joint).z(index) = Kinectstream_Mas_Number.(Joint).z(mas_sub_index(i,1));
                        kinectstream_merge.(Joint).Quaternion.w(index) = Kinectstream_Mas_Number.(Joint).Quaternion.w(mas_sub_index(i,1));
                        kinectstream_merge.(Joint).Quaternion.x(index) = Kinectstream_Mas_Number.(Joint).Quaternion.x(mas_sub_index(i,1));
                        kinectstream_merge.(Joint).Quaternion.y(index) = Kinectstream_Mas_Number.(Joint).Quaternion.y(mas_sub_index(i,1));
                        kinectstream_merge.(Joint).Quaternion.z(index) = Kinectstream_Mas_Number.(Joint).Quaternion.z(mas_sub_index(i,1));
                end
            end
            
            
            
        end
    end
    
end
%% 转置
kinectstream_merge.ktime = (kinectstream_merge.ktime)';
kinectstream_merge.wtime = (kinectstream_merge.wtime)';
kinectstream_merge.name = (kinectstream_merge.name)';

for jn = 1:32
    Joint = ['Joint',num2str(jn)];
    kinectstream_merge.(Joint).Confidence = (kinectstream_merge.(Joint).Confidence)';
    kinectstream_merge.(Joint).x = (kinectstream_merge.(Joint).x)';
    kinectstream_merge.(Joint).y = (kinectstream_merge.(Joint).y)';
    kinectstream_merge.(Joint).z = (kinectstream_merge.(Joint).z)';
    kinectstream_merge.(Joint).Quaternion.w = (kinectstream_merge.(Joint).Quaternion.w)';
    kinectstream_merge.(Joint).Quaternion.x = (kinectstream_merge.(Joint).Quaternion.x)';
    kinectstream_merge.(Joint).Quaternion.y = (kinectstream_merge.(Joint).Quaternion.y)';
    kinectstream_merge.(Joint).Quaternion.z = (kinectstream_merge.(Joint).Quaternion.z)';
end
%%  number转char
kinectstream_Char = Kinect_Azure_Struct_Number2Char(kinectstream_merge);

end