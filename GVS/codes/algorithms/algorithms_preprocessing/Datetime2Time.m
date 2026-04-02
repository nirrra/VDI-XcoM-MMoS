%% FUNC Datetime2Time：转换datetime数组为数值数组，从0开始，单位秒
function timeArray = Datetime2Time(datetimeArray)
    dataLength = size(datetimeArray,1);
    timeArray = zeros(dataLength,1);
    time0 = datetimeArray(1).Hour*3600+datetimeArray(1).Minute*60+datetimeArray(1).Second;
    for i = 2:dataLength
        timeArray(i) = datetimeArray(i).Hour*3600+datetimeArray(i).Minute*60+datetimeArray(i).Second - time0;
    end
end