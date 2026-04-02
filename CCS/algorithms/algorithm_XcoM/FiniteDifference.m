function omega_deg = FiniteDifference(theta_deg, fs)
    dt = 1/fs;
    omega_deg = zeros(size(theta_deg));
    omega_deg(2:end-1) = (theta_deg(3:end) - theta_deg(1:end-2)) / (2*dt);
    
    % 边界处理（前向和后向差分）
    omega_deg(1) = (theta_deg(2) - theta_deg(1)) / dt;
    omega_deg(end) = (theta_deg(end) - theta_deg(end-1)) / dt;