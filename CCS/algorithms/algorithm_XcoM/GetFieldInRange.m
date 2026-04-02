function [nx] = GetFieldInRange(x,ranges)
nx = x;
names = fieldnames(x);
for i = 1:length(names)
    name = names{i};
    nx.(name) = x.(name)(ranges);
end
