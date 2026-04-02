% 点击回调函数
function txt = ClickPointsCallBack(~, event_obj)
    global horizontal_plane clickCount;

    % 如果已经点击了3个点，直接返回
    if clickCount >= 3
        txt = '已达到3个点，无法继续点击';
        disp(txt);
        return;
    end

    % 获取点击点的坐标
    pos = get(event_obj, 'Position');
    x = pos(1);
    y = pos(2);
    z = pos(3);

    % 将坐标存入 horizontal_plane
    clickCount = clickCount + 1;
    horizontal_plane(clickCount, :) = [x, y, z];

    % 显示当前点击点的坐标
    txt = ['(' num2str(x) ', ' num2str(y) ', ' num2str(z) ')'];
    disp(['当前点击点: ', txt]);

%     % 显示已点击的点
%     disp('已点击的点：');
%     for i = 1:clickCount
%         disp(horizontal_plane(i, :));
%     end

    % 如果点击了3个点，提示用户
    if clickCount == 3
        disp('已点击3个点，点击完成。');
        disp('horizontal_plane 的值为：');
        aux = [num2str(horizontal_plane(1,1)) ', ' num2str(horizontal_plane(1,2)) ', ' num2str(horizontal_plane(1,3)) '; ' ...
            num2str(horizontal_plane(2,1)) ', ' num2str(horizontal_plane(2,2)) ', ' num2str(horizontal_plane(2,3)) '; ' ...
            num2str(horizontal_plane(3,1)) ', ' num2str(horizontal_plane(3,2)) ', ' num2str(horizontal_plane(3,3))];
        disp(aux);
    end
end