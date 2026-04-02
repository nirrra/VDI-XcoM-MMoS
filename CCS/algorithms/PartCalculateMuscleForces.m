%% 计算各体段长度
% segments_length = Get_Segments_Length_Struct(streamInter);
segments_length = CalSegmentsLength(streamInter);

%% 肌肉位置
muscles = InitMuscles;
muscle_names = fieldnames(muscles);

DrawKinectFrame_WithMuscles(streamInter,300,muscles,segments_RM,segments_origin,segments_length,muscle_names);

%% 根据实际肌肉长度调整模型肌腱参数（保证合理的归一化长度和速度）
% 计算肌肉长度
[~, ~, muscle_lengths] = CalMuscleLengths(muscles,segments_RM,segments_origin,segments_length);
muscle_lengths = FilterMuscleData(muscle_lengths, fsInter, 6);

% 根据数据的实际肌肉长度范围重新计算模型肌腱参数
[muscles_new, tableLength] = ReviseMuscleParameters(muscles,muscle_lengths);

%% 重新计算肌肉长度
[fiber_lengths, tendon_lengths, muscle_lengths] = CalMuscleLengths(muscles_new,segments_RM,segments_origin,segments_length);

%% 计算肌肉速度
muscle_velocities = CalMuscleVelocities(fiber_lengths,fsInter);

%% 查看归一化的纤维长度和速度
[normal_fiber_lengths,normal_fiber_velocities] = CalNormalFiberLengths(muscles_new,fiber_lengths,muscle_velocities);

%% 静态优化前的数据滤波
fprintf('对静态优化输入数据进行6Hz低通滤波...\n');
fiber_lengths = FilterMuscleData(fiber_lengths, fsInter, 6);
muscle_velocities = FilterMuscleData(muscle_velocities, fsInter, 6);
jointMomentGlobal = FilterJointMomentData(jointMomentGlobal, fsInter, 6);
segments_RM = FilterRotationMatrixData(segments_RM, fsInter, 6);
segments_origin = FilterSegmentOriginData(segments_origin, fsInter, 6);
segments_length = FilterSegmentLengthData(segments_length, fsInter, 6);

%% ====== 肌肉激活水平 ======
%% 静态优化
fprintf('开始静态优化计算肌肉激活...\n');
optimization_options = struct();
% optimization_options.objective = 'sum_squared';
optimization_options.objective = 'sum_squared_smooth';
optimization_options.max_activation = 1.0;
optimization_options.min_activation = 0.01;
optimization_options.tolerance = 1e-6;
optimization_options.include_lumbar = true;  % 包含腰椎关节
optimization_options.include_lumbar_muscle = true;  % 包含腰椎肌肉

% 静态优化
[muscle_activations, residuals, exitflag] = StaticOptimization(...
    muscles_new, fiber_lengths, muscle_velocities, jointMomentGlobal, ...
    segments_RM, segments_origin, segments_length, streamInter, optimization_options);

% 检查优化结果
successful_frames = sum(exitflag > 0);
fprintf('静态优化完成: %d/%d 帧成功收敛 (%.1f%%)\n', successful_frames, length(exitflag), 100*successful_frames/length(exitflag));

%% 计算肌肉力
[muscle_forces, muscle_forces_ce, muscle_forces_pe, f_ls, f_vs, f_pes] = CalMuscleForces(muscles_new,fiber_lengths,muscle_velocities,muscle_activations);

%% 对总肌肉力进行滤波处理
fprintf('对总肌肉力进行滤波处理...\n');

% 滤波选项设置
filter_options = struct();
filter_options.use_adaptive = true; % 设置为true使用自适应滤波，false使用标准滤波

if filter_options.use_adaptive
    % 自适应滤波参数
    filter_options.base_cutoff = 8;      % 基础截止频率
    filter_options.min_cutoff = 4;       % 最小截止频率
    filter_options.max_cutoff = 12;      % 最大截止频率
    filter_options.filter_order = 4;     % 滤波器阶数
    filter_options.noise_threshold = 0.15; % 噪声阈值
else
    % 标准滤波参数
    filter_options.cutoff_freq = 8;      % 固定截止频率
    filter_options.filter_order = 4;     % 滤波器阶数
end

% 对总肌肉力进行滤波
[muscle_forces_filtered, filter_params] = ...
    FilterMuscleForces_Total(muscle_forces, fsInter, filter_options);

% 使用滤波后的总肌肉力更新数据
muscle_forces = muscle_forces_filtered;