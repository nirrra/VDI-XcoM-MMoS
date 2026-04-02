%% 计算小腿与z轴的角度，默认静止站立时小腿竖直，修正角度angleRevise
function [angles] = CalShankAngle(knee,ankle,angleRevise)
    if nargin<3, angleRevise.x = 0; angleRevise.y = 0; angleRevise.z = 0; end
    angles.x = zeros(length(knee.x),1); % 矢状面 小腿向前为负
    angles.y = zeros(length(knee.x),1); % 冠状面
    angles.z = zeros(length(knee.x),1); % 横截面
    vABs = [ankle.x-knee.x,ankle.y-knee.y,ankle.z-knee.z];
    vCB = [0,0,-1];
    for i = 1:length(knee.x)
        vAB = vABs(i,:);
        aux = asind(cross(vAB,vCB)/(norm(vAB)*norm(vCB)));
        angles.x(i) = aux(1)-angleRevise.x;
        angles.y(i) = aux(2)-angleRevise.y;
        angles.z(i) = aux(3)-angleRevise.z;
    end
end