% 获取kinect到opensim的转换矩阵
% kinect: 左后上；vicon：前上右
function T = GetKinect2OpensimT(stream,analysis,times,timeStart,timeEnd)
[comX_k,comY_k,comZ_k] = GravityKinectAzure(stream,'M');

% 插值到同样长度
comX_k = interp1(stream.wtime,comX_k,times.vicon,'spline');
comY_k = interp1(stream.wtime,comY_k,times.vicon,'spline');
comZ_k = interp1(stream.wtime,comZ_k,times.vicon,'spline');

comK = [comX_k,comY_k,comZ_k];
% comV = [dataVicon.analysis.pos_center_of_mass_X,dataVicon.analysis.pos_center_of_mass_Y,dataVicon.analysis.pos_center_of_mass_Z];
comV = [analysis.pos_center_of_mass_Z,analysis.pos_center_of_mass_X,analysis.pos_center_of_mass_Y];

if nargin<4
    comK = comK(501:end-500,:); comV = comV(501:end-500,:);
else
    aux = GetIdxTime(times.vicon,[timeStart,timeEnd]);
    comK = comK(aux(1):aux(2),:); comV = comV(aux(1):aux(2),:);
end

comK_center = mean(comK); comV_center = mean(comV);
comK = comK-comK_center; comK = comK';
comV = comV-comV_center; comV = comV';

% figure; hold on;
% plot(-comK(1,:),-comK(2,:));
% plot(comV(3,:),comV(1,:));
% hold off; legend('kinect','vicon');

% 协方差矩阵
[U,~,V] = svd(comK*comV');
% V*U'的行列式可能为-1.即R可能求到的不是旋转矩阵而是反射矩阵，为此引入一个中间矩阵M
M = eye(3,3);
M(3,3) = det(V*U');
R = V * M * U';

t = comV_center'-R*comK_center';

T = zeros(4,4);
T(1:3,1:3) = R;
T(1:3,4) = t;
T(4,4) = 1;

end