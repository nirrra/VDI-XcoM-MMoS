%根据Byron中COPResult.cs中算法修改了摆动速度、速度长短轴、得分计算部分 —— by wdy
%样本熵、多尺度熵、排列熵
function [ p_list, p_name, enve, idx, outlier_idx] = computation_COPparameters_DeOutliers( ml, ap, fs )
%COMPUTATION_COPPARAMETERS 基于COP分解信号的特征参数计算：输入单位毫米
BasicMathematicalMethod = application_BasicMathematicalMethod;
COPDecomposition = application_COPDecomposition;

Handler_RMSD = @(s)rms(s - mean(s));
Handler_ApEn_m2_sdo2 = ...
    @(s)BasicMathematicalMethod.Parameter_ApEn(2, 0.2*std(s), s, 1);
Handler_SampEn_m2_sdo2 = ...
    @(s)BasicMathematicalMethod.Parameter_SampEn(2, 0.2*std(s), s, 1);
Handler_MSEn_m2_sdo2 = ...
    @(s)multiscaleSampleEntropy(s, 2, 0.2*std(s), 1);
Handler_PEn_m2_sdo2 = ...
    @(s)permutationEntropy(s, 3, 10);%嵌入维数和延迟时间由phaseSpaceReconstruction()获得

Handler_computeVelocity_withSGfilter = ...
    @(s, fs)smooth(gradient(s,1/fs), 5, 'sgolay', 1)';
Handler_computeAcceleration_withSGfilter = ...
    @(s, fs)smooth(gradient(gradient(s,1/fs),1/fs), 5, 'sgolay', 1)';

Handler_PoinSD1 = ...
    @(x, y) std(deleteoutliers(x*cos(3*pi/4)+y*sin(3*pi/4)));
Handler_PoinSD2 = ...
    @(x, y) std(deleteoutliers(x*cos(pi/4)+y*sin(pi/4)));
%% 参数列表
p_name = { ...
    'mlRMSD',       ...1
    'apRMSD',       ...2
    'CEA',          ...3.椭圆面积（mm2）
    'mlApEn',       ...4.COP ML信号的近似熵（无单位）
    'apApEn',       ...5
    'mlMigrRMSD',   ...6.ML方向Migr（分解慢成分）的RMSD（mm）
    'apMigrRMSD',   ...7
    'mlMigrApEn',   ...8.ML方向Migr（分解慢成分）的近似熵
    'apMigrApEn',   ...9
    'mlResiRMSD',   ...10
    'apResiRMSD',   ...11
    'mlResiApEn',   ...12
    'apResiApEn',   ...13
    ...
    'mlmVel',       ...14.COP ML信号的速度（mm/s）
    'apmVel',       ...15
    'mVel',         ...16.COP轨迹的速度
    ...
    'mlSD1',        ...17.COP ML信号的Poincare SD1（mm）
    'mlSD2',        ...18
    'apSD1',        ...19
    'apSD2',        ...20
    ...
    'mlVSD1',       ...21.COP ML信号速度的Poincare SD1（mm）
    'mlVSD2',       ...22
    'apVSD1',       ...23
    'apVSD2',       ...24
    ...
    'mlRMratio',    ...25.ML方向Migr（分解慢成分）与Resi（快成份）的RMSD比值（无单位）
    'apRMratio',    ...26
    'mlSD12ratio',  ...27.COP ML信号的Poincare SD1与SD2比值（无单位）
    'apSD12ratio',  ...28
    'mlVSD12ratio', ...29.COP ML信号速度的Poincare SD1与SD2比值（无单位）
    'apVSD12ratio', ...30
    ...
    'areaofsway',   ...31.轨迹多边形包络面积（mm2）
    'acc',          ...32.加速度均值（mm/s2）
    'copSD2',       ...33.COP轨迹的Poincare SD2（mm）
    'mlacc',        ...34
    'copSD1',       ...35
    'apacc',        ...36
    'vSD2',         ...37.COP轨迹速度的Poincare SD2（mm/s）
    'vSD1',         ...38
    ...
    'mlHFD',        ...39.ML信号的Higuchi分形维数
    'apHFD',        ...40.AP信号的Higuchi分形维数
    'hcApEn',       ...41.heading change的近似熵
    'hcHFD',        ...42.heading change的Higuchi分形维数
    'accHFD',       ...43.加速度分形维数
    'vHFD',         ...44.速度分形维数
    ...
    'mlSampEn',     ...45.ML样本熵
    'apSampEn',     ...46.AP样本熵
    'mlMSEn',       ...47.ML多尺度熵
    'apMSEn',       ...48.AP多尺度熵
    'mlPEn',        ...49.ML排列熵
    'apPEn',        ...50.AP排列熵
    ...
    'score',        ...51.得分  
    };
