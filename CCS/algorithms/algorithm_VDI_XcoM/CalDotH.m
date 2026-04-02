function [dot_hx, dot_hy, dot_hz] = CalDotH(analysisGround)
    % CalDotH 计算质心角动量率 \dot{h} (三维分量)
    %
    % 输入:
    %   analysisGround: 包含运动学数据的结构体 (OpenSim BodyKinematics输出)
    %
    % 输出:
    %   dot_hx: 人体坐标系 X分量 (Right)
    %   dot_hy: 人体坐标系 Y分量 (Forward)
    %   dot_hz: 人体坐标系 Z分量 (Up)
    
    %% 0. 初始化（OpenSim/analysisGround 统一使用：X向前，Y向上，Z向右）
    segments.names_segment = {'pelvis','femur_l','femur_r','tibia_l','tibia_r','talus_l','talus_r','calcn_l','calcn_r','toes_l','toes_r','torso','torso'};
    segments.mass_segment = [9.035944476077825
                    10.494173838321878
                    10.494173838321878
                    2.4123062893179696
                    2.4123062893179696
                    0.08204888759957253
                    0.08204888759957253
                    1.0256110949946566
                    1.0256110949946566
                    0.17771789054067408
                    0.17771789054067408
                    30.580339522372704];
    segments.inertia_segment = {
        [0.0669813 0.0567517 0.0377259 0 0 0]
        [0.165899 0.043488 0.174943 0 0 0]
        [0.165899 0.043488 0.174943 0 0 0]
        [0.0249505 0.00252475 0.025297 0 0 0]
        [0.0249505 0.00252475 0.025297 0 0 0]
        [0.000728647 0.000728647 0.000728647 0 0 0]
        [0.000728647 0.000728647 0.000728647 0 0 0]
        [0.00102011 0.00284172 0.00298745 0 0 0]
        [0.00102011 0.00284172 0.00298745 0 0 0]
        [7.28647e-05 0.000145729 7.28647e-05 0 0 0]
        [7.28647e-05 0.000145729 7.28647e-05 0 0 0]
        [1.23773 0.634186 1.20155 0 0 0]
    };
    segments.mass_center_segment = {
        [-0.0651524 0 0]
        [0 -0.178148 0]
        [0 -0.178148 0]
        [0 -0.162852 0]
        [0 -0.162852 0]
        [0 0 0]
        [0 0 0]
        [0.0942372 0.0282711 0]
        [0.0942372 0.0282711 0]
        [0.0326061 0.00565423 -0.0164915]
        [0.0326061 0.00565423 -0.0164915]
        [-0.0290828 0.310217 0]
    };

    %% 1. 参数解析与准备
    names = segments.names_segment;
    masses = segments.mass_segment;
    inertias = segments.inertia_segment;
    % coms_local = segments.mass_center_segment; % 暂未使用，因采用近似处理
    
    % 截取有效段数 (处理 names 可能多出的元素)
    num_segments = length(masses);
    
    % 获取时间帧数
    % table 使用 height
    if ismember('pos_center_of_mass_X', analysisGround.Properties.VariableNames)
        num_frames = height(analysisGround);
    else
        error('analysisGround 中缺少 pos_center_of_mass_X 数据');
    end
    
    % 全身 CoM 位置与速度 (analysisGround 坐标系)
    % X: Forward, Y: Up, Z: Right
    
    C_whole = [analysisGround.pos_center_of_mass_X, ...
               analysisGround.pos_center_of_mass_Y, ...
               analysisGround.pos_center_of_mass_Z]; % [X, Y, Z]
               
    V_whole = [analysisGround.vel_center_of_mass_X, ...
               analysisGround.vel_center_of_mass_Y, ...
               analysisGround.vel_center_of_mass_Z];
    
    hx_all = zeros(num_frames, 1);
    hy_all = zeros(num_frames, 1);
    hz_all = zeros(num_frames, 1);
    
    %% 2. 循环计算每一帧的 h (三维分量)
    % h = sum [ I * w + m * (r x v) ]
    
    % 预先检查字段是否存在，以决定是否进行单位转换 (Deg -> Rad)
    % OpenSim 输出通常为角度(deg)和角速度(deg/s)
    toRad = pi/180;
    
    for i = 1:num_segments
        seg_name = names{i};
        
        % 尝试构建字段名
        % 假设字段格式为 pos_segname_X
        % 注意：OpenSim 输出的名称可能与 segments 中的名称大小写不一致，这里假设一致
        
        try
            p_x = analysisGround.(['pos_', seg_name, '_X']);
            p_y = analysisGround.(['pos_', seg_name, '_Y']);
            p_z = analysisGround.(['pos_', seg_name, '_Z']);
            
            v_x = analysisGround.(['vel_', seg_name, '_X']);
            v_y = analysisGround.(['vel_', seg_name, '_Y']);
            v_z = analysisGround.(['vel_', seg_name, '_Z']);
            
            % 角速度
            w_x = analysisGround.(['vel_', seg_name, '_Ox']);
            w_y = analysisGround.(['vel_', seg_name, '_Oy']);
            w_z = analysisGround.(['vel_', seg_name, '_Oz']);
            
            % 尝试获取姿态以转换局部 CoM 和 惯量
            % 如果没有姿态数据，只能近似认为局部坐标系与全局平行 (对于 STS 这种大幅度运动误差较大，但无数据也没办法)
            % 或者假设 pos_segname 已经是 CoM 位置 (OpenSim BodyKinematics 输出 body origin)
            
            % 默认使用 body origin 作为 segment CoM 近似
            % 理想情况应结合欧拉角/旋转矩阵将 local CoM 转换到 global
            % 但目前简化处理，忽略 local offset (即假设 Body Origin = Body CoM)
            c_x = p_x;
            c_y = p_y;
            c_z = p_z;
            
        catch
            warning(['缺少段 ', seg_name, ' 的运动学数据，跳过该段。']);
            continue;
        end
        
        m = masses(i);
        
        % 惯量处理
        % segments.inertia_segment{i} 是 [Ixx Iyy Izz Ixy Ixz Iyz]
        % 假设局部坐标系:
        % X: 沿骨骼轴
        % Y: 前后
        % Z: 内外(横向)
        % 
        % analysisGround 与段参数坐标系一致:
        % X: Forward, Y: Up, Z: Right
        
        I_local = inertias{i};
        I_xx = I_local(1);
        I_yy = I_local(2);
        I_zz = I_local(3); 
        
        % 1. 自转项 (Spin): I * w
        % 简化假设：局部轴与全局轴方向大致对齐 (忽略姿态旋转)
        % h_spin_x = I_xx * w_x
        % 由于坐标系已统一，无需交换惯量轴
        
        h_spin_x = I_xx * (w_x * toRad);
        h_spin_y = I_yy * (w_y * toRad);
        h_spin_z = I_zz * (w_z * toRad);
        
        % 2. 公转项 (Orbital): m * r x v
        % r = c_seg - C_whole = [rx, ry, rz]
        % v = v_seg - V_whole = [vx, vy, vz]
        
        % 当前坐标系分量:
        % X (Forward), Y (Up), Z (Right)
        
        rx = c_x - C_whole(:,1); 
        ry = c_y - C_whole(:,2);
        rz = c_z - C_whole(:,3); 
        
        vx = v_x - V_whole(:,1);
        vy = v_y - V_whole(:,2);
        vz = v_z - V_whole(:,3);
        
        % Cross product:
        % (r x v)_x = ry*vz - rz*vy
        % (r x v)_y = rz*vx - rx*vz
        % (r x v)_z = rx*vy - ry*vx
        
        h_orb_x = m * (ry .* vz - rz .* vy);
        h_orb_y = m * (rz .* vx - rx .* vz);
        h_orb_z = m * (rx .* vy - ry .* vx);
        
        % 累加
        hx_all = hx_all + h_spin_x + h_orb_x;
        hy_all = hy_all + h_spin_y + h_orb_y;
        hz_all = hz_all + h_spin_z + h_orb_z;
    end
    
    %% 3. 平滑与求导
    % MoS_CMP.md 建议先平滑再求导
    
    % 使用简单的低通滤波或移动平均
    % 这里使用 smoothdata (rloess 或 gaussian)
    fs = 100; % 假设 Vicon 采样率 100Hz (需确认，若未知则只能用点数)
    % 尝试从 analysisGround 推断采样率 (通过 time 字段)
    if ismember('time', analysisGround.Properties.VariableNames)
        dt = mean(diff(analysisGround.time));
        if dt > 0
            fs = 1/dt;
        end
    end
    
    % 平滑 h
    % 窗口大小可调，这里设为 0.1s 左右
    window_size = round(0.1 * fs); 
    if window_size < 3, window_size = 3; end
    
    hx_smooth = smoothdata(hx_all, 'gaussian', window_size);
    hy_smooth = smoothdata(hy_all, 'gaussian', window_size);
    hz_smooth = smoothdata(hz_all, 'gaussian', window_size);
    
    % 求导 \dot{h}
    % 使用中心差分
    dot_hx_global = gradient(hx_smooth) * fs;
    dot_hy_global = gradient(hy_smooth) * fs;
    dot_hz_global = gradient(hz_smooth) * fs;
    
    % 或者再次平滑导数
    dot_hx_global = smoothdata(dot_hx_global, 'gaussian', window_size);
    dot_hy_global = smoothdata(dot_hy_global, 'gaussian', window_size);
    dot_hz_global = smoothdata(dot_hz_global, 'gaussian', window_size);

    % 转换到人体坐标系:
    % 人体 X(右) = 全局 Z(右)
    % 人体 Y(前) = 全局 X(前)
    % 人体 Z(上) = 全局 Y(上)
    dot_hx = dot_hz_global;
    dot_hy = dot_hx_global;
    dot_hz = dot_hy_global;

end
