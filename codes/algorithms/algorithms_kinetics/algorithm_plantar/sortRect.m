%% FUNC sortRect：整理矩形顶点顺序，右上→左上→左下→右下
function [rectx, recty] = sortRect(rectx, recty)
    for i = 1:2
        rx = rectx(i,1:4); ry = recty(i,1:4);
        [~,idx] = max(rx+ry);
        if idx>1
            rx = [rx(:,idx:end),rx(:,1:idx-1)];
            ry = [ry(:,idx:end),ry(:,1:idx-1)]; % 四个顶点：右上→左上→左下→右下
        end
%         rx(1)=rx(1)+0.5; rx(2)=rx(2)-0.5; rx(3)=rx(3)-0.5; rx(4)=rx(4)+0.5;
%         ry(1)=ry(1)+0.5; ry(2)=ry(2)+0.5; ry(3)=ry(3)-0.5; ry(4)=ry(4)-0.5;
        rectx(i,1:4) = rx; rectx(i,5) = rectx(i,1);
        recty(i,1:4) = ry; recty(i,5) = recty(i,1);
    end
end