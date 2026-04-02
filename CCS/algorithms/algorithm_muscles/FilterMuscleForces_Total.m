function [muscle_forces_filtered, filter_params] = FilterMuscleForces_Total(muscle_forces, fs, options)
%% 直接对总肌肉力进行滤波处理以减少短时跳跃
% 支持标准滤波和自适应滤波两种模式
% 
% 输入参数:
%   muscle_forces - 总肌肉力结构体
%   fs - 采样频率 (Hz)
%   options - 滤波选项结构体（可选）
%     .use_adaptive - 是否使用自适应滤波 (默认false)
%     .cutoff_freq - 截止频率 (Hz)，标准滤波时使用 (默认8Hz)
%     .filter_order - 滤波器阶数 (默认4)
%     .base_cutoff - 自适应滤波基础截止频率 (默认8Hz)
%     .min_cutoff - 自适应滤波最小截止频率 (默认4Hz)
%     .max_cutoff - 自适应滤波最大截止频率 (默认15Hz)
%     .noise_threshold - 噪声阈值 (默认0.15)
%
% 输出参数:
%   muscle_forces_filtered - 滤波后的总肌肉力
%   filter_params - 滤波参数信息

if nargin < 3
    options = struct();
end

% 默认选项
if ~isfield(options, 'use_adaptive'), options.use_adaptive = false; end
if ~isfield(options, 'cutoff_freq'), options.cutoff_freq = 8; end
if ~isfield(options, 'filter_order'), options.filter_order = 4; end
if ~isfield(options, 'base_cutoff'), options.base_cutoff = 8; end
if ~isfield(options, 'min_cutoff'), options.min_cutoff = 4; end
if ~isfield(options, 'max_cutoff'), options.max_cutoff = 15; end
if ~isfield(options, 'noise_threshold'), options.noise_threshold = 0.15; end

% 获取肌肉名称
muscle_names = fieldnames(muscle_forces);

% 初始化输出结构体
muscle_forces_filtered = struct();
filter_params = struct();

if options.use_adaptive
    fprintf('正在对 %d 块肌肉的总肌肉力进行自适应滤波处理...\n', length(muscle_names));
else
    fprintf('正在对 %d 块肌肉的总肌肉力进行标准滤波处理...\n', length(muscle_names));
end

for i = 1:length(muscle_names)
    muscle_name = muscle_names{i};
    
    try
        signal = muscle_forces.(muscle_name);
        
        if options.use_adaptive
            % 自适应滤波：分析信号特性并调整参数
            [adaptive_cutoff, signal_stats] = AnalyzeSignalAndAdaptFilter_Total(signal, fs, options);
            
            % 设计自适应滤波器
            [b, a] = butter(options.filter_order, adaptive_cutoff/(fs/2), 'low');
            
            % 存储滤波参数
            filter_params.(muscle_name) = struct(...
                'cutoff_freq', adaptive_cutoff, ...
                'noise_level', signal_stats.noise_level, ...
                'dominant_freq', signal_stats.dominant_freq, ...
                'energy_ratio', signal_stats.energy_ratio, ...
                'signal_variability', signal_stats.signal_variability);
        else
            % 标准滤波：使用固定参数
            [b, a] = butter(options.filter_order, options.cutoff_freq/(fs/2), 'low');
            
            % 存储滤波参数
            filter_params.(muscle_name) = struct(...
                'cutoff_freq', options.cutoff_freq, ...
                'filter_type', 'standard');
        end
        
        % 应用滤波
        muscle_forces_filtered.(muscle_name) = filtfilt(b, a, signal);
        
        % 确保滤波后的力值为非负
        muscle_forces_filtered.(muscle_name) = max(0, muscle_forces_filtered.(muscle_name));
        
        % 检查数值有效性
        if any(isnan(muscle_forces_filtered.(muscle_name))) || any(isinf(muscle_forces_filtered.(muscle_name)))
            warning('肌肉 %s 总肌肉力滤波后存在无效值，使用原始数据', muscle_name);
            muscle_forces_filtered.(muscle_name) = max(0, signal);
        end
        
    catch ME
        warning('肌肉 %s 总肌肉力滤波失败: %s，使用原始数据', muscle_name, ME.message);
        muscle_forces_filtered.(muscle_name) = muscle_forces.(muscle_name);
        
        % 错误情况下的参数记录
        if options.use_adaptive
            filter_params.(muscle_name) = struct(...
                'cutoff_freq', options.base_cutoff, ...
                'error', ME.message);
        else
            filter_params.(muscle_name) = struct(...
                'cutoff_freq', options.cutoff_freq, ...
                'error', ME.message);
        end
    end
end

% 显示滤波完成信息
if options.use_adaptive
    cutoff_freqs = cellfun(@(x) filter_params.(x).cutoff_freq, muscle_names);
    fprintf('总肌肉力自适应滤波完成:\n');
    fprintf('  截止频率范围: %.1f - %.1f Hz\n', min(cutoff_freqs), max(cutoff_freqs));
    fprintf('  平均截止频率: %.1f Hz\n', mean(cutoff_freqs));
else
    fprintf('总肌肉力标准滤波完成，使用 %.1f Hz 低通滤波器 (阶数: %d)\n', options.cutoff_freq, options.filter_order);
end

% 计算滤波效果统计
total_reduction = 0;
valid_muscles = 0;

for i = 1:length(muscle_names)
    muscle_name = muscle_names{i};
    original_std = std(muscle_forces.(muscle_name));
    filtered_std = std(muscle_forces_filtered.(muscle_name));
    
    if original_std > 0
        reduction = (original_std - filtered_std) / original_std * 100;
        total_reduction = total_reduction + reduction;
        valid_muscles = valid_muscles + 1;
    end
