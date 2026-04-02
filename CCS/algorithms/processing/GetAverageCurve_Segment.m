function [datas_interp, time_mean, idxSegs] = GetAverageCurve_Segment(cellSegs,str_para,idxStage)
time_interp = 0:0.01:1;

datas_interp = zeros(0,length(time_interp));
time_mean = [];
idxSegs = [];

for idxSeg = 1:length(cellSegs)
    seg = cellSegs{idxSeg};
    if idxStage == 1
        period = 1:seg.idx.idx_stage12;
    elseif idxStage == 2
        period = seg.idx.idx_stage12:seg.idx.idx_stage23;
    elseif idxStage == 3
        period = seg.idx.idx_stage23:seg.idx.idx_stage34;
    elseif idxStage == 4
        period = seg.idx.idx_stage34:seg.idx.idx_end;
    end

    if length(1:seg.idx.idx_stage12)<2 ...
            || length(seg.idx.idx_stage12:seg.idx.idx_stage23)<2 ...
            || length(seg.idx.idx_stage23:seg.idx.idx_stage34)<2 ...
            || length(seg.idx.idx_stage34:seg.idx.idx_end)<2
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

    idxSegs = [idxSegs;idxSeg];
end

time_mean = mean(time_mean);
end


