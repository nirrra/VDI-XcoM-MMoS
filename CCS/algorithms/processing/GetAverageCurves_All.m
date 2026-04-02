function [mean_curve, std_curve, time_curve, time_stage] = GetAverageCurves_All(cellSegs, str_para)

mean_curve = [];
std_curve = [];
time_curve = [0];
time_stage = [0];

for idxStage = 1:4
    [datas_interp, time_mean] = GetAverageCurve_Segment(cellSegs,str_para,idxStage);
    mean_data = mean(datas_interp);
    std_data = std(datas_interp);

    mean_curve = [mean_curve,mean_data];
    std_curve = [std_curve,std_data];
    time_curve = [time_curve,time_curve(end)+(0:time_mean/(length(mean_data)-1):time_mean)];

    time_stage(end+1) = time_stage(end)+time_mean;
end
time_curve(1) = [];

end

