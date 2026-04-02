% Active force-length relationship for Hill-type muscle model
% 主动张力-长度曲线
function fl = CalFl(l_normal, curve_option)
    if nargin < 2
        curve_option = 'groote2016';
    end
    
    switch lower(curve_option)
        case 'gaussian'
            % Original Gaussian curve - commonly used in biomechanics
            % Reference: Generic Hill-type muscle model
            fl = exp(-0.5.*((l_normal-1.05)/0.19).^2);
            
        case 'groote2016'
            b11 = 0.815; b21 = 1.055; b31 = 0.162; b41 = 0.063;
            b12 = 0.433; b22 = 0.717; b32 = -0.030; b42 = 0.200;
            b13 = 0.1; b23 = 1.0; b33 = 0.354; b43 = 0.0;
  
            fl = b11*exp(-0.5.*(l_normal-b21).^2./(b31+b41.*l_normal)) +...
                b12*exp(-0.5.*(l_normal-b22).^2./(b32+b42.*l_normal)) +...
                b13*exp(-0.5.*(l_normal-b23).^2./(b33+b43.*l_normal));

        otherwise
            error('Unknown curve option: %s. Available options: default, thelen2003, millard2013, dejong1998, gordon1966', curve_option);
    end
    
%     % Ensure non-negative force
%     fl = max(0, fl);
end