function cellSegs = RecalculateBoSMMoSFromSegs(cellSegs, plantar_buttock_displacement_old, plantar_buttock_displacement_new, height_sit)
% Recalculate BoS/MMoS from existing segment results after changing the
% plantar-to-buttock displacement used in the buttock sensor transform.

    if nargin < 4
        error('RecalculateBoSMMoSFromSegs requires cellSegs, old displacement, new displacement, and height_sit.');
    end

    if isempty(cellSegs)
        return;
    end

    delta_buttock_y = plantar_buttock_displacement_old - plantar_buttock_displacement_new;
    rng_state = rng;
    cleanup_obj = onCleanup(@() rng(rng_state)); %#ok<NASGU>

    nSeg = numel(cellSegs);
    for idxSeg = 1:nSeg
        seg = cellSegs{idxSeg};
        if ~is_valid_seg_for_recalc(seg)
            cellSegs{idxSeg} = seg;
            if mod(idxSeg, 50) == 0 || idxSeg == nSeg
                disp(['RecalculateBoSMMoSFromSegs: ', num2str(idxSeg), ' / ', num2str(nSeg)]);
            end
            continue;
        end

        seg.recalc.plantar_buttock_displacement_old = plantar_buttock_displacement_old;
        seg.recalc.plantar_buttock_displacement_new = plantar_buttock_displacement_new;
        seg.recalc.delta_buttock_y = delta_buttock_y;
        if ~isfield(seg.recalc, 'original_bos_buttock')
            seg.recalc.original_bos_buttock = seg.bos.buttock;
        end

        seg.bos.buttock = shift_bos_y(seg.recalc.original_bos_buttock, delta_buttock_y);
        seg.bos.new = recalculate_seg_bos_new(seg, height_sit);

        seg.mos.com_new = calc_mos_signed_distance(seg.com, seg.bos.new, seg.times);
        seg.mos.hof_new = calc_mos_signed_distance(seg.xcom_hof, seg.bos.new, seg.times);
        seg.mos.cmp_h_new = calc_mos_signed_distance(seg.xcom_cmp_h, seg.bos.new, seg.times);

        cellSegs{idxSeg} = seg;
        if mod(idxSeg, 50) == 0 || idxSeg == nSeg
            disp(['RecalculateBoSMMoSFromSegs: ', num2str(idxSeg), ' / ', num2str(nSeg)]);
        end
    end
end

function tf = is_valid_seg_for_recalc(seg)
    tf = isfield(seg, 'bos') && isfield(seg.bos, 'plantar_left') && isfield(seg.bos, 'plantar_right') && ...
         isfield(seg.bos, 'buttock') && isfield(seg, 'grf') && isfield(seg, 'times') && ...
         isfield(seg.times, 'union') && isfield(seg, 'com') && isfield(seg, 'xcom_hof') && ...
         isfield(seg, 'xcom_cmp_h');
end

function bos_out = shift_bos_y(bos_in, delta_y)
    bos_out = bos_in;
    for idxFrame = 1:numel(bos_in.y)
        if isempty(bos_in.y{idxFrame})
            continue;
        end
        bos_out.y{idxFrame} = bos_in.y{idxFrame} + delta_y;
    end
end

function bos_new = recalculate_seg_bos_new(seg, height_sit)
    nFrame = infer_frame_count(seg);
    bos_new = struct('x', {cell(nFrame, 1)}, 'y', {cell(nFrame, 1)});

    seed = calc_seg_seed(seg);
    rng(seed, 'twister');

    for idxFrame = 1:nFrame
        hasPlantarLeft = has_polygon(seg.bos.plantar_left, idxFrame) && has_vertical_support(seg.grf.plantar_left_z, idxFrame);
        hasPlantarRight = has_polygon(seg.bos.plantar_right, idxFrame) && has_vertical_support(seg.grf.plantar_right_z, idxFrame);
        hasButtock = has_polygon(seg.bos.buttock, idxFrame) && has_vertical_support(seg.grf.hip_z, idxFrame);
        hasPlantar = hasPlantarLeft || hasPlantarRight;

        if ~hasPlantar && ~hasButtock
            continue;
        end

        if hasPlantar && ~hasButtock
            [bos_new.x{idxFrame}, bos_new.y{idxFrame}] = combine_plantar_only(seg, idxFrame, hasPlantarLeft, hasPlantarRight);
            continue;
        end

        if ~hasPlantar && hasButtock
            [bos_new.x{idxFrame}, bos_new.y{idxFrame}] = buttock_only_bos(seg, idxFrame, height_sit);
            continue;
        end

        [bos_x, bos_y] = combine_plantar_buttock(seg, idxFrame, height_sit, hasPlantarLeft, hasPlantarRight, hasButtock);
        bos_new.x{idxFrame} = bos_x;
        bos_new.y{idxFrame} = bos_y;
    end
end

function nFrame = infer_frame_count(seg)
    nFrame = min([ ...
        numel(seg.times.union), ...
        numel(seg.bos.plantar_left.x), numel(seg.bos.plantar_left.y), ...
        numel(seg.bos.plantar_right.x), numel(seg.bos.plantar_right.y), ...
        numel(seg.bos.buttock.x), numel(seg.bos.buttock.y), ...
        numel(seg.grf.plantar_left_x), numel(seg.grf.plantar_left_y), numel(seg.grf.plantar_left_z), ...
        numel(seg.grf.plantar_right_x), numel(seg.grf.plantar_right_y), numel(seg.grf.plantar_right_z), ...
        numel(seg.grf.hip_x), numel(seg.grf.hip_y), numel(seg.grf.hip_z)]);
