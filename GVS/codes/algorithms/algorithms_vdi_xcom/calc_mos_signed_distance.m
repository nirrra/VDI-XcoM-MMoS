function mos = calc_mos_signed_distance(com, bos, times)
% 计算MoS：sum为最短有符号距离，front/back/left/right为方向距离

    if isstruct(com) && isstruct(bos) && isstruct(times)
        n = length(times.union);
        mos = struct('sum',nan(n,1),'front',nan(n,1),'back',nan(n,1),...
            'left',nan(n,1),'right',nan(n,1));
        for idx_frame = 1:n
            idx_vicon = GetIdxTime(times.vicon,[times.union(idx_frame)]);
            px = com.x(idx_vicon);
            py = com.y(idx_vicon);
            bx = bos.x{idx_frame};
            by = bos.y{idx_frame};
            mos_frame = calc_mos_signed_distance([px, py], bx, by);
            mos.sum(idx_frame) = mos_frame.sum;
            mos.front(idx_frame) = mos_frame.front;
            mos.back(idx_frame) = mos_frame.back;
            mos.left(idx_frame) = mos_frame.left;
            mos.right(idx_frame) = mos_frame.right;
        end
        return;
    end

    mos = struct('sum',NaN,'front',NaN,'back',NaN,'left',NaN,'right',NaN);
    if isempty(bos) || isempty(times)
        return;
    end

    bx = bos(:);
    by = times(:);
    if numel(bx) < 3 || numel(by) < 3
        return;
    end

    % 确保多边形闭合
    if bx(1) ~= bx(end) || by(1) ~= by(end)
        bx(end+1) = bx(1);
        by(end+1) = by(1);
    end

    px = com(1);
    py = com(2);

    % 点到多边形边界最短距离
    min_dist = inf;
    for i = 1:(numel(bx)-1)
        d = point_to_segment_distance(px, py, bx(i), by(i), bx(i+1), by(i+1));
        if d < min_dist
            min_dist = d;
        end
    end

    % 在内部为正，外部为负
    inside = inpolygon(px, py, bx, by);
    if inside
        mos.sum = min_dist;
    else
        mos.sum = -min_dist;
    end

    mos.front = direction_distance(px, py, bx, by, 0, 1, inside);
    mos.back = direction_distance(px, py, bx, by, 0, -1, inside);
    mos.left = direction_distance(px, py, bx, by, -1, 0, inside);
    mos.right = direction_distance(px, py, bx, by, 1, 0, inside);
end

function d = point_to_segment_distance(px, py, x1, y1, x2, y2)
% 点到线段距离
    vx = x2 - x1;
    vy = y2 - y1;
    wx = px - x1;
    wy = py - y1;
    c1 = vx * wx + vy * wy;
    if c1 <= 0
        d = hypot(px - x1, py - y1);
        return;
    end
    c2 = vx * vx + vy * vy;
    if c2 <= c1
        d = hypot(px - x2, py - y2);
        return;
    end
    b = c1 / c2;
    bx = x1 + b * vx;
    by = y1 + b * vy;
    d = hypot(px - bx, py - by);
end

function dist = direction_distance(px, py, bx, by, dx, dy, inside)
% 沿指定方向到BoS边界的有符号距离（内为正，外为负）
    t_list = [];
    for i = 1:(numel(bx)-1)
        t = line_segment_intersection_t(px, py, dx, dy, bx(i), by(i), bx(i+1), by(i+1));
        if ~isnan(t)
            t_list(end+1,1) = t; %#ok<AGROW>
        end
    end
    if isempty(t_list)
        dist = NaN;
        return;
    end
    if inside
        t_pos = t_list(t_list >= 0);
        if isempty(t_pos)
            dist = NaN;
        else
            dist = min(t_pos);
        end
    else
        t_neg = t_list(t_list <= 0);
        if isempty(t_neg)
            dist = NaN;
        else
            dist = max(t_neg);
        end
    end
end

function t = line_segment_intersection_t(px, py, dx, dy, x1, y1, x2, y2)
% 计算直线 P + t*d 与线段 [A,B] 的交点参数t（线段内时返回t）
    sx = x2 - x1;
    sy = y2 - y1;
    detA = dx * (-sy) - dy * (-sx);
    if abs(detA) < 1e-12
        t = NaN;
        return;
    end
    rhsx = x1 - px;
    rhsy = y1 - py;
    t = (rhsx * (-sy) - rhsy * (-sx)) / detA;
    u = (dx * rhsy - dy * rhsx) / detA;
    if u < 0 || u > 1
        t = NaN;
    end
end
