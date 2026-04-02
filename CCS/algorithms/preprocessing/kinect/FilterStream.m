function filteredStream = FilterStream(stream, fs, fc)
% FILTERJOINTDATA 对stream结构体中的关节点坐标进行低通滤波
%   stream: 输入数据流结构体
%   fs: 采样频率(Hz)
%   fc: 截止频率(Hz)

    % 设计Butterworth低通滤波器
    order = 4; % 滤波器阶数
    [b, a] = butter(order, fc/(fs/2), 'low');
    
    % 获取所有关节点名称
    jointNames = fieldnames(stream);
    
    % 创建输出结构体
    filteredStream = stream;
    
    for i = 1:length(jointNames)
        joint = jointNames{i};
        
        % 检查该关节点是否包含x,y,z字段
        if isfield(stream.(joint), 'x') && isfield(stream.(joint), 'y') && isfield(stream.(joint), 'z')
            % 对x,y,z坐标分别滤波
            filteredStream.(joint).x = filtfilt(b, a, stream.(joint).x);
            filteredStream.(joint).y = filtfilt(b, a, stream.(joint).y);
            filteredStream.(joint).z = filtfilt(b, a, stream.(joint).z);
            
%             % 可选：保存原始数据
%             filteredStream.(joint).x_original = stream.(joint).x;
%             filteredStream.(joint).y_original = stream.(joint).y;
%             filteredStream.(joint).z_original = stream.(joint).z;
        end
    end
end