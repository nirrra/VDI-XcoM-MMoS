%% 程序功能，将kinect数据 剪切到 与步道是时间长度一致
function  KinectStream = KinectStream_TimeCut(Kinectstream,time_range)
Kinectstream_Number = Kinect_Azure_Struct_Char2Number(Kinectstream);

%mas
index = find(Kinectstream.wtime >= time_range(1) & Kinectstream.wtime <= time_range(2));
kinectstream.ktime = Kinectstream_Number.ktime(index);
kinectstream.wtime = Kinectstream_Number.wtime(index);
kinectstream.name = Kinectstream_Number.name(index);
for jn = 1:32
    Joint = ['Joint',num2str(jn)];
    kinectstream.(Joint).Confidence = Kinectstream_Number.(Joint).Confidence(index);
    kinectstream.(Joint).x = Kinectstream_Number.(Joint).x(index);
    kinectstream.(Joint).y = Kinectstream_Number.(Joint).y(index);
    kinectstream.(Joint).z = Kinectstream_Number.(Joint).z(index);
    kinectstream.(Joint).Quaternion.w = Kinectstream_Number.(Joint).Quaternion.w(index);
    kinectstream.(Joint).Quaternion.x = Kinectstream_Number.(Joint).Quaternion.x(index);
    kinectstream.(Joint).Quaternion.y = Kinectstream_Number.(Joint).Quaternion.y(index);
    kinectstream.(Joint).Quaternion.z = Kinectstream_Number.(Joint).Quaternion.z(index);
end
KinectStream = Kinect_Azure_Struct_Number2Char(kinectstream);
end