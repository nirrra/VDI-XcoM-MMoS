%% 函数：grf信号滤波并插值到kinect时间
function ns = FilterXYZAndInter(s,time,posStart,posEnd,stream)
    if istable(s.x)
        s.x = table2array(s.x);
        s.y = table2array(s.y);
        s.z = table2array(s.z);
    end
    framelen = 11; order = 5;
    s.x = sgolayfilt(s.x,order,framelen); s.x = interp1(time,s.x(posStart:posEnd),stream.wtime,'spline');
    s.y = sgolayfilt(s.y,order,framelen); s.y = interp1(time,s.y(posStart:posEnd),stream.wtime,'spline');
    s.z = sgolayfilt(s.z,order,framelen); s.z = interp1(time,s.z(posStart:posEnd),stream.wtime,'spline');
    ns = s;
end