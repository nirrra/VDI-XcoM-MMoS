function [tableMean, tableStd] = GetTableCorrelationCoefficient(cellSegs, str_paras_a, str_paras_b)
% GetTableCorrelationCoefficient - 计算两个参数集合之间的相关系数
%
% 输入参数:
%   cellSegs - 包含所有seg的cell数组
%   str_paras_a - 第一个参数集合，如{'seg.com.x', 'seg.com.y'}
%   str_paras_b - 第二个参数集合，如{'seg.xcom.x', 'seg.xcom.y'}
%
% 输出参数:
%   tableMean - 相关系数平均值表格，size为(length(str_paras_a), length(str_paras_b))
%   tableStd - 相关系数标准差表格，size为(length(str_paras_a), length(str_paras_b))
%
% 功能:
%   对cellSegs中的所有seg，计算str_paras_a和str_paras_b所有两两对应的相关系数，
%   求所有segs的相关系数的平均值和标准差

% 初始化输出矩阵
n_a = length(str_paras_a);
n_b = length(str_paras_b);
correlation_matrix = zeros(length(cellSegs), n_a, n_b);

% 遍历所有seg
for idxSeg = 1:length(cellSegs)
    seg = cellSegs{idxSeg};
    
    % 提取参数a的数据
    data_a = zeros(n_a, length(seg.time));
    for i = 1:n_a
        try
            eval(['data_a(i,:) = ', str_paras_a{i}, ';']);
        catch
            % 如果参数不存在，用NaN填充
            data_a(i,:) = NaN;
        end
    end
    
    % 提取参数b的数据
    data_b = zeros(n_b, length(seg.time));
    for j = 1:n_b
        try
            eval(['data_b(j,:) = ', str_paras_b{j}, ';']);
        catch
            % 如果参数不存在，用NaN填充
            data_b(j,:) = NaN;
        end
    end
    
    % 计算相关系数矩阵
    for i = 1:n_a
        for j = 1:n_b
            % 检查数据是否有效
            if ~any(isnan(data_a(i,:))) && ~any(isnan(data_b(j,:))) && ...
               length(data_a(i,:)) == length(data_b(j,:)) && length(data_a(i,:)) > 1
                
                % 计算相关系数
                corr_coef = corrcoef(data_a(i,:), data_b(j,:));
                if size(corr_coef, 1) == 2 && size(corr_coef, 2) == 2
                    correlation_matrix(idxSeg, i, j) = corr_coef(1, 2);
                else
                    correlation_matrix(idxSeg, i, j) = NaN;
                end
            else
                correlation_matrix(idxSeg, i, j) = NaN;
            end
        end
    end
end

% 计算平均值和标准差
mean_matrix = zeros(n_a, n_b);
std_matrix = zeros(n_a, n_b);

for i = 1:n_a
    for j = 1:n_b
        % 提取所有seg的相关系数
        corr_values = squeeze(correlation_matrix(:, i, j));
        
        % 去除NaN值
        corr_values = corr_values(~isnan(corr_values));
        
        if ~isempty(corr_values)
            mean_matrix(i, j) = mean(corr_values);
            std_matrix(i, j) = std(corr_values);
        else
            mean_matrix(i, j) = NaN;
            std_matrix(i, j) = NaN;
        end
    end
end

% 创建输出表格
% 为表格创建行名和列名
row_names = str_paras_a;
col_names = str_paras_b;

% 创建table对象
tableMean = array2table(mean_matrix, 'RowNames', row_names, 'VariableNames', col_names);
tableStd = array2table(std_matrix, 'RowNames', row_names, 'VariableNames', col_names);

end
