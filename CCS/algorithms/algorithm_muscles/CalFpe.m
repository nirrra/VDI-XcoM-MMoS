% Passive force-length relationship for Hill-type muscle model
% 被动张力-长度曲线
function fpe = CalFpe(l_normal, curve_option)

    if nargin < 2
        curve_option = 'groote2016';
%         curve_option = 'thelen2003';
%         curve_option = 'zero';
    end
    
    if l_normal <= 1
        fpe = 0; % No passive force at or below optimal length
        return;
    end
    
    switch lower(curve_option)
        case 'millard2013'
            fpe = 5*(l_normal-1);
            
        case 'thelen2003'
            fpe = (exp(10.*(l_normal-1))-1)./(exp(5)-1);
            
        case 'groote2016'
            kpe = 4; e0 = 0.6;
            fpe = (exp(kpe*(l_normal-1)/e0)-1)./(exp(kpe)-1);
        case 'zero'
            fpe = 0;
        otherwise
            error('Unknown curve option: %s. Available options: default, millard2013, thelen2003, mcgill1986, winters1988, schutte1993, gentle, exponential_gentle', curve_option);
    end
    
    % Ensure non-negative force
%     fpe = max(0, fpe);
end
