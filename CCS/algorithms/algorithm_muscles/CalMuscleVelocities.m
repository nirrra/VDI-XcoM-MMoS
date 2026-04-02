function [muscle_velocities] = CalMuscleVelocities(muscle_lengths,fs)
muscle_velocities = struct();
names = fieldnames(muscle_lengths);
for idx_name = 1:length(names)
    name = names{idx_name};
    if true % 中心有限差分法精度更高，但是有延迟
        vs = [0;0;(-muscle_lengths.(name)(5:end)+8*muscle_lengths.(name)(4:end-1)-8*muscle_lengths.(name)(2:end-3)+muscle_lengths.(name)(1:end-4))*fs/12;0;0];
        vs(1) = (muscle_lengths.(name)(2)-muscle_lengths.(name)(1))*fs;
        vs(2) = (muscle_lengths.(name)(3)-muscle_lengths.(name)(1))*2*fs;
        vs(end-1) = (muscle_lengths.(name)(end)-muscle_lengths.(name)(end-2))*2*fs;
        vs(end) = (muscle_lengths.(name)(end)-muscle_lengths.(name)(end-1))*fs;
    else % 普通方法，没有延迟
        vs = [(muscle_lengths.(name)(2)-muscle_lengths.(name)(1))*fsInter;(muscle_lengths.(name)(2:end)-muscle_lengths.(name)(1:end-1))*fsInter];
    end
    muscle_velocities.(name) = vs;
end