end

function seed = calc_seg_seed(seg)
    idx_sub = get_info_value(seg, 'idx_sub', 1);
    idx_file = get_info_value(seg, 'idx_file', 1);
    idx_seg = get_info_value(seg, 'idx_seg', 1);
    seed = mod(1000003 * double(idx_sub) + 1009 * double(idx_file) + double(idx_seg), 2^32 - 1);
    if seed <= 0
        seed = 1;
    end
end

function value = get_info_value(seg, field_name, default_value)
    value = default_value;
    if isfield(seg, 'info') && isfield(seg.info, field_name)
        value = seg.info.(field_name);
    end
end

function tf = has_polygon(bos_struct, idxFrame)
    tf = idxFrame <= numel(bos_struct.x) && idxFrame <= numel(bos_struct.y) && ...
         numel(bos_struct.x{idxFrame}) >= 3 && numel(bos_struct.y{idxFrame}) >= 3;
end

function tf = has_vertical_support(force_z, idxFrame)
    tf = idxFrame <= numel(force_z) && ~isnan(force_z(idxFrame)) && force_z(idxFrame) > 0;
end

function [bos_x, bos_y] = combine_plantar_only(seg, idxFrame, hasPlantarLeft, hasPlantarRight)
    if hasPlantarLeft && hasPlantarRight
        p_lr = [seg.bos.plantar_left.x{idxFrame}, seg.bos.plantar_left.y{idxFrame}; ...
                seg.bos.plantar_right.x{idxFrame}, seg.bos.plantar_right.y{idxFrame}];
        k_lr = convhull(p_lr(:,1), p_lr(:,2));
        bos_x = p_lr(k_lr, 1);
        bos_y = p_lr(k_lr, 2);
    elseif hasPlantarLeft
        bos_x = seg.bos.plantar_left.x{idxFrame};
        bos_y = seg.bos.plantar_left.y{idxFrame};
    else
        bos_x = seg.bos.plantar_right.x{idxFrame};
        bos_y = seg.bos.plantar_right.y{idxFrame};
    end
end

function [bos_x, bos_y] = buttock_only_bos(seg, idxFrame, height_sit)
    bos_x = [];
    bos_y = [];
    fz_buttock = seg.grf.hip_z(idxFrame);
    if abs(fz_buttock) <= eps
        return;
    end
    shift_y = -height_sit * seg.grf.hip_y(idxFrame) / fz_buttock;
    bos_x = seg.bos.buttock.x{idxFrame};
    bos_y = seg.bos.buttock.y{idxFrame} + shift_y;
end

function [bos_x, bos_y] = combine_plantar_buttock(seg, idxFrame, height_sit, hasPlantarLeft, hasPlantarRight, hasButtock)
    bos_x = [];
    bos_y = [];
    nSample = 100;

    if hasPlantarLeft
        p_left = sample_points_in_polygon(seg.bos.plantar_left.x{idxFrame}, seg.bos.plantar_left.y{idxFrame}, nSample);
    else
        p_left = zeros(nSample, 2);
    end

    if hasPlantarRight
        p_right = sample_points_in_polygon(seg.bos.plantar_right.x{idxFrame}, seg.bos.plantar_right.y{idxFrame}, nSample);
    else
        p_right = zeros(nSample, 2);
    end

    if hasButtock
        p_b = sample_points_in_polygon(seg.bos.buttock.x{idxFrame}, seg.bos.buttock.y{idxFrame}, nSample);
    else
        p_b = zeros(nSample, 2);
    end

    if (hasPlantarLeft && size(p_left, 1) < 3) || (hasPlantarRight && size(p_right, 1) < 3) || (hasButtock && size(p_b, 1) < 3)
        return;
    end

    n_use = nSample;
    if hasPlantarLeft
        n_use = min(n_use, size(p_left, 1));
    end
    if hasPlantarRight
        n_use = min(n_use, size(p_right, 1));
    end
    if hasButtock
        n_use = min(n_use, size(p_b, 1));
    end
    if n_use < 3
        return;
    end

    p_left = p_left(1:n_use, :);
    p_right = p_right(1:n_use, :);
    p_b = p_b(1:n_use, :);

    fz_sum = seg.grf.plantar_left_z(idxFrame) + seg.grf.plantar_right_z(idxFrame) + seg.grf.hip_z(idxFrame);
    if ~isfinite(fz_sum) || abs(fz_sum) <= eps
        return;
    end

    alpha_left = seg.grf.plantar_left_z(idxFrame) / fz_sum;
    alpha_right = seg.grf.plantar_right_z(idxFrame) / fz_sum;
    alpha_buttock = seg.grf.hip_z(idxFrame) / fz_sum;
    delta = -height_sit / fz_sum * [seg.grf.hip_x(idxFrame), seg.grf.hip_y(idxFrame)];

    p_new = alpha_left * p_left + alpha_right * p_right + alpha_buttock * p_b + delta;
    if size(p_new, 1) < 3
        return;
    end

    k = convhull(p_new(:,1), p_new(:,2));
    bos_x = p_new(k, 1);
    bos_y = p_new(k, 2);
end
