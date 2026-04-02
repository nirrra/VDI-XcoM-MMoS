function [dot_hx, dot_hy, dot_hz] = CalDotHCoM3D(mass, sex, kinectstream, segments_com_position, r_all_segments, segments_W_L, segments_Alfa_L, segments_com_velocity, segments_com_acceleration, freq)
% CalDotHCoM3D 计算绕全身CoM的角动量率三维分量（基于Kinect结果）
%
% 输入参数（前7个参数对齐 Segments_Moment_WithPelvis）：
%   mass                  - 体重(kg)
%   sex                   - 性别('M'/'F')
%   kinectstream          - Kinect关节点结构体
%   segments_com_position - 各体段CoM位置结构体
%   r_all_segments        - 各体段旋转矩阵（体段坐标系到全局坐标系）
%   segments_W_L          - 各体段局部角速度反对称矩阵
%   segments_Alfa_L       - 各体段局部角加速度反对称矩阵
%   segments_com_velocity - 各体段CoM速度结构体（可为空）
%   segments_com_acceleration - 各体段CoM加速度结构体（可为空）
%   freq                  - 采样频率(Hz)
%
% 输出：
%   dot_hx, dot_hy, dot_hz - 绕全身CoM的角动量率分量

if nargin < 10 || isempty(freq)
    if isfield(kinectstream, 'wtime')
        dt = mean(diff(kinectstream.wtime(:)));
        freq = 1 / max(dt, eps);
    else
        freq = 30;
    end
end

if nargin < 4 || isempty(segments_com_position)
    [segments_com_position, segments_com_velocity, segments_com_acceleration] = ...
        Segments_Velocity_Acceleration_WithPelvis(kinectstream, sex, freq);
end

if nargin < 8
    segments_com_velocity = [];
end

if nargin < 9 || isempty(segments_com_acceleration)
    if ~isempty(segments_com_velocity)
        segment_names_vel = {'HeadNeck','Trunk','Pelvis','Upperarm_Left','Upperarm_Right','Forearm_Left','Forearm_Right', ...
            'Hand_Left','Hand_Right','Thigh_Left','Thigh_Right','Shank_Left','Shank_Right','Foot_Left','Foot_Right','human'};
        segments_com_acceleration = struct();
        for idx_seg = 1:numel(segment_names_vel)
            seg_name = segment_names_vel{idx_seg};
            segments_com_acceleration.(seg_name).x = gradient(segments_com_velocity.(seg_name).x) .* freq;
            segments_com_acceleration.(seg_name).y = gradient(segments_com_velocity.(seg_name).y) .* freq;
            segments_com_acceleration.(seg_name).z = gradient(segments_com_velocity.(seg_name).z) .* freq;
        end
    else
        [~, ~, segments_com_acceleration] = Segments_Velocity_Acceleration_WithPelvis(kinectstream, sex, freq);
    end
end

if nargin < 5 || isempty(r_all_segments) || nargin < 6 || isempty(segments_W_L) || nargin < 7 || isempty(segments_Alfa_L)
    [r_all_segments, ~] = Segments_Rotation_WithPelvis(kinectstream);
    [segments_W_G, segments_W_L, ~, ~] = Segments_Rotation_Angular_velocity(r_all_segments, freq);
    [~, segments_Alfa_L, ~, ~] = Segments_Rotation_Angular_Acceleration(segments_W_G, segments_W_L, freq);
end

if sex == 'M'
    M.HeadNeck = 0.0694;
    M.Trunk = 0.3229;
    M.Pelvis = 0.1117;
    M.Upperarm = 0.0271;
    M.Forearm = 0.0162;
    M.Hand = 0.0061;
    M.Thigh = 0.1416;
    M.Shank = 0.0433;
    M.Foot = 0.0137;
else
    M.HeadNeck = 0.0669;
    M.Trunk = 0.301;
    M.Pelvis = 0.1247;
    M.Upperarm = 0.0255;
    M.Forearm = 0.0138;
    M.Hand = 0.0056;
    M.Thigh = 0.1478;
    M.Shank = 0.0481;
    M.Foot = 0.0129;
end

Segments_Length = Get_Segments_Length_Struct(kinectstream);
Moment_of_Inertia = build_moi(Segments_Length, sex);

