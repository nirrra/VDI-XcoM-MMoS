%% 获取times数组中每个时间在time中的idx
function [idxTime] = GetIdxTime(time,times)
    idxTime = zeros(length(times),1);
    for i = 1:length(times)
        [~,idxTime(i)] = min(abs(time-times(i)));
    end
end