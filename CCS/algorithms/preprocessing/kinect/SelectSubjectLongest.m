%% 寻找时间最长的Kinect捕获目标
function [stream,stream2] = SelectSubjectLongest(streamAll)
% 寻找捕获时间最长的目标
aux = 1; 
for i = 1:length(streamAll) 
    if length(streamAll{1,i}.wtime)>length(streamAll{1,aux}.wtime)
        aux = i;
    end
end
stream = streamAll{1,aux}; 

stream2 = stream;
if length(streamAll)>1
    group = setdiff(1:length(streamAll),aux);
    aux = group(1);
    for i = 1:length(group)
        if length(streamAll{1,group(i)}.wtime)>length(streamAll{1,aux}.wtime)
            aux = group(i);
        end
    end
    stream2 = streamAll{1,aux};
end

end