segment_map = {
    'HeadNeck', 'HeadNeck', M.HeadNeck
    'Trunk', 'Trunk', M.Trunk
    'Pelvis', 'Pelvis', M.Pelvis
    'Upperarm_Left', 'Upperarm', M.Upperarm
    'Upperarm_Right', 'Upperarm', M.Upperarm
    'Forearm_Left', 'Forearm', M.Forearm
    'Forearm_Right', 'Forearm', M.Forearm
    'Hand_Left', 'Hand', M.Hand
    'Hand_Right', 'Hand', M.Hand
    'Thigh_Left', 'Thigh', M.Thigh
    'Thigh_Right', 'Thigh', M.Thigh
    'Shank_Left', 'Shank', M.Shank
    'Shank_Right', 'Shank', M.Shank
    'Foot_Left', 'Foot', M.Foot
    'Foot_Right', 'Foot', M.Foot
    };

num_frames = numel(segments_com_position.human.x);
dot_h = zeros(num_frames, 3);
pos_human = xyz2mat(segments_com_position.human);
acc_human = xyz2mat(segments_com_acceleration.human);

for idx_seg = 1:size(segment_map, 1)
    seg_name = segment_map{idx_seg, 1};
    moi_name = segment_map{idx_seg, 2};
    mass_ratio = segment_map{idx_seg, 3};

    seg_mass = mass * mass_ratio;
    I_local_mass = seg_mass * Moment_of_Inertia.(moi_name);

    pos_seg = xyz2mat(segments_com_position.(seg_name));
    acc_seg = xyz2mat(segments_com_acceleration.(seg_name));
    r_seg = pos_seg - pos_human;
    a_rel = acc_seg - acc_human;
    dot_h_orb = seg_mass .* cross(r_seg, a_rel, 2);

    dot_h_spin = zeros(num_frames, 3);
    for idx_frame = 1:num_frames
        omega_local_skew = segments_W_L.(seg_name){idx_frame};
        alpha_local_skew = segments_Alfa_L.(seg_name){idx_frame};
        omega_local = [omega_local_skew(3,2); omega_local_skew(1,3); omega_local_skew(2,1)];
        alpha_local = [alpha_local_skew(3,2); alpha_local_skew(1,3); alpha_local_skew(2,1)];
        dot_h_local = I_local_mass * alpha_local + omega_local_skew * (I_local_mass * omega_local);
        dot_h_global = r_all_segments.(seg_name){idx_frame} * dot_h_local;
        dot_h_spin(idx_frame, :) = dot_h_global.';
    end

    dot_h = dot_h + dot_h_orb + dot_h_spin;
end

dot_hx = dot_h(:, 1);
dot_hy = dot_h(:, 2);
dot_hz = dot_h(:, 3);
end

function mat_xyz = xyz2mat(s)
mat_xyz = [s.x(:), s.y(:), s.z(:)];
end

function Moment_of_Inertia = build_moi(Segments_Length, sex)
Moment_of_Inertia.HeadNeck = zeros(3,3);
Moment_of_Inertia.Trunk = zeros(3,3);
Moment_of_Inertia.Pelvis = zeros(3,3);
Moment_of_Inertia.Upperarm = zeros(3,3);
Moment_of_Inertia.Forearm = zeros(3,3);
Moment_of_Inertia.Hand = zeros(3,3);
Moment_of_Inertia.Thigh = zeros(3,3);
Moment_of_Inertia.Shank = zeros(3,3);
Moment_of_Inertia.Foot = zeros(3,3);

