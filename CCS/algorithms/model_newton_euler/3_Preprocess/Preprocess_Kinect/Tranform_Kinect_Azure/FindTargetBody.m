%% 因为可能有多个人体被kinect捕捉，需要提取出目标对象,当有步道数据输入时，程序如下,时间转换成了秒
function Kinect_stream = FindTargetBody(stream_all,Sub2Mas_T,Mas2Pathway_T,support_time,intial_time_pathway,numpath)
%寻找目标人物,% kinect视角的前方为z，原始kinect坐标是向下为y，向右是x
for bodyid = 1:length(stream_all)
    stream = stream_all{bodyid};
    % kinect_Azure到步道坐标系
    if stream.name(1) == "SUB"
        stream = Transform_Azure(Sub2Mas_T,stream);
    end
    Kinect_stream = Transform_Azure(Mas2Pathway_T,stream);
    Kinect_stream.wtime = seconds(Kinect_stream.wtime - intial_time_pathway);
    % Sub kinect 找出目标人物
    % 获取有效时间
    PELVIS_x = 0;
    PELVIS_y = 0;
    match = find(Kinect_stream.wtime >= (min(support_time{1})) & Kinect_stream.wtime <= (max((support_time{length(support_time)}))));
    for j = 1:length(match)
        m = match(j);
        PELVIS_x(j) = Kinect_stream.PELVIS.x(m);
        PELVIS_y(j) = Kinect_stream.PELVIS.y(m);
    end
    % 识别站在步道上的时间比例，超过0.5 则视为被测对象
    xpencent = length(find(PELVIS_x >0 & PELVIS_x<0.48))/length(match);
    ypencent = length(find(PELVIS_y >0.32 & PELVIS_y<(numpath+1)*0.32))/length(match);
    if xpencent>0.5 && ypencent>0.5
        break;
    end
end

end