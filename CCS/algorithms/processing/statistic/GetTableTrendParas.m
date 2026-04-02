% 计算趋势特征
function [table_trend_paras, trend_fields] = GetTableTrendParas(cellSegs_patient,cellSegs_control,str_paras)
table_trend_paras = cell(5,1);

% 初始化结构体
trend_fields = {'cv','diff_mean','diff_std','diff_skewness','mcr','en','maxAbsV','maxAbsT','minV','minT','maxV','maxT','mean','rms'};
for i = 1:5
    table_trend_paras{i} = struct();
    for f = 1:length(trend_fields)
        table_trend_paras{i}.patient.(trend_fields{f}) = zeros(length(cellSegs_patient),length(str_paras));
        table_trend_paras{i}.control.(trend_fields{f}) = zeros(length(cellSegs_control),length(str_paras));
    end
end

% 患者组
for idxSeg = 1:length(cellSegs_patient)
    seg = cellSegs_patient{idxSeg};
    if length(1:seg.idx.idx_stage12)<2 ...
        || length(seg.idx.idx_stage12:seg.idx.idx_stage23)<2 ...
        || length(seg.idx.idx_stage23:seg.idx.idx_stage34)<2 ...
        || length(seg.idx.idx_stage34:seg.idx.idx_end)<2
        continue;
    end

    for idxPara = 1:length(str_paras)
        str_para = str_paras{idxPara};
        
        % 分期：1-4分别为4个站起阶段，5为完整站起
        for idx_stage = 1:5
            eval(['data = ',str_para,';']);

            if idx_stage == 1
                idxP = 1:seg.idx.idx_stage12;
            elseif idx_stage == 2
                idxP = seg.idx.idx_stage12:seg.idx.idx_stage23;
            elseif idx_stage == 3
                idxP = seg.idx.idx_stage23:seg.idx.idx_stage34;
            elseif idx_stage == 4
                idxP = seg.idx.idx_stage34:seg.idx.idx_end;
            elseif idx_stage == 5
                idxP = 1:seg.idx.idx_end;
            end
            t = seg.time(idxP);
            data = data(idxP);
            data = data(:); n = length(data); mean_val = mean(data);
            % 1. 变异系数（Coefficient of Variation, 振荡强度）
            CV = std(data) / abs(mean_val);
            table_trend_paras{idx_stage}.patient.cv(idxSeg,idxPara) = CV;
            % 2. 一阶差分均值（diff_mean, 变化方向）、标准差（diff_std, 变化剧烈程度）、偏度（diff_skewness, 方向不对称性）
            diff_data = diff(data);
            table_trend_paras{idx_stage}.patient.diff_mean(idxSeg,idxPara) = mean(diff_data);
            table_trend_paras{idx_stage}.patient.diff_std(idxSeg,idxPara) = std(diff_data);
            table_trend_paras{idx_stage}.patient.diff_skewness(idxSeg,idxPara) = skewness(diff_data);
            % 3. 过平均值率（Mean Crossing Rate, 振荡强度）
            zero_crossings = sum(diff(sign(data - mean_val)) ~= 0);
            MCR = zero_crossings / (n-1);
            table_trend_paras{idx_stage}.patient.mcr(idxSeg,idxPara) = MCR;
            % 4. 近似熵（Approximate Entropy, 信号复杂度）
            apen = ApEn(2, 0.2*std(data), data, 1);
            table_trend_paras{idx_stage}.patient.en(idxSeg,idxPara) = apen;
            % 5. 最大值及其时间点
            [~,aux] = max(abs(data));
            table_trend_paras{idx_stage}.patient.maxAbsV(idxSeg,idxPara) = abs(data(aux));
            table_trend_paras{idx_stage}.patient.maxAbsT(idxSeg,idxPara) = t(aux);
            [~,aux] = min(data);
            table_trend_paras{idx_stage}.patient.minV(idxSeg,idxPara) = data(aux);
            table_trend_paras{idx_stage}.patient.minT(idxSeg,idxPara) = t(aux);
            [~,aux] = max(data);
            table_trend_paras{idx_stage}.patient.maxV(idxSeg,idxPara) = data(aux);
            table_trend_paras{idx_stage}.patient.maxT(idxSeg,idxPara) = t(aux);
            % 6. 平均值和均方根（RMS）
            table_trend_paras{idx_stage}.patient.mean(idxSeg,idxPara) = mean(data);
            table_trend_paras{idx_stage}.patient.rms(idxSeg,idxPara) = rms(data);
        end
        
    end
