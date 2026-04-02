function [table_compare_4groups] = GetTableCompare_4groups(cellSegs_patient_1, cellSegs_patient_2, cellSegs_patient_3, cellSegs_control, str_paras, str_paras_names)
% GetTableCompare_4groups - 比较四个组（三个患者组+对照组）之间的统计差异
%
% 输入参数:
%   cellSegs_patient_1 - 第一组患者数据
%   cellSegs_patient_2 - 第二组患者数据  
%   cellSegs_patient_3 - 第三组患者数据
%   cellSegs_control - 对照组数据
%   str_paras - 要比较的参数列表，如{'seg.com.x', 'seg.com.y'}
%
% 输出参数:
%   table_compare_4groups - 统计比较表格，包含20列：
%     - 12列p和h值: p_1vs2, h_1vs2, p_1vs3, h_1vs3, p_1vs4, h_1vs4, 
%                   p_2vs3, h_2vs3, p_2vs4, h_2vs4, p_3vs4, h_3vs4
%     - 8列均值和标准差: mean_1, std_1, mean_2, std_2, mean_3, std_3, mean_4, std_4
%     其中组4为对照组

% 初始化结果矩阵
n_paras = length(str_paras);
results = zeros(n_paras, 20);

% 定义列名 - 12列p和h值 + 8列均值和标准差
col_names = {'p_1vs2', 'h_1vs2', 'p_1vs3', 'h_1vs3', 'p_1vs4', 'h_1vs4', ...
             'p_2vs3', 'h_2vs3', 'p_2vs4', 'h_2vs4', 'p_3vs4', 'h_3vs4', ...
             'mean_1', 'std_1', 'mean_2', 'std_2', 'mean_3', 'std_3', 'mean_4', 'std_4'};

% 遍历每个参数
for idxPara = 1:n_paras
    str_para = str_paras{idxPara};
    
    % 提取四组数据
    data_group_1 = extractParaData(cellSegs_patient_1, str_para);
    data_group_2 = extractParaData(cellSegs_patient_2, str_para);
    data_group_3 = extractParaData(cellSegs_patient_3, str_para);
    data_group_4 = extractParaData(cellSegs_control, str_para);
    
    % 计算统计量
    if ~isempty(data_group_1) && ~isempty(data_group_2) && ~isempty(data_group_3) && ~isempty(data_group_4)
        % ranksum检验：所有两两比较 (6种组合)
        [p_1vs2, h_1vs2] = ranksum(data_group_1, data_group_2);
        [p_1vs3, h_1vs3] = ranksum(data_group_1, data_group_3);
        [p_1vs4, h_1vs4] = ranksum(data_group_1, data_group_4);
        [p_2vs3, h_2vs3] = ranksum(data_group_2, data_group_3);
        [p_2vs4, h_2vs4] = ranksum(data_group_2, data_group_4);
        [p_3vs4, h_3vs4] = ranksum(data_group_3, data_group_4);
        
        % 计算均值和标准差
        mean_1 = mean(data_group_1, 'omitnan');
        std_1 = std(data_group_1, 0, 'omitnan');
        mean_2 = mean(data_group_2, 'omitnan');
        std_2 = std(data_group_2, 0, 'omitnan');
        mean_3 = mean(data_group_3, 'omitnan');
        std_3 = std(data_group_3, 0, 'omitnan');
        mean_4 = mean(data_group_4, 'omitnan');
        std_4 = std(data_group_4, 0, 'omitnan');
        
        % 存储结果
        results(idxPara, :) = [p_1vs2, h_1vs2, p_1vs3, h_1vs3, p_1vs4, h_1vs4, ...
                              p_2vs3, h_2vs3, p_2vs4, h_2vs4, p_3vs4, h_3vs4, ...
                              mean_1, std_1, mean_2, std_2, mean_3, std_3, mean_4, std_4];
    else
        % 如果数据为空，填入NaN
        results(idxPara, :) = NaN;
    end
end

% 创建表格
table_compare_4groups = array2table(results, 'VariableNames', col_names, 'RowNames', str_paras_names);

end

function data_combined = extractParaData(cellSegs, str_para)
% 从cellSegs中提取指定参数的数据
% 输入:
%   cellSegs - cell数组，包含所有seg
%   str_para - 参数字符串，如'seg.com.x'
% 输出:
%   data_combined - 所有seg的该参数数据合并后的向量

data_combined = [];

for idxSeg = 1:length(cellSegs)
    seg = cellSegs{idxSeg};
    
    try
        % 使用eval提取参数数据
        data_seg = [];  % 初始化变量
        eval(['data_seg = ', str_para, ';']);
        
        % 检查数据有效性
        if ~isempty(data_seg) && ~all(isnan(data_seg))
            % 将数据展平并添加到合并数据中
            data_combined = [data_combined; data_seg(:)];
        end
    catch
        % 如果参数不存在或提取失败，跳过这个seg
        continue;
    end
end

% 移除NaN值
data_combined = data_combined(~isnan(data_combined));

end

