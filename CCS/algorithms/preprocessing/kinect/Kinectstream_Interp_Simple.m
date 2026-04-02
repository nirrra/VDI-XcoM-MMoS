function streamInter = Kinectstream_Interp_Simple(stream,fsInter)

time_original = Datetime2Time(stream.wtime);
time_interp = (time_original(1):(1/fsInter):time_original(end))';

% kinect_cell_arrays = Kinect_Azure_Struct_To_Array(stream);
streamInter = struct();
streamInter.wtime = time_interp;

names = fieldnames(stream);
for i = 4:length(names)
    name = names{i};
    % 插值
    streamInter.(name).x = interp1(time_original, stream.(name).x, time_interp, 'pchip');
    streamInter.(name).y = interp1(time_original, stream.(name).y, time_interp, 'pchip');
    streamInter.(name).z = interp1(time_original, stream.(name).z, time_interp, 'pchip');
end