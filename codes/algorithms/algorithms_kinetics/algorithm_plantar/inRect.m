%% FUNC inRect：判断是否在四个点组成的矩形中（右上→左上→左下→右下）
function [ret] = inRect(pt, rx, ry)
    h1 = (ry(1)-ry(2))*pt(1)-(rx(1)-rx(2))*pt(2)+rx(1)*ry(2)-rx(2)*ry(1);
    h2 = (ry(4)-ry(3))*pt(1)-(rx(4)-rx(3))*pt(2)+rx(4)*ry(3)-rx(3)*ry(4);
    v1 = (ry(1)-ry(4))*pt(1)-(rx(1)-rx(4))*pt(2)+rx(1)*ry(4)-rx(4)*ry(1);
    v2 = (ry(2)-ry(3))*pt(1)-(rx(2)-rx(3))*pt(2)+rx(2)*ry(3)-rx(3)*ry(2);
    if h1*h2<=0 && v1*v2<=0
        ret = true;
    else
        ret = false;
    end
end