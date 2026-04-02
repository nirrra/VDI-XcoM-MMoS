function dot_h_z = CalDotHzCoM(posCOMSegments, vCOMSegments, com, vcom, gender, weight, fs, streamInter, segments_W_G_xyz, flag_trans_only)
% CalDotHzCoM
% 计算关于全身CoM的角动量率 z 分量（dot{h_z}）
%
% 公式（见 MoS_CMP.md 5.6~5.7）：
%   h(t) = sum_s [ I_s * omega_s(t) + m_s * (c_s(t) - c(t)) x (v_s(t) - v(t)) ]
%   h_z(t) = h(t) · z_hat
%   dot{h_z}(t) = d/dt h_z(t)
%
% 变量对应关系：
%   c_s(t)      -> posCOMSegments.(seg).x/.y/.z
%   v_s(t)      -> vCOMSegments.(seg).x/.y/.z
%   c(t)        -> com.x/.y/.z
%   v(t)        -> vcom.x/.y/.z
%   m_s         -> weight * M.(baseSeg)
%   omega_s(t)  -> segments_W_G_xyz.(seg).x/.y/.z （体段全局坐标系角速度）
%   I_s         -> 由段长与惯性系数估计的转动惯量（与 CalRotaryInertia 一致的数据来源）
%
% 说明：
% - flag_trans_only 为 true 时，仅使用平动项（第二项）近似，忽略转动项。
% - 仅输出 dot{h_z}，用于 MoS_CMP 的校正项。

if nargin < 10
    flag_trans_only = false;
end

% 体段质量比例（与 Segments_Velocity_Acceleration / CalRotaryInertia 一致）
[M, hasPelvis] = GetSegmentMassRatio(gender, posCOMSegments);

names = fieldnames(posCOMSegments);
names = names(~strcmpi(names,'human'));

% 初始化
n = length(com.x);
h_vec.x = zeros(n,1);
h_vec.y = zeros(n,1);
h_vec.z = zeros(n,1);

% 是否计算旋转项
use_rot = ~flag_trans_only;
if use_rot
    segLen = Get_Segments_Length_Struct(streamInter);
    Icoeff = GetSegmentInertiaCoeff(gender, hasPelvis);
end

for i = 1:length(names)
    segName = names{i};
    baseSeg = GetBaseSegmentName(segName);
    if ~isfield(M, baseSeg)
        continue;
    end

    % 体段质量
    m_s = weight * M.(baseSeg);

    % 相对质心位置与速度
    rx = posCOMSegments.(segName).x - com.x;
    ry = posCOMSegments.(segName).y - com.y;
    rz = posCOMSegments.(segName).z - com.z;

    vx = vCOMSegments.(segName).x - vcom.x;
    vy = vCOMSegments.(segName).y - vcom.y;
    vz = vCOMSegments.(segName).z - vcom.z;

    % 平动角动量项：m_s * (r x v)
    h_vec.x = h_vec.x + m_s .* (ry .* vz - rz .* vy);
    h_vec.y = h_vec.y + m_s .* (rz .* vx - rx .* vz);
    h_vec.z = h_vec.z + m_s .* (rx .* vy - ry .* vx);

    % 旋转角动量项：I_s * omega_s
    if use_rot && isfield(segments_W_G_xyz, segName) && isfield(Icoeff, baseSeg)
        if isfield(segLen, baseSeg)
            % 使用全局角速度与惯量估计旋转角动量
            Ixx = m_s .* (segLen.(baseSeg) .^ 2) .* (Icoeff.(baseSeg).x .^ 2);
            Iyy = m_s .* (segLen.(baseSeg) .^ 2) .* (Icoeff.(baseSeg).y .^ 2);
            Izz = m_s .* (segLen.(baseSeg) .^ 2) .* (Icoeff.(baseSeg).z .^ 2);
            h_vec.x = h_vec.x + Ixx .* segments_W_G_xyz.(segName).x;
            h_vec.y = h_vec.y + Iyy .* segments_W_G_xyz.(segName).y;
            h_vec.z = h_vec.z + Izz .* segments_W_G_xyz.(segName).z;
        end
    end
end

% 取 z 分量，并计算时间导数
dot_h_z = FiniteDifference(h_vec.z, fs);

end

function baseSeg = GetBaseSegmentName(segName)
% Upperarm_Left -> Upperarm
idx = strfind(segName,'_');
if isempty(idx)
    baseSeg = segName;
else
    baseSeg = segName(1:idx(1)-1);
end
end

function [M, hasPelvis] = GetSegmentMassRatio(gender, posCOMSegments)
hasPelvis = isfield(posCOMSegments,'Pelvis');
if gender == 'M'
    M.HeadNeck = 0.0694;
    if hasPelvis
        M.Trunk = 0.3229;
        M.Pelvis = 0.1117;
    else
        M.Trunk = 0.4346;
    end
    M.Upperarm = 0.0271;
    M.Forearm = 0.0162;
    M.Hand = 0.0061;
    M.Thigh = 0.1416;
    M.Shank = 0.0433;
    M.Foot = 0.0137;
else
    M.HeadNeck = 0.0669; % 为了将体重凑到100%
    if hasPelvis
        M.Trunk = 0.301;
        M.Pelvis = 0.1247;
    else
        M.Trunk = 0.4257;
    end
    M.Upperarm = 0.0255;
    M.Forearm = 0.0138;
    M.Hand = 0.0056;
    M.Thigh = 0.1478;
    M.Shank = 0.0481;
    M.Foot = 0.0129;
end
end

function Icoeff = GetSegmentInertiaCoeff(gender, hasPelvis)
% 参考 Segments_Moment_WithPelvis 的转动惯量系数（各轴）
% 未给出/未启用的轴系数置为 0，避免引入不确定性
Icoeff = struct();
if gender == 'M'
    Icoeff.HeadNeck = struct('x',0.376,'y',0.362,'z',0.0);
    Icoeff.Trunk = struct('x',0.349,'y',0.406,'z',0.276);
    if hasPelvis
        Icoeff.Pelvis = struct('x',0.551,'y',0.615,'z',0.587);
    end
    Icoeff.Upperarm = struct('x',0.269,'y',0.285,'z',0.0);
    Icoeff.Forearm = struct('x',0.265,'y',0.276,'z',0.0);
    Icoeff.Hand = struct('x',0.513,'y',0.628,'z',0.0);
    Icoeff.Thigh = struct('x',0.329,'y',0.329,'z',0.0);
    Icoeff.Shank = struct('x',0.249,'y',0.255,'z',0.0);
    Icoeff.Foot = struct('x',0.245,'y',0.0,'z',0.257);
else
    Icoeff.HeadNeck = struct('x',0.359,'y',0.330,'z',0.0);
    Icoeff.Trunk = struct('x',0.361,'y',0.409,'z',0.271);
    if hasPelvis
        Icoeff.Pelvis = struct('x',0.402,'y',0.433,'z',0.444);
    end
    Icoeff.Upperarm = struct('x',0.260,'y',0.278,'z',0.0);
    Icoeff.Forearm = struct('x',0.257,'y',0.261,'z',0.0);
    Icoeff.Hand = struct('x',0.454,'y',0.531,'z',0.0);
    Icoeff.Thigh = struct('x',0.364,'y',0.369,'z',0.0);
    Icoeff.Shank = struct('x',0.267,'y',0.271,'z',0.0);
    Icoeff.Foot = struct('x',0.279,'y',0.0,'z',0.299);
end
end
