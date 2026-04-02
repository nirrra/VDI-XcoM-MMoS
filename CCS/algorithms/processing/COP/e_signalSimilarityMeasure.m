% clc; clear;
%%
% 说明：计算rms和dtw结果进行对比
% load('dataPackage_StepThree.mat')

rms_UL = zeros(N, 1);
rms_IP = zeros(N, 1);
rms_cop = zeros(N, 1);

dtw_UL = zeros(N, 1);
dtw_IP = zeros(N, 1);

rsquare_UL = zeros(N, 1);
rsquare_IP = zeros(N, 1);

rsquareAdj_UL = zeros(N, 1);
rsquareAdj_IP = zeros(N, 1);

ML = 2; AP = 3;

data = ankle;
for ii = 1:N
    ii = 12;
    rowN = ii + 1;
    sig = data{rowN, AP};
    mdl_UL = data{rowN, AP}.regData_RegressionResult;
    mdl_IP = data{rowN, AP}.regData_invertedPendulum_RegressionResult;
    
    % sig
    cop_UL = predict(mdl_UL, mdl_UL.Variables(:, 1:3));
    
    com = sig.signalFun_demean(sig.signalFun_smoothdata ...
        (sig.sig_Tblsway.Time, sig.sig_Tblsway.COM));
    cop_IP = predict(mdl_IP, mdl_IP.Variables(:, 1)) + com;
    cop = sig.signalFun_demean(sig.sig_cop);
    
    % dtw, rms
    rms_UL(ii) = rms(cop_UL - cop);
    rms_IP(ii) = rms(cop_IP - cop);
    rms_cop(ii) = rms(cop);
    
    T = 0.5; Hz = 100; % 相似比较窗口0.5s(信号采样频率100Hz)
    dtw_UL(ii) = dtw(cop, cop_UL, T*Hz);
    dtw_IP(ii) = dtw(cop, cop_IP, T*Hz);
    
    rsquare_UL(ii) = mdl_UL.Rsquared.Ordinary;
    rsquare_IP(ii) = mdl_IP.Rsquared.Ordinary;
    
    rsquareAdj_UL(ii) = mdl_UL.Rsquared.Adjusted;
    rsquareAdj_IP(ii) = mdl_IP.Rsquared.Adjusted;
    
    figure; plot(cop); hold on; plot(cop_UL); plot(cop_IP);
    hold off; legend('COP', 'UL', 'IP');
end

% ID = (1:N)';
% tbl = table(ID, rms_UL, rms_IP, rms_cop, dtw_UL, dtw_IP, ...
%     rsquare_UL, rsquare_IP, rsquareAdj_UL, rsquareAdj_IP);
% writetable(tbl, 'compare.xlsx');