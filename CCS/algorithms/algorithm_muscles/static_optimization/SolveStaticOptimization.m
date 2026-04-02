function [activations, residual, exitflag] = SolveStaticOptimization(R, F_active_max, F_passive, target_moments, options)
%% 求解静态优化问题
% 修正约束函数：R * (a .* F_active_max + F_passive) = target_moments
% 最小化: sum(a_i^2) 或 sum(a_i^p)
% 约束条件: R * (a .* F_active_max + F_passive) = target_moments
%          0.01 <= a_i <= 1.0

n_muscles = length(F_active_max);

% 优化设置
lb = ones(n_muscles, 1) * options.min_activation;  % 下界
ub = ones(n_muscles, 1) * options.max_activation;  % 上界
x0 = ones(n_muscles, 1) * 0.1;  % 初始猜测

% 目标函数
switch options.objective
    case 'sum_squared'
        objective = @(a) sum(a.^2);  % 最小化激活度平方和
    case 'sum_cubed'
        objective = @(a) sum(a.^3);  % 最小化激活度立方和
    case 'max_activation'
        objective = @(a) max(a);     % 最小化最大激活度
    case 'sum_squared_smooth'
        objective = @(a) sum(a.^2) + 5 * sum(abs(diff(a)));  % 添加平滑项
    case 'balanced_activation'
        % 新增：平衡激活目标函数
        % 最小化激活度平方和 + 惩罚激活度不均匀分布
        objective = @(a) sum(a.^2) + 0.1*length(a).*var(a) + 0.1*length(a).*max(a);
    otherwise
        objective = @(a) sum(a.^2);
end

% 修正的约束函数: R * (a .* F_active_max + F_passive) = target_moments
constraint = @(a) R * (a .* F_active_max + F_passive) - target_moments;

% 优化选项
opt_options = optimoptions('fmincon', ...
    'Display', 'off', ...
    'TolFun', options.tolerance, ...
    'TolCon', options.tolerance, ...
    'Algorithm', 'sqp');

% 求解优化问题
try
    [activations, ~, exitflag] = fmincon(objective, x0, [], [], [], [], lb, ub, ...
        @(a) deal(constraint(a), []), opt_options);

    % 计算残差
    residual = norm(constraint(activations));

catch ME
    warning(ME.identifier, '优化失败: %s', ME.message);
    activations = x0;
    residual = inf;
    exitflag = -1;
end
end