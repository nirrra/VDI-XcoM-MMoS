function [muscle_forces_filtered, muscle_forces_ce_filtered, muscle_forces_pe_filtered, filter_params] = AdaptiveFilterMuscleForces(muscle_forces, muscle_forces_ce, muscle_forces_pe, fs, options)
%% 自适应肌肉力滤波，根据信号特性调整滤波参数
% 
% 输入参数:
%   muscle_forces - 总肌肉力结构体
%   muscle_forces_ce - 主动收缩力结构体
%   muscle_forces_pe - 被动力结构体
%   fs - 采样频率 (Hz)
%   options - 滤波选项结构体（可选）
%
% 输出参数:
%   muscle_forces_filtered - 滤波后的总肌肉力
%   muscle_forces_ce_filtered - 滤波后的主动收缩力
%   muscle_forces_pe_filtered - 滤波后的被动力
%   filter_params - 使用的滤波参数

if nargin < 5
    options = struct();
end

% 默认选项
if ~isfield(options, 'base_cutoff'), options.base_cutoff = 8; end % 基础截止频率
if ~isfield(options, 'min_cutoff'), options.min_cutoff = 4; end % 最小截止频率
if ~isfield(options, 'max_cutoff'), options.max_cutoff = 15; end % 最大截止频率
if ~isfield(options, 'filter_order'), options.filter_order = 4; end % 滤波器阶数
if ~isfield(options, 'noise_threshold'), options.noise_threshold = 0.1; end % 噪声阈值

% 获取肌肉名称
muscle_names = fieldnames(muscle_forces);

% 初始化输出结构体
muscle_forces_filtered = struct();
muscle_forces_ce_filtered = struct();
muscle_forces_pe_filtered = struct();
filter_params = struct();

fprintf('正在进行自适应肌肉力滤波处理...\n');

for i = 1:length(muscle_names)
    muscle_name = muscle_names{i};
    
    try
        % 分析信号特性
        signal = muscle_forces.(muscle_name);
        
        % 计算信号的变化率和噪声水平
        signal_diff = diff(signal);
        noise_level = std(signal_diff) / mean(abs(signal_diff) + eps);
        
        % 计算信号的频率特性
        [psd, freq] = pwelch(signal, [], [], [], fs);
        
        % 找到主要频率成分
        [~, peak_idx] = max(psd);
        dominant_freq = freq(peak_idx);
        
        % 计算能量集中度
        total_energy = sum(psd);
        low_freq_energy = sum(psd(freq <= 10)); % 10Hz以下的能量
        energy_ratio = low_freq_energy / total_energy;
        
        % 自适应调整截止频率
        if noise_level > options.noise_threshold
            % 高噪声：使用较低的截止频率
            adaptive_cutoff = options.base_cutoff * (1 - 0.3 * min(noise_level, 1));
        else
            % 低噪声：根据频率特性调整
            if energy_ratio > 0.8
                % 主要是低频信号，可以使用较高的截止频率
                adaptive_cutoff = options.base_cutoff * 1.2;
            else
                % 包含较多高频成分，使用标准截止频率
                adaptive_cutoff = options.base_cutoff;
            end
        end
        
        % 限制截止频率范围
        adaptive_cutoff = max(options.min_cutoff, min(options.max_cutoff, adaptive_cutoff));
        
        % 设计滤波器
        [b, a] = butter(options.filter_order, adaptive_cutoff/(fs/2), 'low');
        
        % 应用滤波
        muscle_forces_filtered.(muscle_name) = filtfilt(b, a, signal);
        
        % 主动收缩力滤波
        if isfield(muscle_forces_ce, muscle_name)
            muscle_forces_ce_filtered.(muscle_name) = filtfilt(b, a, muscle_forces_ce.(muscle_name));
        else
            muscle_forces_ce_filtered.(muscle_name) = muscle_forces_filtered.(muscle_name);
        end
        
        % 被动力滤波
        if isfield(muscle_forces_pe, muscle_name)
            muscle_forces_pe_filtered.(muscle_name) = filtfilt(b, a, muscle_forces_pe.(muscle_name));
        else
            muscle_forces_pe_filtered.(muscle_name) = zeros(size(muscle_forces_filtered.(muscle_name)));
        end
        
        % 确保滤波后的力值为非负
        muscle_forces_filtered.(muscle_name) = max(0, muscle_forces_filtered.(muscle_name));
        muscle_forces_ce_filtered.(muscle_name) = max(0, muscle_forces_ce_filtered.(muscle_name));
        muscle_forces_pe_filtered.(muscle_name) = max(0, muscle_forces_pe_filtered.(muscle_name));
        
        % 存储滤波参数
        filter_params.(muscle_name) = struct(...
            'cutoff_freq', adaptive_cutoff, ...
            'noise_level', noise_level, ...
            'dominant_freq', dominant_freq, ...
            'energy_ratio', energy_ratio);
        
        % 检查数值有效性
        if any(isnan(muscle_forces_filtered.(muscle_name))) || any(isinf(muscle_forces_filtered.(muscle_name)))
            warning('肌肉 %s 滤波后存在无效值，使用原始数据', muscle_name);
            muscle_forces_filtered.(muscle_name) = max(0, signal);
            muscle_forces_ce_filtered.(muscle_name) = max(0, muscle_forces_ce.(muscle_name));
            muscle_forces_pe_filtered.(muscle_name) = max(0, muscle_forces_pe.(muscle_name));
        end
        
    catch ME
        warning('肌肉 %s 自适应滤波失败: %s，使用原始数据', muscle_name, ME.message);
        muscle_forces_filtered.(muscle_name) = muscle_forces.(muscle_name);
        muscle_forces_ce_filtered.(muscle_name) = muscle_forces_ce.(muscle_name);
        muscle_forces_pe_filtered.(muscle_name) = muscle_forces_pe.(muscle_name);
        
        filter_params.(muscle_name) = struct(...
            'cutoff_freq', options.base_cutoff, ...
            'noise_level', NaN, ...
            'dominant_freq', NaN, ...
            'energy_ratio', NaN);
    end
end

% 显示滤波参数统计
cutoff_freqs = cellfun(@(x) filter_params.(x).cutoff_freq, muscle_names);
fprintf('自适应滤波完成:\n');
fprintf('  截止频率范围: %.1f - %.1f Hz\n', min(cutoff_freqs), max(cutoff_freqs));
fprintf('  平均截止频率: %.1f Hz\n', mean(cutoff_freqs));

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
    fprintf('  平均噪声减少: %.1f%%\n', avg_noise_reduction);
end

end 