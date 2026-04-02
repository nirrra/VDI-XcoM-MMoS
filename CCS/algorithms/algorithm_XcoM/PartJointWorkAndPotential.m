%% 关节功与势能+动能关系验证

cellJW = cell(size(cellSegs));

for idxSeg = 1:length(cellSegs)
    seg = cellSegs{idxSeg};
    
    jw = struct();
    jw.time = seg.time;
    jw.left_hip_flexion = cumtrapz(seg.time_vicon,seg.jp.left_hip_flexion);
    jw.left_hip_adduction = cumtrapz(seg.time_vicon,seg.jp.left_hip_adduction);
    jw.left_hip_rotation = cumtrapz(seg.time_vicon,seg.jp.left_hip_rotation);
    jw.left_knee = cumtrapz(seg.time_vicon,seg.jp.left_knee);
    jw.left_ankle = cumtrapz(seg.time_vicon,seg.jp.left_ankle);
    jw.right_hip_flexion = cumtrapz(seg.time_vicon,seg.jp.right_hip_flexion);
    jw.right_hip_adduction = cumtrapz(seg.time_vicon,seg.jp.right_hip_adduction);
    jw.right_hip_rotation = cumtrapz(seg.time_vicon,seg.jp.right_hip_rotation);
    jw.right_knee = cumtrapz(seg.time_vicon,seg.jp.right_knee);
    jw.right_ankle = cumtrapz(seg.time_vicon,seg.jp.right_ankle);
    jw.lumbar_extension = cumtrapz(seg.time_vicon,seg.jp.lumbar_extension);
    jw.lumbar_bending = cumtrapz(seg.time_vicon,seg.jp.lumbar_bending);
    jw.lumbar_rotation = cumtrapz(seg.time_vicon,seg.jp.lumbar_rotation);
    
    jw.potential_energy = seg.info.weight*g.*(seg.com.z-seg.com.z(1));
    jw.kinetic_energy_x = 0.5*seg.info.weight.*(seg.com.vx).^2;
    jw.kinetic_energy_y = 0.5*seg.info.weight.*(seg.com.vy).^2;
    jw.kinetic_energy_z = 0.5*seg.info.weight.*(seg.com.vz).^2;
    jw.kinetic_energy = jw.kinetic_energy_x + jw.kinetic_energy_y + jw.kinetic_energy_z;
    jw.energy = jw.potential_energy + jw.kinetic_energy;

    names = fieldnames(jw);
    for i = 1:length(names)
        name = names{i};
        if length(jw.(name)) > length(jw.time)
            jw.(name) = interp1(seg.time_vicon,jw.(name),jw.time);
        end
    end

    cellJW{idxSeg} = jw;
end

idxSeg = 1;
jw = cellJW{idxSeg};
figure; 
subplot(4,1,1);
hold on;
p1 = plot(jw.time,jw.energy,'DisplayName','Energy');
p2 = plot(jw.time,jw.potential_energy,'DisplayName','Potential Energy');
p3 = plot(jw.time,jw.kinetic_energy,'DisplayName','Kinetic Energy');
p4 = plot(jw.time,jw.kinetic_energy_y,'DisplayName','Kinetic Energy Y');
p5 = plot(jw.time,jw.kinetic_energy_z,'DisplayName','Kinetic Energy Z');
hold off;
legend([p1,p2,p3,p4,p5]);

subplot(4,1,2);
hold on;
p1 = plot(jw.time,jw.left_hip_flexion,'DisplayName','Left Hip Flexion');
p2 = plot(jw.time,jw.right_hip_flexion,'DisplayName','Right Hip Flexion');
p3 = plot(jw.time,jw.left_hip_adduction,'DisplayName','Left Hip Adduction');
p4 = plot(jw.time,jw.right_hip_adduction,'DisplayName','Right Hip Adduction');
p5 = plot(jw.time,jw.left_hip_rotation,'DisplayName','Left Hip Rotation');
p6 = plot(jw.time,jw.right_hip_rotation,'DisplayName','Right Hip Rotation');
hold off;
legend([p1,p2,p3,p4,p5,p6]);

subplot(4,1,3);
hold on;
p1 = plot(jw.time,jw.left_knee,'DisplayName','Left Knee');
p2 = plot(jw.time,jw.right_knee,'DisplayName','Right Knee');
p3 = plot(jw.time,jw.left_ankle,'DisplayName','Left Ankle');
p4 = plot(jw.time,jw.right_ankle,'DisplayName','Right Ankle');
hold off;
legend([p1,p2,p3,p4]);

subplot(4,1,4);
hold on;
p1 = plot(jw.time,jw.lumbar_extension,'DisplayName','Lumbar Extension');
p2 = plot(jw.time,jw.lumbar_bending,'DisplayName','Lumbar Bending');
p3 = plot(jw.time,jw.lumbar_rotation,'DisplayName','Lumbar Rotation');
hold off;
legend([p1,p2,p3]);

