%% ======== Local functions ========
function pts = sample_points_in_polygon(poly_x, poly_y, n_sample)
    % 在多边形内均匀采样点（拒绝采样）
        pts = zeros(0,2);
        if numel(poly_x) < 3 || numel(poly_y) < 3
            return;
        end
        poly_x = poly_x(:);
        poly_y = poly_y(:);
        if poly_x(1) ~= poly_x(end) || poly_y(1) ~= poly_y(end)
            poly_x = [poly_x; poly_x(1)];
            poly_y = [poly_y; poly_y(1)];
        end
        min_x = min(poly_x); max_x = max(poly_x);
        min_y = min(poly_y); max_y = max(poly_y);
        max_iter = 50;
        iter = 0;
        while size(pts,1) < n_sample && iter < max_iter
            iter = iter + 1;
            batch_n = max(5*n_sample, 200);
            rx = min_x + (max_x - min_x) * rand(batch_n,1);
            ry = min_y + (max_y - min_y) * rand(batch_n,1);
            in = inpolygon(rx, ry, poly_x, poly_y);
            new_pts = [rx(in), ry(in)];
            if ~isempty(new_pts)
                pts = [pts; new_pts]; %#ok<AGROW>
            end
        end
        if size(pts,1) > n_sample
            pts = pts(1:n_sample,:);
        end
    end