%%
num = numel(p_name);
p_list = cell(1, num);
p_list = cell2table(p_list, 'VariableNames', p_name);
%% parameter calculation
ml = ml - mean(ml); ap = ap - mean(ap);
[idx, outlier_idx] = COP_Outliers(ml, ap);
% 1 - 3
p_list.mlRMSD = Handler_RMSD(deleteoutliers(ml));
p_list.apRMSD = Handler_RMSD(deleteoutliers(ap));

[~,~, ellipseState ] = ellipsate(ml, ap, 3);     %# 2 standard deviations, 95% of population
p_list.CEA = pi*ellipseState.majorLength*ellipseState.minorLength;

% 4 - 5
p_list.mlApEn = Handler_ApEn_m2_sdo2(ml);
p_list.apApEn = Handler_ApEn_m2_sdo2(ap);
p_list.mlSampEn = Handler_SampEn_m2_sdo2(ml);
p_list.apSampEn = Handler_SampEn_m2_sdo2(ap);
p_list.mlMSEn = Handler_MSEn_m2_sdo2(ml);
p_list.apMSEn = Handler_MSEn_m2_sdo2(ap);
p_list.mlPEn = Handler_PEn_m2_sdo2(ml');
p_list.apPEn = Handler_PEn_m2_sdo2(ap');
% aux = lyarosenstein(ml,3,10,30,200);
% p_list.mlLLE = mean(aux(101:200));
% aux = lyarosenstein(ap,3,10,30,200);
% p_list.apLLE = mean(aux(101:200));

% COP的Migr-Resi分解信号
decomposed = COPDecomposition.getMigrResiDecomposition(ml, ap, fs); 
% 6 - 9
p_list.mlMigrRMSD = Handler_RMSD(deleteoutliers(decomposed.migr_ml));
p_list.apMigrRMSD = Handler_RMSD(deleteoutliers(decomposed.migr_ap));

p_list.mlMigrApEn = Handler_ApEn_m2_sdo2(decomposed.migr_ml);
p_list.apMigrApEn = Handler_ApEn_m2_sdo2(decomposed.migr_ap);
% 10 - 13
p_list.mlResiRMSD = Handler_RMSD(deleteoutliers(decomposed.resi_ml));
p_list.apResiRMSD = Handler_RMSD(deleteoutliers(decomposed.resi_ap));

p_list.mlResiApEn = Handler_ApEn_m2_sdo2(decomposed.resi_ml);
p_list.apResiApEn = Handler_ApEn_m2_sdo2(decomposed.resi_ap);
% Velocity of COP Signal
% vel旧算法
% mlVel = Handler_computeVelocity_withSGfilter(ml, fs);
% apVel = Handler_computeVelocity_withSGfilter(ap, fs);
% Vel = sqrt(mlVel.^2 + apVel.^2);

% vel新算法
mlVel = Handler_computeVelocity_withSGfilter_new(ml, fs);
apVel = Handler_computeVelocity_withSGfilter_new(ap, fs);
Vel = sqrt(mlVel.^2 + apVel.^2);

% 14 - 16
p_list.mlmVel = mean(deleteoutliers(abs(mlVel)));
p_list.apmVel = mean(deleteoutliers(abs(apVel)));
p_list.mVel = mean(deleteoutliers(Vel));
% 17 - 20
ml_n = ml(1:end-1); ml_p = ml(2:end);
p_list.mlSD1 = Handler_PoinSD1(ml_n, ml_p);
p_list.mlSD2 = Handler_PoinSD2(ml_n, ml_p);
ap_n = ap(1:end-1); ap_p = ap(2:end);
p_list.apSD1 = Handler_PoinSD1(ap_n, ap_p);
p_list.apSD2 = Handler_PoinSD2(ap_n, ap_p);
% 21 - 24
mlVel_n = mlVel(1:end-1); mlVel_p = mlVel(2:end);
p_list.mlVSD1 = Handler_PoinSD1(mlVel_n, mlVel_p);
p_list.mlVSD2 = Handler_PoinSD2(mlVel_n, mlVel_p);
apVel_n = apVel(1:end-1); apVel_p = apVel(2:end);
p_list.apVSD1 = Handler_PoinSD1(apVel_n, apVel_p);
p_list.apVSD2 = Handler_PoinSD2(apVel_n, apVel_p);
% 25 - 30
p_list.mlRMratio = p_list.mlResiRMSD / p_list.mlMigrRMSD;
p_list.apRMratio = p_list.apResiRMSD / p_list.apMigrRMSD;
p_list.mlSD12ratio = p_list.mlSD1 / p_list.mlSD2;
p_list.apSD12ratio = p_list.apSD1 / p_list.apSD2;
p_list.mlVSD12ratio = p_list.mlVSD1 / p_list.mlVSD2;
p_list.apVSD12ratio = p_list.apVSD1 / p_list.apVSD2;
% 31 - 38
X = ml(idx); Y = ap(idx);
[K, p_list.areaofsway] = convhull(X, Y);
enve.ml = X(K); enve.ap = Y(K);
% % 新包络面面积
% [area,~] = Handler_computeEnvelopeArea(ml(idx), ap(idx));
% p_list.CEA = area;

% acc旧算法
% acc_ml = Handler_computeAcceleration_withSGfilter(ml, fs);
% acc_ap = Handler_computeAcceleration_withSGfilter(ap, fs);
% acc = sqrt(acc_ml.^2 + acc_ap.^2);

% acc新算法
acc_ml = Handler_computeAcceleration_withSGfilter_new(mlVel, fs);
acc_ap = Handler_computeAcceleration_withSGfilter_new(apVel, fs);
acc = sqrt(acc_ml.^2 + acc_ap.^2);

p_list.acc = mean(deleteoutliers(acc));
p_list.mlacc = mean(deleteoutliers(abs(acc_ml)));
p_list.apacc = mean(deleteoutliers(abs(acc_ap)));

cop = sqrt(ml.^2 + ap.^2);
cop_n = cop(1:end-1); cop_p = cop(2:end);
p_list.copSD2 = Handler_PoinSD2(cop_n, cop_p);
p_list.copSD1 = Handler_PoinSD1(cop_n, cop_p);

% 旧摆速长短轴
% vel_ml = Handler_computeVelocity_withSGfilter(ml, fs);
% vel_ap = Handler_computeVelocity_withSGfilter(ap, fs);
% vel = sqrt(vel_ml.^2 + vel_ap.^2);
% vel_n = vel(1:end-1); vel_p = vel(2:end);
% p_list.vSD2 = Handler_PoinSD2(vel_n, vel_p);
% p_list.vSD1 = Handler_PoinSD1(vel_n, vel_p);

% 新摆速长短轴
vel_n = Vel(1:end-1); vel_p = Vel(2:end);
p_list.vSD2 = Handler_PoinSD2(vel_n, vel_p);
p_list.vSD1 = Handler_PoinSD1(vel_n, vel_p);

%% 得分
% 适用全年龄段参考值
        MEDIOLATERALRANGEAVE = 2.5;
        MEDIOLATERALRANGESTD = 1.0;
        ANTEROPOSTERIORRANGEAVE = 4.8;
        ANTEROPOSTERIORRANGESTD = 1.6;
        ENVELOPEAREAAVG = 160;
        ENVELOPEAREASTD = 125;
        MEDIOLATERALVELOCITYAVG = 2.9;
        MEDIOLATERALVELOCITYSTD = 1.4;
        ANTEROPOSTERIORVELOCITYAVG = 4.8;
        ANTEROPOSTERIORVELOCITYSTD = 0.8;
        SWINGSPEEDAVG = 6.2;
        SWINGSPEEDSTD = 1.6;
        MEDIOLATERALACCELERATIONAVG = 28.0;
        MEDIOLATERALACCELERATIONSTD = 16.0;
        ANTEROPOSTERIORACCLERATIONAVG = 53.0;
        ANTEROPOSTERIORACCLERATIONSTD = 15.0;
        SWINGACCELERATIONAVG = 66.0;
        SWINGACCELERATIONSTD = 21.0;
        COPMAJORAXISAVG = 3.7;
        COPMAJORAXISSTD = 1.3;
        COPMINORAXISAVG = 0.042;
        COPMINORAXISSTD = 0.013;
        SWINGVELOCITYMAJORAXISAVG = 6.6;
        SWINGVELOCITYMAJORAXISSTD = 3.3;
        SWINGVELOCITYMINORAXISAVG = 0.5;
        SWINGVELOCITYMINORAXISSTD = 0.2;
%适用全年龄段参考值（根据体脂秤数据，20Hz）
        MEDIOLATERALRANGEAVE = 2.61;
        MEDIOLATERALRANGESTD = 0.99;
        ANTEROPOSTERIORRANGEAVE = 4.03;
        ANTEROPOSTERIORRANGESTD = 1.53;
        ENVELOPEAREAAVG = 176.8;
        ENVELOPEAREASTD = 119.7;
        MEDIOLATERALVELOCITYAVG = 3.56;
        MEDIOLATERALVELOCITYSTD = 1.28;
        ANTEROPOSTERIORVELOCITYAVG = 5.29;
        ANTEROPOSTERIORVELOCITYSTD = 1.53;
        SWINGSPEEDAVG = 7.14;
        SWINGSPEEDSTD = 2.08;
        MEDIOLATERALACCELERATIONAVG = 30.76;
        MEDIOLATERALACCELERATIONSTD = 13.09;
        ANTEROPOSTERIORACCLERATIONAVG = 46.70;
        ANTEROPOSTERIORACCLERATIONSTD = 18.62;
        SWINGACCELERATIONAVG = 62.39;
        SWINGACCELERATIONSTD = 24.35;
        COPMAJORAXISAVG = 3.32;
        COPMAJORAXISSTD = 1.15;
        COPMINORAXISAVG = 0.224;
        COPMINORAXISSTD = 0.068;
        SWINGVELOCITYMAJORAXISAVG = 5.89;
        SWINGVELOCITYMAJORAXISSTD = 1.79;
        SWINGVELOCITYMINORAXISAVG = 2.15;
        SWINGVELOCITYMINORAXISSTD = 0.83;

p_list.score = 0.700 * ZToScore((p_list.mlRMSD - MEDIOLATERALRANGEAVE) / MEDIOLATERALRANGESTD)...
                      + 0.354 * ZToScore((p_list.apRMSD - ANTEROPOSTERIORRANGEAVE) / ANTEROPOSTERIORRANGESTD)...
                      + 0.834 * ZToScore((p_list.areaofsway - ENVELOPEAREAAVG) / ENVELOPEAREASTD)...
                      + 0.801 * ZToScore((p_list.mlmVel - MEDIOLATERALVELOCITYAVG) / MEDIOLATERALVELOCITYSTD)...
                      + 0.252 * ZToScore((p_list.apmVel - ANTEROPOSTERIORVELOCITYAVG) / ANTEROPOSTERIORVELOCITYSTD)...
                      + 0.496 * ZToScore((p_list.mVel - SWINGSPEEDAVG) / SWINGSPEEDSTD)...
                      + 0.293 * ZToScore((p_list.mlacc - MEDIOLATERALACCELERATIONAVG) / MEDIOLATERALACCELERATIONSTD)...
                      + 0.931 * ZToScore((p_list.apacc - ANTEROPOSTERIORACCLERATIONAVG) / ANTEROPOSTERIORACCLERATIONSTD)...
                      + 0.191 * ZToScore((p_list.acc - SWINGACCELERATIONAVG) / SWINGACCELERATIONSTD)...
                      + 0.096 * ZToScore((p_list.copSD2 - COPMAJORAXISAVG) / COPMAJORAXISSTD)...
                      + 0.225 * ZToScore((p_list.copSD1 - COPMINORAXISAVG) / COPMINORAXISSTD)...
                      + 0.385 * ZToScore((p_list.vSD2 - SWINGVELOCITYMAJORAXISAVG) / SWINGVELOCITYMAJORAXISSTD)...
                      + 0.117 * ZToScore((p_list.vSD1 - SWINGVELOCITYMINORAXISAVG) / SWINGVELOCITYMINORAXISSTD);
p_list.score = p_list.score * 100 / 5.675;     

%% 分形维数
% Higuchi分形维数
p_list.mlHFD = Higuchi_FD(ml, 30);
p_list.apHFD = Higuchi_FD(ap, 60);

headingChange = Handler_computeHeadingChange(ml, ap);
p_list.hcApEn = Handler_ApEn_m2_sdo2(headingChange);
p_list.hcHFD = Higuchi_FD(headingChange, 60);
p_list.vHFD = Higuchi_FD(Vel, 60);
p_list.accHFD = Higuchi_FD(acc, 60);

%% 小波变换
% numLayers = 5;
% % ML
% [c, l] = wavedec(ml, numLayers, 'db2');
% [cd1, cd2, cd3, cd4, cd5] = detcoef(c, l, (1:numLayers));
% p_list.mlcd1RMSD = Handler_RMSD(cd1);
% p_list.mlcd1ApEn = Handler_ApEn_m2_sdo2(cd1);
% p_list.mlcd1HFD = Higuchi_FD(cd1, 60);
% p_list.mlcd2RMSD = Handler_RMSD(cd2);
% p_list.mlcd2ApEn = Handler_ApEn_m2_sdo2(cd2);
% p_list.mlcd2HFD = Higuchi_FD(cd2, 60);
% p_list.mlcd3RMSD = Handler_RMSD(cd3);
% p_list.mlcd3ApEn = Handler_ApEn_m2_sdo2(cd3);
% p_list.mlcd3HFD = Higuchi_FD(cd3, 60);
% p_list.mlcd4RMSD = Handler_RMSD(cd4);
% p_list.mlcd4ApEn = Handler_ApEn_m2_sdo2(cd4);
% p_list.mlcd4HFD = Higuchi_FD(cd4, 60);
% p_list.mlcd5RMSD = Handler_RMSD(cd5);
% p_list.mlcd5ApEn = Handler_ApEn_m2_sdo2(cd5);
% p_list.mlcd5HFD = Higuchi_FD(cd5, 60);
% % AP
% [c, l] = wavedec(ap, numLayers, 'db2');
% [cd1, cd2, cd3, cd4, cd5] = detcoef(c, l, (1:numLayers));
% p_list.apcd1RMSD = Handler_RMSD(cd1);
% p_list.apcd1ApEn = Handler_ApEn_m2_sdo2(cd1);
% p_list.apcd1HFD = Higuchi_FD(cd1, 60);
% p_list.apcd2RMSD = Handler_RMSD(cd2);
% p_list.apcd2ApEn = Handler_ApEn_m2_sdo2(cd2);
% p_list.apcd2HFD = Higuchi_FD(cd2, 60);
% p_list.apcd3RMSD = Handler_RMSD(cd3);
% p_list.apcd3ApEn = Handler_ApEn_m2_sdo2(cd3);
% p_list.apcd3HFD = Higuchi_FD(cd3, 60);
% p_list.apcd4RMSD = Handler_RMSD(cd4);
% p_list.apcd4ApEn = Handler_ApEn_m2_sdo2(cd4);
% p_list.apcd4HFD = Higuchi_FD(cd4, 60);
% p_list.apcd5RMSD = Handler_RMSD(cd5);
% p_list.apcd5ApEn = Handler_ApEn_m2_sdo2(cd5);
% p_list.apcd5HFD = Higuchi_FD(cd5, 60);

end

% function idx = prctileIndex(x, range)
% range = prctile(x, range);
% idx = find(x > range(1) & x < range(2));
% end

function [ ellipseX , ellipseY, ellipseState ] = ellipsate( dataX , dataY , stdev )
% ELLIPSATE circumscribe data into an ellipse
%
% Syntax:  [ ellipseX , ellipseY ] = ellipsate( dataX , dataY , stdev )
%
% Example:
%   data=mvnrnd([0.5 1.5], [0.025 0.03 ; 0.03 0.16], 100);
%   dataX=data(:,1);
%   dataY=data(:,2);
%   stdev = 2;           %# 2 standard deviations, 95% of population
%   [ ellipseX , ellipseY ] = ellipsate( dataX , dataY , stdev );
%   plot(dataX, dataY, '.')
%   axis square
%   hold on 
%   plot(ellipseX , ellipseY, 'r')
%
% Function based on the code of Amro, described in 
% http://stackoverflow.com/questions/3417028/ellipse-around-the-data-in-matlab
%
% Doubts, bugs: rpavao@gmail.com

data=[dataX(:) , dataY(:)];

Mu = mean( data );
X0 = bsxfun(@minus, data, Mu);

conf = 2*normcdf(stdev)-1;   %# if stdev=2, it covers around 95% of population
scale = chi2inv(conf,2);     %# inverse chi-squared with dof=#dimensions

Cov = cov(X0) * scale;
[V D] = eig(Cov);

[D order] = sort(diag(D), 'descend');
D = diag(D);
V = V(:, order);

t = linspace(0,2*pi,1000);
e = [cos(t) ; sin(t)];        %# unit circle
VV = V*sqrt(D);               %# scale eigenvectors
e = bsxfun(@plus, VV*e, Mu'); %#' project circle back to orig space

ellipseX=e(1,:);
ellipseY=e(2,:);
%% find major and minor axis
ellipse = [ellipseX(:), ellipseY(:)];
len = length(ellipseX);

center = mean(ellipse);
deltas = ellipse - repmat(center, len, 1);
distances = zeros(len, 1);
for i = 1 : len, distances(i) = norm(deltas(i, :)); end
[majorLength, majorIndex] = max(distances);
major = ellipse(majorIndex, :);
[minorLength, minorIndex] = min(distances);
minor = ellipse(minorIndex, :);

ellipseState.majorLength = majorLength;
ellipseState.minorLength = minorLength;
ellipseState.center = center;       % x,y
ellipseState.majorpoint = major;    % x,y
ellipseState.minorpoint = minor;    % x,y
ellipseState.k = (major(2)-center(2))/(major(1)-center(1));
end

function [b,idx,outliers] = deleteoutliers(a,alpha,rep)
% [B, IDX, OUTLIERS] = DELETEOUTLIERS(A, ALPHA, REP)
% 
% For input vector A, returns a vector B with outliers (at the significance
% level alpha) removed. Also, optional output argument idx returns the
% indices in A of outlier values. Optional output argument outliers returns
% the outlying values in A.
%
% ALPHA is the significance level for determination of outliers. If not
% provided, alpha defaults to 0.05.
% 
% REP is an optional argument that forces the replacement of removed
% elements with NaNs to presereve the length of a. (Thanks for the
% suggestion, Urs.)
%
% This is an iterative implementation of the Grubbs Test that tests one
% value at a time. In any given iteration, the tested value is either the
% highest value, or the lowest, and is the value that is furthest
% from the sample mean. Infinite elements are discarded if rep is 0, or
% replaced with NaNs if rep is 1 (thanks again, Urs).
% 
% Appropriate application of the test requires that data can be reasonably
% approximated by a normal distribution. For reference, see:
% 1) "Procedures for Detecting Outlying Observations in Samples," by F.E.
%    Grubbs; Technometrics, 11-1:1--21; Feb., 1969, and 
% 2) _Outliers in Statistical Data_, by V. Barnett and
%    T. Lewis; Wiley Series in Probability and Mathematical Statistics;
%    John Wiley & Sons; Chichester, 1994.
% A good online discussion of the test is also given in NIST's Engineering
% Statistics Handbook:
% http://www.itl.nist.gov/div898/handbook/eda/section3/eda35h.htm
%
% ex:
% [B,idx,outliers] = deleteoutliers([1.1 1.3 0.9 1.2 -6.4 1.2 0.94 4.2 1.3 1.0 6.8 1.3 1.2], 0.05)
%    returns:
%    B = 1.1000    1.3000    0.9000    1.2000    1.2000    0.9400    1.3000    1.0000    1.3000    1.2000
%    idx =  5     8    11
%    outliers = -6.4000    4.2000    6.8000
%
% ex:
% B = deleteoutliers([1.1 1.3 0.9 1.2 -6.4 1.2 0.94 4.2 1.3 1.0 6.8 1.3 1.2
% Inf 1.2 -Inf 1.1], 0.05, 1)
% returns:
% B = 1.1000  1.3000  0.9000  1.2000  NaN  1.2000  0.9400  NaN  1.3000  1.0000  NaN  1.3000  1.2000  NaN  1.2000  NaN  1.1000
% Written by Brett Shoelson, Ph.D.
% shoelson@helix.nih.gov
% 9/10/03
% Modified 9/23/03 to address suggestions by Urs Schwartz.
% Modified 10/08/03 to avoid errors caused by duplicate "maxvals."
%    (Thanks to Valeri Makarov for modification suggestion.)

if nargin == 1
	alpha = 0.05;
	rep = 0;
elseif nargin == 2
	rep = 0;
elseif nargin == 3
	if ~ismember(rep,[0 1])
		error('Please enter a 1 or a 0 for optional argument rep.')
	end
elseif nargin > 3
	error('Requires 1,2, or 3 input arguments.');
end

if isempty(alpha)
	alpha = 0.05;
end

b = a;
b(isinf(a)) = NaN;

%Delete outliers:
outlier = 1;
while outlier
	tmp = b(~isnan(b));
	meanval = mean(tmp);
	maxval = tmp(find(abs(tmp-mean(tmp))==max(abs(tmp-mean(tmp)))));
	maxval = maxval(1);
	sdval = std(tmp);
	tn = abs((maxval-meanval)/sdval);
	critval = zcritical(alpha,length(tmp));
	outlier = tn > critval;
	if outlier
		tmp = find(a == maxval);
		b(tmp) = NaN;
	end
end
if nargout >= 2
	idx = find(isnan(b));
end
if nargout > 2
	outliers = a(idx);
end
if ~rep
	b=b(~isnan(b));
end
end

function zcrit = zcritical(alpha,n)
%ZCRIT = ZCRITICAL(ALPHA,N)
% Computes the critical z value for rejecting outliers (GRUBBS TEST)
tcrit = tinv(alpha/(2*n),n-2);
zcrit = (n-1)/sqrt(n)*(sqrt(tcrit^2/(n-2+tcrit^2)));
end

%% COP Processing
function [idx, outlier_idx] = COP_Outliers(ml, ap)
if ne(numel(ml), numel(ap)), error('Require equal length of ML and AP signal.'); end;
ml = ml - mean(ml); ap = ap - mean(ap);
delta = 0.1; % step of rotation
angle = 0: delta : 2*pi;
% Configuration
step_num = 100;
width_ratio = 0.04;
threshold = 0.1; size = numel(ml);
threshold = size * width_ratio * threshold;

outlier_idx = [];
for theta = angle
    % 坐标变换
    Y = ml * sin(theta) + ap * cos(theta);
    
    flag = 0; % adaptive adjustment along each direction
    width = width_ratio * (max(Y)-min(Y)) / 2;
    b = max(Y); step = (max(Y)-min(Y))/step_num;
    while eq(flag, 0)
        % test the boundary according to counting of data in band
        count = numel(find((Y < b + width)&(Y > b - width))); 
        if count < threshold && b > (min(Y) - step), b = b - step;
        else, flag = 1; 
        end
    end
    outlier_idx = union(outlier_idx, find(Y > b));
end
idx = setdiff(1:size, outlier_idx);
end
%% 新vel计算
%与C Sharp中算法一致
function [vel] = Handler_computeVelocity_withSGfilter_new(s, fs)
    len = length(s);vel = zeros(len,1);
    vel(1) = (s(2)-s(1))*fs;
    vel(len) = (s(len)-s(len-1))*fs;
    for iVel = 2:len-1
        vel(iVel) = (s(iVel+1)-s(iVel-1))/2*fs;
    end
end
%% 新acc计算
function [acc] = Handler_computeAcceleration_withSGfilter_new(s, fs)
    len = length(s);acc = zeros(len,1);
    acc(1) = (s(2)-s(1))*fs;
    acc(len) = (s(len)-s(len-1))*fs;
    for iAcc = 2:len-1
        acc(iAcc) = (s(iAcc+1)-s(iAcc-1))/2*fs;
    end
end
%% 计算包络面积
function [envelopeArea,idx] = Handler_computeEnvelopeArea(ml,ap)
    len = length(ml);
    rotationNum = 100;%包络面计算精度
    rotationStep = 2*pi/rotationNum;%包络面旋转角度
    envelopeArea = 0;
    envelopeRotatedX = zeros(len,1);%包络面旋转后X坐标
    triangleLength = zeros(3,1);%三角形三边长
    idx = zeros(rotationNum,1);
    
    %寻找包络面顶点
    for i = 1:rotationNum
        for j = 1:len
            envelopeRotatedX(j) = ml(j)*cos((i-1)*rotationStep)+ap(j)*sin((i-1)*rotationStep);            
        end
        idx(i) = find(envelopeRotatedX == max(envelopeRotatedX));
    end
    idx = unique(idx);%去除重复项
    %计算包络面面积
    for i = 2:length(idx)-2
        triangleLength(1) = sqrt((ml(idx(i))-ml(1))^2+(ap(idx(i))-ap(1))^2);
        triangleLength(2) = sqrt((ml(idx(i+1))-ml(1))^2+(ap(idx(i+1))-ap(1))^2);
        triangleLength(3) = sqrt((ml(idx(i+1))-ml(idx(i)))^2+(ap(idx(i+1))-ap(idx(i)))^2);
        semiPerimeter = sum(triangleLength)/2;
        envelopeArea = envelopeArea+sqrt(semiPerimeter*(semiPerimeter-triangleLength(1))...
            *(semiPerimeter-triangleLength(2))*(semiPerimeter-triangleLength(3)));
    end
end

%% ZToScore
function [score] = ZToScore(z)
    if z<=0.5
        score = 0;
    elseif z>0.5 && z<4.5
        score = (z-0.5)/4;
    else
        score = 1;
    end
end

%% heading change 计算方向矢量变化
function [headingChange] = Handler_computeHeadingChange(ml, ap)
    len = length(ml);
    COPHeading = zeros(1, len-1);
    headingChange = zeros(1, len-2);
    for i = 1:len-1
        COPHeading(i) = atan2((ap(i+1)-ap(i)),(ml(i+1)-ml(i)))/pi*180; 
    end
    for i = 1:len-2
        headingChange(i) = COPHeading(i+1)-COPHeading(i);
        if headingChange(i)<-180
            headingChange(i) = headingChange(i)+360;
        end
        if headingChange(i)>180
            headingChange(i) = headingChange(i)-360;
        end
    end
end