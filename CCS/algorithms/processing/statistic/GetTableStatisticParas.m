function [table_statistic_paras] = GetTableStatisticParas(cellSegs_patient,cellSegs_control,str_paras,str_para_names)

%% 计算趋势特征
[table_trend_paras, trend_fields] = GetTableTrendParas(cellSegs_patient,cellSegs_control,str_paras);

%% 趋势特征统计分析（患者组 vs 对照组）
table_statistic_paras = struct();
% 创建统计表格，30列（6列×5个阶段）
stage_names = {'Stage1', 'Stage2', 'Stage3', 'Stage4', 'Full'};
col_names = {};
for s = 1:5
    stage_prefix = stage_names{s};
    col_names = [col_names, {[stage_prefix '_h'], [stage_prefix '_p'], ...
        [stage_prefix '_mean_patient'], [stage_prefix '_std_patient'], ...
        [stage_prefix '_mean_control'], [stage_prefix '_std_control']}];
end

% 为每个特征创建统计表格
for f = 1:length(trend_fields)
    field = trend_fields{f};
    stats_data = zeros(length(str_paras), 30); % 22个参数×30列
    
    for idx_stage = 1:5
        col_offset = (idx_stage-1) * 6; % 每个阶段6列
        
        for idxPara = 1:length(str_paras)
            % 获取患者组和对照组数据
            data_patient = table_trend_paras{idx_stage}.patient.(field)(:,idxPara);
            data_control = table_trend_paras{idx_stage}.control.(field)(:,idxPara);
            
            % 剔除全为0的数据（未赋值的seg段）
            valid_patient = data_patient(data_patient ~= 0);
            valid_control = data_control(data_control ~= 0);
            
            % 计算统计量
            if ~isempty(valid_patient) && ~isempty(valid_control)
                mean_patient = mean(valid_patient, 'omitnan');
                std_patient = std(valid_patient, 0, 'omitnan');
                mean_control = mean(valid_control, 'omitnan');
                std_control = std(valid_control, 0, 'omitnan');
                
                % ranksum检验
                [p, h] = ranksum(valid_patient, valid_control);
                
                % 存储结果
                stats_data(idxPara, col_offset+1) = h; % h值
                stats_data(idxPara, col_offset+2) = p; % p值
                stats_data(idxPara, col_offset+3) = mean_patient;
                stats_data(idxPara, col_offset+4) = std_patient;
                stats_data(idxPara, col_offset+5) = mean_control;
                stats_data(idxPara, col_offset+6) = std_control;
            else
                % 如果数据为空，填入NaN
                stats_data(idxPara, col_offset+1:col_offset+6) = NaN;
            end
        end
    end
    
    % 创建表格
    table_statistic_paras.(field)= array2table(stats_data, 'VariableNames', col_names, 'RowNames', str_para_names);
end