if sex == 'M'
    Moment_of_Inertia.HeadNeck(1,1) = (Segments_Length.HeadNeck)^2 * 0.376 * 0.376;
    Moment_of_Inertia.Trunk(1,1) = (Segments_Length.Trunk)^2 * 0.349 * 0.349;
    Moment_of_Inertia.Pelvis(1,1) = (Segments_Length.Trunk)^2 * 0.551 * 0.551;
    Moment_of_Inertia.Upperarm(1,1) = (Segments_Length.Upperarm)^2 * 0.269 * 0.269;
    Moment_of_Inertia.Forearm(1,1) = (Segments_Length.Forearm)^2 * 0.265 * 0.265;
    Moment_of_Inertia.Hand(1,1) = (Segments_Length.Hand)^2 * 0.513 * 0.513;
    Moment_of_Inertia.Thigh(1,1) = (Segments_Length.Thigh)^2 * 0.329 * 0.329;
    Moment_of_Inertia.Shank(1,1) = (Segments_Length.Shank)^2 * 0.249 * 0.249;
    Moment_of_Inertia.Foot(1,1) = (Segments_Length.Foot)^2 * 0.245 * 0.245;

    Moment_of_Inertia.HeadNeck(2,2) = (Segments_Length.HeadNeck)^2 * 0.362 * 0.362;
    Moment_of_Inertia.Trunk(2,2) = (Segments_Length.Trunk)^2 * 0.406 * 0.406;
    Moment_of_Inertia.Pelvis(2,2) = (Segments_Length.Trunk)^2 * 0.615 * 0.615;
    Moment_of_Inertia.Upperarm(2,2) = (Segments_Length.Upperarm)^2 * 0.285 * 0.285;
    Moment_of_Inertia.Forearm(2,2) = (Segments_Length.Forearm)^2 * 0.276 * 0.276;
    Moment_of_Inertia.Hand(2,2) = (Segments_Length.Hand)^2 * 0.628 * 0.628;
    Moment_of_Inertia.Thigh(2,2) = (Segments_Length.Thigh)^2 * 0.329 * 0.329;
    Moment_of_Inertia.Shank(2,2) = (Segments_Length.Shank)^2 * 0.255 * 0.255;

    Moment_of_Inertia.Trunk(3,3) = (Segments_Length.Trunk)^2 * 0.276 * 0.276;
    Moment_of_Inertia.Pelvis(3,3) = (Segments_Length.Pelvis)^2 * 0.587 * 0.587;
    Moment_of_Inertia.Foot(3,3) = (Segments_Length.Foot)^2 * 0.257 * 0.257;
else
    Moment_of_Inertia.HeadNeck(1,1) = (Segments_Length.HeadNeck)^2 * 0.359 * 0.359;
    Moment_of_Inertia.Trunk(1,1) = (Segments_Length.Trunk)^2 * 0.361 * 0.361;
    Moment_of_Inertia.Pelvis(1,1) = (Segments_Length.Trunk)^2 * 0.402 * 0.402;
    Moment_of_Inertia.Upperarm(1,1) = (Segments_Length.Upperarm)^2 * 0.260 * 0.260;
    Moment_of_Inertia.Forearm(1,1) = (Segments_Length.Forearm)^2 * 0.257 * 0.257;
    Moment_of_Inertia.Hand(1,1) = (Segments_Length.Hand)^2 * 0.454 * 0.454;
    Moment_of_Inertia.Thigh(1,1) = (Segments_Length.Thigh)^2 * 0.364 * 0.364;
    Moment_of_Inertia.Shank(1,1) = (Segments_Length.Shank)^2 * 0.267 * 0.267;
    Moment_of_Inertia.Foot(1,1) = (Segments_Length.Foot)^2 * 0.279 * 0.279;

    Moment_of_Inertia.HeadNeck(2,2) = (Segments_Length.HeadNeck)^2 * 0.330 * 0.330;
    Moment_of_Inertia.Trunk(2,2) = (Segments_Length.Trunk)^2 * 0.409 * 0.409;
    Moment_of_Inertia.Pelvis(2,2) = (Segments_Length.Trunk)^2 * 0.433 * 0.433;
    Moment_of_Inertia.Upperarm(2,2) = (Segments_Length.Upperarm)^2 * 0.278 * 0.278;
    Moment_of_Inertia.Forearm(2,2) = (Segments_Length.Forearm)^2 * 0.261 * 0.261;
    Moment_of_Inertia.Hand(2,2) = (Segments_Length.Hand)^2 * 0.531 * 0.531;
    Moment_of_Inertia.Thigh(2,2) = (Segments_Length.Thigh)^2 * 0.369 * 0.369;
    Moment_of_Inertia.Shank(2,2) = (Segments_Length.Shank)^2 * 0.271 * 0.271;

    Moment_of_Inertia.Trunk(3,3) = (Segments_Length.Trunk)^2 * 0.271 * 0.271;
    Moment_of_Inertia.Pelvis(3,3) = (Segments_Length.Pelvis)^2 * 0.444 * 0.444;
    Moment_of_Inertia.Foot(3,3) = (Segments_Length.Foot)^2 * 0.299 * 0.299;
end
end
