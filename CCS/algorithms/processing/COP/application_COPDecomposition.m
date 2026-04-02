function [ f ] = application_COPDecomposition
%APPLICATION_COPDECOMPOSITION: COP分解方法集合
%% global function handler
global Handler_Filter_med2sg Handler_generateTimetag Handler_computeAcc_withSGfilter
Handler_Filter_med2sg = @(s)sgolayfilt(medfilt1(s,3),3,7);
Handler_computeAcc_withSGfilter = ...
    @(s, T)smooth(gradient(gradient(s, T), T), 5, 'sgolay', 1);
Handler_generateTimetag = @(T,n) (0: T : (n-1)*T)';
%% functions
f.getMigrResiDecomposition = ...
    @(ml, ap, fs)getMigrResiDecomposition(ml, ap, fs);
f.getResiAboveo01 = ...
    @(resi_ml, resi_ap) find(sqrt(resi_ml.^2 + resi_ap.^2) > 0.1);
f.getResiBelowo01 = ...
    @(resi_ml, resi_ap) find(sqrt(resi_ml.^2 + resi_ap.^2) <= 0.1);
end

function out = getMigrResiDecomposition(ml, ap, fs)
%% 实现COP信号的分解
%       输入信号单位：ml（毫米），ap（毫米），fs（Hz），均为列向量
%       输出：包含分解结果以及经过剪裁的原始COP信号（各信号时间对应）
%

if ~iscolumn(ml)||~iscolumn(ap)
    error('Input of ML and AP should be column vector.');
end
global Handler_Filter_med2sg Handler_generateTimetag
ml = ml - mean(ml);     % 去平均
ap = ap - mean(ap);
ml = Handler_Filter_med2sg(ml);     % 平滑
ap = Handler_Filter_med2sg(ap);
T = 1/fs;
t = Handler_generateTimetag(T, numel(ml));
% interpolation point
p_t = getFeaturePoints(ml, ap, t, T);
% interpolate signal
migr_rough_ml = interp1(t, ml, p_t, 'pchip');       % 插值获得特征时间的COP位置
migr_rough_ap = interp1(t, ap, p_t, 'pchip');
migr_ml = interp1(p_t, migr_rough_ml, t, 'pchip');  % Migr信号
migr_ap = interp1(p_t, migr_rough_ap, t, 'pchip');
resi_ml = ml - migr_ml;                             % Resi信号
resi_ap = ap - migr_ap;
% trim signal
index = t > p_t(1) & t < p_t(end);     % 剪裁开始和末尾偏差较大的插值结果
out.ml = ml(index); out.ap = ap(index);
out.migr_ml = migr_ml(index); out.migr_ap = migr_ap(index);
out.resi_ml = resi_ml(index); out.resi_ap = resi_ap(index);
out.t = t(index); out.t = out.t - out.t(1);     % 信号时间从第一个特征时间到最后一个特征时间
end

function p_t = getFeaturePoints(ml, ap, t, T)
%% 计算COP信号中用于分解信号的特征点，包括：
%       低价速度点：加速度阈值25mm/s
%       快速转折点：加速度阈值25mm/s
%   输入均为列向量，ml、ap分别是左右、前后信号，t是时间标签，T是采样间隔
%
global Acc_threshold
Acc_threshold = 25;     % 预设阈值
global Handler_computeAcc_withSGfilter
a_ml = Handler_computeAcc_withSGfilter(ml, T);
a_ap = Handler_computeAcc_withSGfilter(ap, T);
a = sqrt(a_ml.^2 + a_ap.^2);
% low acceleration point
low_acc_index = a < Acc_threshold;
% quick transient
q_t = getQuickTransietPoint(a_ml, a_ap, t); %       快速转折点

p_t = sort([t(low_acc_index); q_t]);
end

function q_t = getQuickTransietPoint(a_ml, a_ap, t)
%% 计算COP信号中的快速转换特征点
%       输入均为列向量，单位：加速度a_ml, a_ap --> mm*s-2, t --> s
%
global Acc_threshold
CellOpen = @(in) [in{:}]';

Acc_previous_ml = a_ml(1:end-1);
Acc_previous_ap = a_ap(1:end-1);
Acc_latter_ml = a_ml(2:end);
Acc_latter_ap = a_ap(2:end);
dt = CellOpen( ...计算相邻两个加速度线性转换过程中经过的最小加速度以及相关的距离量
    arrayfun(@(x1, y1, x2, y2)getTriangleAreaHeightByHeronformula ...
    (x1, y1, x2, y2), Acc_previous_ml, Acc_previous_ap, ...
    Acc_latter_ml, Acc_latter_ap, 'UniformOutput', false) ...
    );

transientAcc = dt(1:5:end);     % 提取线性转换过程中的最小加速度
lambda_previous = dt(2:5:end);
lambda_latter = dt(3:5:end);
t_previous = t(1:end-1);
t_latter = t(2:end);

q_t = t_previous + ...计算每个线性转换过程中最小加速度所在点的时间
    (t_latter - t_previous) .* lambda_previous ./ (lambda_previous + lambda_latter);
% 筛选有效的点，即最小加速度在前后加速度之间同时小于阈值
index_valid = lambda_previous > 0 & lambda_latter > 0 & transientAcc < Acc_threshold;
q_t = q_t(index_valid);
end

%% Basic Mathematic
function result = getTriangleAreaHeightByHeronformula(x1,y1,x2,y2)
% 概要: 计算两共起点二维向量的转角相关特征
% 参考:
%   海伦公式 https://baike.baidu.com/item/%E6%B5%B7%E4%BC%A6%E5%85%AC%E5%BC%8F/106956?fr=aladdin
%   余弦定理 https://baike.baidu.com/item/%E4%BD%99%E5%BC%A6%E5%AE%9A%E7%90%86#1
% 输入：
%   两个共起点二维向量的坐标
% 输出：
%   以两向量为两边所成三角形高（D）、垂点到起始向量末端距离（D_pre）、
%   垂点到终止向量末端距离（D_lat）、三角形面积（S）、
%   夹角大小（angle_theta，度数0-180）
%

a = sqrt(x1^2+y1^2);
b = sqrt(x2^2+y2^2);
c = sqrt((x1-x2)^2+(y1-y2)^2);
p = (a+b+c)/2;

D_pre = (c^2+a^2-b^2)/(2*c);
D_lat = (c^2+b^2-a^2)/(2*c);
S = sqrt(p*(p-a)*(p-b)*(p-c));
H = 2*S/c;
angle_theta = acosd((a^2+b^2-c^2)/(2*a*b));

result = [H, D_pre, D_lat, S, angle_theta];
end