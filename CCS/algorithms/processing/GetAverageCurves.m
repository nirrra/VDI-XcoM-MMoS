function [mean_curves, std_curves, time_curves, time_stages] = GetAverageCurves(cellSegs, idxs_sts, str_para)

mean_curves = [];
std_curves = [];
time_curves = [];
time_stages = [];

for idxSTS = 1:4
    mean_curve = [];
    std_curve = [];
    time_curve = [0];
    time_stage = [0];
    for idxStage = 1:4
        [datas_interp, time_mean] = GetAverageCurve_Segment(cellSegs(idxs_sts{idxSTS}),str_para,idxStage);
        mean_data = mean(datas_interp);
        std_data = std(datas_interp);

        mean_curve = [mean_curve,mean_data];
        std_curve = [std_curve,std_data];
        time_curve = [time_curve,time_curve(end)+(0:time_mean/(length(mean_data)-1):time_mean)];

        time_stage(end+1) = time_stage(end)+time_mean;
    end
    time_curve(1) = [];

    mean_curves = [mean_curves; mean_curve];
    std_curves = [std_curves; std_curve];
    time_curves = [time_curves; time_curve];
    time_stages = [time_stages; time_stage];
end

end

function [datas_interp, time_mean] = GetAverageCurve_Segment(cellSegs,str_para,idxStage)
time_interp = 0:0.01:1;

datas_interp = zeros(0,length(time_interp));
time_mean = [];

for idxSeg = 1:length(cellSegs)
    seg = cellSegs{idxSeg};
    if idxStage == 1
        period = 1:seg.idx.idx_p2;
    elseif idxStage == 2
        period = seg.idx.idx_p2:seg.idx.idx_p3;
    elseif idxStage == 3
        period = seg.idx.idx_p3:seg.idx.idx_p4;
    elseif idxStage == 4
        period = seg.idx.idx_p4:seg.idx.idx_end;

    end

    if length(1:seg.idx.idx_p2)<2 ...
            || length(seg.idx.idx_p2:seg.idx.idx_p3)<2 ...
            || length(seg.idx.idx_p3:seg.idx.idx_p4)<2 ...
            || length(seg.idx.idx_p4:seg.idx.idx_end)<2
        continue;
    end

    time = seg.time(period);

    time_mean(end+1) = range(time);
    
    time = (time-time(1))./range(time);
%     data = seg.xcom.y(period);
    eval(['data = ',str_para,';']);
    data = data(period);
    data_interp = interp1(time,data,time_interp);

    datas_interp(size(datas_interp,1)+1,:) = data_interp;
end

time_mean = mean(time_mean);
end