end

% 对照组
for idxSeg = 1:length(cellSegs_control)
    seg = cellSegs_control{idxSeg};
    if length(1:seg.idx.idx_stage12)<2 ...
        || length(seg.idx.idx_stage12:seg.idx.idx_stage23)<2 ...
        || length(seg.idx.idx_stage23:seg.idx.idx_stage34)<2 ...
        || length(seg.idx.idx_stage34:seg.idx.idx_end)<2
        continue;
    end

    for idxPara = 1:length(str_paras)
        str_para = str_paras{idxPara};
        
        % 分期：1-4分别为4个站起阶段，5为完整站起
        for idx_stage = 1:5
            eval(['data = ',str_para,';']);

            if idx_stage == 1
                idxP = 1:seg.idx.idx_stage12;
            elseif idx_stage == 2
                idxP = seg.idx.idx_stage12:seg.idx.idx_stage23;
            elseif idx_stage == 3
                idxP = seg.idx.idx_stage23:seg.idx.idx_stage34;
            elseif idx_stage == 4
                idxP = seg.idx.idx_stage34:seg.idx.idx_end;
            elseif idx_stage == 5
                idxP = 1:seg.idx.idx_end;
            end
            t = seg.time(idxP);
            data = data(idxP);
            data = data(:); n = length(data); mean_val = mean(data);
            % 1. 变异系数（Coefficient of Variation, 振荡强度）
            CV = std(data) / abs(mean_val);
            table_trend_paras{idx_stage}.control.cv(idxSeg,idxPara) = CV;
            % 2. 一阶差分均值（diff_mean, 变化方向）、标准差（diff_std, 变化剧烈程度）、偏度（diff_skewness, 方向不对称性）
            diff_data = diff(data);
            table_trend_paras{idx_stage}.control.diff_mean(idxSeg,idxPara) = mean(diff_data);
            table_trend_paras{idx_stage}.control.diff_std(idxSeg,idxPara) = std(diff_data);
            table_trend_paras{idx_stage}.control.diff_skewness(idxSeg,idxPara) = skewness(diff_data);
            % 3. 过平均值率（Mean Crossing Rate, 振荡强度）
            zero_crossings = sum(diff(sign(data - mean_val)) ~= 0);
            MCR = zero_crossings / (n-1);
            table_trend_paras{idx_stage}.control.mcr(idxSeg,idxPara) = MCR;
            % 4. 近似熵（Approximate Entropy, 信号复杂度）
            apen = ApEn(2, 0.2*std(data), data, 1);
            table_trend_paras{idx_stage}.control.en(idxSeg,idxPara) = apen;
            % 5. 最大值及其时间点
            [~,aux] = max(abs(data));
            table_trend_paras{idx_stage}.control.maxAbsV(idxSeg,idxPara) = abs(data(aux));
            table_trend_paras{idx_stage}.control.maxAbsT(idxSeg,idxPara) = t(aux);
            [~,aux] = min(data);
            table_trend_paras{idx_stage}.control.minV(idxSeg,idxPara) = data(aux);
            table_trend_paras{idx_stage}.control.minT(idxSeg,idxPara) = t(aux);
            [~,aux] = max(data);
            table_trend_paras{idx_stage}.control.maxV(idxSeg,idxPara) = data(aux);
            table_trend_paras{idx_stage}.control.maxT(idxSeg,idxPara) = t(aux);
            % 6. 平均值和均方根（RMS）
            table_trend_paras{idx_stage}.control.mean(idxSeg,idxPara) = mean(data);
            table_trend_paras{idx_stage}.control.rms(idxSeg,idxPara) = rms(data);
        end
        
    end
end