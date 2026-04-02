function [muscle_activations_opt, residuals, exitflag] = StaticOptimization(muscles, muscle_lengths, muscle_velocities, jointMomentGlobal, segments_RM, segments_origin, segments_length, streamInter, options)
%% 肌肉激活静态优化计算
% 该函数使用类似OpenSim的静态优化方法计算满足关节力矩平衡的肌肉激活度
% 修改：加入基于解剖学知识的肌肉-关节映射关系
% 新增：控制腰椎关节是否参与优化的选项
%
% 输入参数:
%   muscles - 来自InitMuscles的肌肉结构体
%   muscle_lengths - 随时间变化的肌肉长度
%   muscle_velocities - 随时间变化的肌肉速度
%   jointMomentGlobal - 来自逆动力学的关节力矩
%   segments_RM - 体段旋转矩阵
%   segments_origin - 体段原点
%   segments_length - 体段长度
%   streamInter - 运动学数据
%   options - 优化选项（可选）
%   include_lumbar - 是否包含腰椎关节的优化（可选，默认true）
%   include_lumbar_muscle - 是否包含腰椎肌肉的优化（可选，默认true）
%
% 输出参数:
%   muscle_activations_opt - 优化后的肌肉激活度
%   residuals - 力矩平衡残差
%   exitflag - 优化退出标志

if nargin < 9
    options = struct();
end

% 默认优化选项
if ~isfield(options, 'objective'), options.objective = 'sum_squared'; end
if ~isfield(options, 'max_activation'), options.max_activation = 1.0; end
if ~isfield(options, 'min_activation'), options.min_activation = 0.01; end
if ~isfield(options, 'tolerance'), options.tolerance = 1e-6; end
if ~isfield(options, 'include_lumbar'), options.include_lumbar = true; end
if ~isfield(options, 'include_lumbar_muscle'), options.include_lumbar_muscle = true; end

muscle_names = fieldnames(muscles);
n_muscles = length(muscle_names);
n_frames = length(streamInter.wtime);

% 初始化输出变量
muscle_activations_opt = struct();
for i = 1:n_muscles
    muscle_activations_opt.(muscle_names{i}) = zeros(n_frames, 1);
end
residuals = struct();
exitflag = zeros(n_frames, 1);

% 计算基于解剖学的肌肉-关节力臂
fprintf('正在计算基于解剖学的力臂...\n');
moment_arms = CalculateAnatomicalMomentArms(muscles, segments_RM, segments_origin, ...
    segments_length, streamInter, options.include_lumbar, options.include_lumbar_muscle);

% 定义需要优化的关节（根据include_lumbar参数决定是否包含腰椎）
if options.include_lumbar
    joints_to_optimize = {'lumbar', 'hip_l', 'hip_r', 'knee_l', 'knee_r', 'ankle_l', 'ankle_r'};
    fprintf('静态优化包含腰椎关节\n');
else
    joints_to_optimize = {'hip_l', 'hip_r', 'knee_l', 'knee_r', 'ankle_l', 'ankle_r'};
    fprintf('静态优化不包含腰椎关节\n');
end

% 对每个时间帧进行优化
fprintf('开始静态优化...\n');
for frame = 1:n_frames
    if mod(frame, 1000) == 0
        fprintf('正在处理第 %d/%d 帧\n', frame, n_frames);
    end

    % 提取当前帧的关节力矩
    target_moments = ExtractJointMoments(jointMomentGlobal, joints_to_optimize, frame);

    % 提取当前帧的力臂矩阵（基于解剖学映射）
    R = ExtractAnatomicalMomentArmsFrame(moment_arms, muscle_names, joints_to_optimize, frame);

    % 计算当前帧的肌肉主动力和被动力
    [F_active_max, F_passive] = CalculateMuscleForceComponents(muscles, muscle_lengths, muscle_velocities, muscle_names, frame);

    % 建立并求解优化问题
    [activations, residual, flag] = SolveStaticOptimization(R, F_active_max, F_passive, target_moments, options);

    % 存储结果
    for i = 1:n_muscles
        muscle_activations_opt.(muscle_names{i})(frame) = activations(i);
    end
    residuals.(['frame_' num2str(frame)]) = residual;
    exitflag(frame) = flag;
end

fprintf('静态优化完成。\n');
end
