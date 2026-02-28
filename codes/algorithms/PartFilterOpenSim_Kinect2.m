%% 滤波器
Fs = 100;
Fc = 6;
Wn = Fc / (Fs/2);
n = 4;
[b,a] = butter(n,Wn,'low');

funcFilter = @(data) filter(b,a,data);
%% 滤波
names = ik.Properties.VariableNames;
for i = 2:size(ik,2)
    ik.(names{i}) = funcFilter(ik.(names{i}));
end

names = id.Properties.VariableNames;
for i = 2:size(id,2)
    id.(names{i}) = funcFilter(id.(names{i}));
end

names = analysisGround.Properties.VariableNames;
for i = 1:size(analysisGround,2)
    if contains(names{i},'time')
        continue;
    end
    analysisGround.(names{i}) = funcFilter(analysisGround.(names{i}));
end

names = analysisParent.Properties.VariableNames;
for i = 1:size(analysisParent,2)
    if contains(names{i},'time')
        continue;
    end
    analysisParent.(names{i}) = funcFilter(analysisParent.(names{i}));
end