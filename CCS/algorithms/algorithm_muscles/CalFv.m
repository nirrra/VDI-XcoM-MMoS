% Force-velocity relationship for Hill-type muscle model
% 力-速曲线
function fv = CalFv(v_normal, curve_option)
    
    if nargin < 2
        curve_option = 'groote2016';
    end
    
    switch lower(curve_option)
        case 'thelen2003'
            kce1 = 0.25; kce2 = 0.06; fymax = 1.6;
            if v_normal <= 0
                fv = (1+v_normal)/(1-v_normal/kce1);
            else
                fv = (1+v_normal*fymax/kce2)/(1+v_normal/kce2);
            end
            
        case 'vansoest1993'
            fv = 0.1433/(0.1074+exp(-0.1409*sinh(3.2*v_normal+1.6)));
            
        case 'groote2016'
            d1 = -0.318; d2 = -8.149; d3 = -0.374; d4 = 0.886;
            fv = d1*log((d2*v_normal+d3)+sqrt((d2*v_normal+d3)^2+1))+d4;
            
        otherwise
            error('Unknown curve option: %s. Available options: default, thelen2003, vansoest1993, millard2013, dejong1998, hill1938', curve_option);
    end
    
%     % Ensure reasonable bounds
%     fv = max(0.1, fv); % Minimum 10% of isometric force
end
