function tableTrendPara =  GetTableTrendPara(tableTrendParas,idxPara)
    names_para = fieldnames(tableTrendParas{1,1});
    tableTrendPara = struct();

    for i = 1:length(names_para)
        aux = zeros(6,4);
        for idxSTS = 1:3
            for idxStage = 1:5
                aux(idxSTS,idxStage) = tableTrendParas{idxStage}.(names_para{i}).mean_std{2*idxSTS+1,idxPara}; % 平均值
                aux(idxSTS+3,idxStage) = tableTrendParas{idxStage}.(names_para{i}).mean_std{2*idxSTS+2,idxPara}; % 标准差
            end
        end
        aux = array2table(aux,'RowNames',{'MT mean','ETF mean','DVR mean','MT std','ETF std','DVR std'},'VariableNames',{'All','S1','S2','S3','S4'});
        tableTrendPara.(names_para{i}) = aux;
    end
    
end
