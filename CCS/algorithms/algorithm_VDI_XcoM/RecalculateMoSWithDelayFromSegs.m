function cellSegs = RecalculateMoSWithDelayFromSegs(cellSegs, delay_time, fs)
% Recalculate dynamic MoS after correcting the timing mismatch between
% Kinect-derived kinematics and array-derived BoS/GRF signals.
%
% Positive delay_frames means the array signal lags Kinect by N frames.
% The correction therefore shifts array-derived signals earlier by N frames.

    if nargin < 3
        error('RecalculateMoSWithDelayFromSegs requires cellSegs and delay_frames.');
    end

    if isempty(cellSegs)
        return;
    end

    delay_frames = round(delay_time*fs);

    nSeg = numel(cellSegs);
    for idxSeg = 1:nSeg
        seg = cellSegs{idxSeg};
        if ~is_valid_seg_for_delay(seg)
            cellSegs{idxSeg} = seg;
            print_progress(idxSeg, nSeg);
            continue;
        end

        if ~isfield(seg, 'delay_align')
            seg.delay_align = struct();
        end
        if ~isfield(seg.delay_align, 'original_bos')
            seg.delay_align.original_bos = seg.bos;
        end
        if isfield(seg, 'grf') && ~isfield(seg.delay_align, 'original_grf')
            seg.delay_align.original_grf = seg.grf;
        end

        seg.delay_align.delay_frames = delay_frames;

        [seg.bos.plantar_left, ~] = shift_polygon_struct(seg.delay_align.original_bos.plantar_left, delay_frames);
        [seg.bos.plantar_right, ~] = shift_polygon_struct(seg.delay_align.original_bos.plantar_right, delay_frames);
        [seg.bos.plantar, pad_mask_plantar] = shift_polygon_struct(seg.delay_align.original_bos.plantar, delay_frames);
        [seg.bos.buttock, ~] = shift_polygon_struct(seg.delay_align.original_bos.buttock, delay_frames);
        [seg.bos.new, pad_mask_new] = shift_polygon_struct(seg.delay_align.original_bos.new, delay_frames);

        if isfield(seg.delay_align, 'original_grf')
            seg.grf = shift_grf_struct(seg.delay_align.original_grf, delay_frames);
        end

        seg.mos.com_plantar = calc_mos_signed_distance(seg.com, seg.bos.plantar, seg.times);
        seg.mos.hof_plantar = calc_mos_signed_distance(seg.xcom_hof, seg.bos.plantar, seg.times);
        seg.mos.cmp_h_plantar = calc_mos_signed_distance(seg.xcom_cmp_h, seg.bos.plantar, seg.times);

        seg.mos.com_new = calc_mos_signed_distance(seg.com, seg.bos.new, seg.times);
        seg.mos.hof_new = calc_mos_signed_distance(seg.xcom_hof, seg.bos.new, seg.times);
        seg.mos.cmp_h_new = calc_mos_signed_distance(seg.xcom_cmp_h, seg.bos.new, seg.times);

        seg.mos.com_plantar = zero_pad_mos(seg.mos.com_plantar, pad_mask_plantar);
        seg.mos.hof_plantar = zero_pad_mos(seg.mos.hof_plantar, pad_mask_plantar);
        seg.mos.cmp_h_plantar = zero_pad_mos(seg.mos.cmp_h_plantar, pad_mask_plantar);

        seg.mos.com_new = zero_pad_mos(seg.mos.com_new, pad_mask_new);
        seg.mos.hof_new = zero_pad_mos(seg.mos.hof_new, pad_mask_new);
        seg.mos.cmp_h_new = zero_pad_mos(seg.mos.cmp_h_new, pad_mask_new);

        cellSegs{idxSeg} = seg;
        print_progress(idxSeg, nSeg);
    end
end

function tf = is_valid_seg_for_delay(seg)
    tf = isfield(seg, 'bos') && isfield(seg, 'mos') && isfield(seg, 'times') && ...
         isfield(seg.times, 'union') && isfield(seg, 'com') && ...
         isfield(seg, 'xcom_hof') && isfield(seg, 'xcom_cmp_h') && ...
         isfield(seg.bos, 'plantar_left') && isfield(seg.bos, 'plantar_right') && ...
         isfield(seg.bos, 'plantar') && isfield(seg.bos, 'buttock') && ...
         isfield(seg.bos, 'new');
end

function [bos_out, pad_mask] = shift_polygon_struct(bos_in, delay_frames)
    n = min(numel(bos_in.x), numel(bos_in.y));
    bos_out = struct('x', {cell(n, 1)}, 'y', {cell(n, 1)});
    pad_mask = false(n, 1);

    for idx = 1:n
        src_idx = idx + delay_frames;
        if src_idx >= 1 && src_idx <= n
            bos_out.x{idx} = bos_in.x{src_idx};
            bos_out.y{idx} = bos_in.y{src_idx};
        else
            bos_out.x{idx} = [];
            bos_out.y{idx} = [];
            pad_mask(idx) = true;
        end
    end
end

function grf_out = shift_grf_struct(grf_in, delay_frames)
    grf_out = grf_in;
    field_names = fieldnames(grf_in);
    for iField = 1:numel(field_names)
        field_name = field_names{iField};
        values = grf_in.(field_name);
        if isnumeric(values) && isvector(values)
            grf_out.(field_name) = shift_numeric_vector(values, delay_frames);
        end
    end
end

function values_out = shift_numeric_vector(values_in, delay_frames)
    values_in = values_in(:);
    n = numel(values_in);
    values_out = zeros(n, 1);
    for idx = 1:n
        src_idx = idx + delay_frames;
        if src_idx >= 1 && src_idx <= n
            values_out(idx) = values_in(src_idx);
        end
    end
end

function mos = zero_pad_mos(mos, pad_mask)
    if isempty(pad_mask)
        return;
    end
    field_names = {'sum', 'front', 'back', 'left', 'right'};
    for iField = 1:numel(field_names)
        field_name = field_names{iField};
        if isfield(mos, field_name)
            values = mos.(field_name);
            n = min(numel(values), numel(pad_mask));
            values = values(:);
            values(pad_mask(1:n)) = 0;
            mos.(field_name) = values;
        end
    end
end

function print_progress(idxSeg, nSeg)
    if mod(idxSeg, 50) == 0 || idxSeg == nSeg
        disp(['RecalculateMoSWithDelayFromSegs: ', num2str(idxSeg), ' / ', num2str(nSeg)]);
    end
end
