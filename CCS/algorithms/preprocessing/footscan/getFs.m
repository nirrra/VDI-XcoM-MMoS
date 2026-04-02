%% FUNC getFs：获取采样频率
function [fs] = getFs(fileName)
    fid = fopen(fileName);
    if fgetl(fid) == -1
        fs = -1; 
        return;
    end

    fid = fopen(fileName);
    line = fgetl(fid);
    t1 = str2num(line(12:13))*3600+str2num(line(15:16))*60+str2num(line(18:19))+str2num(line(21:23))/1000;
    cnt = 1;
    while ~feof(fid)
        line = fgetl(fid);
        cnt = cnt+1;
    end
    t2 = str2num(line(12:13))*3600+str2num(line(15:16))*60+str2num(line(18:19))+str2num(line(21:23))/1000;
    fs = 1/((t2-t1)/cnt);
    fs = roundn(fs,-2);
end