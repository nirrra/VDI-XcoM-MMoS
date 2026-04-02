% Tendon force-length relationship for Hill-type muscle model
% 肌腱张力-长度曲线
function ft = CalFt(l_normal, curve_option)
    if nargin < 2
        curve_option = 'groote2016';
    end
    
    switch lower(curve_option)
        case 'groote2016'
            kT = 35; c1 = 0.2; c2 = 0.995; c3 = 0.25;
  
            ft = c1*exp(kT*(l_normal-c2))-c3;
        otherwise
            error('Unknown curve option: %s. Available options: default, thelen2003, millard2013, dejong1998, gordon1966', curve_option);
    end
    
    % Ensure non-negative force
    ft = max(0, ft);
end