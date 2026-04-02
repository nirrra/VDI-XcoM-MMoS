% times [a,b,a,b]，a为一段的起始时间，b为一段的结束时间
function [segs] = GetSegsTime(time,times)
    segs = [];
    for i = 1:2:length(times)
        idx = GetIdxTime(time,[times(i),times(i+1)]);
        segs = [segs,idx(1):idx(2)];
    end
end