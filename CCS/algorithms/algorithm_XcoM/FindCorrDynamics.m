function topValues = FindCorrDynamics(tableCorrs,idxPara)
    topValues = struct();
    names_segs = fieldnames(tableCorrs);
    names_sts = fieldnames(tableCorrs.all);
    names_paras = {'jp hip','jp knee','jp ankle', 'jp lumbar extension', ...
        'jw hip','jw knee','jw ankle', 'jw lumbar extension'};

    for idxSeg = 1:length(names_segs)
        dataSeg_mean = [];
        dataSeg_std = [];
        for idxSTS = 1:length(names_sts)
            tableCorr = tableCorrs.(names_segs{idxSeg}).(names_sts{idxSTS});
            data_mean = tableCorr.mean{idxPara,[49,52:54,57,60:62]};
            data_std = tableCorr.std{idxPara,[49,52:54,57,60:62]};
            
            dataSeg_mean = [dataSeg_mean,data_mean(:)];
            dataSeg_std = [dataSeg_std,data_std(:)];
        end

        [~,indices] = sort(abs(dataSeg_mean(:,1)),'descend');
        indices = 1:size(dataSeg_mean,1);

        dataSeg_mean = array2table(dataSeg_mean(indices,:),'RowNames', names_paras(indices),'VariableNames',names_sts);
        dataSeg_std = array2table(dataSeg_std(indices,:),'RowNames', names_paras(indices),'VariableNames',names_sts);
        topValues.(names_segs{idxSeg}).mean = dataSeg_mean;
        topValues.(names_segs{idxSeg}).std = dataSeg_std;
    end
end