end

if valid_muscles > 0
    avg_noise_reduction = total_reduction / valid_muscles;
    fprintf('总肌肉力平均噪声减少: %.1f%%\n', avg_noise_reduction);
end

% 显示滤波前后的对比统计
fprintf('\n=== 总肌肉力滤波效果详细统计 ===\n');
total_rms_reduction = 0;
total_peak_reduction = 0;
valid_count = 0;

for i = 1:length(muscle_names)
    muscle_name = muscle_names{i};
    
    % 计算RMS值变化
    rms_orig = rms(muscle_forces.(muscle_name));
    rms_filt = rms(muscle_forces_filtered.(muscle_name));
    
    % 计算峰值变化
    peak_orig = max(muscle_forces.(muscle_name));
    peak_filt = max(muscle_forces_filtered.(muscle_name));
    
    if rms_orig > 0 && peak_orig > 0
        rms_reduction = (rms_orig - rms_filt) / rms_orig * 100;
        peak_reduction = (peak_orig - peak_filt) / peak_orig * 100;
        
        total_rms_reduction = total_rms_reduction + rms_reduction;
        total_peak_reduction = total_peak_reduction + peak_reduction;
        valid_count = valid_count + 1;
        
        if i <= 6 % 显示前几个肌肉的详细信息
            if options.use_adaptive && isfield(filter_params, muscle_name) && isfield(filter_params.(muscle_name), 'cutoff_freq')
                fprintf('%s: RMS减少 %.1f%%, 峰值减少 %.1f%% (截止频率: %.1f Hz)\n', ...
                    muscle_name, rms_reduction, peak_reduction, filter_params.(muscle_name).cutoff_freq);
            else
                fprintf('%s: RMS减少 %.1f%%, 峰值减少 %.1f%%\n', muscle_name, rms_reduction, peak_reduction);
            end
        end
    end
end

if valid_count > 0
    fprintf('平均RMS减少: %.1f%%\n', total_rms_reduction / valid_count);
    fprintf('平均峰值减少: %.1f%%\n', total_peak_reduction / valid_count);
end

end

%% 辅助函数：分析信号特性并自适应调整滤波器
function [adaptive_cutoff, signal_stats] = AnalyzeSignalAndAdaptFilter_Total(signal, fs, options)
%% 分析总肌肉力信号特性并确定最佳截止频率

try
    % 计算信号的变化率和噪声水平
    signal_diff = diff(signal);
    noise_level = std(signal_diff) / (mean(abs(signal_diff)) + eps);
    
    % 计算信号变异性
    signal_variability = std(signal) / (mean(signal) + eps);
    
    % 计算信号的频率特性
    [psd, freq] = pwelch(signal, [], [], [], fs);
    
    % 找到主要频率成分
    [~, peak_idx] = max(psd);
    dominant_freq = freq(peak_idx);
    
    % 计算能量集中度
    total_energy = sum(psd);
    low_freq_energy = sum(psd(freq <= 10)); % 10Hz以下的能量
    energy_ratio = low_freq_energy / total_energy;
    
    % 计算高频噪声比例
    high_freq_energy = sum(psd(freq > 15)); % 15Hz以上的能量
    high_freq_ratio = high_freq_energy / total_energy;
    
    % 自适应调整截止频率的策略（针对总肌肉力优化）
    adaptive_cutoff = options.base_cutoff;
    
    % 策略1：基于噪声水平调整（总肌肉力通常噪声较低）
    if noise_level > options.noise_threshold * 1.2 % 对总肌肉力使用更宽松的阈值
        % 高噪声：降低截止频率
        noise_factor = min(noise_level / (options.noise_threshold * 1.2), 2.0);
        adaptive_cutoff = adaptive_cutoff * (1 - 0.25 * (noise_factor - 1));
    end
    
    % 策略2：基于信号变异性调整（总肌肉力变异性通常较小）
    if signal_variability > 0.3 % 对总肌肉力使用更低的阈值
        % 高变异性：适度降低截止频率
        adaptive_cutoff = adaptive_cutoff * 0.95;
    end
    
    % 策略3：基于频率特性调整
    if energy_ratio > 0.9
        % 主要是低频信号：可以使用较高的截止频率
        adaptive_cutoff = adaptive_cutoff * 1.15;
    elseif high_freq_ratio > 0.1
        % 包含较多高频噪声：降低截止频率
        adaptive_cutoff = adaptive_cutoff * 0.85;
    end
    
    % 策略4：基于主频率调整
    if dominant_freq > 0 && dominant_freq < 4
        % 主频率很低：可以使用较高的截止频率
        adaptive_cutoff = adaptive_cutoff * 1.25;
    elseif dominant_freq > 10
        % 主频率较高：保留更多高频信息
        adaptive_cutoff = min(adaptive_cutoff * 1.4, options.max_cutoff);
    end
    
    % 限制截止频率范围
    adaptive_cutoff = max(options.min_cutoff, min(options.max_cutoff, adaptive_cutoff));
    
    % 存储信号统计信息
    signal_stats = struct(...
        'noise_level', noise_level, ...
        'signal_variability', signal_variability, ...
        'dominant_freq', dominant_freq, ...
        'energy_ratio', energy_ratio, ...
        'high_freq_ratio', high_freq_ratio);
    
catch ME
    % 如果分析失败，使用默认值
    adaptive_cutoff = options.base_cutoff;
    signal_stats = struct(...
        'noise_level', NaN, ...
        'signal_variability', NaN, ...
        'dominant_freq', NaN, ...
        'energy_ratio', NaN, ...
        'high_freq_ratio', NaN, ...
        'error', ME.message);
end

end 