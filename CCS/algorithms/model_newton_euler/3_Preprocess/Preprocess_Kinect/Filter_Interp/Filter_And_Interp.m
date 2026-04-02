function out_interp_freq = Filter_And_Interp(freq,Order_N,t,value,Fc)
% freq > 30,表示最后需要插值
% value 是列向量
% t是列列向量
if nargin < 5; Fc = 3; end

switch Order_N
    case 0
        out_interp_freq = interp1(t',value',t(1):1/30:t(end),'spline');
    case {1 2 3 4} % iir 低通滤波器 fc 截止频率，Fs 采样频率
%         if freq > 30
            % 滤波前插值
            Fs = 30;        % Sampling Frequency,插值频率
            out_interp_Fs = interp1(t',value',t(1):1/Fs:t(end),'spline');
            % 滤波
%             Fc = 3;
            [b,a] = butter(Order_N,Fc/(Fs/2));
            temp = filtfilt(b,a,out_interp_Fs)';

            t_o = t(1):1/Fs:t(end);
            t_i = t(1):1/freq:t(end);

            out_interp_freq = interp1(t_o,temp,t_i,'spline')';
%         end

    otherwise % hamming窗滤波

        Fs = 30;
        out_interp_Fs = interp1(t',value',t(1):1/Fs:t(end),'spline');

        t_o = t(1):1/Fs:t(end);
        t_i = t(1):1/freq:t(end);


%         Fc = 3;          % First Cutoff Frequency
        flag = 'scale';  % Sampling Flag
        win = hamming(Order_N);

        b  = fir1(Order_N-1, Fc/(Fs/2), 'LOW', win, flag);
        out_filter = filter(b,1,out_interp_Fs);
        out_filter = out_filter(Order_N:end);

        temp= [out_interp_Fs(1:(Order_N-1)/2),out_filter(1:end),out_interp_Fs(end-(Order_N-1)/2+1:end)]';

        out_interp_freq = interp1(t_o,temp,t_i,'spline')';
end


%% Savitzky-Golay Filter,暂时该算法未实现

end

